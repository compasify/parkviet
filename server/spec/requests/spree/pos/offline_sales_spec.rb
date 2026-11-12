# frozen_string_literal: true

require 'spree/api/testing_support/v3/base'
require_relative '../../../support/pos_menu_helpers'
require_relative '../../../support/pos_schema_helpers'

# Offline selling over HTTP: the snapshot a counter keeps, the keyed replay
# of a sale (twice, as after a lost response), the review list, and the
# cashier's and manager's decisions on a sale that no longer fits.
RSpec.describe 'POS offline sales API', type: :request do
  include PosMenuHelpers
  include PosSchemaHelpers

  let(:store) { menu_store }
  let(:branch) { menu_branch(store) }
  let(:cashier) { credit_staff(store, branch, PosCreditHelpers::CASHIER) }
  let(:manager) { credit_staff(store, branch, PosCreditHelpers::MANAGER) }
  let(:register) { open_drawer(store, branch, cashier) }
  let(:shift) { Spree::Pos::Shift.find_by!(register_id: register.id, status: 'open') }
  let(:item) { menu_item!(store, branch, name: 'Cà phê sữa', price: 30_000) }
  let(:variant) { item.product.default_variant }

  before { allow(Spree::Store).to receive(:default).and_return(store) }

  def auth(user, key = SecureRandom.uuid)
    post '/api/v3/admin/auth/login', params: { email: user.email, password: 'secret123' }, as: :json
    { 'Authorization' => "Bearer #{response.parsed_body.fetch('token')}", 'Idempotency-Key' => key }
  end

  def sale_body(offline_id = SecureRandom.uuid)
    { offline_id: offline_id, provisional_number: "OFF-#{register.code}-7", register_id: register.prefixed_id,
      shift_id: shift.prefixed_id, client_sold_at: 3.minutes.ago.iso8601, client_now: Time.current.iso8601,
      total: '60000', handed_amount: '100000',
      lines: [{ variant_id: variant.prefixed_id, quantity: 2, unit_price: '30000', name: 'Cà phê sữa' }] }
  end

  it 'gives the counter its snapshot, then 304 while nothing changed' do
    item
    get '/api/v3/admin/pos/offline_snapshot', params: { register_id: register.prefixed_id }, headers: auth(cashier)
    expect(response).to have_http_status(:ok)
    expect_pos_schema!(response, 'OfflineSnapshot')
    data = response.parsed_body['data']
    expect(data).to include('offline' => { 'allowed' => true, 'reason' => nil }, 'shift' => include('id' => shift.prefixed_id))
    expect(data.dig('staff', 'id')).to eq(cashier.prefixed_id)
    expect(data.to_json).not_to include(cashier.email)
    expect(data.dig('menu', 'items').map { |row| row['name'] }).to include('Cà phê sữa')

    get '/api/v3/admin/pos/offline_snapshot', params: { register_id: register.prefixed_id },
                                              headers: auth(cashier).merge('If-None-Match' => %("#{data['etag']}"))
    expect(response).to have_http_status(:not_modified)
  end

  it 'replays a sale under its offline key once, however often it is sent' do
    body = sale_body
    key = "offline:#{body[:offline_id]}"
    headers = auth(cashier, key)
    post '/api/v3/admin/pos/offline_sales', params: body, headers: headers, as: :json
    expect(response).to have_http_status(:ok)
    expect_pos_schema!(response, 'OfflineSale')
    first = response.parsed_body['data']
    expect(first).to include('status' => 'completed', 'collected_total' => '60000.0')
    expect(first['order_number']).to be_present

    post '/api/v3/admin/pos/offline_sales', params: body.merge(client_now: 1.minute.from_now.iso8601), headers: headers, as: :json
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.dig('data', 'id')).to eq(first['id'])
    expect(Spree::Pos::CashMovement.where(shift_id: shift.id, kind: 'receipt').sum(:amount)).to eq(60_000)

    post '/api/v3/admin/pos/offline_sales', params: sale_body, headers: auth(cashier, 'offline:other'), as: :json
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('offline_key_mismatch')
  end

  it 'lists a changed sale for review and lets the cashier finish it at today\'s price' do
    variant.set_price('VND', 35_000)
    body = sale_body
    post '/api/v3/admin/pos/offline_sales', params: body, headers: auth(cashier, "offline:#{body[:offline_id]}"), as: :json
    sale = response.parsed_body['data']
    expect(sale).to include('status' => 'needs_review', 'review_reason' => 'price_changed', 'current_total' => '70000.0')

    get '/api/v3/admin/pos/offline_sales', params: { branch_id: branch.prefixed_id }, headers: auth(cashier)
    expect(response).to have_http_status(:ok)
    expect_pos_schema!(response, 'OfflineSale')
    expect(response.parsed_body['data'].map { |row| row['id'] }).to eq([sale['id']])

    other = credit_staff(store, branch, PosCreditHelpers::CASHIER)
    get '/api/v3/admin/pos/offline_sales', params: { branch_id: branch.prefixed_id }, headers: auth(other)
    expect(response.parsed_body['data']).to eq([])

    post "/api/v3/admin/pos/offline_sales/#{sale['id']}/resolve", params: { mode: 'accept_collected' }, headers: auth(cashier), as: :json
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'details')).to include('reason' => 'approval_required', 'action' => 'workspace.override_price')

    post "/api/v3/admin/pos/offline_sales/#{sale['id']}/resolve", params: { mode: 'current_price', handed_amount: '100000' },
                                                                  headers: auth(cashier), as: :json
    expect(response).to have_http_status(:ok)
    expect_pos_schema!(response, 'OfflineSale')
    expect(response.parsed_body['data']).to include('status' => 'completed', 'resolution' => 'current_price')
  end

  it 'lets only a manager reject a sale waiting for review' do
    variant.set_price('VND', 35_000)
    body = sale_body
    post '/api/v3/admin/pos/offline_sales', params: body, headers: auth(cashier, "offline:#{body[:offline_id]}"), as: :json
    id = response.parsed_body.dig('data', 'id')

    post "/api/v3/admin/pos/offline_sales/#{id}/reject", params: { reason: 'Bán thử' }, headers: auth(cashier), as: :json
    expect(response).to have_http_status(:forbidden)

    post "/api/v3/admin/pos/offline_sales/#{id}/reject", params: { reason: 'Bán thử' }, headers: auth(manager), as: :json
    expect(response).to have_http_status(:ok)
    expect_pos_schema!(response, 'OfflineSale')
    expect(response.parsed_body['data']).to include('status' => 'rejected', 'resolution_note' => 'Bán thử')
  end

  it 'reports a replayed sale with the time it was sold offline' do
    body = sale_body
    post '/api/v3/admin/pos/offline_sales', params: body, headers: auth(cashier, "offline:#{body[:offline_id]}"), as: :json
    report = Spree::Pos::Reports.build('sales', scope: Spree::Pos::Reports::Scope.new(store: store, staff: cashier, branch: branch),
                                                values: {})
    expect(report.summary).to include(offline_orders: 1)
    expect(report.rows(report.relation.to_a).first[:sold_offline_at]).to be_present
  end
end
