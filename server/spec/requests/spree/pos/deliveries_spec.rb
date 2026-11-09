# frozen_string_literal: true

require 'spree/api/testing_support/v3/base'
require_relative '../../../support/pos_credit_helpers'

# Delivery orders: a sale marked for delivery completes like any sale (stock,
# money, credit) and waits as pending until staff mark it delivered. The
# delivery fee is an order-level core fee, so the server total carries it.
RSpec.describe 'POS delivery orders API', type: :request do
  include PosCreditHelpers

  let(:store) { create(:store, default_currency: 'VND', supported_currencies: 'VND') }
  let(:branch) { credit_branch(store) }
  let(:cashier) { credit_staff(store, branch, PosCreditHelpers::CASHIER) }
  let(:profile) { credit_customer(store, cashier) }

  before { allow(Spree::Store).to receive(:default).and_return(store) }

  def token_for(user)
    @tokens ||= {}
    @tokens[user.id] ||= begin
      post '/api/v3/admin/auth/login', params: { email: user.email, password: 'secret123' }, as: :json
      response.parsed_body.fetch('token')
    end
  end

  def headers(user, key = nil)
    { 'Authorization' => "Bearer #{token_for(user)}" }.merge(key ? { 'Idempotency-Key' => key } : {})
  end

  def call(user, path, body = {}, key: SecureRandom.uuid)
    post "/api/v3/admin/pos/#{path}", headers: headers(user, key), params: body.merge(idempotency_key: key), as: :json
    response.parsed_body
  end

  def list(user, status: nil, branch_id: branch.prefixed_id)
    get '/api/v3/admin/pos/deliveries', headers: headers(user), params: { branch_id: branch_id, status: status }.compact
    response.parsed_body
  end

  def editing_body(sale)
    workspace = sale.workspace.reload
    { expected_revision: workspace.revision, lease_generation: workspace.lease_generation, editor_id: sale.editor_id }
  end

  def mark_delivery(sale, deliverer: 'Bố', fee: '20000', key: SecureRandom.uuid)
    call(sale.cashier, "workspaces/#{sale.workspace.prefixed_id}/delivery", editing_body(sale).merge(deliverer: deliverer, fee: fee), key: key)
  end

  def complete(sale, approval_id = nil)
    call(sale.cashier, "workspaces/#{sale.workspace.prefixed_id}/complete",
         editing_body(sale).merge(credit_approval_id: approval_id).compact)
  end

  def purchasable(sale)
    level = branch.stock_location.stock_level(sale.product.default_variant).reload
    level.count_on_hand - level.allocated_count
  end

  it 'completes a paid delivery order with the fee in the server total, pending until delivered' do
    sale = credit_sale(store, branch, price: 100_000, cashier: cashier)
    assign(sale, profile)

    data = mark_delivery(sale)['data']
    expect(response).to have_http_status(:ok), response.body
    expect(data['delivery']).to include('status' => 'pending', 'deliverer' => 'Bố', 'fee' => '20000.0')
    expect(data['totals']).to include('fee_total' => '20000.0', 'total' => '120000.0')
    expect(sale.workspace.order.reload.fees.sole).to have_attributes(kind: 'handling', amount: BigDecimal('20000'))

    take_tender(sale, 'cash', 120_000)
    data = complete(sale)['data']
    expect(response).to have_http_status(:ok), response.body
    order = sale.workspace.reload.order
    expect(order).to be_placed
    expect(order.total).to eq(BigDecimal('120000'))
    expect(purchasable(sale)).to eq(9)
    expect(data['delivery']).to include('status' => 'pending')
    expect(Spree::Pos::AuditEntry.where(action: %w[workspace.delivery.set workspace.complete]).pluck(:action)).
      to contain_exactly('workspace.delivery.set', 'workspace.complete')

    receipt = Spree::Pos::ReceiptSnapshot.find_by!(source_type: 'sale', source_id: sale.workspace.id)
    expect(receipt.payload['delivery']).to eq('deliverer' => 'Bố', 'fee' => '20000.0')
    expect(receipt.payload['totals']).to include('fee_total' => '20000.0', 'total' => '120000.0')

    rows = list(cashier)['data']
    expect(response).to have_http_status(:ok)
    expect(rows.sole).to include('order_number' => order.number, 'status' => 'pending', 'deliverer' => 'Bố',
                                 'total' => '120000.0', 'paid' => '120000.0', 'owed' => '0.0')
    expect(rows.sole['customer']).to include('name' => profile.name, 'phone' => profile.phone)
  end

  it 'puts the fee into the debt of a delivery sold on credit' do
    manager = credit_staff(store, branch, PosCreditHelpers::MANAGER)
    configure_credit(store, manager, branch, profile, limit: 1_000_000)
    sale = credit_sale(store, branch, price: 100_000, cashier: cashier)
    assign(sale, profile)
    mark_delivery(sale, fee: '15000')
    take_tender(sale, 'cash', 40_000)
    approval = approve_credit(sale, manager, 75_000)

    complete(sale, approval['approval_id'])
    expect(response).to have_http_status(:ok), response.body
    order = sale.workspace.reload.order
    expect(receivable_balance(order)).to eq(BigDecimal('75000'))

    row = list(cashier)['data'].sole
    expect(row).to include('total' => '115000.0', 'paid' => '40000.0', 'owed' => '75000.0')
  end

  it 'renames the deliverer, changes and clears the fee while the draft is editable' do
    sale = credit_sale(store, branch, price: 100_000, cashier: cashier)
    mark_delivery(sale, deliverer: '  Lan  ', fee: '10000')
    data = mark_delivery(sale, deliverer: 'Lan', fee: '30000')['data']
    expect(data['totals']).to include('total' => '130000.0')
    expect(sale.workspace.order.reload.fees.count).to eq(1)

    data = mark_delivery(sale, deliverer: 'Lan', fee: '')['data']
    expect(data['totals']).to include('total' => '100000.0', 'fee_total' => '0.0')
    expect(data['delivery']).to include('fee' => '0.0', 'deliverer' => 'Lan')
    expect(sale.workspace.order.reload.fees).to be_empty

    mark_delivery(sale, fee: '5000')
    data = call(cashier, "workspaces/#{sale.workspace.prefixed_id}/delivery/clear", editing_body(sale))['data']
    expect(response).to have_http_status(:ok), response.body
    expect(data['delivery']).to be_nil
    expect(data['totals']).to include('total' => '100000.0')
    expect(Spree::Pos::Delivery.count).to eq(0)
  end

  it 'keeps the fee once money was taken, but still lets the deliverer change' do
    sale = credit_sale(store, branch, price: 100_000, cashier: cashier)
    mark_delivery(sale, fee: '20000')
    take_tender(sale, 'cash', 120_000)

    mark_delivery(sale, deliverer: 'Bố', fee: '30000')
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('snapshot_locked')

    data = mark_delivery(sale, deliverer: 'Lan', fee: '20000')['data']
    expect(response).to have_http_status(:ok), response.body
    expect(data['delivery']).to include('deliverer' => 'Lan', 'fee' => '20000.0')
  end

  it 'refuses an invalid fee' do
    sale = credit_sale(store, branch, price: 100_000, cashier: cashier)
    mark_delivery(sale, fee: '-5')
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('delivery_fee_invalid')
    mark_delivery(sale, fee: '100.5')
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('delivery_fee_invalid')
    expect(Spree::Pos::Delivery.count).to eq(0)
  end

  it 'marks a delivery delivered once per key, audited, and lists it under delivered today' do
    sale = credit_sale(store, branch, price: 50_000, cashier: cashier)
    mark_delivery(sale, fee: '0')
    take_tender(sale, 'cash', 50_000)
    complete(sale)
    delivery = Spree::Pos::Delivery.sole
    key = SecureRandom.uuid

    first = call(cashier, "deliveries/#{delivery.prefixed_id}/deliver", {}, key: key)['data']
    expect(response).to have_http_status(:ok), response.body
    expect(first).to include('status' => 'delivered', 'delivered_by' => Spree::Pos::StaffName.call(cashier))
    second = call(cashier, "deliveries/#{delivery.prefixed_id}/deliver", {}, key: key)['data']
    expect(second).to eq(first)
    # Another tap (new key) on a delivered row changes nothing.
    call(cashier, "deliveries/#{delivery.prefixed_id}/deliver")
    expect(response).to have_http_status(:ok)
    expect(Spree::Pos::AuditEntry.where(action: 'delivery.delivered').count).to eq(1)
    expect(delivery.reload.delivered_at).to be_present

    expect(list(cashier)['data']).to be_empty
    expect(list(cashier, status: 'delivered')['data'].sole).to include('id' => delivery.prefixed_id)
  end

  it 'puts a delivery tapped by mistake back to pending' do
    sale = credit_sale(store, branch, price: 50_000, cashier: cashier)
    mark_delivery(sale, fee: '0')
    take_tender(sale, 'cash', 50_000)
    complete(sale)
    delivery = Spree::Pos::Delivery.sole
    call(cashier, "deliveries/#{delivery.prefixed_id}/deliver")

    data = call(cashier, "deliveries/#{delivery.prefixed_id}/reopen")['data']
    expect(response).to have_http_status(:ok), response.body
    expect(data).to include('status' => 'pending', 'delivered_at' => nil)
    expect(Spree::Pos::AuditEntry.where(action: 'delivery.pending').count).to eq(1)
    expect(list(cashier)['data'].sole).to include('id' => delivery.prefixed_id)
  end

  it 'does not list or deliver a draft that is not completed' do
    sale = credit_sale(store, branch, price: 50_000, cashier: cashier)
    mark_delivery(sale)
    delivery = Spree::Pos::Delivery.sole

    call(cashier, "deliveries/#{delivery.prefixed_id}/deliver")
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('delivery_not_placed')
    expect(list(cashier)['data']).to be_empty
  end

  it 'refuses staff without a selling or collecting grant, and scopes the list to the branch' do
    sale = credit_sale(store, branch, price: 50_000, cashier: cashier)
    mark_delivery(sale, fee: '0')
    take_tender(sale, 'cash', 50_000)
    complete(sale)
    delivery = Spree::Pos::Delivery.sole

    reader = credit_staff(store, branch, [Spree::Pos::Capabilities::REPORT_READ])
    call(reader, "deliveries/#{delivery.prefixed_id}/deliver")
    expect(response).to have_http_status(:forbidden)
    expect(delivery.reload.status).to eq('pending')

    other_branch = credit_branch(store)
    outsider = credit_staff(store, other_branch, PosCreditHelpers::CASHIER)
    call(outsider, "deliveries/#{delivery.prefixed_id}/deliver")
    expect(response).to have_http_status(:forbidden)
    expect(list(outsider, branch_id: other_branch.prefixed_id)['data']).to be_empty
    list(reader)
    expect(response).to have_http_status(:forbidden)
  end

  it 'suggests the names used lately at the branch' do
    sale = credit_sale(store, branch, price: 50_000, cashier: cashier)
    mark_delivery(sale, deliverer: 'Bố', fee: '0')
    other = credit_sale(store, branch, price: 50_000)
    mark_delivery(other, deliverer: 'Lan', fee: '0')

    get '/api/v3/admin/pos/deliveries/deliverers', headers: headers(cashier), params: { branch_id: branch.prefixed_id }
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body['data']).to contain_exactly('Bố', 'Lan')
  end

  it 'refuses marking a delivery while the switch is off', pos_features: :default do
    sale = credit_sale(store, branch, price: 50_000, cashier: cashier)

    mark_delivery(sale)
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('feature_disabled')
    expect(Spree::Pos::Delivery.count).to eq(0)
    expect(sale.workspace.order.reload.fees).to be_empty
  end
end
