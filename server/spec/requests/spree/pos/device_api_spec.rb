# frozen_string_literal: true

require 'spree/api/testing_support/v3/base'
require_relative '../../../support/pos_credit_helpers'

RSpec.describe 'POS device API', type: :request do
  include PosCreditHelpers

  let(:store) { create(:store, default_currency: 'VND', supported_currencies: 'VND') }
  let(:branch) { credit_branch(store) }
  let(:manager) { credit_staff(store, branch, PosCreditHelpers::MANAGER + [Spree::Pos::Capabilities::DEVICE_MANAGE]) }
  let(:cashier) { credit_staff(store, branch, [Spree::Pos::Capabilities::OPEN_SHIFT]) }

  before { allow(Spree::Store).to receive(:default).and_return(store) }

  def bearer(user)
    post '/api/v3/admin/auth/login', params: { email: user.email, password: 'secret123' }, as: :json
    response.parsed_body.fetch('token')
  end

  def pair(mode)
    key = SecureRandom.uuid
    post '/api/v3/admin/pos/devices/pairing', headers: { 'Authorization' => "Bearer #{bearer(manager)}", 'Idempotency-Key' => key },
                                              params: { branch_id: branch.prefixed_id, mode: mode, idempotency_key: key }, as: :json
    code = response.parsed_body.dig('data', 'code')
    post '/api/v3/pos_device/pair', params: { code: code, platform: 'web', name: mode }, as: :json
    response.parsed_body.dig('data', 'token')
  end

  it 'refuses a kitchen device with no staff session on the selling API' do
    token = pair('kds')
    get '/api/v3/admin/pos/workspaces', headers: { 'Authorization' => "Device #{token}" }
    expect(response).to have_http_status(:forbidden)
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('device_staff_required')

    get '/api/v3/pos_device/me', headers: { 'Authorization' => "Device #{token}" }
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.dig('data', 'device', 'mode')).to eq('kds')
  end

  def signed_in_session(staff)
    membership = Spree::Pos::StaffMembership.find_by!(staff: staff, branch: branch)
    membership.set_pin!('2468')
    token = pair('waiter')
    post '/api/v3/pos_device/staff_sessions', headers: { 'Authorization' => "Device #{token}" },
                                              params: { membership_id: membership.prefixed_id, pin: '2468' }, as: :json
    [token, response.parsed_body.dig('data', 'token')]
  end

  it 'answers an unknown membership with JSON 404' do
    token = pair('waiter')
    post '/api/v3/pos_device/staff_sessions', headers: { 'Authorization' => "Device #{token}" },
                                              params: { membership_id: 'posmembership_missing', pin: '2468' }, as: :json
    expect(response).to have_http_status(:not_found)
    expect(response.parsed_body.dig('error', 'code')).to eq('record_not_found')
  end

  it 'refuses a device session once the person has no role in the store' do
    token, session = signed_in_session(cashier)
    headers = { 'Authorization' => "Device #{token}", 'X-Pos-Staff-Session' => session }
    get '/api/v3/admin/pos/context', headers: headers
    expect(response).to have_http_status(:ok)

    Spree::RoleUser.where(user: cashier).destroy_all
    get '/api/v3/admin/pos/context', headers: headers
    expect(response).to have_http_status(:forbidden)
  end

  it 'refuses a device paired at another store' do
    token, session = signed_in_session(cashier)
    Spree::Pos::Device.last.update_columns(store_id: create(:store).id)
    headers = { 'Authorization' => "Device #{token}", 'X-Pos-Staff-Session' => session }
    get '/api/v3/admin/pos/context', headers: headers.merge('X-Spree-Store-Id' => store.prefixed_id)
    expect(response).to have_http_status(:unauthorized)

    # Unnamed, the store is the device's own, where the cashier holds no role.
    get '/api/v3/admin/pos/context', headers: headers
    expect(response).to have_http_status(:forbidden)
  end

  it 'signs a cashier in with a PIN and does not grant device management' do
    membership = Spree::Pos::StaffMembership.find_by!(staff: cashier, branch: branch)
    key = SecureRandom.uuid
    put '/api/v3/admin/pos/staff_pins', headers: { 'Authorization' => "Bearer #{bearer(cashier)}", 'Idempotency-Key' => key },
                                        params: { membership_id: membership.prefixed_id, pin: '2468', idempotency_key: key }, as: :json
    expect(response).to have_http_status(:ok)

    token = pair('waiter')
    post '/api/v3/pos_device/staff_sessions', headers: { 'Authorization' => "Device #{token}" },
                                              params: { membership_id: membership.prefixed_id, pin: '2468' }, as: :json
    expect(response).to have_http_status(:created)
    session = response.parsed_body.dig('data', 'token')

    device_id = Spree::Pos::Device.last.prefixed_id
    revoke_key = SecureRandom.uuid
    post "/api/v3/admin/pos/devices/#{device_id}/revoke",
         headers: { 'Authorization' => "Device #{token}", 'X-Pos-Staff-Session' => session, 'Idempotency-Key' => revoke_key },
         params: { idempotency_key: revoke_key }, as: :json
    expect(response).to have_http_status(:forbidden)
  end
end
