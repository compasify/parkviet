# frozen_string_literal: true

require 'spree/api/testing_support/v3/base'

RSpec.describe 'POS staff context', type: :request do
  let(:store) { Spree::Store.default }
  let(:password) { 'secret123' }
  let(:login_path) { '/api/v3/admin/auth/login' }
  let(:context_path) { '/api/v3/admin/pos/context' }

  def login_as(user)
    post login_path, params: { email: user.email, password: password }, as: :json
    expect(response).to have_http_status(:ok)
    response.parsed_body.fetch('token')
  end

  def staff_with(permissions, target_store = store)
    user = create(:admin_user, :without_admin_role, password: password)
    role = create(:role, resource: target_store, permissions: permissions)
    create(:role_user, user: user, role: role)
    user
  end

  it 'pages and searches only branches and registers visible to the staff member' do
    user = staff_with(%w[read_pos_orders])
    location = create(:stock_location, store: store)
    first = Spree::Pos::Branch.create!(store: store, stock_location: location, name: 'Alpha', code: 'alpha', timezone: 'Asia/Ho_Chi_Minh', status: 'active')
    second = Spree::Pos::Branch.create!(store: store, stock_location: location, name: 'Beta', code: 'beta', timezone: 'Asia/Ho_Chi_Minh', status: 'active')
    [first, second].each do |branch|
      Spree::Pos::StaffMembership.create!(store: store, branch: branch, staff: user, capabilities: [], status: 'active')
    end
    register = Spree::Pos::Register.create!(store: store, branch: second, name: 'Counter Beta', code: 'counter', status: 'active')
    headers = { 'Authorization' => "Bearer #{login_as(user)}" }
    get '/api/v3/admin/pos/context/branches', headers: headers, params: { page: 2, limit: 1 }, as: :json
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.dig('data', 0, 'id')).to eq(second.prefixed_id)
    get '/api/v3/admin/pos/context/registers', headers: headers, params: { branch_id: second.prefixed_id, q: 'Counter' }, as: :json
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.dig('data', 0, 'id')).to eq(register.prefixed_id)
    outsider = staff_with(%w[read_pos_orders])
    get '/api/v3/admin/pos/context/registers', headers: { 'Authorization' => "Bearer #{login_as(outsider)}" }, params: { branch_id: second.prefixed_id }, as: :json
    expect(response).to have_http_status(:not_found)
  end

  it 'rejects a request with no credentials' do
    get context_path, as: :json

    expect(response).to have_http_status(:unauthorized)
  end

  it 'rejects a customer JWT because the audience is not admin' do
    token = Spree::Api::V3::TestingSupport.generate_jwt(create(:customer))

    get context_path, headers: { 'Authorization' => "Bearer #{token}" }, as: :json

    expect(response).to have_http_status(:unauthorized)
  end

  it 'rejects a cross-origin request that only presents the refresh cookie' do
    login_as(staff_with(%w[read_pos_orders]))
    get context_path, headers: { 'Origin' => 'https://evil.example' }, as: :json

    expect(response).to have_http_status(:unauthorized)
    expect(response.headers['Access-Control-Allow-Origin']).not_to eq('https://evil.example')
    expect(response.parsed_body).not_to have_key('staff')
  end

  it 'rejects an access token after the staff account is deactivated' do
    user = staff_with(%w[read_pos_orders])
    token = login_as(user)
    user.deactivate!

    get context_path, headers: { 'Authorization' => "Bearer #{token}" }, as: :json

    expect(response).to have_http_status(:unauthorized)
  end

  it 'rejects store staff who do not hold the POS permission' do
    token = login_as(staff_with(%w[read_orders]))

    get context_path, headers: { 'Authorization' => "Bearer #{token}" }, as: :json

    expect(response).to have_http_status(:forbidden)
    expect(response.parsed_body.dig('error', 'details', 'required_permission')).to eq('read_pos_orders')
    expect(response.parsed_body).not_to have_key('staff')
  end

  it 'returns an empty capability set for staff who can read POS drafts' do
    user = staff_with(%w[read_pos_orders])
    token = login_as(user)

    get context_path, headers: { 'Authorization' => "Bearer #{token}" }, as: :json

    expect(response).to have_http_status(:ok)
    body = response.parsed_body
    expect(body.keys).to contain_exactly(
        'staff', 'store', 'capabilities', 'features', 'modules', 'module_usage', 'profile', 'einvoice_type', 'onboarding', 'branches', 'registers', 'shift',
        'selection', 'administration', 'sales_channel'
    )
    expect(body['staff']).to eq(
      'id' => user.prefixed_id,
      'email' => user.email,
      'full_name' => user.full_name
    )
    expect(body['store']).to include(
      'id' => store.prefixed_id,
      'name' => store.name,
      'currency' => store.default_currency,
      'locale' => store.default_locale
    )
    expect(body['store']).to have_key('timezone')
    expect(body['capabilities']).to eq([])
    expect(body['branches']).to eq([])
    expect(body['registers']).to eq([])
    expect(body['shift']).to be_nil
    expect(body['selection']).to eq('branch_id' => nil, 'register_id' => nil)
    expect(body.to_json).not_to include('permission_keys', 'setup_token', 'write_orders')
  end

  it 'treats write_pos_orders as sufficient to read context and still blocks core order writes' do
    user = staff_with(%w[write_pos_orders])
    token = login_as(user)
    headers = { 'Authorization' => "Bearer #{token}" }

    get context_path, headers: headers, as: :json
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body['capabilities']).to eq([])

    post '/api/v3/admin/orders', headers: headers, params: { order: {} }, as: :json
    expect(response).to have_http_status(:forbidden)
    expect(response.parsed_body.dig('error', 'details', 'required_permission')).to eq('write_orders')
  end

  it 'does not reveal another store when the staff member has no membership there' do
    other = create(:store)
    token = login_as(staff_with(%w[read_pos_orders]))

    get context_path, headers: {
      'Authorization' => "Bearer #{token}",
      'X-Spree-Store-Id' => other.prefixed_id
    }, as: :json

    expect(response).to have_http_status(:forbidden)
    expect(response.parsed_body.to_json).not_to include(other.prefixed_id)
    expect(response.parsed_body).not_to have_key('staff')
  end
end
