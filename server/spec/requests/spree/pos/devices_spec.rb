# frozen_string_literal: true

require 'spree/api/testing_support/v3/base'
require_relative '../../../support/pos_credit_helpers'

RSpec.describe 'POS devices API', type: :request do
  include PosCreditHelpers

  let(:store) { create(:store, default_currency: 'VND', supported_currencies: 'VND') }
  let(:branch) { credit_branch(store) }
  let(:manager) { credit_staff(store, branch, PosCreditHelpers::MANAGER + [Spree::Pos::Capabilities::DEVICE_MANAGE]) }
  let(:cashier) { credit_staff(store, branch, [Spree::Pos::Capabilities::OPEN_SHIFT]) }

  before { allow(Spree::Store).to receive(:default).and_return(store) }

  def token_for(user)
    post '/api/v3/admin/auth/login', params: { email: user.email, password: 'secret123' }, as: :json
    response.parsed_body.fetch('token')
  end

  def auth(user, key = SecureRandom.uuid)
    { 'Authorization' => "Bearer #{token_for(user)}", 'Idempotency-Key' => key }
  end

  it 'lists only their own PIN row to a cashier and every row to a device manager' do
    mine = Spree::Pos::StaffMembership.find_by!(staff: cashier, branch: branch)
    manager

    get '/api/v3/admin/pos/staff_pins', headers: auth(cashier), params: { branch_id: branch.prefixed_id }
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body['data'].map { |row| row['id'] }).to eq([mine.prefixed_id])

    get '/api/v3/admin/pos/staff_pins', headers: auth(manager), params: { branch_id: branch.prefixed_id }
    expect(response.parsed_body['data'].length).to eq(2)
  end

  it 'publishes a contract whose every path has a route' do
    document = YAML.safe_load_file(Rails.root.join('openapi/pos-staff.yaml'), aliases: true)
    document.fetch('paths').each do |path, operations|
      operations.each_key do |verb|
        concrete = path.gsub(/\{\w+\}/, 'x')
        expect { Rails.application.routes.recognize_path(concrete, method: verb.to_sym) }.not_to raise_error, "#{verb} #{path}"
      end
    end
  end

  it 'issues a QR, lists the device, and refuses a cashier without the capability' do
    key = SecureRandom.uuid
    post '/api/v3/admin/pos/devices/pairing', headers: auth(manager, key), params: {
      branch_id: branch.prefixed_id, mode: 'kds', idempotency_key: key
    }, as: :json
    expect(response).to have_http_status(:created)
    expect_pos_schema!(response, 'DevicePairing')
    body = response.parsed_body.fetch('data')
    expect(body.dig('qr', 'url')).to eq('http://www.example.com')
    expect(body.dig('qr', 'code')).to eq(body['code'])

    post '/api/v3/pos_device/pair', params: { code: body['code'], platform: 'android', name: 'Bếp 1' }, as: :json
    expect(response).to have_http_status(:created)
    device_token = response.parsed_body.dig('data', 'token')

    get '/api/v3/admin/pos/devices', headers: auth(manager), params: { branch_id: branch.prefixed_id }
    expect(response).to have_http_status(:ok)
    expect_pos_schema!(response, 'Device')
    device_id = response.parsed_body.dig('data', 0, 'id')

    refused = SecureRandom.uuid
    post "/api/v3/admin/pos/devices/#{device_id}/revoke", headers: auth(cashier, refused), params: { idempotency_key: refused }, as: :json
    expect(response).to have_http_status(:forbidden)

    allowed = SecureRandom.uuid
    post "/api/v3/admin/pos/devices/#{device_id}/revoke", headers: auth(manager, allowed), params: { idempotency_key: allowed }, as: :json
    expect(response).to have_http_status(:ok)
    get '/api/v3/pos_device/me', headers: { 'Authorization' => "Device #{device_token}" }
    expect(response).to have_http_status(:unauthorized)
  end
end
