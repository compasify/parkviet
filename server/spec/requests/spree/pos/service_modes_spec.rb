# frozen_string_literal: true

require 'spree/api/testing_support/v3/base'
require_relative '../../../support/pos_credit_helpers'

# Service mode is a value on the draft. It can change until money locks the
# snapshot. Retail stays counter unless someone sets another mode.
RSpec.describe 'POS service modes API', type: :request do
  include PosCreditHelpers

  let(:store) { create(:store, default_currency: 'VND', supported_currencies: 'VND') }
  let(:branch) { credit_branch(store) }

  before { allow(Spree::Store).to receive(:default).and_return(store) }

  def token_for(user)
    post '/api/v3/admin/auth/login', params: { email: user.email, password: 'secret123' }, as: :json
    response.parsed_body.fetch('token')
  end

  def headers(user, key)
    { 'Authorization' => "Bearer #{token_for(user)}", 'Idempotency-Key' => key }
  end

  def set_mode(sale, value, key: SecureRandom.uuid)
    workspace = sale.workspace.reload
    body = {
      expected_revision: workspace.revision, lease_generation: workspace.lease_generation,
      editor_id: sale.editor_id, service_mode: value, idempotency_key: key
    }
    patch "/api/v3/admin/pos/workspaces/#{workspace.prefixed_id}/service_mode",
          headers: headers(sale.cashier, key), params: body, as: :json
    response.parsed_body
  end

  it 'defaults to counter, audits a change, and ignores the same mode' do
    sale = credit_sale(store, branch, price: 50_000)
    expect(sale.workspace).to have_attributes(service_mode: 'counter', business_date: be_present)
    expect_pos_schema!(response_for_show(sale), 'Workspace')

    body = set_mode(sale, 'dine_in')
    expect(response).to have_http_status(:ok), response.body
    expect(body.dig('data', 'service_mode')).to eq('dine_in')
    expect(Spree::Pos::AuditEntry.where(action: 'workspace.service_mode').sole.metadata).
      to include('before' => 'counter', 'service_mode' => 'dine_in')

    set_mode(sale, 'dine_in')
    expect(response).to have_http_status(:ok)
    expect(Spree::Pos::AuditEntry.where(action: 'workspace.service_mode').count).to eq(1)

    set_mode(sale, 'banquet')
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('service_mode_invalid')
    expect(sale.workspace.reload.service_mode).to eq('dine_in')
  end

  it 'refuses a change after money locks the snapshot' do
    sale = credit_sale(store, branch, price: 50_000)
    take_tender(sale, 'cash', 50_000)
    set_mode(sale, 'takeaway')
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('snapshot_locked')
    expect(sale.workspace.reload.service_mode).to eq('counter')
  end

  def response_for_show(sale)
    get "/api/v3/admin/pos/workspaces/#{sale.workspace.prefixed_id}",
        headers: { 'Authorization' => "Bearer #{token_for(sale.cashier)}" }, as: :json
    response
  end
end
