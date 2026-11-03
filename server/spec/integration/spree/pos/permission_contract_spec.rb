# frozen_string_literal: true

require 'spree/api/testing_support/v3/base'

RSpec.describe Spree::Api::V3::Admin::OrdersController, type: :controller do
  routes { Spree::Core::Engine.routes }
  include_context 'API v3 Admin with custom permissions'

  let(:custom_permissions) { %w[read_orders] }

  before { request.headers.merge!(headers) }

  it 'permits a staff member with read_orders to list orders' do
    get :index, as: :json

    expect(response).to have_http_status(:ok)
  end

  it 'rejects direct order writes without write_orders' do
    post :create, params: { order: { email: 'buyer@example.test' } }, as: :json

    expect(response).to have_http_status(:forbidden)
    expect(JSON.parse(response.body).dig('error', 'details', 'required_permission')).to eq('write_orders')
  end

  context 'without credentials' do
    let(:headers) { {} }

    it 'rejects an unauthenticated request to orders' do
      get :index, as: :json

      expect(response).to have_http_status(:unauthorized)
    end
  end

  it 'rejects a customer JWT on the admin orders endpoint' do
    customer = create(:customer)
    token = Spree::Api::V3::TestingSupport.generate_jwt(customer)
    request.headers['Authorization'] = "Bearer #{token}"

    get :index, as: :json

    expect(response).to have_http_status(:unauthorized)
  end
end
