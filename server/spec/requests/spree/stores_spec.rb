# frozen_string_literal: true

require 'spree/api/testing_support/v3/base'

RSpec.describe 'Opening another store', type: :request do
  let(:store) { Spree::Store.default }
  let(:password) { 'secret123' }

  def login_as(user)
    post '/api/v3/admin/auth/login', params: { email: user.email, password: password }, as: :json
    expect(response).to have_http_status(:ok)
    response.parsed_body.fetch('token')
  end

  def headers_for(user, target_store = store)
    { 'Authorization' => "Bearer #{login_as(user)}", 'X-Spree-Store-Id' => target_store.prefixed_id }
  end

  let(:owner) do
    create(:admin_user, :without_admin_role, password: password).tap { |user| store.add_user(user) }
  end

  it 'creates a store the owner administers, with its own channel, market, warehouse and VAT' do
    post '/api/v3/admin/stores', headers: headers_for(owner), params: { name: 'Nhà hàng', country_code: 'VN' }, as: :json

    expect(response).to have_http_status(:created)
    created = Spree::Store.find_by_prefix_id!(response.parsed_body.fetch('id'))
    expect(created.name).to eq('Nhà hàng')
    expect(created).not_to be_default
    expect(store.reload).to be_default
    expect(owner.reload.spree_admin?(created)).to be(true)
    expect(created.default_channel).to be_present
    expect(created.default_market).to have_attributes(currency: 'VND', default_locale: 'vi')
    expect(created.stock_locations.where(default: true)).to exist
    expect(Spree::TaxCategory.where(store: created, tax_code: Spree::Pos::TaxCategories::CODES).count).to eq(2)
    expect(created.mail_from_address).to eq(store.mail_from_address)
  end

  it 'keeps each store’s catalog apart' do
    create(:product, store: store)
    post '/api/v3/admin/stores', headers: headers_for(owner), params: { name: 'Nhà hàng', country_code: 'VN' }, as: :json
    created = Spree::Store.find_by_prefix_id!(response.parsed_body.fetch('id'))

    get '/api/v3/admin/products', headers: headers_for(owner, created), as: :json

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.fetch('data')).to be_empty
  end

  it 'refuses staff who are not an admin of the current store' do
    staff = create(:admin_user, :without_admin_role, password: password)
    create(:role_user, user: staff, role: create(:role, resource: store, permissions: %w[read_settings write_settings]))

    expect do
      post '/api/v3/admin/stores', headers: headers_for(staff), params: { name: 'Nhà hàng', country_code: 'VN' }, as: :json
    end.not_to change(Spree::Store, :count)

    expect(response).to have_http_status(:forbidden)
  end

  it 'reports an unknown country on its field' do
    post '/api/v3/admin/stores', headers: headers_for(owner), params: { name: 'Nhà hàng', country_code: 'XX' }, as: :json

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.parsed_body.dig('error', 'details', 'country_code')).to be_present
  end
end
