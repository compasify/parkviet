# frozen_string_literal: true

RSpec.describe 'POS staff authentication contract', type: :request do
  let!(:staff) { create(:admin_user, password: 'secret123') }
  let(:login_path) { '/api/v3/admin/auth/login' }
  let(:refresh_path) { '/api/v3/admin/auth/refresh' }
  let(:logout_path) { '/api/v3/admin/auth/logout' }

  def login
    post login_path, params: { email: staff.email, password: 'secret123' }, as: :json
  end

  it 'authenticates staff and rotates and revokes the refresh cookie' do
    login
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.fetch('token')).to be_present
    expect(response.parsed_body).not_to have_key('refresh_token')
    expect(response.headers['set-cookie']).to match(/httponly/i)

    old_cookie = cookies['spree_admin_refresh_token']
    expect(old_cookie).to be_present
    post refresh_path, as: :json
    expect(response).to have_http_status(:ok)
    expect(cookies['spree_admin_refresh_token']).not_to eq(old_cookie)

    post logout_path, as: :json
    expect(response).to have_http_status(:no_content)
    post refresh_path, as: :json
    expect(response).to have_http_status(:unauthorized)
  end

  it 'rejects an incorrect password without issuing a refresh cookie' do
    post login_path, params: { email: staff.email, password: 'incorrect' }, as: :json
    expect(response).to have_http_status(:unauthorized)
    expect(cookies['spree_admin_refresh_token']).to be_nil
  end

  it 'rejects replay of the previous refresh cookie after rotation' do
    login
    old_cookie = cookies['spree_admin_refresh_token']
    post refresh_path, as: :json
    expect(response).to have_http_status(:ok)

    cookies['spree_admin_refresh_token'] = old_cookie
    post refresh_path, as: :json
    expect(response).to have_http_status(:unauthorized)
  end

  it 'characterizes whether logout invalidates an already issued access token' do
    login
    token = response.parsed_body.fetch('token')
    post logout_path, as: :json
    expect(response).to have_http_status(:no_content)

    get '/api/v3/admin/me', headers: { 'Authorization' => "Bearer #{token}" }, as: :json
    expect(response).to have_http_status(:ok)
  end

  it 'rejects an existing access token and refresh after staff deactivation' do
    login
    token = response.parsed_body.fetch('token')
    staff.deactivate!

    get '/api/v3/admin/me', headers: { 'Authorization' => "Bearer #{token}" }, as: :json
    expect(response).to have_http_status(:unauthorized)
    post refresh_path, as: :json
    expect(response).to have_http_status(:unauthorized)
  end

  it 'does not let the ordinary order API create a walk-in marker through parameters' do
    login
    token = response.parsed_body.fetch('token')
    previous_ids = Spree::Store.default.orders.pluck(:id)
    post '/api/v3/admin/orders',
         headers: { 'Authorization' => "Bearer #{token}" },
         params: { order: { metadata: { pos_walk_in: true }, pos_walk_in_order: { enabled: true } } }, as: :json

    expect(response).to have_http_status(:created)
    order = Spree::Store.default.orders.where.not(id: previous_ids).sole
    expect(order).to be_present
    expect(Pos::WalkInOrder.exists?(order_id: order.id)).to be(false)
  end

  it 'does not allow POS-only staff to write through the ordinary orders API' do
    pos_staff = create(:admin_user, :without_admin_role, password: 'secret123')
    role = create(:role, resource: Spree::Store.default, permissions: %w[write_pos_orders])
    create(:role_user, user: pos_staff, role: role)
    post login_path, params: { email: pos_staff.email, password: 'secret123' }, as: :json
    expect(response).to have_http_status(:ok)

    post '/api/v3/admin/orders', headers: { 'Authorization' => "Bearer #{response.parsed_body.fetch('token')}" },
         params: { order: {} }, as: :json
    expect(response).to have_http_status(:forbidden)
    expect(response.parsed_body.dig('error', 'details', 'required_permission')).to eq('write_orders')
  end
end
