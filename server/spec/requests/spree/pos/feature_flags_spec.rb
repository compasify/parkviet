# frozen_string_literal: true

require 'spree/api/testing_support/v3/base'
require_relative '../../../support/pos_shift_helpers'
require_relative '../../../support/pos_trace_helpers'

# Kill-switches of risky POS features: everything starts off, the effective
# value is the store default AND the branch override (a branch can only be
# switched off), only topology managers switch them, every change is audited,
# and off refuses only new commands of the feature while replays and every
# recovery and resolution path keep working on what exists.
RSpec.describe 'POS feature kill-switches', type: :request, pos_features: :default do
  include PosShiftHelpers
  include PosTraceHelpers

  let(:store) { create(:store, default_currency: 'VND', supported_currencies: 'VND') }
  let(:branch) { returns_branch(store) }
  let(:admin) { credit_staff(store, branch, [], extra_permissions: %w[read_pos_topology write_pos_topology]) }
  let(:manager) do
    caps = Spree::Pos::Capabilities
    credit_staff(store, branch, PosShiftHelpers::MANAGER + [caps::INVENTORY_MANAGE, caps::REPORT_READ, caps::REPORT_EXPORT])
  end
  let(:cashier) { credit_staff(store, branch, PosShiftHelpers::LEAD) }

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

  # Store default.
  def turn(feature, enabled)
    set_pos_feature(store, feature, enabled, actor: admin)
  end

  def turn_all(enabled)
    Spree::Pos::FeatureFlag::FEATURES.each { |feature| turn(feature, enabled) }
  end

  def expect_disabled(feature, &block)
    expect(&block).to raise_error(Spree::Pos::Conflict) do |error|
      expect(error.reason).to eq('feature_disabled')
      expect(error.details).to eq(feature: feature)
    end
  end

  def features_at(user, at = branch)
    call(user, :get, 'context', { branch_id: at.prefixed_id })['features']
  end

  describe 'switches' do
    it 'starts off, turns on only through the store default, and lets a branch override only switch off' do
      expect(features_at(cashier)).to eq(Spree::Pos::FeatureFlag::FEATURES.index_with(false))

      call(admin, :put, 'feature_flags/credit', { branch_id: branch.prefixed_id, enabled: true, reason: 'Thử bật riêng chi nhánh' })
      expect(response).to have_http_status(:ok)
      expect(features_at(cashier)['credit']).to be(false)
      expect(Spree::Pos::FeatureFlag.where(branch_id: branch.id)).to be_empty

      call(admin, :put, 'feature_flags/credit', { enabled: true, reason: 'Mở bán nợ' })
      expect(features_at(cashier)).to include('credit' => true, 'returns' => false)
      expect(call(cashier, :get, 'context')['features']).to include('credit' => true)

      other = returns_branch(store)
      call(admin, :put, 'feature_flags/credit', { branch_id: branch.prefixed_id, enabled: false, reason: 'Chi nhánh chưa sẵn sàng' })
      expect(features_at(cashier)['credit']).to be(false)
      expect(Spree::Pos::FeaturePolicy.enabled?(other, :credit)).to be(true)

      listing = call(admin, :get, 'feature_flags', { branch_id: branch.prefixed_id })['data']
      expect(listing['switches']['credit']).to eq('store' => true, 'branch_override' => false, 'effective' => false)
      expect(listing['switches']['returns']).to eq('store' => false, 'branch_override' => nil, 'effective' => false)
      expect(listing['features']['credit']).to be(false)

      # Store off wins over a branch with no override.
      call(admin, :put, 'feature_flags/credit', { enabled: false, reason: 'Tạm dừng' })
      expect(Spree::Pos::FeaturePolicy.enabled?(other, :credit)).to be(false)
      call(admin, :put, 'feature_flags/credit', { enabled: true, reason: 'Mở lại' })
      call(admin, :put, 'feature_flags/credit', { branch_id: branch.prefixed_id, enabled: nil, reason: 'Theo mặc định cửa hàng' })
      expect(features_at(cashier)['credit']).to be(true)

      audits = Spree::Pos::AuditEntry.where(action: 'feature_flag.change').order(:id).map(&:metadata)
      expect(audits.map { |row| row.values_at('scope', 'from', 'to') }).
        to eq([['store', nil, true], ['branch', nil, false], ['store', true, false], ['store', false, true], ['branch', false, nil]])
      expect(audits.map { |row| row['reason'] }).to all(be_present)
    end

    it 'lets a branch manager switch only their own branch off, and only store managers switch on' do
      turn(:returns, true)
      call(cashier, :put, 'feature_flags/returns', { branch_id: branch.prefixed_id, enabled: false, reason: 'x' })
      expect(response).to have_http_status(:forbidden)

      branch_manager = credit_staff(store, branch, [Spree::Pos::Capabilities::MANAGE])
      call(branch_manager, :put, 'feature_flags/returns', { enabled: false, reason: 'Toàn cửa hàng' })
      expect(response).to have_http_status(:forbidden)
      call(branch_manager, :put, 'feature_flags/returns', { branch_id: branch.prefixed_id, enabled: false, reason: 'Kho đang kiểm' })
      expect(response).to have_http_status(:ok)
      call(branch_manager, :put, 'feature_flags/returns', { branch_id: branch.prefixed_id, enabled: false, reason: 'Lại' })
      expect(Spree::Pos::AuditEntry.where(action: 'feature_flag.change', actor_id: branch_manager.id).count).to eq(1)
      [true, nil].each do |value|
        call(branch_manager, :put, 'feature_flags/returns', { branch_id: branch.prefixed_id, enabled: value, reason: 'Mở lại' })
        expect(response).to have_http_status(:forbidden)
      end
      expect(Spree::Pos::FeaturePolicy.enabled?(branch, :returns)).to be(false)
      call(branch_manager, :get, 'feature_flags', { branch_id: branch.prefixed_id })
      expect(response).to have_http_status(:ok)

      elsewhere = returns_branch(store)
      call(branch_manager, :get, 'feature_flags', { branch_id: elsewhere.prefixed_id })
      expect(response.status).to be_in([403, 404])
      call(branch_manager, :put, 'feature_flags/returns', { branch_id: elsewhere.prefixed_id, enabled: false, reason: 'x' })
      expect(response.status).to be_in([403, 404])
      call(branch_manager, :get, 'feature_flags')
      expect(response.status).to be_in([403, 404])
      expect(Spree::Pos::FeaturePolicy.enabled?(elsewhere, :returns)).to be(true)

      call(admin, :put, 'feature_flags/returns', { branch_id: branch.prefixed_id, enabled: false })
      expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('reason_required')
      call(admin, :put, 'feature_flags/teleport', { enabled: true, reason: 'x' })
      expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('feature_unknown')
      call(admin, :put, 'feature_flags/returns', { enabled: 'yes', reason: 'x' })
      expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('feature_value_invalid')
      # Authority is checked before the input is.
      call(cashier, :put, 'feature_flags/teleport', { enabled: true, reason: '' })
      expect(response).to have_http_status(:forbidden)

      foreign_branch = returns_branch(create(:store, default_currency: 'VND', supported_currencies: 'VND'))
      call(admin, :put, 'feature_flags/returns', { branch_id: foreign_branch.prefixed_id, enabled: false, reason: 'x' })
      expect(response).to have_http_status(:not_found)
    end

    it 'answers a refused command with 409 feature_disabled' do
      sale = paid_sale(store, branch, cashier: cashier, price: 50_000)
      call(cashier, :post, 'returns', { branch_id: branch.prefixed_id, order_id: sale.workspace.order.prefixed_id, reason: 'Lỗi',
                                        lines: [{ sale_line_id: sale_line(sale).prefixed_id, quantity: 1, condition: 'resellable' }] })
      expect(response).to have_http_status(:conflict)
      expect(response.parsed_body.dig('error', 'details')).to include('reason' => 'feature_disabled', 'feature' => 'returns')
      expect(Spree::Pos::ReturnOperation.count).to eq(0)
    end
  end

  describe 'with a feature switched off' do
    it 'refuses new credit sales, gives back approved exposure, replays executed commands and keeps collecting debt' do
      turn(:credit, true)
      profile = credit_customer(store, manager)
      account = configure_credit(store, manager, branch, profile, limit: 5_000_000)
      sold = credit_sale(store, branch, price: 300_000)
      assign(sold, profile)
      sold_approval = approve_credit(sold, manager, 300_000)
      complete_args = editing_args(sold).merge(credit_approval_id: sold_approval['approval_id'])
      completed = Spree::Pos::Workspaces::Complete.call(**complete_args)
      asked = credit_sale(store, branch, price: 150_000)
      assign(asked, profile)
      request_args = editing_args(asked)
      requested = Spree::Pos::Credit::RequestApproval.call(**request_args)
      pending = credit_sale(store, branch, price: 200_000)
      assign(pending, profile)
      key = SecureRandom.uuid
      approval = approve_credit(pending, manager, 200_000, key: key)

      open_drawer(store, branch, manager)
      turn(:credit, false)
      expect(approve_credit(pending, manager, 200_000, key: key)).to eq(approval)
      expect(Spree::Pos::Workspaces::Complete.call(**complete_args)).to eq(completed)
      expect(Spree::Pos::Credit::RequestApproval.call(**request_args)).to eq(requested)
      expect_disabled('credit') { complete_on_credit(pending, approval['approval_id']) }
      reservation = Spree::Pos::CreditReservation.find_by!(workspace_id: pending.workspace.id)
      expect(reservation.status).to eq('released')
      expect(reservation.released_reason).to eq('feature_disabled')
      expect(reservation.approval.reload.status).to eq('revoked')
      expect_disabled('credit') { request_credit(pending) }
      fresh = credit_sale(store, branch, price: 100_000)
      assign(fresh, profile)
      expect_disabled('credit') { approve_credit(fresh, manager, 100_000) }
      expect(pending.workspace.reload.operational_status).to eq('editing')

      Spree::Pos::Collections::Receive.call(
        store: store, staff: manager, key: SecureRandom.uuid, branch_id: branch.prefixed_id, credit_account_id: account.prefixed_id,
        kind: 'cash', amount: '100000', allocations: [{ 'order_id' => sold.workspace.order.prefixed_id, 'amount' => '100000' }]
      )
      expect(receivable_balance(sold.workspace.order)).to eq(BigDecimal('200000'))
      # An ordinary paid sale never depends on a switch.
      complete_paid(fresh)
      expect(fresh.workspace.reload.operational_status).to eq('completed')
    end

    it 'refuses new returns, refunds and exchanges but replays and finishes the ones already started' do
      %i[returns refunds exchanges].each { |feature| turn(feature, true) }
      sale = paid_sale(store, branch, cashier: cashier, price: 100_000, quantity: 4)
      received = return_and_receive(store, cashier, branch, sale, quantity: 1)
      refund_key = SecureRandom.uuid
      refund = request_refund(store, cashier, received, amount: 100_000, key: refund_key)
      prepare_key = SecureRandom.uuid
      waiting = prepare_return(store, cashier, branch, sale, quantity: 1, key: prepare_key)
      dropped = prepare_return(store, cashier, branch, sale, quantity: 1)
      register = Spree::Pos::Shift.open_now.find_by!(owner: cashier).register
      exchange_args = { store: store, staff: cashier, key: SecureRandom.uuid, return_id: received['id'],
                        editor_id: SecureRandom.uuid, register_id: register.prefixed_id }
      exchange = Spree::Pos::Exchanges::Execute.call(**exchange_args)

      %i[returns refunds exchanges].each { |feature| turn(feature, false) }
      expect(prepare_return(store, cashier, branch, sale, quantity: 1, key: prepare_key)).to eq(waiting)
      expect(request_refund(store, cashier, received, amount: 100_000, key: refund_key)).to eq(refund)
      expect(Spree::Pos::Exchanges::Execute.call(**exchange_args)).to eq(exchange)
      expect_disabled('returns') { prepare_return(store, cashier, branch, sale, quantity: 1) }
      expect_disabled('refunds') { request_refund(store, cashier, received, amount: 1_000) }
      second = receive_return(store, cashier, waiting)
      expect(second['status']).to eq('received')
      expect_disabled('exchanges') do
        Spree::Pos::Exchanges::Execute.call(**exchange_args, key: SecureRandom.uuid, return_id: second['id'])
      end

      Spree::Pos::Returns::Cancel.call(store: store, staff: cashier, key: SecureRandom.uuid, return_id: dropped['id'], reason: 'Khách đổi ý')
      approve_refund(store, manager, refund)
      expect(confirm_refund(store, cashier, refund)['status']).to eq('confirmed')
      expect(Spree::Refund.where(payment_id: sale.workspace.order.payments.select(:id)).sum(:amount)).to eq(BigDecimal('100000'))
    end

    it 'refuses opening tracked stock and starting to track a SKU, but replays and keeps selling tracked goods' do
      turn(:traceability, true)
      phone = stocked_product(store, branch, price: 1_000_000, stock: 1)
      track_variant!(store, phone.default_variant, 'serial')
      enroll_serials!(branch, phone.default_variant, %w[IMEI-A IMEI-B], opened_by: manager)
      milk = stocked_product(store, branch, price: 20_000, stock: 1)
      track_variant!(store, milk.default_variant, 'lot')
      tea = stocked_product(store, branch, price: 20_000, stock: 2)
      track_variant!(store, tea.default_variant, 'lot')
      open_args = { store: store, staff: manager, key: SecureRandom.uuid, branch_id: branch.prefixed_id,
                    variant_id: tea.default_variant.prefixed_id, lots: [{ lot_code: 'T1', quantity: 2 }] }
      opened = Spree::Pos::Inventory::OpenBalance.call(**open_args)
      configurer = credit_staff(store, branch, [Spree::Pos::Capabilities::MANAGE], extra_permissions: %w[write_pos_topology])
      plain = stocked_product(store, branch, price: 5_000)
      track = lambda do
        call(configurer, :put, 'units/variant', { branch_id: branch.prefixed_id, variant_id: plain.default_variant.prefixed_id,
                                                  sale_unit: 'item', tracked_mode: 'serial' })
      end

      # The tracked mode is store-wide: one branch switched off does not decide it.
      set_pos_feature(store, :traceability, false, actor: admin, branch: branch)
      expect_disabled('traceability') do
        Spree::Pos::Inventory::OpenBalance.call(**open_args, key: SecureRandom.uuid, variant_id: milk.default_variant.prefixed_id, lots: [])
      end

      turn(:traceability, false)
      expect(Spree::Pos::Inventory::OpenBalance.call(**open_args)).to eq(opened)
      track.call
      expect(response).to have_http_status(:conflict)
      expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('feature_disabled')
      turn(:traceability, true)
      track.call
      expect(response).to have_http_status(:ok)
      turn(:traceability, false)

      sale = open_sale(store, branch, cashier: cashier, product: stocked_product(store, branch, price: 1_000))
      workspace = sale.workspace.reload
      Spree::Pos::Workspaces::ManageLineItem.add(workspace: workspace, staff: cashier, revision: workspace.revision, key: SecureRandom.uuid,
                                                 lease_generation: workspace.lease_generation, editor_id: sale.editor_id,
                                                 variant_id: phone.default_variant.prefixed_id, quantity: 1, serial_codes: ['IMEI-A'])
      complete_paid(sale)
      hand_over(sale)
      expect(Spree::Pos::SerialUnit.find_by!(serial: 'IMEI-A').status).to eq('sold')
    end

    it 'refuses binding, pinning and pairing the customer display but replays, clears and revokes it' do
      turn(:customer_display, true)
      sale = open_sale(store, branch, cashier: cashier, product: stocked_product(store, branch, price: 25_000))
      shift = sale.workspace.reload.shift
      bound = Spree::Pos::Displays::Bind.call(store: store, staff: cashier, shift_id: shift.prefixed_id)
      session = Spree::Pos::DisplaySession.find_by_prefix_id!(bound[:session][:id])
      display = { 'Authorization' => "Display #{bound[:token]}" }
      get '/api/v3/pos_display/state', headers: display
      state = response.parsed_body['data']
      post '/api/v3/pos_display/ack', headers: display, params: { generation: state['generation'], lease_id: state['lease_id'] }, as: :json
      pin_args = { store: store, staff: cashier, key: SecureRandom.uuid, session_id: session.prefixed_id,
                   expected_generation: session.generation, workspace_id: sale.workspace.prefixed_id }
      pinned = Spree::Pos::Displays::Pin.call(**pin_args)
      code = Spree::Pos::Displays::Pairing.issue(store: store, staff: cashier, session_id: session.prefixed_id)[:code]

      turn(:customer_display, false)
      expect(Spree::Pos::Displays::Pin.call(**pin_args)).to eq(pinned)
      expect_disabled('customer_display') do
        Spree::Pos::Displays::Pin.call(**pin_args, key: SecureRandom.uuid, expected_generation: session.reload.generation)
      end
      expect_disabled('customer_display') { Spree::Pos::Displays::Bind.call(store: store, staff: cashier, shift_id: shift.prefixed_id) }
      expect_disabled('customer_display') do
        Spree::Pos::Displays::Pairing.issue(store: store, staff: cashier, session_id: session.prefixed_id)
      end
      # Codes issued before the switch were spent by it, and no code pairs while it is off.
      expect(Spree::Pos::DisplayPairing.where(display_session_id: session.id, used_at: nil)).to be_empty
      expect(Spree::Pos::Displays::Pairing.exchange(code)).to be_nil

      get '/api/v3/pos_display/state', headers: display
      expect(response).to have_http_status(:ok)
      cleared = Spree::Pos::Displays::Pin.clear(store: store, staff: cashier, key: SecureRandom.uuid, session_id: session.prefixed_id,
                                                expected_generation: session.reload.generation)
      expect(cleared['pinned_workspace_id']).to be_nil
      Spree::Pos::Displays::Revoke.call(store: store, staff: cashier, session_id: session.prefixed_id, reason: 'ended')
      expect(session.reload.revoked_at).to be_present
    end

    it 'refuses a pairing exchange once the display is switched off after the code was issued' do
      turn(:customer_display, true)
      sale = open_sale(store, branch, cashier: cashier, product: stocked_product(store, branch, price: 25_000))
      bound = Spree::Pos::Displays::Bind.call(store: store, staff: cashier, shift_id: sale.workspace.reload.shift.prefixed_id)
      code = Spree::Pos::Displays::Pairing.issue(store: store, staff: cashier, session_id: bound[:session][:id])[:code]
      Spree::Pos::FeatureFlag.create!(store: store, branch: branch, feature: 'customer_display', enabled: false, reason: 'x',
                                      changed_by: admin)
      expect(Spree::Pos::Displays::Pairing.exchange(code)).to be_nil
    end

    it 'refuses new drawer movements but replays and confirms requests already made, and still closes the shift' do
      turn(:cash_moves, true)
      shift = open_shift(store, branch, cashier, float: 500_000)
      key = SecureRandom.uuid
      requested = move_cash(shift, cashier, 'cash_out', 100_000, key: key)

      turn(:cash_moves, false)
      expect(move_cash(shift, cashier, 'cash_out', 100_000, key: key)).to eq(requested)
      expect_disabled('cash_moves') { move_cash(shift, cashier, 'cash_in', 50_000) }
      expect_disabled('cash_moves') { move_cash(shift, cashier, 'safe_drop', 50_000) }
      expect(decide_cash(store, manager, requested['id'], 'confirm')['status']).to eq('confirmed')
      expect(expected_cash(shift)).to eq(BigDecimal('400000'))
      count_shift(shift, cashier, 400_000)
      expect(close_shift(shift, cashier)['variance']).to eq('0.0')
    end

    it 'refuses new exports but replays an accepted one and keeps reports readable' do
      call(manager, :post, 'exports', { branch_id: branch.prefixed_id, report_type: 'sales' })
      expect(response).to have_http_status(:conflict)
      expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('feature_disabled')
      expect(Spree::Pos::ExportRequest.count).to eq(0)
      call(manager, :get, 'reports/sales', { branch_id: branch.prefixed_id })
      expect(response).to have_http_status(:ok)

      turn(:exports, true)
      key = SecureRandom.uuid
      accepted = call(manager, :post, 'exports', { branch_id: branch.prefixed_id, report_type: 'sales' }, key: key)
      expect(response).to have_http_status(:accepted)
      turn(:exports, false)
      expect(call(manager, :post, 'exports', { branch_id: branch.prefixed_id, report_type: 'sales' }, key: key)).to eq(accepted)
      expect(response).to have_http_status(:accepted)
      expect(Spree::Pos::ExportRequest.count).to eq(1)
    end

    it 'never deletes or rewrites recorded money, stock or receipts when switching' do
      turn_all(true)
      sale = paid_sale(store, branch, cashier: cashier, price: 80_000, quantity: 2)
      received = return_and_receive(store, cashier, branch, sale, quantity: 1)
      request_refund(store, cashier, received, amount: 80_000)
      tables = [Spree::Pos::TenderAttempt, Spree::Pos::ReceivedFunds, Spree::Pos::FundsAllocation, Spree::Pos::CashMovement,
                Spree::Pos::ReceiptSnapshot, Spree::Pos::ReturnOperation, Spree::Pos::RefundRequest, Spree::Pos::CommandReceipt,
                Spree::Payment, Spree::StockMovement]
      snapshot = -> { tables.to_h { |model| [model.name, model.order(:id).pluck(:id, :updated_at)] } }
      before = snapshot.call

      turn_all(false)
      turn_all(true)
      expect(snapshot.call).to eq(before)
      expect(Spree::Pos::AuditEntry.where(action: 'feature_flag.change').count).to eq(Spree::Pos::FeatureFlag::FEATURES.size * 3)
    end
  end
end
