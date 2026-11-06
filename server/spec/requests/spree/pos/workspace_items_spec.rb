# frozen_string_literal: true

require 'spree/api/testing_support/v3/base'

RSpec.describe 'POS workspace items', type: :request do
  let(:store) { create(:store, default_currency: 'VND', supported_currencies: 'VND') }
  let(:password) { 'secret123' }
  let(:editor_id) { SecureRandom.uuid }

  before { allow(Spree::Store).to receive(:default).and_return(store) }

  def setup_workspace
    user = create(:admin_user, :without_admin_role, password: password)
    role = create(:role, resource: store, permissions: %w[write_pos_orders write_pos_workspaces write_pos_shifts])
    create(:role_user, user: user, role: role)
    location = create(:stock_location, store: store)
    suffix = SecureRandom.hex(4)
    branch = Spree::Pos::Branch.create!(store: store, stock_location: location, name: "B#{suffix}", code: "b#{suffix}", timezone: 'Asia/Ho_Chi_Minh', status: 'active')
    register = Spree::Pos::Register.create!(store: store, branch: branch, name: 'R', code: "r#{suffix}", status: 'active')
    Spree::Pos::StaffMembership.create!(store: store, branch: branch, staff: user, capabilities: [Spree::Pos::Capabilities::OPEN_SHIFT, Spree::Pos::Capabilities::DISCOUNT], status: 'active')
    post '/api/v3/admin/auth/login', params: { email: user.email, password: password }, as: :json
    token = response.parsed_body.fetch('token')
    post '/api/v3/admin/pos/shifts', headers: { 'Authorization' => "Bearer #{token}" }, params: { register_id: register.prefixed_id, opening_float: '0' }, as: :json
    created = Spree::Pos::Workspaces::Create.call(store: store, staff: user, register_id: register.prefixed_id, key: SecureRandom.uuid, editor_id: editor_id)
    workspace = Spree::Pos::Workspace.find_by_prefix_id!(created['id'])
    product = create(:product, store: store, status: 'active', name: 'Ao')
    product.default_variant.set_price('VND', 100)
    Spree::Pos::BranchProduct.create!(branch: branch, product: product)
    [user, branch, workspace, product, token]
  end

  it 'adds, updates, removes and recalculates a POS percentage discount by line ID' do
    _user, _branch, workspace, product, token = setup_workspace
    headers = { 'Authorization' => "Bearer #{token}" }
    base = { expected_revision: 0, lease_generation: workspace.lease_generation, editor_id: editor_id }
    key = SecureRandom.uuid
    post "/api/v3/admin/pos/workspaces/#{workspace.prefixed_id}/items", headers: headers.merge('Idempotency-Key' => key),
      params: base.merge(variant_id: product.default_variant.prefixed_id, quantity: 1, idempotency_key: key), as: :json
    expect(response).to have_http_status(:ok)
    line_id = response.parsed_body.dig('data', 'line_items', 0, 'id')
    expect(response.parsed_body.dig('data', 'totals', 'total')).to eq('100.0')

    post "/api/v3/admin/pos/workspaces/#{workspace.prefixed_id}/items", headers: headers.merge('Idempotency-Key' => key),
      params: base.merge(variant_id: product.default_variant.prefixed_id, quantity: 1, idempotency_key: key), as: :json
    expect(workspace.order.line_items.count).to eq(1)

    discount_key = SecureRandom.uuid
    post "/api/v3/admin/pos/workspaces/#{workspace.prefixed_id}/discount", headers: headers.merge('Idempotency-Key' => discount_key),
      params: { expected_revision: 1, lease_generation: workspace.lease_generation, editor_id: editor_id,
                value_type: 'percent', value: '10', reason: 'Test', idempotency_key: discount_key }, as: :json
    expect(response.parsed_body.dig('data', 'totals', 'total')).to eq('90.0')

    post "/api/v3/admin/pos/workspaces/#{workspace.prefixed_id}/items/#{line_id}/update", headers: headers.merge('Idempotency-Key' => SecureRandom.uuid),
      params: { expected_revision: 2, lease_generation: workspace.lease_generation, editor_id: editor_id, quantity: 2 }, as: :json
    expect(response.parsed_body.dig('data', 'totals', 'total')).to eq('180.0')

    post "/api/v3/admin/pos/workspaces/#{workspace.prefixed_id}/items/#{line_id}/remove", headers: headers.merge('Idempotency-Key' => SecureRandom.uuid),
      params: { expected_revision: 3, lease_generation: workspace.lease_generation, editor_id: editor_id }, as: :json
    expect(response.parsed_body.dig('data', 'line_items')).to eq([])
    expect(response.parsed_body.dig('data', 'totals', 'total')).to eq('0.0')
  end

  it 'rejects variants outside the branch assortment' do
    _user, _branch, workspace, _product, token = setup_workspace
    other = create(:product, store: store, status: 'active')
    other.default_variant.set_price('VND', 100)
    post "/api/v3/admin/pos/workspaces/#{workspace.prefixed_id}/items", headers: { 'Authorization' => "Bearer #{token}", 'Idempotency-Key' => SecureRandom.uuid },
      params: { expected_revision: 0, lease_generation: workspace.lease_generation, editor_id: editor_id,
                variant_id: other.default_variant.prefixed_id, quantity: 1 }, as: :json
    expect(response).to have_http_status(:not_found)
    expect(workspace.order.line_items).to be_empty
  end
end
