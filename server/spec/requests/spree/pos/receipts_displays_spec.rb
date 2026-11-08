# frozen_string_literal: true

require 'spree/api/testing_support/v3/base'
require_relative '../../../support/pos_shift_helpers'
require_relative '../../../support/pos_trace_helpers'

# HTTP contract for immutable receipts (lookup, search, print and copies,
# print templates of originals and reprints, masking) and the customer display (token scope, expiry, revoke, rotation,
# generation, acknowledgement and the content it may show).
RSpec.describe 'POS receipts and customer display API', type: :request do
  include PosShiftHelpers
  include PosTraceHelpers
  include ActiveSupport::Testing::TimeHelpers

  let(:store) { create(:store, default_currency: 'VND', supported_currencies: 'VND') }
  let(:branch) { returns_branch(store) }
  let(:cashier) { credit_staff(store, branch, PosShiftHelpers::LEAD) }
  let(:manager) { credit_staff(store, branch, PosShiftHelpers::MANAGER) }

  before { allow(Spree::Store).to receive(:default).and_return(store) }

  def token_for(user)
    @tokens ||= {}
    @tokens[user.id] ||= begin
      post '/api/v3/admin/auth/login', params: { email: user.email, password: 'secret123' }, as: :json
      response.parsed_body.fetch('token')
    end
  end

  def call(user, verb, path, body = {}, key: SecureRandom.uuid)
    send(verb, "/api/v3/admin/pos/#{path}", headers: { 'Authorization' => "Bearer #{token_for(user)}", 'Idempotency-Key' => key },
                                            params: verb == :get ? body : body.merge(idempotency_key: key), as: verb == :get ? nil : :json)
    response.parsed_body
  end

  def display(verb, path, token, body = {}, scheme: 'Display')
    send(verb, "/api/v3/pos_display/#{path}", headers: { 'Authorization' => "#{scheme} #{token}" },
                                              params: body, as: verb == :get ? nil : :json)
    response.parsed_body
  end

  def ack!(token)
    state = display(:get, 'state', token)['data']
    display(:post, 'ack', token, { generation: state['generation'], lease_id: state['lease_id'] })
    state
  end

  def shift_of(sale)
    sale.workspace.reload.shift
  end

  def ledger_counts
    [Spree::Payment.count, Spree::StockMovement.count, Spree::Order.count, Spree::Pos::FundsAllocation.count,
     Spree::Pos::ReceivedFunds.count, Spree::Pos::CashMovement.count, Spree::Refund.count]
  end

  describe 'receipts' do
    it 'serves the posted sale once, prints the original then numbered copies, and never moves money or stock' do
      sale = paid_sale(store, branch, cashier: cashier, price: 45_000, quantity: 2)
      workspace = sale.workspace.reload
      receipt = call(cashier, :get, 'receipts/lookup', { source_id: workspace.prefixed_id })['data']
      expect(response).to have_http_status(:ok)
      expect(receipt).to include('source_type' => 'sale', 'number' => workspace.order.number, 'issued_late' => false,
                                 'disclaimer' => 'Phiếu bán hàng POS — không phải hóa đơn điện tử', 'printed' => false)
      document = receipt['document']
      expect(document['title']).to eq('PHIẾU BÁN HÀNG')
      expect(document['lines'].first).to include('quantity' => 2, 'unit_price' => '45000.0', 'net_amount' => '90000.0')
      expect(document['totals']['total']).to eq('90000.0')
      expect(document['receipts']).to eq([{ 'method' => 'cash', 'amount' => '90000.0', 'handed' => '90000.0', 'change' => '0.0' }])
      expect(document['credit']).to be_nil
      expect(Spree::Pos::ReceiptSnapshot.where(source_type: 'sale', source_id: workspace.id).count).to eq(1)

      before = ledger_counts
      key = SecureRandom.uuid
      original = call(cashier, :post, "receipts/#{receipt['id']}/prints", {}, key: key)['data']
      expect(response).to have_http_status(:created)
      expect(original['print']).to include('copy' => false, 'copy_number' => 0, 'label' => nil)
      replay = call(cashier, :post, "receipts/#{receipt['id']}/prints", {}, key: key)['data']
      expect(replay['print']['id']).to eq(original['print']['id'])
      copy = call(manager, :post, "receipts/#{receipt['id']}/prints")['data']
      expect(copy['print']).to include('copy' => true, 'copy_number' => 1, 'label' => 'BẢN SAO')
      expect(copy['receipt']).to include('copy_count' => 1, 'printed' => true)
      expect(copy['receipt']['document']).to eq(document)
      expect(ledger_counts).to eq(before)
      expect(Spree::Pos::ReceiptPrint.count).to eq(2)
      expect(Spree::Pos::AuditEntry.where(action: %w[receipt.print receipt.reprint]).pluck(:action)).to eq(%w[receipt.print receipt.reprint])
    end

    it 'keeps the snapshot unchanged after price, unit, branch and payment configuration changes' do
      sale = paid_sale(store, branch, cashier: cashier, price: 30_000)
      receipt = call(cashier, :get, 'receipts/lookup', { source_id: sale.workspace.prefixed_id })['data']
      sale.product.default_variant.set_price(store.default_currency, 99_000)
      sale.product.update!(name: 'Tên mới')
      branch.update!(name: 'Chi nhánh đổi tên')
      Spree::PaymentMethod.where(store_id: store.id).find_each { |row| row.update!(description: 'Tài khoản mới') }
      again = call(cashier, :get, "receipts/#{receipt['id']}")['data']
      expect(again['document']).to eq(receipt['document'])
      expect(again['document']['lines'].first['unit_price']).to eq('30000.0')
      expect(again['document']['branch']['name']).not_to eq('Chi nhánh đổi tên')
      expect { Spree::Pos::ReceiptSnapshot.find(Spree::Pos::ReceiptSnapshot.last.id).update!(number: 'X') }.
        to raise_error(ActiveRecord::ReadOnlyRecord)
    end

    it 'refuses a receipt for a workspace that is not completed' do
      sale = open_sale(store, branch, cashier: cashier, product: stocked_product(store, branch, price: 10_000))
      call(cashier, :get, 'receipts/lookup', { source_id: sale.workspace.prefixed_id })
      expect(response).to have_http_status(:conflict)
      expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('receipt_unavailable')
      expect(Spree::Pos::ReceiptSnapshot.count).to eq(0)
    end

    it 'masks the customer name for readers without contact rights and always masks the phone' do
      sale = open_sale(store, branch, cashier: cashier, product: stocked_product(store, branch, price: 20_000))
      profile = credit_customer(store, cashier, name: 'Nguyễn Văn An')
      assign(sale, profile)
      complete_paid(sale)
      receipt = call(cashier, :get, 'receipts/lookup', { source_id: sale.workspace.prefixed_id })['data']
      expect(receipt['document']['customer']['name']).to eq('Nguyễn Văn An')
      expect(receipt['document']['customer']['phone']).to eq(Spree::Pos::ReceivableProjection.masked(profile.phone))
      expect(receipt['document']['customer']['phone']).not_to include(profile.phone[0, 5])

      viewer = credit_staff(store, branch, [Spree::Pos::Capabilities::OPEN_SHIFT])
      masked = call(viewer, :get, "receipts/#{receipt['id']}")['data']
      expect(masked['document']['customer']['name']).to eq('N••••• V•• A•')
      expect(Spree::Pos::ReceiptSnapshot.last.payload['customer']['phone']).to eq(profile.phone)
    end

    it 'searches receipts by number only within branches the reader works at' do
      sale = paid_sale(store, branch, cashier: cashier, price: 12_000)
      number = sale.workspace.order.number
      call(cashier, :get, 'receipts/lookup', { source_id: sale.workspace.prefixed_id })
      found = call(cashier, :get, 'receipts', { branch_id: branch.prefixed_id, number: number[-5..] })
      expect(found['data'].map { |row| row['number'] }).to eq([number])

      other = returns_branch(store)
      outsider = credit_staff(store, other, PosShiftHelpers::LEAD)
      call(outsider, :get, 'receipts', { branch_id: branch.prefixed_id, number: number })
      expect(response).to have_http_status(:not_found)
      call(outsider, :get, "receipts/#{found['data'].first['id']}")
      expect(response).to have_http_status(:not_found)
      call(outsider, :get, 'receipts/lookup', { source_id: sale.workspace.prefixed_id })
      expect(response).to have_http_status(:not_found)
    end

    it 'issues return, refund and shift closing slips from posted facts' do
      sale = paid_sale(store, branch, cashier: cashier, price: 50_000, quantity: 2)
      result = return_and_receive(store, cashier, branch, sale, quantity: 1)
      operation = operation(result)
      slip = Spree::Pos::ReceiptSnapshot.find_by!(source_type: 'return', source_id: operation.id)
      expect(slip.payload).to include('title' => 'PHIẾU TRẢ HÀNG', 'order_number' => sale.workspace.order.number,
                                      'entitlement_posted' => true, 'refund_entitlement' => '50000.0')

      refund = request_refund(store, cashier, result, amount: 50_000)
      approval = Spree::Pos::Refunds::Approve.call(store: store, staff: manager, key: SecureRandom.uuid, refund_id: refund['id'])
      Spree::Pos::Refunds::ConfirmPayout.call(store: store, staff: cashier, key: SecureRandom.uuid, refund_id: refund['id'],
                                              evidence_kind: 'cash_count', approval_id: approval.dig('approval', 'id'))
      request = Spree::Pos::RefundRequest.find_by_prefix_id!(refund['id'])
      refund_slip = call(cashier, :get, 'receipts/lookup', { source_id: request.prefixed_id })['data']
      expect(refund_slip['document']).to include('title' => 'PHIẾU HOÀN TIỀN', 'amount' => '50000.0', 'method' => 'cash')
      expect(refund_slip['issued_late']).to be(false)

      shift = shift_of(sale)
      count_shift(shift, cashier, expected_cash(shift))
      closure = close_shift(shift, cashier)
      closing = call(cashier, :get, 'receipts/lookup', { source_id: closure['id'] })['data']
      expect(closing['document']).to include('title' => 'PHIẾU ĐÓNG CA', 'expected' => closure['expected'], 'variance' => '0.0')
    end
  end

  describe 'customer display' do
    let(:sale) { open_sale(store, branch, cashier: cashier, product: stocked_product(store, branch, price: 25_000)) }

    def bind(user = cashier, shift = shift_of(sale))
      body = call(user, :post, 'display_sessions', { shift_id: shift.prefixed_id })
      [body['data'], body['token']]
    end

    def generation_of(session)
      Spree::Pos::DisplaySession.find_by_prefix_id!(session['id']).generation
    end

    # `expected` defaults to the generation the server holds now.
    def pin(session, workspace, attempt_id: nil, expected: generation_of(session), user: cashier)
      call(user, :post, "display_sessions/#{session['id']}/pin",
           { workspace_id: workspace.prefixed_id, tender_attempt_id: attempt_id, expected_generation: expected })
    end

    def clear(session, expected: generation_of(session), user: cashier)
      call(user, :post, "display_sessions/#{session['id']}/clear", { expected_generation: expected })
    end

    it 'gives the display token no admin authority and refuses staff tokens on the display route' do
      session, token = bind
      expect(response).to have_http_status(:created)
      expect(token).to be_present
      expect(Spree::Pos::DisplaySession.last.token_digest).not_to eq(token)

      get '/api/v3/admin/pos/context', headers: { 'Authorization' => "Bearer #{token}" }
      expect(response).to have_http_status(:unauthorized)
      get '/api/v3/admin/pos/context', headers: { 'Authorization' => "Display #{token}" }
      expect(response).to have_http_status(:unauthorized)
      get "/api/v3/admin/pos/display_sessions/#{session['id']}", headers: { 'Authorization' => "Bearer #{token}" }
      expect(response).to have_http_status(:unauthorized)

      display(:get, 'state', token_for(cashier), scheme: 'Bearer')
      expect(response).to have_http_status(:unauthorized)
      display(:get, 'state', token_for(cashier))
      expect(response).to have_http_status(:unauthorized)
      get "/api/v3/pos_display/state?token=#{token}"
      expect(response).to have_http_status(:unauthorized)

      display(:get, 'state', token)
      expect(response).to have_http_status(:ok)
      expect(response.headers['Cache-Control']).to eq('no-store')
      expect(response.headers['Referrer-Policy']).to eq('no-referrer')
      expect(response.parsed_body['data']).to include('state' => 'idle', 'generation' => 1)
    end

    it 'shows only the pinned order and waiting bank transfer, without staff, customer or debt data' do
      sale # creates the branch and its configured bank payment method
      Spree::PaymentMethod.where(store_id: store.id).where('name ILIKE ?', '%bank%').
        find_each { |row| row.update!(description: '<p>Vietcombank 0123456789 — CONG TY PARK VIET</p>') }
      assign(sale, credit_customer(store, cashier, name: 'Trần Thị Bình'))
      method = Spree::Pos::PaymentMethodResolver.new(store: store).available.find { |row| row.kind == 'bank_manual' }
      Spree::Pos::Tenders::Prepare.call(**editing_args(sale), payment_method_id: method.prefixed_id || 'posmethod-bank_manual',
                                                              amount: '25000')
      attempt = Spree::Pos::TenderAttempt.where(workspace: sale.workspace).last
      session, token = bind
      ack!(token)
      pinned = pin(session, sale.workspace, attempt_id: attempt.prefixed_id)['data']
      expect(pinned).to include('generation' => 2, 'pinned_order_number' => sale.workspace.order.number)

      state = display(:get, 'state', token)['data']
      expect(state).to include('state' => 'order', 'generation' => 2)
      expect(state['order']).to include('total' => '25000.0', 'amount_due' => '25000.0')
      expect(state['payment']).to eq('kind' => 'bank_manual', 'amount' => '25000.0', 'currency' => 'VND',
                                     'transfer_note' => sale.workspace.order.number,
                                     'account_text' => 'Vietcombank 0123456789 — CONG TY PARK VIET')
      text = response.body
      %w[customer phone debt balance credit cashier email staff owner].each { |word| expect(text).not_to include("\"#{word}") }
      expect(text).not_to include('Trần Thị Bình')
      expect(text).not_to include(cashier.email)

      Spree::Pos::Tenders::Cancel.call(**editing_args(sale), attempt_id: attempt.prefixed_id)
      expect(display(:get, 'state', token)['data']['payment']).to be_nil
    end

    it 'enforces generation, clear-before-next-customer and current acknowledgements' do
      other = open_sale(store, branch, cashier: cashier, product: stocked_product(store, branch, price: 5_000))
      session, token = bind
      pin(session, sale.workspace)
      expect(response).to have_http_status(:conflict)
      expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('display_ack_required')

      ack!(token)
      expect(pin(session, sale.workspace)['data']['generation']).to eq(2)
      pin(session, other.workspace)
      expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('display_busy')

      old = display(:get, 'state', token)['data']
      cleared = clear(session)['data']
      expect(cleared).to include('generation' => 3, 'pinned_workspace_id' => nil, 'ack_current' => false)
      pin(session, other.workspace)
      expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('display_ack_required')

      # A delayed acknowledgement of the previous generation proves nothing.
      display(:post, 'ack', token, { generation: old['generation'], lease_id: old['lease_id'] })
      expect(response).to have_http_status(:conflict)
      expect(response.parsed_body.dig('error', 'code')).to eq('generation_stale')
      state = display(:get, 'state', token)['data']
      display(:post, 'ack', token, { generation: state['generation'] + 1, lease_id: state['lease_id'] })
      expect(response.parsed_body.dig('error', 'code')).to eq('generation_stale')
      display(:post, 'ack', token, { generation: state['generation'], lease_id: "#{state['lease_id']}x" })
      expect(response.parsed_body.dig('error', 'code')).to eq('lease_invalid')
      expect(state['sequence']).to be > old['sequence']

      display(:post, 'ack', token, { generation: state['generation'], lease_id: state['lease_id'] })
      expect(response).to have_http_status(:ok)
      expect(call(cashier, :get, "display_sessions/#{session['id']}")['data']).to include('ack_current' => true, 'acked_generation' => 3)
      expect(pin(session, other.workspace)['data']['generation']).to eq(4)
    end

    it 'expires acknowledgements after the freshness window and leases signed for another session' do
      branch.update!(display_freshness_ttl_seconds: 10)
      session, token = bind
      state = display(:get, 'state', token)['data']
      expect(state['freshness_ttl_seconds']).to eq(10)
      second_shift = open_shift(store, branch, manager)
      _, other_token = bind(manager, second_shift)
      display(:post, 'ack', other_token, { generation: state['generation'], lease_id: state['lease_id'] })
      expect(response.parsed_body.dig('error', 'code')).to eq('lease_invalid')

      travel 11.seconds do
        display(:post, 'ack', token, { generation: state['generation'], lease_id: state['lease_id'] })
        expect(response.parsed_body.dig('error', 'code')).to eq('lease_invalid')
      end
      ack!(token)
      travel 11.seconds do
        expect(call(cashier, :get, "display_sessions/#{session['id']}")['data']['ack_current']).to be(false)
        pin(session, sale.workspace)
        expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('display_ack_required')
      end
    end

    it 'expires, rotates and revokes tokens on the server' do
      session, token = bind
      ack!(token)
      pin(session, sale.workspace)
      rotated, new_token = bind
      expect(rotated).to include('id' => session['id'], 'generation' => 3, 'pinned_workspace_id' => nil)
      display(:get, 'state', token)
      expect(response).to have_http_status(:unauthorized)
      display(:get, 'state', new_token)
      expect(response).to have_http_status(:ok)

      travel(Spree::Pos::DisplaySession::TOKEN_TTL + 1.second) do
        display(:get, 'state', new_token)
        expect(response).to have_http_status(:unauthorized)
      end

      revoked = call(cashier, :post, "display_sessions/#{session['id']}/revoke", { reason: 'unresponsive' })['data']
      expect(revoked).to include('status' => 'revoked', 'revoke_reason' => 'unresponsive')
      display(:get, 'state', new_token)
      expect(response).to have_http_status(:unauthorized)
      pin(session, sale.workspace)
      expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('display_inactive')
      expect(call(cashier, :get, 'display_sessions/current', { shift_id: shift_of(sale).prefixed_id })['data']).to be_nil
    end

    it 'binds only the caller own open shift and pins only that shift orders' do
      intruder = credit_staff(store, branch, PosShiftHelpers::LEAD)
      call(intruder, :post, 'display_sessions', { shift_id: shift_of(sale).prefixed_id })
      expect(response).to have_http_status(:not_found)

      session, token = bind
      ack!(token)
      foreign = open_sale(store, branch, cashier: intruder, product: stocked_product(store, branch, price: 1_000))
      pin(session, foreign.workspace)
      expect(response).to have_http_status(:not_found)
      clear(session, expected: 1, user: intruder)
      expect(response).to have_http_status(:not_found)

      shift = shift_of(sale)
      sale.workspace.update_columns(operational_status: 'canceled')
      count_shift(shift, cashier, expected_cash(shift))
      close_shift(shift, cashier)
      display(:get, 'state', token)
      expect(response).to have_http_status(:unauthorized)
    end

    it 'refuses a pin or clear decided against an older generation' do
      other = open_sale(store, branch, cashier: cashier, product: stocked_product(store, branch, price: 5_000))
      session, token = bind
      ack!(token)
      expect(pin(session, sale.workspace, expected: 1)['data']['generation']).to eq(2)
      expect(clear(session, expected: 2)['data']['generation']).to eq(3)
      ack!(token)
      # The cashier decided to show B while A was still pinned; that request arrives after the clear.
      pin(session, other.workspace, expected: 2)
      expect(response).to have_http_status(:conflict)
      expect(response.parsed_body.dig('error', 'details')).to include('reason' => 'generation_stale', 'current_revision' => 3)
      clear(session, expected: 2)
      expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('generation_stale')
      call(cashier, :post, "display_sessions/#{session['id']}/pin", { workspace_id: other.workspace.prefixed_id })
      expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('generation_required')
      expect(pin(session, other.workspace, expected: 3)['data']['generation']).to eq(4)
    end

    it 'pairs a separate device with a short single-use code and never shows the token to the cashier' do
      Spree::Pos::DisplayViewsController::PAIRING_LIMIT_STORE.clear
      exchange = ->(code) { post '/api/v3/pos_display/pair', params: { code: code }, as: :json }
      session, window_token = bind
      issued = call(cashier, :post, "display_sessions/#{session['id']}/pairing_code")
      expect(response).to have_http_status(:created)
      expect(response.headers['Cache-Control']).to include('no-store')
      code = issued.dig('data', 'code')
      expect(code).to match(/\A[A-Z2-9]{8}\z/)
      expect(issued.to_s).not_to include('token')
      expect(Spree::Pos::DisplayPairing.last.code_digest).not_to include(code)

      exchange.call("#{code[0, 4].downcase}-#{code[4..]}")
      expect(response).to have_http_status(:ok)
      device_token = response.parsed_body.dig('data', 'token')
      expect(display(:get, 'state', device_token)['data']['generation']).to eq(2)
      display(:get, 'state', window_token)
      expect(response).to have_http_status(:unauthorized)
      exchange.call(code)
      expect(response).to have_http_status(:not_found)
      expect(response.parsed_body.dig('error', 'code')).to eq('pairing_invalid')

      late = call(cashier, :post, "display_sessions/#{session['id']}/pairing_code").dig('data', 'code')
      travel(Spree::Pos::DisplayPairing::TTL + 1.second) { exchange.call(late) }
      expect(response).to have_http_status(:not_found)

      spent = call(cashier, :post, "display_sessions/#{session['id']}/pairing_code").dig('data', 'code')
      call(cashier, :post, "display_sessions/#{session['id']}/pairing_code")
      exchange.call(spent)
      expect(response).to have_http_status(:not_found)

      revoked = call(cashier, :post, "display_sessions/#{session['id']}/pairing_code").dig('data', 'code')
      call(cashier, :post, "display_sessions/#{session['id']}/revoke", { reason: 'ended' })
      exchange.call(revoked)
      expect(response).to have_http_status(:not_found)

      statuses = Array.new(Spree::Pos::DisplayViewsController::PAIRING_ATTEMPTS) do
        exchange.call('ZZZZZZZZ')
        response.status
      end
      expect(statuses.last).to eq(429)
      expect(response.parsed_body.dig('error', 'code')).to eq('pairing_rate_limited')
      Spree::Pos::DisplayViewsController::PAIRING_LIMIT_STORE.clear
    end
  end

  describe 'receipt readers, issuance and traceability' do
    it 'limits return, refund and closing slips to their readers' do
      sale = paid_sale(store, branch, cashier: cashier, price: 50_000, quantity: 2)
      operation = operation(return_and_receive(store, cashier, branch, sale, quantity: 1))
      slip = call(cashier, :get, 'receipts/lookup', { source_id: operation.prefixed_id })['data']
      seller = credit_staff(store, branch, [Spree::Pos::Capabilities::OPEN_SHIFT, Spree::Pos::Capabilities::PAYMENT])
      call(seller, :get, 'receipts/lookup', { source_id: operation.prefixed_id })
      expect(response).to have_http_status(:not_found)
      call(seller, :get, "receipts/#{slip['id']}")
      expect(response).to have_http_status(:not_found)
      call(seller, :post, "receipts/#{slip['id']}/prints")
      expect(response).to have_http_status(:not_found)
      listed = call(seller, :get, 'receipts', { branch_id: branch.prefixed_id })['data'].map { |row| row['source_type'] }
      expect(listed).to eq(['sale'])
      expect(call(cashier, :get, 'receipts', { branch_id: branch.prefixed_id })['data'].map { |row| row['source_type'] }).
        to contain_exactly('sale', 'return')

      # Received at another branch: return staff of the sale branch still read it.
      other = returns_branch(store)
      other_staff = credit_staff(store, other, PosShiftHelpers::MANAGER)
      prepared = prepare_return(store, other_staff, other, sale, quantity: 1)
      approval = Spree::Pos::Returns::Approve.call(store: store, staff: credit_staff(store, other, PosShiftHelpers::MANAGER),
                                                   key: SecureRandom.uuid, return_id: prepared['id'])
      receive_return(store, other_staff, prepared, approval_id: approval.dig('approval', 'id'))
      away = call(cashier, :get, 'receipts/lookup', { source_id: prepared['id'] })
      expect(response).to have_http_status(:ok)
      expect(away.dig('data', 'branch_id')).to eq(other.prefixed_id)
      call(seller, :get, 'receipts/lookup', { source_id: prepared['id'] })
      expect(response).to have_http_status(:not_found)

      shift = shift_of(sale)
      count_shift(shift, cashier, expected_cash(shift))
      closure = close_shift(shift, cashier)
      closing = call(cashier, :get, 'receipts/lookup', { source_id: closure['id'] })['data']
      call(manager, :get, "receipts/#{closing['id']}")
      expect(response).to have_http_status(:not_found)
      expect(call(manager, :get, 'receipts', { branch_id: branch.prefixed_id })['data'].map { |row| row['source_type'] }).
        not_to include('shift_closure')
      reporter = credit_staff(store, branch, [Spree::Pos::Capabilities::REPORT_READ])
      expect(call(reporter, :get, "receipts/#{closing['id']}").dig('data', 'number')).to eq(closing['number'])
    end

    it 'commits the sale, return, refund and shift close even when a slip cannot be built' do
      allow(Rails.error).to receive(:report)
      allow(Spree::Pos::ReceiptBuilder).to receive(:new).and_raise(RuntimeError, 'layout broke')
      sale = paid_sale(store, branch, cashier: cashier, price: 50_000, quantity: 2)
      expect(sale.workspace.reload.operational_status).to eq('completed')
      result = return_and_receive(store, cashier, branch, sale, quantity: 1)
      expect(operation(result).status).to eq('received')
      refund = request_refund(store, cashier, result, amount: 50_000)
      approval = approve_refund(store, manager, refund)
      Spree::Pos::Refunds::ConfirmPayout.call(store: store, staff: cashier, key: SecureRandom.uuid, refund_id: refund['id'],
                                              evidence_kind: 'cash_count', approval_id: approval.dig('approval', 'id'))
      expect(Spree::Pos::RefundRequest.find_by_prefix_id!(refund['id']).status).to eq('confirmed')
      shift = shift_of(sale)
      count_shift(shift, cashier, expected_cash(shift))
      close_shift(shift, cashier)
      expect(shift.reload.status).to eq('closed')
      expect(Spree::Pos::ReceiptSnapshot.count).to eq(0)
      expect(Rails.error).to have_received(:report).at_least(4).times

      allow(Spree::Pos::ReceiptBuilder).to receive(:new).and_call_original
      late = call(cashier, :get, 'receipts/lookup', { source_id: sale.workspace.prefixed_id })['data']
      expect(late).to include('issued_late' => true, 'number' => sale.workspace.order.number)
    end

    it 'issues a supplementary return slip when the entitlement posts after the slip' do
      sale = paid_sale(store, branch, cashier: cashier, price: 50_000, quantity: 2)
      first = prepare_return(store, cashier, branch, sale, quantity: 1)
      second = prepare_return(store, cashier, branch, sale, quantity: 1)
      receive_return(store, cashier, second)
      waiting = operation(second)
      expect(waiting.reload.entitlement_status).to eq('awaiting_predecessor')
      slip = Spree::Pos::ReceiptSnapshot.find_by!(source_type: 'return', source_id: waiting.id)
      expect(slip.payload).to include('entitlement_posted' => false, 'refund_entitlement' => nil)

      Spree::Pos::Returns::Cancel.call(store: store, staff: cashier, key: SecureRandom.uuid, return_id: first['id'], reason: 'Khách đổi ý')
      expect(waiting.reload.entitlement_status).to eq('posted')
      supplement = Spree::Pos::ReceiptSnapshot.find_by!(source_type: 'return_supplement', source_id: waiting.id)
      expect(supplement.number).to eq("#{waiting.core_return.number}-BS")
      expect(supplement.payload).to include('title' => 'PHIẾU BỔ SUNG TRẢ HÀNG', 'entitlement_posted' => true,
                                            'refund_entitlement' => '50000.0')
      expect(slip.reload.payload['entitlement_posted']).to be(false)
      listed = call(cashier, :get, 'receipts', { branch_id: branch.prefixed_id, source_type: 'return_supplement' })['data']
      expect(listed.map { |row| row['number'] }).to eq([supplement.number])
    end

    it 'prints the serials and lots sold on each line from the committed allocations' do
      products = %w[phone milk].to_h do |kind|
        product = create(:product, store: store, status: 'active', name: kind)
        product.default_variant.set_price(store.default_currency, kind == 'phone' ? 3_000_000 : 20_000)
        Spree::Pos::BranchProduct.create!(branch: branch, product: product)
        [kind, product]
      end
      phone = products['phone'].default_variant
      milk = products['milk'].default_variant
      track_variant!(store, phone, 'serial')
      enroll_serials!(branch, phone, %w[IMEI-1 IMEI-2], opened_by: manager)
      track_variant!(store, milk, 'lot')
      enroll_lots!(branch, milk, [['L-LATE', Date.current + 60, 5], ['L-EARLY', Date.current + 10, 2]], opened_by: manager)

      editor_id = SecureRandom.uuid
      created = Spree::Pos::Workspaces::Create.call(store: store, staff: cashier, register_id: open_drawer(store, branch, cashier).prefixed_id,
                                                    key: SecureRandom.uuid, editor_id: editor_id)
      workspace = Spree::Pos::Workspace.find_by_prefix_id!(created['id'])
      sale = PosCreditHelpers::Sale.new(workspace: workspace, cashier: cashier, editor_id: editor_id, product: nil)
      [[phone, { quantity: 1, serial_codes: ['IMEI-2'] }], [milk, { quantity: 3 }]].each do |variant, extra|
        current = workspace.reload
        Spree::Pos::Workspaces::ManageLineItem.add(workspace: current, staff: cashier, revision: current.revision,
                                                   lease_generation: current.lease_generation, editor_id: sale.editor_id,
                                                   key: SecureRandom.uuid, variant_id: variant.prefixed_id, **extra)
      end
      complete_paid(sale)
      lines = call(cashier, :get, 'receipts/lookup', { source_id: workspace.prefixed_id }).dig('data', 'document', 'lines')
      by_name = lines.index_by { |line| line['name'] }
      expect(by_name['phone']['trace']).to eq([{ 'serial' => 'IMEI-2', 'quantity' => 1 }])
      expect(by_name['milk']['trace']).to eq([
                                               { 'lot_code' => 'L-EARLY', 'expiry_on' => (Date.current + 10).iso8601, 'quantity' => 2 },
                                               { 'lot_code' => 'L-LATE', 'expiry_on' => (Date.current + 60).iso8601, 'quantity' => 1 }
                                             ])
    end

    it 'replays a print without a second copy and renders the receipt with the reader masking of now' do
      sale = open_sale(store, branch, cashier: cashier, product: stocked_product(store, branch, price: 20_000))
      assign(sale, credit_customer(store, cashier, name: 'Lê Văn Bảo'))
      complete_paid(sale)
      receipt = call(cashier, :get, 'receipts/lookup', { source_id: sale.workspace.prefixed_id })['data']
      key = SecureRandom.uuid
      first = call(cashier, :post, "receipts/#{receipt['id']}/prints", {}, key: key)['data']
      expect(first.dig('receipt', 'document', 'customer', 'name')).to eq('Lê Văn Bảo')
      expect(Spree::Pos::CommandReceipt.order(:id).last.result.keys).
        to match_array(%w[id receipt_id copy copy_number label printed_at template_id template_version paper])

      Spree::Pos::StaffMembership.find_by!(staff_id: cashier.id, branch_id: branch.id).
        update!(capabilities: [Spree::Pos::Capabilities::OPEN_SHIFT])
      replay = call(cashier, :post, "receipts/#{receipt['id']}/prints", {}, key: key)['data']
      expect(replay['print']).to eq(first['print'])
      expect(replay.dig('receipt', 'document', 'customer', 'name')).to eq('L• V•• B••')
      expect(Spree::Pos::ReceiptPrint.count).to eq(1)
    end
  end

  describe 'print templates' do
    let(:templates) { Spree::Pos::ReceiptTemplate }

    def default_template(type)
      templates.ensure_defaults!(store)
      templates.for_store(store).active.find_by!(document_type: type, is_default: true)
    end

    def sale_receipt
      sale = paid_sale(store, branch, cashier: cashier, price: 25_000)
      call(cashier, :get, 'receipts/lookup', { source_id: sale.workspace.prefixed_id })['data']
    end

    def print!(receipt, body = {}, key: SecureRandom.uuid)
      call(cashier, :post, "receipts/#{receipt['id']}/prints", body, key: key)['data']
    end

    def error_pointers
      response.parsed_body.dig('error', 'details', 'errors').map { |error| error['pointer'] }
    end

    it "reprints with the original's template, version and paper even after it was edited or disabled" do
      receipt = sale_receipt
      template = default_template('sale')
      original = print!(receipt)
      layout = { 'template_id' => template.prefixed_id, 'template_version' => 1, 'paper' => '80mm' }
      expect(original['print']).to include(layout.merge('copy_number' => 0))
      expect(original['receipt']['original_print']).to eq(layout)
      expect(Spree::Pos::AuditEntry.find_by!(action: 'receipt.print').metadata).to include(layout)

      edited = template.current_config.merge('footer' => [{ 'type' => 'divider' }])
      template.with_lock { template.revise!(config: edited, actor: nil, paper: '58mm') }
      successor = templates.create_with_version!(store: store, document_type: 'sale', name: 'A4', paper: 'a4',
                                                 config: edited, actor: nil)
      template.update!(status: 'disabled', is_default: false)
      successor.update!(is_default: true)

      copy = print!(receipt)
      expect(copy['print']).to include(layout.merge('copy_number' => 1, 'label' => 'BẢN SAO'))
      explicit = print!(receipt, { receipt_template_id: template.prefixed_id, template_version: 1, paper: '80mm' })
      expect(explicit['print']).to include(layout)
      listed = call(cashier, :get, 'receipts', { branch_id: branch.prefixed_id })['data'].find { |row| row['id'] == receipt['id'] }
      expect(listed['original_print']).to eq(layout)
      expect(call(cashier, :get, "receipts/#{receipt['id']}")['data']['original_print']).to eq(layout)
    end

    it 'records another template of the same type and keeps defaulting to the original afterwards' do
      receipt = sale_receipt
      template = default_template('sale')
      a4 = templates.create_with_version!(store: store, document_type: 'sale', name: 'A4', paper: 'a4',
                                          config: template.current_config, actor: nil)
      print!(receipt)
      other = print!(receipt, { receipt_template_id: a4.prefixed_id })
      expect(other['print']).to include('template_id' => a4.prefixed_id, 'template_version' => 1, 'paper' => 'a4', 'copy_number' => 1)
      expect(other['receipt']['original_print']['template_id']).to eq(template.prefixed_id)
      again = print!(receipt)
      expect(again['print']).to include('template_id' => template.prefixed_id, 'paper' => '80mm', 'copy_number' => 2)
      expect(Spree::Pos::ReceiptPrint.order(:copy_number).pluck(:receipt_template_id, :paper)).
        to eq([[template.id, '80mm'], [a4.id, 'a4'], [template.id, '80mm']])
    end

    it 'refuses a template of another document type, a disabled one, an unknown version or a foreign template' do
      receipt = sale_receipt
      sale_template = default_template('sale')
      spare = templates.create_with_version!(store: store, document_type: 'sale', name: 'Cũ', paper: '58mm',
                                             config: sale_template.current_config, actor: nil)
      spare.update!(status: 'disabled')
      other_store = create(:store, default_currency: 'VND', supported_currencies: 'VND')
      templates.ensure_defaults!(other_store)
      foreign = templates.for_store(other_store).find_by!(document_type: 'sale')

      [[{ receipt_template_id: default_template('return').prefixed_id }, '/receipt_template_id'],
       [{ receipt_template_id: spare.prefixed_id }, '/receipt_template_id'],
       [{ receipt_template_id: foreign.prefixed_id }, '/receipt_template_id'],
       [{ receipt_template_id: sale_template.prefixed_id, template_version: 4 }, '/template_version'],
       [{ receipt_template_id: sale_template.prefixed_id, paper: 'A3' }, '/paper'],
       [{ template_version: 1 }, '/template_version']].each do |body, pointer|
        print!(receipt, body)
        expect(response).to have_http_status(:unprocessable_content), body.inspect
        expect(error_pointers).to eq([pointer])
      end
      expect(Spree::Pos::ReceiptPrint.count).to eq(0)
      expect(Spree::Pos::AuditEntry.where(action: %w[receipt.print receipt.reprint])).to be_empty
    end

    it 'prints a return with the return template and binds the chosen layout to the idempotency key' do
      sale = paid_sale(store, branch, cashier: cashier, price: 50_000, quantity: 2)
      operation = operation(return_and_receive(store, cashier, branch, sale, quantity: 1))
      slip = call(cashier, :get, 'receipts/lookup', { source_id: operation.prefixed_id })['data']
      return_template = default_template('return')
      key = SecureRandom.uuid
      first = print!(slip, { receipt_template_id: return_template.prefixed_id }, key: key)
      expect(first['print']).to include('template_id' => return_template.prefixed_id, 'paper' => '80mm')
      expect(print!(slip, { receipt_template_id: return_template.prefixed_id }, key: key)['print']['id']).to eq(first['print']['id'])
      print!(slip, { receipt_template_id: return_template.prefixed_id, paper: '58mm' }, key: key)
      expect(response).to have_http_status(:conflict)
      expect(Spree::Pos::ReceiptPrint.count).to eq(1)
    end

    it "keeps the original's version and paper when only the original's template is named" do
      receipt = sale_receipt
      template = default_template('sale')
      print!(receipt)
      edited = template.current_config.merge('footer' => [{ 'type' => 'divider' }])
      template.with_lock { template.revise!(config: edited, actor: nil, paper: 'a4') }

      same = print!(receipt, { receipt_template_id: template.prefixed_id })
      expect(same['print']).to include('template_id' => template.prefixed_id, 'template_version' => 1, 'paper' => '80mm')
      newer = print!(receipt, { receipt_template_id: template.prefixed_id, template_version: 2 })
      expect(newer['print']).to include('template_version' => 2, 'paper' => '80mm')
      wider = print!(receipt, { receipt_template_id: template.prefixed_id, paper: 'a4' })
      expect(wider['print']).to include('template_version' => 1, 'paper' => 'a4')
    end

    it 'prints a supplementary return slip with the return template and refuses a sale template' do
      sale = paid_sale(store, branch, cashier: cashier, price: 50_000, quantity: 2)
      first = prepare_return(store, cashier, branch, sale, quantity: 1)
      second = prepare_return(store, cashier, branch, sale, quantity: 1)
      receive_return(store, cashier, second)
      Spree::Pos::Returns::Cancel.call(store: store, staff: cashier, key: SecureRandom.uuid, return_id: first['id'], reason: 'Khách đổi ý')
      supplement = Spree::Pos::ReceiptSnapshot.find_by!(source_type: 'return_supplement', source_id: operation(second).id)
      slip = { 'id' => supplement.prefixed_id }

      print!(slip, { receipt_template_id: default_template('sale').prefixed_id })
      expect(response).to have_http_status(:unprocessable_content)
      expect(error_pointers).to eq(['/receipt_template_id'])
      expect(response.parsed_body.dig('error', 'details', 'errors', 0, 'code')).to eq('mismatch')

      printed = print!(slip)
      expect(response).to have_http_status(:created)
      expect(printed['print']).to include('template_id' => default_template('return').prefixed_id, 'template_version' => 1, 'paper' => '80mm')
      expect(printed['receipt']).to include('source_type' => 'return_supplement')
      explicit = print!(slip, { receipt_template_id: default_template('return').prefixed_id })
      expect(explicit['print']).to include('copy_number' => 1, 'template_id' => default_template('return').prefixed_id)
    end

    it 'uses the current default when the original predates templates' do
      receipt = sale_receipt
      snapshot = Spree::Pos::ReceiptSnapshot.find_by_prefix_id(receipt['id'])
      Spree::Pos::ReceiptPrint.create!(store: store, receipt_snapshot: snapshot, actor: cashier, copy_number: 0)
      expect(call(cashier, :get, "receipts/#{receipt['id']}")['data']['original_print']).to be_nil
      copy = print!(receipt)
      expect(copy['print']).to include('copy_number' => 1, 'template_id' => default_template('sale').prefixed_id, 'paper' => '80mm')
      expect(copy['receipt']['original_print']).to be_nil
    end
  end
end
