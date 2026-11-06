# frozen_string_literal: true

require 'spree/api/testing_support/v3/base'

# Phase 6 sandbox gates: F01 split tender/cash change, allocation conservation,
# liability payout reservation, tracked-SKU tender guard, guarded completion.
RSpec.describe 'POS split tender and settlement (phase 6 sandbox)', type: :request do
  let(:store) { create(:store, default_currency: 'VND', supported_currencies: 'VND') }
  let(:password) { 'secret123' }
  let(:editor_id) { SecureRandom.uuid }

  before { allow(Spree::Store).to receive(:default).and_return(store) }

  CAPS = [Spree::Pos::Capabilities::OPEN_SHIFT, Spree::Pos::Capabilities::PAYMENT,
          Spree::Pos::Capabilities::RESOLVE, Spree::Pos::Capabilities::APPROVE, Spree::Pos::Capabilities::MANAGE].freeze

  def setup_workspace(price: 250, capabilities: CAPS)
    user = create(:admin_user, :without_admin_role, password: password)
    role = create(:role, resource: store, permissions: %w[write_pos_orders write_pos_workspaces write_pos_shifts write_pos_topology])
    create(:role_user, user: user, role: role)
    location = create(:stock_location, store: store, backorderable_default: false)
    suffix = SecureRandom.hex(4)
    branch = Spree::Pos::Branch.create!(store: store, stock_location: location, name: "B#{suffix}", code: "b#{suffix}", timezone: 'Asia/Ho_Chi_Minh', status: 'active')
    register = Spree::Pos::Register.create!(store: store, branch: branch, name: 'R', code: "r#{suffix}", status: 'active')
    Spree::Pos::StaffMembership.create!(store: store, branch: branch, staff: user, capabilities: capabilities, status: 'active')
    create(:check_payment_method, store: store, name: "Bank transfer #{suffix}", active: true)
    location.restock(create(:product, store: store).default_variant, 0) rescue nil
    post '/api/v3/admin/auth/login', params: { email: user.email, password: password }, as: :json
    token = response.parsed_body.fetch('token')
    post '/api/v3/admin/pos/shifts', headers: { 'Authorization' => "Bearer #{token}" }, params: { register_id: register.prefixed_id, opening_float: '0' }, as: :json
    created = Spree::Pos::Workspaces::Create.call(store: store, staff: user, register_id: register.prefixed_id, key: SecureRandom.uuid, editor_id: editor_id)
    workspace = Spree::Pos::Workspace.find_by_prefix_id!(created['id'])
    product = create(:product, store: store, status: 'active', name: 'Ao')
    product.default_variant.set_price('VND', price)
    Spree::Pos::BranchProduct.create!(branch: branch, product: product)
    branch.stock_location.restock(product.default_variant, 10)
    [user, branch, workspace, product, token]
  end

  def headers(token, key = SecureRandom.uuid)
    { 'Authorization' => "Bearer #{token}", 'Idempotency-Key' => key }
  end

  def add_item(workspace, token, revision, variant_id, quantity = 1)
    key = SecureRandom.uuid
    post "/api/v3/admin/pos/workspaces/#{workspace.prefixed_id}/items", headers: headers(token, key),
      params: { expected_revision: revision, lease_generation: workspace.lease_generation, editor_id: editor_id,
                variant_id: variant_id, quantity: quantity, merge: true, idempotency_key: key }, as: :json
    expect(response).to have_http_status(:ok)
    response.parsed_body.fetch('data')
  end

  def methods(workspace, token)
    get "/api/v3/admin/pos/workspaces/#{workspace.prefixed_id}/payment_methods", headers: headers(token), as: :json
    expect(response).to have_http_status(:ok)
    response.parsed_body.fetch('data')
  end

  def prepare(workspace, token, revision, method_id, amount, key: SecureRandom.uuid)
    post "/api/v3/admin/pos/workspaces/#{workspace.prefixed_id}/tender_attempts", headers: headers(token, key),
      params: { expected_revision: revision, lease_generation: workspace.lease_generation, editor_id: editor_id,
                payment_method_id: method_id, amount: amount.to_s, idempotency_key: key }, as: :json
    response.parsed_body.fetch('data')
  end

  def attempt_at(workspace, token, index = -1)
    get "/api/v3/admin/pos/workspaces/#{workspace.prefixed_id}", headers: headers(token), as: :json
    response.parsed_body.dig('data', 'financial', 'attempts')[index]
  end

  def confirm(workspace, token, revision, attempt_id, key: SecureRandom.uuid, **attrs)
    post "/api/v3/admin/pos/workspaces/#{workspace.prefixed_id}/tender_attempts/#{attempt_id}/confirm",
      headers: headers(token, key),
      params: { expected_revision: revision, lease_generation: workspace.lease_generation, editor_id: editor_id,
                idempotency_key: key }.merge(attrs), as: :json
    response.parsed_body.fetch('data')
  end

  it 'F01: cash handed 200 change 50 on a 150 remainder -> Payment 150, drawer +150, duplicate confirm does not double' do
    _user, _branch, workspace, product, token = setup_workspace(price: 250)
    add_item(workspace, token, 0, product.default_variant.prefixed_id)
    list = methods(workspace, token)
    cash = list.find { |row| row['kind'] == 'cash' }
    bank = list.find { |row| row['kind'] == 'bank_manual' }
    expect(cash).to be_present
    expect(bank).to be_present

    prepare(workspace, token, 1, bank['id'], 100)
    expect(response).to have_http_status(:ok)
    confirm(workspace, token, 2, attempt_at(workspace, token)['id'], evidence_kind: 'bank_manual', reference: 'FT001', receiving_account: 'VCB-123')
    expect(response).to have_http_status(:ok)

    prepare(workspace, token, 3, cash['id'], 150)
    attempt_id = attempt_at(workspace, token)['id']
    data = confirm(workspace, token, 4, attempt_id, evidence_kind: 'cash_count', handed_amount: '200')
    expect(response).to have_http_status(:ok)
    financial = data['financial']
    expect(financial['received']).to eq('250.0')
    expect(financial['allocated']).to eq('250.0')
    expect(financial['change_due']).to eq('50.0')
    expect(financial['remaining']).to eq('0.0')

    order = workspace.reload.order
    expect(order.payments.completed.sum(:amount)).to eq(BigDecimal('250'))
    expect(order.payments.completed.count).to eq(2)
    drawer = Spree::Pos::CashMovement.where(shift: workspace.shift, kind: 'receipt').sum(:amount)
    expect(drawer).to eq(BigDecimal('150'))

    # Duplicate confirm with the same intent (new key, same payload except
    # revision advanced by the first confirm): replaying must not double
    # money — the attempt is already confirmed, so it conflicts cleanly.
    post "/api/v3/admin/pos/workspaces/#{workspace.prefixed_id}/tender_attempts/#{attempt_id}/confirm",
      headers: headers(token), params: { expected_revision: 5, lease_generation: workspace.lease_generation,
        editor_id: editor_id, evidence_kind: 'cash_count', handed_amount: '200' }, as: :json
    expect(response).to have_http_status(:conflict)
    expect(order.reload.payments.completed.count).to eq(2)
  end

  it 'locks items after prepare, refuses tracked tender, and completes + hands over only with completed receipts' do
    user, branch, workspace, product, token = setup_workspace(price: 100)
    add_item(workspace, token, 0, product.default_variant.prefixed_id)
    cash = methods(workspace, token).find { |row| row['kind'] == 'cash' }

    # Completion before any receipt is refused.
    key = SecureRandom.uuid
    post "/api/v3/admin/pos/workspaces/#{workspace.prefixed_id}/complete", headers: headers(token, key),
      params: { expected_revision: 1, lease_generation: workspace.lease_generation, editor_id: editor_id, idempotency_key: key }, as: :json
    expect(response).to have_http_status(:conflict)
    expect(workspace.reload.order).not_to be_placed

    prepare(workspace, token, 1, cash['id'], 100)
    # Snapshot locked while prepared.
    post_item_status = nil
    key2 = SecureRandom.uuid
    post "/api/v3/admin/pos/workspaces/#{workspace.prefixed_id}/items", headers: headers(token, key2),
      params: { expected_revision: 2, lease_generation: workspace.lease_generation, editor_id: editor_id,
                variant_id: product.default_variant.prefixed_id, quantity: 1, idempotency_key: key2 }, as: :json
    expect(response).to have_http_status(:conflict)

    confirm(workspace, token, 2, attempt_at(workspace, token)['id'], evidence_kind: 'cash_count', handed_amount: '100')
    key3 = SecureRandom.uuid
    post "/api/v3/admin/pos/workspaces/#{workspace.prefixed_id}/complete", headers: headers(token, key3),
      params: { expected_revision: 3, lease_generation: workspace.lease_generation, editor_id: editor_id, idempotency_key: key3 }, as: :json
    expect(response).to have_http_status(:ok)
    expect(workspace.reload.operational_status).to eq('completed')
    expect(workspace.order.placed?).to be(true)

    level = branch.stock_location.stock_level(product.default_variant).reload
    expect(level.allocated_count).to eq(1)

    key4 = SecureRandom.uuid
    post "/api/v3/admin/pos/workspaces/#{workspace.prefixed_id}/handover", headers: headers(token, key4),
      params: { idempotency_key: key4 }, as: :json
    expect(response).to have_http_status(:ok)
    level = branch.stock_location.stock_level(product.default_variant).reload
    expect(level.count_on_hand).to eq(9)
    expect(level.allocated_count).to eq(0)
  end

  it 'refuses tender for tracked (serial) goods before any money is taken' do
    _user, branch, workspace, product, token = setup_workspace(price: 100)
    headers_h = { 'Authorization' => "Bearer #{token}" }
    put '/api/v3/admin/pos/units/variant', headers: headers_h,
      params: { branch_id: branch.prefixed_id, variant_id: product.default_variant.prefixed_id,
                sale_unit: 'item', base_unit: 'item', price_unit: 'item', tracked_mode: 'lot' }, as: :json
    expect(response).to have_http_status(:ok)
    key = SecureRandom.uuid
    post "/api/v3/admin/pos/workspaces/#{workspace.prefixed_id}/items", headers: headers(token, key),
      params: { expected_revision: 0, lease_generation: workspace.lease_generation, editor_id: editor_id,
                variant_id: product.default_variant.prefixed_id, quantity: 1, serial_codes: ['SN-1'], idempotency_key: key }, as: :json
    expect(response).to have_http_status(:ok)

    cash = methods(workspace, token).find { |row| row['kind'] == 'cash' }
    key2 = SecureRandom.uuid
    post "/api/v3/admin/pos/workspaces/#{workspace.prefixed_id}/tender_attempts", headers: headers(token, key2),
      params: { expected_revision: 1, lease_generation: workspace.lease_generation, editor_id: editor_id,
                payment_method_id: cash['id'], amount: '100', idempotency_key: key2 }, as: :json
    expect(response).to have_http_status(:conflict)
    expect(Spree::Pos::ReceivedFunds.where(workspace: workspace)).to be_empty
  end

  it 'keeps excess as unapplied liability, reserves payout, blocks double-spend, and pays out with evidence' do
    _user, _branch, workspace, product, token = setup_workspace(price: 100)
    add_item(workspace, token, 0, product.default_variant.prefixed_id)
    cash = methods(workspace, token).find { |row| row['kind'] == 'cash' }
    prepare(workspace, token, 1, cash['id'], 100)
    data = confirm(workspace, token, 2, attempt_at(workspace, token)['id'], evidence_kind: 'cash_count', handed_amount: '100')
    expect(data['financial']['allocated']).to eq('100.0')

    # Unsolicited extra 40 arrives: posted as attention liability, not a Payment.
    key = SecureRandom.uuid
    post '/api/v3/admin/pos/received_funds', headers: headers(token, key),
      params: { branch_id: workspace.branch.prefixed_id, shift_id: workspace.shift.prefixed_id, kind: 'bank_manual',
                handed_amount: '40', reference: 'FT-LATE', workspace_id: workspace.prefixed_id, idempotency_key: key }, as: :json
    expect(response).to have_http_status(:created)
    funds_id = response.parsed_body.dig('data', 'id')
    expect(response.parsed_body.dig('data', 'available')).to eq('40.0')
    expect(workspace.order.reload.payments.count).to eq(1)

    # Reserve 40 for payout; a second payout of 40 must fail (no double spend).
    key2 = SecureRandom.uuid
    post "/api/v3/admin/pos/received_funds/#{funds_id}/payouts", headers: headers(token, key2),
      params: { amount: '40', beneficiary_name: 'Khach A', reason: 'Thua chuyen khoan', idempotency_key: key2 }, as: :json
    expect(response).to have_http_status(:created)
    payout_id = response.parsed_body.dig('data', 'id')
    key3 = SecureRandom.uuid
    post "/api/v3/admin/pos/received_funds/#{funds_id}/payouts", headers: headers(token, key3),
      params: { amount: '40', beneficiary_name: 'Khach A', reason: 'Trung', idempotency_key: key3 }, as: :json
    expect(response).to have_http_status(:conflict)

    # Unknown keeps the reservation.
    key4 = SecureRandom.uuid
    post "/api/v3/admin/pos/received_funds/#{funds_id}/payouts/#{payout_id}/resolve", headers: headers(token, key4),
      params: { outcome: 'unknown', idempotency_key: key4 }, as: :json
    expect(response).to have_http_status(:ok)
    get "/api/v3/admin/pos/received_funds/#{funds_id}", headers: headers(token), as: :json
    expect(response.parsed_body.dig('data', 'available')).to eq('0.0')
    expect(response.parsed_body.dig('data', 'payout_reserved')).to eq('40.0')

    # Confirm payout with bank evidence.
    key5 = SecureRandom.uuid
    post "/api/v3/admin/pos/received_funds/#{funds_id}/payouts/#{payout_id}/confirm", headers: headers(token, key5),
      params: { evidence_kind: 'bank_manual', reference: 'FT-OUT', idempotency_key: key5 }, as: :json
    expect(response).to have_http_status(:ok)
    get "/api/v3/admin/pos/received_funds/#{funds_id}", headers: headers(token), as: :json
    expect(response.parsed_body.dig('data', 'paid_out')).to eq('40.0')
    expect(response.parsed_body.dig('data', 'available')).to eq('0.0')
  end

  it 'allocates unapplied funds to a later workspace and reverses before placement' do
    user, branch, workspace, product, token = setup_workspace(price: 100)
    add_item(workspace, token, 0, product.default_variant.prefixed_id)

    key = SecureRandom.uuid
    post '/api/v3/admin/pos/received_funds', headers: headers(token, key),
      params: { branch_id: branch.prefixed_id, shift_id: workspace.shift.prefixed_id, kind: 'bank_manual',
                handed_amount: '100', reference: 'FT-EARLY', workspace_id: workspace.prefixed_id, idempotency_key: key }, as: :json
    funds_id = response.parsed_body.dig('data', 'id')

    key2 = SecureRandom.uuid
    post "/api/v3/admin/pos/workspaces/#{workspace.prefixed_id}/funds/allocate", headers: headers(token, key2),
      params: { expected_revision: 1, lease_generation: workspace.lease_generation, editor_id: editor_id,
                funds_id: funds_id, amount: '100', idempotency_key: key2 }, as: :json
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.dig('data', 'financial', 'allocated')).to eq('100.0')
    allocation_id = Spree::Pos::FundsAllocation.find_by(workspace: workspace, status: 'active').prefixed_id

    key3 = SecureRandom.uuid
    post "/api/v3/admin/pos/workspaces/#{workspace.prefixed_id}/funds/reverse", headers: headers(token, key3),
      params: { expected_revision: 2, lease_generation: workspace.lease_generation, editor_id: editor_id,
                allocation_id: allocation_id, idempotency_key: key3 }, as: :json
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.dig('data', 'financial', 'allocated')).to eq('0.0')
    expect(Spree::Pos::FundsAllocation.find_by(workspace: workspace).status).to eq('reversed')
    expect(workspace.order.reload.payments.where(status: 'completed')).to be_empty
  end
end
