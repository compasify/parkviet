# frozen_string_literal: true

require 'spree/api/testing_support/v3/base'
require_relative '../../../support/pos_return_helpers'

# HTTP contract for order history, returns, refunds and exchanges, including
# who may read or write them and that core return/refund endpoints stay shut
# to cashiers.
RSpec.describe 'POS orders, returns and refunds API', type: :request do
  include PosReturnHelpers

  let(:store) { create(:store, default_currency: 'VND', supported_currencies: 'VND') }
  let(:branch) { returns_branch(store) }
  let(:manager) { credit_staff(store, branch, PosReturnHelpers::APPROVER) }
  let(:cashier) { credit_staff(store, branch, PosReturnHelpers::RETURNS) }

  before { allow(Spree::Store).to receive(:default).and_return(store) }

  def token_for(user)
    @tokens ||= {}
    @tokens[user.id] ||= begin
      post '/api/v3/admin/auth/login', params: { email: user.email, password: 'secret123' }, as: :json
      response.parsed_body.fetch('token')
    end
  end

  def call(user, verb, path, body = {}, prefix: '/api/v3/admin/pos/')
    key = SecureRandom.uuid
    send(verb, "#{prefix}#{path}", headers: { 'Authorization' => "Bearer #{token_for(user)}", 'Idempotency-Key' => key },
                                   params: verb == :get ? body : body.merge(idempotency_key: key), as: verb == :get ? nil : :json)
    response.parsed_body
  end

  def lines(sale, quantity: 1, condition: 'resellable')
    [{ sale_line_id: sale_line(sale).prefixed_id, quantity: quantity, condition: condition }]
  end

  it 'lists and shows branch orders with filters and a timeline, and hides them from other branches' do
    sale = paid_sale(store, branch, cashier: cashier, price: 100_000, quantity: 2)
    paid_sale(store, branch, cashier: cashier, price: 5_000)
    order = sale.workspace.order

    list = call(cashier, :get, 'orders', { branch_id: branch.prefixed_id, number: order.number })
    expect(response).to have_http_status(:ok)
    expect(list['data'].map { |row| row['number'] }).to eq([order.number])
    today = Time.current.in_time_zone(branch.timezone).to_date.iso8601
    expect(call(cashier, :get, 'orders', { branch_id: branch.prefixed_id, from: today, to: today })['meta']['count']).to eq(2)
    expect(call(cashier, :get, 'orders', { branch_id: branch.prefixed_id, status: 'returned' })['meta']['count']).to eq(0)
    call(cashier, :get, 'orders', { branch_id: branch.prefixed_id, status: 'bogus' })
    expect(response).to have_http_status(:conflict)

    detail = call(cashier, :get, "orders/#{order.prefixed_id}")['data']
    expect(detail['totals']).to include('original_total' => '200000.0')
    expect(detail['lines'].first).to include('returnable_quantity' => 2, 'handed_over' => true)
    expect(detail['receipts'].first).to include('amount' => '200000.0', 'refundable' => '200000.0')
    expect(detail['timeline'].map { |event| event['kind'] }).to include('placed', 'receipt', 'handed_over')

    other = returns_branch(store)
    outsider = credit_staff(store, other, [Spree::Pos::Capabilities::OPEN_SHIFT, Spree::Pos::Capabilities::PAYMENT])
    call(outsider, :get, 'orders', { branch_id: branch.prefixed_id })
    expect(response).to have_http_status(:forbidden)
    call(outsider, :get, "orders/#{order.prefixed_id}")
    expect(response).to have_http_status(:not_found)
    call(outsider, :get, 'orders/lookup', { number: order.number, branch_id: other.prefixed_id })
    expect(response).to have_http_status(:not_found)

    # Return staff elsewhere may look one sale up by number, masked, to take it back there.
    returner = credit_staff(store, other, PosReturnHelpers::RETURNS)
    found = call(returner, :get, 'orders/lookup', { number: order.number, branch_id: other.prefixed_id })
    expect(response).to have_http_status(:ok)
    expect(found.dig('data', 'id')).to eq(order.prefixed_id)
  end

  it 'refuses returns to staff without the return capability and on branches where returns are off' do
    sale = paid_sale(store, branch, cashier: cashier, price: 10_000)
    seller = credit_staff(store, branch, [Spree::Pos::Capabilities::OPEN_SHIFT, Spree::Pos::Capabilities::PAYMENT])
    call(seller, :post, 'returns', { branch_id: branch.prefixed_id, order_id: sale.workspace.order.prefixed_id, lines: lines(sale), reason: 'x' })
    expect(response).to have_http_status(:forbidden)

    branch.update!(return_window_days: nil)
    call(cashier, :post, 'returns/preview', { branch_id: branch.prefixed_id, order_id: sale.workspace.order.prefixed_id, lines: lines(sale) })
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('returns_disabled')
  end

  it 'runs preview, prepare, approve, receive, refund request, approval and confirmation over HTTP' do
    sale = paid_sale(store, branch, cashier: cashier, price: 100_000, quantity: 2)
    order_id = sale.workspace.order.prefixed_id
    preview = call(cashier, :post, 'returns/preview', { branch_id: branch.prefixed_id, order_id: order_id, lines: lines(sale, condition: 'damaged') })
    expect(preview['data']).to include('entitlement_total' => '100000.0', 'refund' => '100000.0', 'requires_approval' => true)

    created = call(cashier, :post, 'returns',
                   { branch_id: branch.prefixed_id, order_id: order_id, lines: lines(sale, condition: 'damaged'), reason: 'Vỡ' })
    expect(response).to have_http_status(:created)
    return_id = created.dig('data', 'id')
    pending = call(manager, :get, 'returns', { branch_id: branch.prefixed_id, status: 'pending_approval' })
    expect(pending['data'].map { |row| row['id'] }).to eq([return_id])

    call(cashier, :post, "returns/#{return_id}/approve")
    expect(response).to have_http_status(:forbidden)
    approved = call(manager, :post, "returns/#{return_id}/approve")['data']
    received = call(cashier, :post, "returns/#{return_id}/receive", { approval_id: approved.dig('approval', 'id') })['data']
    expect(received).to include('status' => 'received', 'refund_entitlement' => '100000.0')

    allocation = allocation_of(sale)
    refund = call(cashier, :post, 'refund_requests',
                  { return_id: return_id, allocation_id: allocation.prefixed_id, amount: '100000', method: 'cash' })
    expect(response).to have_http_status(:created)
    refund_id = refund.dig('data', 'id')
    waiting = call(manager, :get, 'refund_requests', { branch_id: branch.prefixed_id })
    expect(waiting['data'].map { |row| row['id'] }).to eq([refund_id])

    call(cashier, :post, "refund_requests/#{refund_id}/confirmation", { evidence_kind: 'cash_count' })
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('approval_required')
    approval = call(manager, :post, "refund_requests/#{refund_id}/approve")['data']
    confirmed = call(cashier, :post, "refund_requests/#{refund_id}/confirmation",
                     { evidence_kind: 'cash_count', approval_id: approval.dig('approval', 'id') })
    expect(response).to have_http_status(:ok)
    expect(confirmed.dig('data', 'status')).to eq('confirmed')

    detail = call(cashier, :get, "orders/#{order_id}")['data']
    expect(detail['receipts'].first).to include('refunded' => '100000.0', 'refundable' => '100000.0')
    expect(detail['timeline'].map { |event| event['kind'] }).to include('return_received', 'refund_paid')
  end

  it 'keeps core return and refund endpoints and the generic approval route out of reach' do
    sale = paid_sale(store, branch, cashier: cashier, price: 10_000)
    order = sale.workspace.order
    payment = order.payments.first
    call(cashier, :post, "orders/#{order.prefixed_id}/refunds", { payment_id: payment.prefixed_id, amount: '10000' }, prefix: '/api/v3/admin/')
    expect(response).to have_http_status(:forbidden)
    call(cashier, :post, "orders/#{order.prefixed_id}/returns", {}, prefix: '/api/v3/admin/')
    expect(response).to have_http_status(:forbidden)
    expect(Spree::Refund.count).to eq(0)

    topology_manager = credit_staff(store, branch, PosReturnHelpers::APPROVER, extra_permissions: %w[write_pos_topology])
    created = call(cashier, :post, 'returns',
                   { branch_id: branch.prefixed_id, order_id: order.prefixed_id, lines: lines(sale, condition: 'damaged'), reason: 'x' })
    call(topology_manager, :post, 'approvals', { branch_id: branch.prefixed_id, requester_id: cashier.prefixed_id,
                                                 workspace_id: sale.workspace.prefixed_id, revision: sale.workspace.reload.revision,
                                                 action_name: 'return.process', amount: '10000' })
    expect(response).to have_http_status(:conflict)
    # A workspace-bound approval never opens a return.
    call(cashier, :post, "returns/#{created.dig('data', 'id')}/receive")
    expect(response).to have_http_status(:conflict)
  end

  it 'lets a topology manager turn returns on and off per branch' do
    admin = credit_staff(store, branch, PosReturnHelpers::APPROVER, extra_permissions: %w[write_pos_topology read_pos_topology])
    data = call(admin, :patch, "branches/#{branch.prefixed_id}", { return_window_days: 7 })['data']
    expect(data['return_window_days']).to eq(7)
    data = call(admin, :patch, "branches/#{branch.prefixed_id}", { return_window_days: '' })['data']
    expect(data['return_window_days']).to be_nil
    call(cashier, :patch, "branches/#{branch.prefixed_id}", { return_window_days: 30 })
    expect(response).to have_http_status(:forbidden)
  end

  def bank_refund(sale)
    created = call(cashier, :post, 'returns', { branch_id: branch.prefixed_id, order_id: sale.workspace.order.prefixed_id,
                                                lines: lines(sale), reason: 'Lỗi' })
    return_id = created.dig('data', 'id')
    call(cashier, :post, "returns/#{return_id}/receive")
    call(cashier, :post, 'refund_requests', { return_id: return_id, allocation_id: allocation_of(sale).prefixed_id, amount: '10000',
                                              method: 'bank_manual', beneficiary_reference: 'VCB 0071000123456 NGUYEN VAN A' })
    [return_id, response.parsed_body.dig('data', 'id')]
  end

  it 'masks payment references unless the reader resolves or approves money at the branch' do
    sale = paid_sale(store, branch, cashier: cashier, price: 10_000, quantity: 2, kind: 'bank_manual')
    return_id, refund_id = bank_refund(sale)
    full = 'VCB 0071000123456 NGUYEN VAN A'

    as_cashier = call(cashier, :get, "refund_requests/#{refund_id}")['data']
    expect(as_cashier['beneficiary_reference']).to end_with(' A').and(start_with('•'))
    expect(response.body).not_to include('0071000123456')
    call(cashier, :get, "returns/#{return_id}")
    expect(response.body).not_to include('0071000123456')
    detail = call(cashier, :get, "orders/#{sale.workspace.order.prefixed_id}")['data']
    expect(response.body).not_to include('0071000123456')
    reference = Spree::Pos::FundsAllocation.find_by_prefix_id!(detail['receipts'].first['allocation_id']).received_funds.reference
    expect(response.body).not_to include(reference)
    expect(detail['receipts'].first['reference']).to end_with(reference[-4..])

    expect(call(manager, :get, "refund_requests/#{refund_id}").dig('data', 'beneficiary_reference')).to eq(full)
    expect(call(manager, :get, 'refund_requests', { branch_id: branch.prefixed_id })['data'].first['beneficiary_reference']).to eq(full)
  end

  it 'shows returns and refunds only to return, resolve or approve staff, not to every branch member' do
    sale = paid_sale(store, branch, cashier: cashier, price: 10_000, quantity: 2)
    return_id, refund_id = bank_refund(sale)
    seller = credit_staff(store, branch, [Spree::Pos::Capabilities::OPEN_SHIFT, Spree::Pos::Capabilities::PAYMENT])
    call(seller, :get, 'returns', { branch_id: branch.prefixed_id })
    expect(response).to have_http_status(:forbidden)
    call(seller, :get, "returns/#{return_id}")
    expect(response).to have_http_status(:not_found)
    call(seller, :get, 'refund_requests', { branch_id: branch.prefixed_id })
    expect(response).to have_http_status(:forbidden)
    call(seller, :get, "refund_requests/#{refund_id}")
    expect(response).to have_http_status(:not_found)
  end

  it 'cancels a refund over HTTP only with a reason, and only for its requester or an approver' do
    sale = paid_sale(store, branch, cashier: cashier, price: 10_000, quantity: 2)
    _return_id, refund_id = bank_refund(sale)
    call(cashier, :post, "refund_requests/#{refund_id}/resolution", { outcome: 'cancel' })
    expect(response).to have_http_status(:conflict)
    other = credit_staff(store, branch, PosReturnHelpers::RETURNS)
    call(other, :post, "refund_requests/#{refund_id}/resolution", { outcome: 'cancel', reason: 'x' })
    expect(response).to have_http_status(:forbidden)
    data = call(cashier, :post, "refund_requests/#{refund_id}/resolution", { outcome: 'cancel', reason: 'Khách đổi ý' })['data']
    expect(data['status']).to eq('canceled')
  end

  it 'reconciles a short handover over HTTP for a resolver of the branch' do
    product = stocked_product(store, branch, price: 20_000, stock: 2)
    sale = open_sale(store, branch, cashier: cashier, product: product, quantity: 2)
    complete_paid(sale)
    branch.stock_location.stock_level(product.default_variant).update_columns(count_on_hand: 0)
    hand_over(sale)
    order_id = sale.workspace.order.prefixed_id
    call(cashier, :post, "orders/#{order_id}/reconcile_handover")
    expect(response).to have_http_status(:forbidden)
    branch.stock_location.restock(product.default_variant, 2)
    data = call(manager, :post, "orders/#{order_id}/reconcile_handover")['data']
    expect(response).to have_http_status(:ok)
    expect(data['stock_discrepancies']).to eq([])
  end

  def queries_for(&block)
    count = 0
    counter = lambda do |*, payload|
      count += 1 unless payload[:name] == 'SCHEMA' || payload[:sql].start_with?('BEGIN', 'COMMIT', 'SAVEPOINT', 'RELEASE')
    end
    ActiveSupport::Notifications.subscribed(counter, 'sql.active_record', &block)
    count
  end

  it 'lists orders, returns and refunds with a query count that does not grow per row' do
    token_for(manager)
    sales = Array.new(4) { paid_sale(store, branch, cashier: cashier, price: 10_000, quantity: 2) }
    sales.first(1).each { |sale| bank_refund(sale) }
    measure = ->(path, params) { queries_for { call(manager, :get, path, params) } }
    one = { orders: measure.call('orders', { branch_id: branch.prefixed_id, limit: 1 }),
            returns: measure.call('returns', { branch_id: branch.prefixed_id, limit: 1 }) }
    sales.drop(1).each { |sale| bank_refund(sale) }
    many = { orders: measure.call('orders', { branch_id: branch.prefixed_id, limit: 25 }),
             returns: measure.call('returns', { branch_id: branch.prefixed_id, limit: 25 }),
             refunds: measure.call('refund_requests', { branch_id: branch.prefixed_id, limit: 25 }) }
    expect(many[:orders]).to be <= one[:orders] + 4
    expect(many[:returns]).to be <= one[:returns] + 4
    expect(many[:refunds]).to be < 60
  end
end
