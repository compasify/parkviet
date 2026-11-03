# frozen_string_literal: true

RSpec.describe 'POS store isolation contract', type: :request do
  let!(:store_a) { Spree::Store.default }
  let!(:store_b) { create(:store) }
  let!(:staff) { create(:admin_user, :without_admin_role, password: 'secret123') }
  let!(:role_a) { create(:role, resource: store_a, permissions: %w[read_orders]) }

  before do
    create(:role_user, user: staff, role: role_a)
    post '/api/v3/admin/auth/login', params: { email: staff.email, password: 'secret123' }, as: :json
    expect(response).to have_http_status(:ok)
    @token = response.parsed_body.fetch('token')
  end

  def headers_for(store)
    { 'Authorization' => "Bearer #{@token}", 'X-Spree-Store-Id' => store.prefixed_id }
  end

  it 'rejects a store for which the staff member has no role' do
    get '/api/v3/admin/orders', headers: headers_for(store_a), as: :json
    expect(response).to have_http_status(:ok)

    get '/api/v3/admin/orders', headers: headers_for(store_b), as: :json
    expect(response).to have_http_status(:forbidden)
  end

  it 'does not expose another store order to staff who can read both stores' do
    role_b = create(:role, resource: store_b, permissions: %w[read_orders])
    create(:role_user, user: staff, role: role_b)
    order_a = create(:order, store: store_a)
    order_b = create(:order, store: store_b)

    get "/api/v3/admin/orders/#{order_a.prefixed_id}", headers: headers_for(store_a), as: :json
    expect(response).to have_http_status(:ok)
    get "/api/v3/admin/orders/#{order_b.prefixed_id}", headers: headers_for(store_b), as: :json
    expect(response).to have_http_status(:ok)
    get "/api/v3/admin/orders/#{order_a.prefixed_id}", headers: headers_for(store_b), as: :json
    expect(response).to have_http_status(:not_found)
  end
end
