# frozen_string_literal: true

require 'spree/api/testing_support/v3/base'

RSpec.describe 'POS customers', type: :request do
  let(:store) { create(:store, default_currency: 'VND', supported_currencies: 'VND') }
  let(:password) { 'secret123' }
  let(:editor_id) { SecureRandom.uuid }

  before { allow(Spree::Store).to receive(:default).and_return(store) }

  def fixture(capabilities)
    user = create(:admin_user, :without_admin_role, password: password)
    role = create(:role, resource: store, permissions: %w[write_pos_orders write_pos_workspaces write_pos_shifts read_pos_orders])
    create(:role_user, user: user, role: role)
    location = create(:stock_location, store: store)
    suffix = SecureRandom.hex(4)
    branch = Spree::Pos::Branch.create!(store: store, stock_location: location, name: "B#{suffix}", code: "b#{suffix}", timezone: 'Asia/Ho_Chi_Minh', status: 'active')
    register = Spree::Pos::Register.create!(store: store, branch: branch, name: 'R', code: "r#{suffix}", status: 'active')
    Spree::Pos::StaffMembership.create!(store: store, branch: branch, staff: user, capabilities: capabilities, status: 'active')
    post '/api/v3/admin/auth/login', params: { email: user.email, password: password }, as: :json
    token = response.parsed_body.fetch('token')
    post '/api/v3/admin/pos/shifts', headers: { 'Authorization' => "Bearer #{token}" }, params: { register_id: register.prefixed_id, opening_float: '0' }, as: :json
    created = Spree::Pos::Workspaces::Create.call(store: store, staff: user, register_id: register.prefixed_id, key: SecureRandom.uuid, editor_id: editor_id)
    workspace = Spree::Pos::Workspace.find_by_prefix_id!(created['id'])
    [user, branch, workspace, token]
  end

  it 'creates a phone-only profile without a fake email, warns on duplicates and assigns it' do
    _user, branch, workspace, token = fixture([Spree::Pos::Capabilities::OPEN_SHIFT, Spree::Pos::Capabilities::CUSTOMER])
    headers = { 'Authorization' => "Bearer #{token}" }
    key = SecureRandom.uuid
    post '/api/v3/admin/pos/customers', headers: headers.merge('Idempotency-Key' => key),
      params: { branch_id: branch.prefixed_id, name: 'Lan', phone: '090 123 4567', idempotency_key: key }, as: :json
    expect(response).to have_http_status(:created)
    profile_id = response.parsed_body.dig('data', 'id')
    expect(response.parsed_body.dig('data', 'email')).to be_nil
    expect(Spree.customer_class.where(email: nil)).to be_empty

    post '/api/v3/admin/pos/customers', headers: headers.merge('Idempotency-Key' => key),
      params: { branch_id: branch.prefixed_id, name: 'Lan', phone: '090 123 4567', idempotency_key: key }, as: :json
    expect(Spree::Pos::CustomerProfile.count).to eq(1)

    key2 = SecureRandom.uuid
    post '/api/v3/admin/pos/customers', headers: headers.merge('Idempotency-Key' => key2),
      params: { branch_id: branch.prefixed_id, name: 'Lan Hai', phone: '+84 901 234 567', idempotency_key: key2 }, as: :json
    expect(response.parsed_body.dig('data', 'duplicates').size).to eq(2)

    process :post, "/api/v3/admin/pos/workspaces/#{workspace.prefixed_id}/customer", headers: headers.merge('Idempotency-Key' => SecureRandom.uuid),
      params: { expected_revision: workspace.revision, lease_generation: workspace.lease_generation, editor_id: editor_id, profile_id: profile_id }, as: :json
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.dig('data', 'customer', 'phone')).to eq('090 123 4567')
    expect(workspace.reload.pos_customer_id).to eq(Spree::Pos::CustomerProfile.find_by_prefix_id!(profile_id).id)
    expect(workspace.order.customer).to be_nil

    process :post, "/api/v3/admin/pos/workspaces/#{workspace.prefixed_id}/customer/clear", headers: headers.merge('Idempotency-Key' => SecureRandom.uuid),
      params: { expected_revision: workspace.reload.revision, lease_generation: workspace.lease_generation, editor_id: editor_id }, as: :json
    expect(response.parsed_body.dig('data', 'customer')).to be_nil

    get '/api/v3/admin/pos/customers', headers: headers, params: { branch_id: branch.prefixed_id, q: '0901234567' }, as: :json
    expect(response.parsed_body.fetch('data').size).to eq(2)
  end

  it 'denies quick create without the customer capability' do
    _user, branch, _workspace, token = fixture([Spree::Pos::Capabilities::OPEN_SHIFT])
    post '/api/v3/admin/pos/customers', headers: { 'Authorization' => "Bearer #{token}", 'Idempotency-Key' => SecureRandom.uuid },
      params: { branch_id: branch.prefixed_id, name: 'Lan', phone: '0901234567' }, as: :json
    expect(response).to have_http_status(:forbidden)
  end
end
