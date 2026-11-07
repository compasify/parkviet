# frozen_string_literal: true

require 'spree/api/testing_support/v3/base'
require_relative '../../../support/pos_return_helpers'
require_relative '../../../support/pos_trace_helpers'

# HTTP contract of serial/lot stock: who may read and change typed stock at a
# branch, recall scoped to trace holders with masked customers, the sale-line
# trace DTO and the unit configuration lock while tracked stock exists.
RSpec.describe 'POS traceability API', type: :request do
  include PosReturnHelpers
  include PosTraceHelpers

  caps = Spree::Pos::Capabilities

  let(:store) { create(:store, default_currency: 'VND', supported_currencies: 'VND') }
  let(:branch) { returns_branch(store) }
  let(:keeper) { credit_staff(store, branch, [caps::INVENTORY_MANAGE], extra_permissions: %w[write_pos_topology]) }
  let(:tracer) { credit_staff(store, branch, [caps::INVENTORY_TRACE]) }
  let(:cashier) { credit_staff(store, branch, PosReturnHelpers::RETURNS) }
  let(:product) do
    create(:product, store: store, status: 'active', name: 'Sữa').tap do |row|
      row.default_variant.set_price('VND', 30_000)
      Spree::Pos::BranchProduct.create!(branch: branch, product: row)
    end
  end
  let(:variant) { product.default_variant }

  before do
    allow(Spree::Store).to receive(:default).and_return(store)
    track_variant!(store, variant, 'lot')
  end

  def token_for(user)
    @tokens ||= {}
    @tokens[user.id] ||= begin
      post '/api/v3/admin/auth/login', params: { email: user.email, password: 'secret123' }, as: :json
      response.parsed_body.fetch('token')
    end
  end

  def call(user, verb, path, body = {})
    key = SecureRandom.uuid
    send(verb, "/api/v3/admin/pos/#{path}", headers: { 'Authorization' => "Bearer #{token_for(user)}", 'Idempotency-Key' => key },
                                            params: verb == :get ? body : body.merge(idempotency_key: key), as: verb == :get ? nil : :json)
    response.parsed_body
  end

  it 'opens, receives and lists lots only for inventory managers of the branch' do
    branch.stock_location.restock(variant, 4)
    body = { branch_id: branch.prefixed_id, variant_id: variant.prefixed_id,
             lots: [{ lot_code: 'A1', expiry_on: (Date.current + 9).iso8601, quantity: 4 }] }
    call(cashier, :post, 'inventory/opening_balances', body)
    expect(response).to have_http_status(:forbidden)
    call(keeper, :post, 'inventory/opening_balances', body.merge(lots: [{ lot_code: 'A1', quantity: 3 }]))
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('opening_unreconciled')
    data = call(keeper, :post, 'inventory/opening_balances', body)['data']
    expect(response).to have_http_status(:created)
    expect(data).to include('enrolled' => true, 'reconciled' => true, 'core_on_hand' => 4, 'typed_on_hand' => 4)

    call(keeper, :post, 'inventory/receipts', branch_id: branch.prefixed_id, variant_id: variant.prefixed_id,
                                              lots: [{ lot_code: 'B2', expiry_on: (Date.current + 30).iso8601, quantity: 2 }])
    expect(response).to have_http_status(:created)

    lots = call(tracer, :get, 'lots', branch_id: branch.prefixed_id)['data']
    expect(lots.map { |lot| [lot['lot_code'], lot['available'], lot['status']] }).to eq([['A1', 4, 'active'], ['B2', 2, 'active']])
    call(cashier, :get, 'lots', branch_id: branch.prefixed_id)
    expect(response).to have_http_status(:forbidden)
    call(tracer, :post, "lots/#{Spree::Pos::InventoryLot.find_by!(lot_code: 'A1').prefixed_id}/quarantine", reason: 'Thu hồi')
    expect(response).to have_http_status(:forbidden)
    quarantined = call(keeper, :post, "lots/#{Spree::Pos::InventoryLot.find_by!(lot_code: 'A1').prefixed_id}/quarantine", reason: 'Thu hồi')['data']
    expect(quarantined).to include('status' => 'quarantined', 'quarantine_reason' => 'Thu hồi')

    status = call(cashier, :get, 'traceability', branch_id: branch.prefixed_id, variant_id: variant.prefixed_id)['data']
    expect(status).to include('tracked_mode' => 'lot', 'sellable' => true, 'blocked_reason' => nil)
    expect(status).not_to have_key('reservation')
    expect(status['lots'].map { |lot| lot['lot_code'] }).to eq(['B2'])
    variants = call(keeper, :get, 'inventory/variants', branch_id: branch.prefixed_id)['data']
    expect(variants.map { |row| row['variant_id'] }).to eq([variant.prefixed_id])

    put '/api/v3/admin/pos/units/variant', headers: { 'Authorization' => "Bearer #{token_for(keeper)}" },
                                           params: { branch_id: branch.prefixed_id, variant_id: variant.prefixed_id, sale_unit: 'item',
                                                     tracked_mode: 'serial' }, as: :json
    expect(response).to have_http_status(:forbidden)
  end

  it 'lets every inventory command be recovered from its command receipt' do
    target = returns_branch(store)
    Spree::Pos::BranchProduct.create!(branch: target, product: product)
    Spree::Pos::StaffMembership.create!(store: store, branch: target, staff: keeper, capabilities: [caps::INVENTORY_MANAGE], status: 'active')
    branch.stock_location.restock(variant, 2)
    commands = {
      'inventory/opening_balances' => { branch_id: branch.prefixed_id, variant_id: variant.prefixed_id,
                                        lots: [{ lot_code: 'C1', expiry_on: (Date.current + 9).iso8601, quantity: 2 }] },
      'inventory/receipts' => { branch_id: branch.prefixed_id, variant_id: variant.prefixed_id,
                                lots: [{ lot_code: 'C2', expiry_on: (Date.current + 19).iso8601, quantity: 3 }] }
    }
    recover = lambda do |key|
      get '/api/v3/admin/pos/command_receipts', headers: { 'Authorization' => "Bearer #{token_for(keeper)}" }, params: { idempotency_key: key }
      expect(response).to have_http_status(:ok)
      response.parsed_body['data']
    end
    send_with_key = lambda do |path, body|
      key = SecureRandom.uuid
      post("/api/v3/admin/pos/#{path}", headers: { 'Authorization' => "Bearer #{token_for(keeper)}", 'Idempotency-Key' => key },
                                        params: body.merge(idempotency_key: key), as: :json)
      expect(response.status).to be_between(200, 201)
      [key, response.parsed_body['data']]
    end
    commands.each do |path, body|
      key, data = send_with_key.call(path, body)
      expect(data['branch_id']).to eq(branch.prefixed_id)
      expect(recover.call(key)).to eq(data)
    end
    call(keeper, :post, 'inventory/opening_balances', branch_id: target.prefixed_id, variant_id: variant.prefixed_id, lots: [])
    lot = Spree::Pos::InventoryLot.find_by!(lot_code: 'C2', stock_location_id: branch.stock_location_id)
    key, data = send_with_key.call('inventory/transfers', from_branch_id: branch.prefixed_id, to_branch_id: target.prefixed_id,
                                                          variant_id: variant.prefixed_id, lots: [{ lot_id: lot.prefixed_id, quantity: 1 }])
    expect(recover.call(key)).to eq(data)
    expect(data['branch_id']).to eq(branch.prefixed_id)
    key, data = send_with_key.call('inventory/adjustments', branch_id: branch.prefixed_id, variant_id: variant.prefixed_id, reason: 'Kiểm kê',
                                                            lots: [{ lot_id: lot.prefixed_id, counted: 1 }])
    expect(recover.call(key)).to eq(data)
    key, data = send_with_key.call("lots/#{lot.prefixed_id}/quarantine", reason: 'Thu hồi')
    expect(recover.call(key)).to eq(data)
    expect(data['branch_id']).to eq(branch.prefixed_id)

    call(keeper, :post, 'inventory/adjustments', branch_id: branch.prefixed_id, variant_id: variant.prefixed_id, reason: 'Kiểm kê',
                                                 lots: [{ lot_id: lot.prefixed_id, counted: lot.reload.on_hand }])
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('count_no_change')
    data = call(tracer, :get, 'inventory/recall', lot_code: 'C2', limit: 1)
    expect(data['meta']).to include('page' => 1, 'limit' => 1, 'truncated' => false)
    expect(data['data']['lots'].map { |row| row['variant_id'] }).to all(eq(variant.prefixed_id))
  end

  it 'locks the unit configuration while tracked stock exists' do
    manager = credit_staff(store, branch, [caps::MANAGE, caps::INVENTORY_MANAGE], extra_permissions: %w[write_pos_topology])
    enroll_lots!(branch, variant, [['A', nil, 2]], opened_by: manager)
    put '/api/v3/admin/pos/units/variant', headers: { 'Authorization' => "Bearer #{token_for(manager)}" },
                                           params: { branch_id: branch.prefixed_id, variant_id: variant.prefixed_id, sale_unit: 'item',
                                                     tracked_mode: 'none' }, as: :json
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('trace_stock_exists')
    put '/api/v3/admin/pos/units/variant', headers: { 'Authorization' => "Bearer #{token_for(manager)}" },
                                           params: { branch_id: branch.prefixed_id, variant_id: variant.prefixed_id, sale_unit: 'item',
                                                     tracked_mode: 'serial_lot' }, as: :json
    expect(response).to have_http_status(:conflict)
  end

  it 'scopes recall to trace holders and masks customer phones' do
    enroll_lots!(branch, variant, [['R1', Date.current + 9, 5]], opened_by: keeper)
    profile = credit_customer(store, cashier, name: 'Chi Hoa')
    sale = open_sale(store, branch, cashier: cashier, product: product, quantity: 2)
    assign(sale, profile)
    complete_paid(sale)
    hand_over(sale)

    call(cashier, :get, 'inventory/recall', lot_code: 'R1')
    expect(response).to have_http_status(:forbidden)
    data = call(tracer, :get, 'inventory/recall', lot_code: 'R1')['data']
    expect(data['lots'].map { |lot| lot['on_hand'] }).to eq([3])
    sold = data['sales'].sole
    expect(sold).to include('order_number' => sale.workspace.order.number, 'quantity' => 2, 'lot_code' => 'R1', 'status' => 'consumed')
    expect(sold['customer']['name']).to eq('Chi Hoa')
    expect(sold['customer']['phone']).to start_with('•')
    expect(sold['customer']['phone']).to end_with(profile.phone[-3..])

    other = returns_branch(store)
    outsider = credit_staff(store, other, [caps::INVENTORY_TRACE])
    expect(call(outsider, :get, 'inventory/recall', lot_code: 'R1')['data']['sales']).to eq([])
    call(tracer, :get, 'inventory/recall', lot_code: 'R1', serial: 'X')
    expect(response).to have_http_status(:conflict)
  end

  it 'shows the FEFO plan on the sale line, reserves it on request and asks approval for a negative count' do
    enroll_lots!(branch, variant, [['L1', Date.current + 3, 1], ['L2', Date.current + 8, 5]], opened_by: keeper)
    sale = open_sale(store, branch, cashier: cashier, product: product, quantity: 2)
    line = sale.workspace.reload.to_pos[:line_items].first
    expect(line[:trace]).to include(mode: 'lot', complete: false, issue: nil)
    expect(line[:trace][:preview].map { |row| [row[:lot_code], row[:quantity]] }).to eq([['L1', 1], ['L2', 1]])

    workspace = sale.workspace.reload
    data = call(cashier, :post, "workspaces/#{workspace.prefixed_id}/trace_allocations",
                expected_revision: workspace.revision, lease_generation: workspace.lease_generation, editor_id: sale.editor_id)['data']
    expect(response).to have_http_status(:ok)
    expect(data['trace']).to eq('ready' => true, 'issues' => [])
    expect(data['line_items'].first['trace']['allocations'].map { |row| [row['lot_code'], row['status']] }).to eq([%w[L1 reserved], %w[L2 reserved]])

    lot = Spree::Pos::InventoryLot.find_by!(lot_code: 'L2')
    adjustment = call(keeper, :post, 'inventory/adjustments', branch_id: branch.prefixed_id, variant_id: variant.prefixed_id,
                                                              reason: 'Vỡ', lots: [{ lot_id: lot.prefixed_id, counted: 4 }])['data']
    expect(adjustment).to include('status' => 'pending_approval', 'delta' => -1)
    pending = call(keeper, :get, 'inventory/adjustments', branch_id: branch.prefixed_id, status: 'pending_approval')['data']
    expect(pending.map { |row| row['id'] }).to eq([adjustment['id']])
    call(keeper, :post, "inventory/adjustments/#{adjustment['id']}/approve")
    expect(response).to have_http_status(:forbidden)
    approver = credit_staff(store, branch, [caps::APPROVE, caps::INVENTORY_MANAGE])
    call(approver, :post, "inventory/adjustments/#{adjustment['id']}/approve")
    expect(response).to have_http_status(:ok)
    applied = call(keeper, :post, "inventory/adjustments/#{adjustment['id']}/apply")['data']
    expect(applied['status']).to eq('applied')
    expect(lot.reload.on_hand).to eq(4)
  end
end
