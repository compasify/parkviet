# frozen_string_literal: true

require 'spree/api/testing_support/v3/base'

# The spree_vietqr API surface the dashboard and the storefront use: receiving
# accounts and webhook events in the Admin API, the QR of a placed order in the
# Store API.
RSpec.describe 'VietQR API', type: :request do
  # The Spree shared contexts define their own store; each block re-points it here.
  let(:vnd_store) { create(:store, default: true, default_currency: 'VND', supported_currencies: 'VND') }
  let!(:vietqr) { Spree::PaymentMethod::Vietqr.create!(store: vnd_store, name: 'VietQR', active: true) }
  let(:account_attributes) do
    { provider: 'sepay', bank_bin: '970436', bank_name: 'Vietcombank', account_number: '0123 456 789',
      account_name: 'PARK VIET', keyword_init: 'PV', webhook_secret: 'super-secret-1234' }
  end

  describe 'Admin API' do
    include_context 'API v3 Admin authenticated'
    let(:store) { vnd_store }

    def admin(verb, path, body = {})
      send(verb, "/api/v3/admin/vietqr/#{path}", headers: headers, params: body, as: verb == :get ? nil : :json)
      response.parsed_body
    end

    it 'manages receiving accounts without ever returning a stored secret' do
      created = admin(:post, 'receiving_accounts', account_attributes.merge(payment_method_id: vietqr.prefixed_id))
      expect(response).to have_http_status(:created)
      expect(created).to include('account_number' => '0123456789', 'webhook_secret' => '••••1234',
                                 'webhook_url' => end_with('/webhooks/payments/sepay'))

      account = SpreeVietqr::ReceivingAccount.find_by_prefix_id!(created['id'])
      admin(:patch, "receiving_accounts/#{created['id']}", { account_name: 'PARK VIET JSC', webhook_secret: '••••1234' })
      expect(account.reload).to have_attributes(account_name: 'PARK VIET JSC', webhook_secret: 'super-secret-1234')

      listed = admin(:get, 'receiving_accounts', { payment_method_id: vietqr.prefixed_id })
      expect(listed['data'].map { |row| row['id'] }).to eq([created['id']])
      expect(listed.to_json).not_to include('super-secret-1234')

      admin(:delete, "receiving_accounts/#{created['id']}")
      expect(response).to have_http_status(:no_content)
    end

    it 'refuses an invalid receiving account' do
      body = admin(:post, 'receiving_accounts', account_attributes.merge(payment_method_id: vietqr.prefixed_id, webhook_secret: ''))
      expect(response).to have_http_status(:unprocessable_content)
      expect(body.dig('error', 'message')).to be_present
    end

    it 'lists banks and webhook events, and only matches an unmatched event by hand' do
      expect(admin(:get, 'banks')['data']).to include('bin' => '970436', 'name' => 'Vietcombank')

      event = SpreeVietqr::WebhookEvent.create!(provider: 'sepay', payment_method: vietqr, status: 'confirmed', amount_cents: 1000)
      listed = admin(:get, 'webhook_events', { status: 'confirmed' })
      expect(listed['data'].map { |row| row['id'] }).to eq([event.prefixed_id])

      admin(:post, "webhook_events/#{event.prefixed_id}/manual_match", { order_number: 'R1' })
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe 'Store API' do
    include_context 'API v3 Store guest'
    let(:store) { vnd_store }

    let(:order) { create(:completed_order_with_totals, store: store, currency: 'VND') }
    let!(:account) { vietqr.receiving_accounts.create!(account_attributes) }

    it 'returns the QR of a placed order to its owner and nobody else' do
      order.payments.create!(payment_method: vietqr, amount: order.total, status: 'pending')

      get "/api/v3/store/orders/#{order.prefixed_id}/vietqr", headers: headers.merge('x-spree-token' => order.token)
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to include('status' => 'allocated', 'account_number' => '0123456789',
                                              'transfer_content' => "PV#{order.number}")

      get "/api/v3/store/orders/#{order.prefixed_id}/vietqr", headers: headers
      expect(response).to have_http_status(:not_found)
    end

    it 'says so when the order is not paid by VietQR' do
      get "/api/v3/store/orders/#{order.prefixed_id}/vietqr", headers: headers.merge('x-spree-token' => order.token)
      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
