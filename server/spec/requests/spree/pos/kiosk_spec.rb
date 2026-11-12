# frozen_string_literal: true

require 'spree/api/testing_support/v3/base'
require_relative '../../../support/pos_kiosk_helpers'

# The self-ordering kiosk over HTTP: its own device API (no staff session,
# writes keyed and rate limited, prices from the server), the managers'
# settings and kiosk shifts, and the cashiers' list of orders left for the
# counter.
RSpec.describe 'POS kiosk API', type: :request do
  include PosKioskHelpers

  let(:store) { menu_store }
  let(:branch) { kiosk_branch(store) }
  let(:manager) { credit_staff(store, branch, PosKioskHelpers::KIOSK_MANAGER) }
  let(:cashier) { credit_staff(store, branch, PosCreditHelpers::CASHIER) }
  let(:register) { kiosk_register!(branch) }
  let!(:paired) { pair_kiosk!(register, manager) }
  let(:device) { paired.first }
  let(:token) { paired.last }
  let(:item) { menu_item!(store, branch, name: 'Cà phê sữa', price: 30_000) }
  let(:variant) { item.product.default_variant }

  before do
    allow(Spree::Store).to receive(:default).and_return(store)
    kiosk_vietqr!(store)
  end

  def kiosk(key = SecureRandom.uuid)
    { 'Authorization' => "Device #{token}", 'Idempotency-Key' => key }
  end

  def staff_auth(user, key = SecureRandom.uuid)
    post '/api/v3/admin/auth/login', params: { email: user.email, password: 'secret123' }, as: :json
    { 'Authorization' => "Bearer #{response.parsed_body.fetch('token')}", 'Idempotency-Key' => key }
  end

  def place(payment, headers: kiosk)
    post '/api/v3/pos_device/kiosk/orders', headers: headers, as: :json,
                                            params: { payment: payment, items: kiosk_items(variant).map { |row| row.merge('price' => '1') } }
  end

  it 'shows a paused kiosk until a manager opens its shift, then the menu and the open state' do
    get '/api/v3/pos_device/kiosk/state', headers: kiosk
    expect(response).to have_http_status(:ok)
    expect_pos_schema!(response, 'KioskState')
    expect(response.parsed_body['data']).to include('open' => false, 'reason' => 'shift_closed')

    post "/api/v3/admin/pos/kiosks/#{register.prefixed_id}/shift", headers: staff_auth(manager), as: :json
    expect(response).to have_http_status(:created)
    expect_pos_schema!(response, 'KioskShift')

    get '/api/v3/pos_device/kiosk/state', headers: kiosk
    expect(response.parsed_body['data']).to include('open' => true, 'payments' => { 'vietqr' => true, 'counter' => true })

    item
    get '/api/v3/pos_device/kiosk/menu', headers: kiosk
    expect(response).to have_http_status(:ok)
    expect_pos_schema!(response, 'KioskMenu')
    expect(response.parsed_body.dig('data', 'items').map { |row| row['name'] }).to include('Cà phê sữa')
  end

  it 'places a QR order at server prices, follows it and finishes it once the bank pays' do
    open_kiosk_shift!(register, manager)
    place('vietqr')
    expect(response).to have_http_status(:created)
    expect_pos_schema!(response, 'KioskOrder')
    order = response.parsed_body['data']
    expect(order).to include('status' => 'awaiting_payment', 'total' => '30000.0')

    get "/api/v3/pos_device/kiosk/orders/#{order['id']}", headers: kiosk
    expect_pos_schema!(response, 'KioskOrder')
    expect(response.parsed_body.dig('data', 'payment', 'state')).to eq('waiting')

    post "/api/v3/pos_device/kiosk/orders/#{order['id']}/finish", headers: kiosk, as: :json
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('vietqr_not_received')

    bank_webhook!(order.dig('payment', 'qr', 'transfer_note'), 30_000)
    post "/api/v3/pos_device/kiosk/orders/#{order['id']}/finish", headers: kiosk, as: :json
    expect(response).to have_http_status(:ok)
    expect_pos_schema!(response, 'KioskOrder')
    expect(response.parsed_body['data']).to include('status' => 'paid', 'call_number' => 1)
  end

  it 'leaves a counter order for the cashier, who lists and takes it to their shift' do
    open_kiosk_shift!(register, manager)
    place('vietqr')
    id = response.parsed_body.dig('data', 'id')
    post "/api/v3/pos_device/kiosk/orders/#{id}/pay_at_counter", headers: kiosk, as: :json
    expect(response.parsed_body['data']).to include('status' => 'at_counter', 'call_number' => 1)

    open_drawer(store, branch, cashier)
    auth = staff_auth(cashier)
    get '/api/v3/admin/pos/kiosk_orders', headers: auth, params: { branch_id: branch.prefixed_id }
    expect(response).to have_http_status(:ok)
    expect_pos_schema!(response, 'KioskHandoffOrder')
    expect(response.parsed_body['data'].map { |row| row['id'] }).to eq([id])

    post "/api/v3/admin/pos/kiosk_orders/#{id}/take", headers: auth, params: { editor_id: SecureRandom.uuid }, as: :json
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.dig('data', 'operational_status')).to eq('editing')

    get "/api/v3/pos_device/kiosk/orders/#{id}", headers: kiosk
    expect(response).to have_http_status(:not_found)
  end

  it 'lets only managers change the settings, within their ranges' do
    get '/api/v3/admin/pos/kiosk_settings', headers: staff_auth(manager), params: { branch_id: branch.prefixed_id }
    expect(response).to have_http_status(:ok)
    expect_pos_schema!(response, 'KioskSettings')
    expect(response.parsed_body.dig('data', 'kiosks').sole).to include('provisioned' => true, 'shift' => nil)

    put '/api/v3/admin/pos/kiosk_settings', headers: staff_auth(manager), as: :json,
                                            params: { branch_id: branch.prefixed_id, kiosk_idle_seconds: 90, kiosk_kitchen_before_payment: true }
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body['data']).to include('kiosk_idle_seconds' => 90, 'kiosk_kitchen_before_payment' => true)

    put '/api/v3/admin/pos/kiosk_settings', headers: staff_auth(manager), as: :json, params: { branch_id: branch.prefixed_id, kiosk_qr_timeout_seconds: 5 }
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('kiosk_settings_invalid')

    put '/api/v3/admin/pos/kiosk_settings', headers: staff_auth(cashier), as: :json, params: { branch_id: branch.prefixed_id, kiosk_idle_seconds: 30 }
    expect(response).to have_http_status(:forbidden)
    expect(branch.reload.kiosk_idle_seconds).to eq(90)
  end

  it 'creates kiosk registers and keeps the kind of one already used' do
    admin = credit_staff(store, branch, PosKioskHelpers::KIOSK_MANAGER, extra_permissions: %w[write_pos_topology read_pos_topology])
    post '/api/v3/admin/pos/registers', headers: staff_auth(admin), as: :json,
                                        params: { branch_id: branch.prefixed_id, name: 'Kiosk cửa', code: 'kiosk-cua', kind: 'kiosk' }
    expect(response).to have_http_status(:created)
    expect(response.parsed_body.dig('data', 'kind')).to eq('kiosk')

    open_kiosk_shift!(register, manager)
    patch "/api/v3/admin/pos/registers/#{register.prefixed_id}", headers: staff_auth(admin), as: :json, params: { kind: 'counter' }
    expect(response.status).to be_in([409, 422])
    expect(register.reload.kind).to eq('kiosk')
  end

  it 'closes the kiosk shift for a manager and pauses the kiosk' do
    open_kiosk_shift!(register, manager)
    post "/api/v3/admin/pos/kiosks/#{register.prefixed_id}/shift/close", headers: staff_auth(manager), as: :json
    expect(response).to have_http_status(:ok)
    expect_pos_schema!(response, 'KioskShiftClosure')
    get '/api/v3/pos_device/kiosk/state', headers: kiosk
    expect(response.parsed_body['data']).to include('open' => false, 'reason' => 'shift_closed')
  end

  it 'needs an Idempotency-Key, refuses other devices and keeps the kiosk token off the staff API' do
    open_kiosk_shift!(register, manager)
    place('counter', headers: { 'Authorization' => "Device #{token}" })
    expect(response).to have_http_status(:unprocessable_content)

    get '/api/v3/admin/pos/kiosk_orders', headers: { 'Authorization' => "Device #{token}" }, params: { branch_id: branch.prefixed_id }
    expect(response.status).to be_in([401, 403])
    get '/api/v3/admin/pos/context', headers: { 'Authorization' => "Device #{token}" }
    expect(response.status).to be_in([401, 403])

    pairing = Spree::Pos::Devices::Pairing.call(store: store, staff: manager, key: SecureRandom.uuid, branch_id: branch.prefixed_id, mode: 'kds',
                                                base_url: 'http://pos.test')
    kds = Spree::Pos::Devices::Pair.call(code: pairing['code'], platform: 'android', name: 'Bếp')
    get '/api/v3/pos_device/kiosk/state', headers: { 'Authorization' => "Device #{kds[:token]}" }
    expect(response).to have_http_status(:forbidden)
  end

  it 'rate limits a kiosk that reads too often' do
    statuses = Array.new(Spree::Pos::DeviceApi::KioskController::READ_ATTEMPTS + 1) do
      get '/api/v3/pos_device/kiosk/state', headers: kiosk
      response.status
    end
    expect(statuses.first).to eq(200)
    expect(statuses.last).to eq(429)
  end
end
