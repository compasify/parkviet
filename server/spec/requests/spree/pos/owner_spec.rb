# frozen_string_literal: true

require 'spree/api/testing_support/v3/base'
require_relative '../../../support/pos_return_helpers'
require_relative '../../../support/pos_owner_helpers'
require_relative '../../../support/pos_schema_helpers'

RSpec.describe 'POS owner app', type: :request do
  include PosReturnHelpers
  include PosOwnerHelpers
  include PosSchemaHelpers

  let(:store) { create(:store, default_currency: 'VND', supported_currencies: 'VND') }
  let(:branch) { credit_branch(store) }
  let(:cashier) { credit_staff(store, branch, [Spree::Pos::Capabilities::OPEN_SHIFT, Spree::Pos::Capabilities::PAYMENT]) }
  let(:owner) { credit_staff(store, branch, [Spree::Pos::Capabilities::APPROVE, Spree::Pos::Capabilities::REPORT_READ]) }

  before { allow(Spree::Store).to receive(:default).and_return(store) }

  after { Spree::Pos::Push::RelayClient.transport = nil }

  def bearer(user)
    post '/api/v3/admin/auth/login', params: { email: user.email, password: 'secret123' }, as: :json
    { 'Authorization' => "Bearer #{response.parsed_body.fetch('token')}" }
  end

  it 'shows today with the very figures of the sales report, and the open orders' do
    paid_sale(store, branch, cashier: cashier, price: 120_000)
    paid_sale(store, branch, cashier: cashier, price: 30_000)
    open = open_sale(store, branch, cashier: cashier, product: stocked_product(store, branch, price: 45_000))
    headers = bearer(owner)

    get '/api/v3/admin/pos/reports/sales', headers: headers, params: { branch_id: branch.prefixed_id }
    summary = response.parsed_body.dig('meta', 'summary')

    get '/api/v3/admin/pos/owner/today', headers: headers, params: { branch_id: branch.prefixed_id }
    expect(response).to have_http_status(:ok)
    expect_pos_schema!(response, 'OwnerToday')
    today = response.parsed_body['data']
    expect(today.slice('orders', 'sales_total', 'net_sales')).to eq(summary.slice('orders', 'sales_total', 'net_sales'))
    expect(today['orders']).to eq(2)
    expect(today['by_source']).to eq(summary['by_source'])
    expect(today['by_hour'].sum { |row| row['orders'] }).to eq(2)
    expect(today).to include('open_orders' => 1, 'open_shifts' => 1, 'open_total' => '45000.0', 'pending_approvals' => 0)

    get '/api/v3/admin/pos/owner/open_units', headers: headers, params: { branch_id: branch.prefixed_id }
    expect_pos_schema!(response, 'OwnerOpenUnit')
    expect(response.parsed_body['data'].pluck('workspace_id')).to eq([open.workspace.prefixed_id])
    expect(response.parsed_body['data'].first).to include('total' => '45000.0', 'kitchen_waiting' => 0, 'kitchen_late' => false)
  end

  it 'refuses the day of a branch to someone without the report capability' do
    get '/api/v3/admin/pos/owner/today', headers: bearer(cashier), params: { branch_id: branch.prefixed_id }
    expect(response).to have_http_status(:forbidden)
    get '/api/v3/admin/pos/owner/alerts', headers: bearer(cashier), params: { branch_id: branch.prefixed_id }
    expect(response).to have_http_status(:forbidden)
  end

  it 'lists the branches the person watches and lets an owner device hear each of them' do
    other = credit_branch(store)
    Spree::Pos::StaffMembership.create!(store: store, branch: other, staff: owner, capabilities: [Spree::Pos::Capabilities::REPORT_READ],
                                        status: 'active')
    credit_branch(store)
    get '/api/v3/admin/pos/owner/branches', headers: bearer(owner)
    expect_pos_schema!(response, 'OwnerBranch')
    expect(response.parsed_body['data'].pluck('id')).to contain_exactly(branch.prefixed_id, other.prefixed_id)

    device, = pair_owner_device!(branch)
    session = Spree::Pos::DeviceStaffSession.new(staff: owner)
    principal = Spree::Pos::ApplicationCable::Principal.for_device(device, session)
    expect(principal.may_read?(other)).to be(true)
    expect(principal.may_read?(credit_branch(store))).to be(false)
    expect(Spree::Pos::ApplicationCable::Principal.for_device(device).may_read?(other)).to be(false)
  end

  it 'raises each alert once and lists it for the branch' do
    events = []
    allow(Spree::Pos::Realtime).to receive(:publish).and_wrap_original do |original, *args, **kwargs|
      events << args[1]
      original.call(*args, **kwargs)
    end
    register = open_drawer(store, branch, cashier)
    shift = Spree::Pos::Shift.find_by!(register: register)
    Spree::Pos::ShiftClosure.insert_all([{ store_id: store.id, branch_id: branch.id, register_id: register.id, shift_id: shift.id,
                                           closer_id: cashier.id, currency: 'VND', opening_float: 0, inflow_total: 100_000, outflow_total: 0,
                                           expected: 100_000, counted: 90_000, variance: -10_000, variance_threshold: 0, movement_count: 0,
                                           breakdown: {}, opened_at: 1.hour.ago, closed_at: 1.minute.ago, created_at: Time.current,
                                           updated_at: Time.current }])

    Spree::Pos::OwnerAlertsScanJob.perform_now
    Spree::Pos::OwnerAlertsScanJob.perform_now
    expect(Spree::Pos::OwnerAlert.where(kind: 'shift_variance').count).to eq(1)
    expect(events.count('owner_alert.created')).to eq(1)

    get '/api/v3/admin/pos/owner/alerts', headers: bearer(owner), params: { branch_id: branch.prefixed_id }
    expect_pos_schema!(response, 'OwnerAlert')
    expect(response.parsed_body['data'].first).to include('kind' => 'shift_variance', 'subject_id' => shift.prefixed_id)
    expect(response.parsed_body.dig('data', 0, 'details')).to eq('variance' => '-10000.0', 'currency' => 'VND')
  end

  it 'raises the revenue threshold alert once the year passes 90%' do
    allow(Spree::Pos::OwnerAlerts).to receive(:raise!).and_call_original
    stub_const('Spree::Pos::OwnerAlerts::REVENUE_THRESHOLD', BigDecimal('100000'))
    paid_sale(store, branch, cashier: cashier, price: 95_000)
    Spree::Pos::OwnerAlerts.revenue_milestone!(store)
    expect(Spree::Pos::OwnerAlert.where(branch: branch, kind: 'revenue_milestone').pick(:details)).to include('percent' => 90)
  end

  it 'keeps the push token of an owner device, write-only, and only on an owner device' do
    _device, token = pair_owner_device!(branch)
    headers = owner_headers(branch, owner, token)
    put '/api/v3/admin/pos/push_registration', headers: headers.merge('Idempotency-Key' => SecureRandom.uuid),
                                                params: { platform: 'fcm', token: 'fcm-device-token' }, as: :json
    expect(response).to have_http_status(:ok)
    expect_pos_schema!(response, 'PushRegistrationState')
    expect(response.parsed_body.dig('data', 'registration')).to include('platform' => 'fcm', 'enabled' => true)
    expect(response.parsed_body.dig('data', 'relay')).to be(false)
    expect(response.body).not_to include('fcm-device-token')

    put '/api/v3/admin/pos/push_registration', headers: headers.merge('Idempotency-Key' => SecureRandom.uuid),
                                                params: { enabled: false }, as: :json
    expect(response.parsed_body.dig('data', 'registration', 'enabled')).to be(false)
    expect(Spree::Pos::PushRegistration.sole.token).to eq('fcm-device-token')

    delete '/api/v3/admin/pos/push_registration', headers: headers.merge('Idempotency-Key' => SecureRandom.uuid)
    expect(response.parsed_body.dig('data', 'registration')).to be_nil

    put '/api/v3/admin/pos/push_registration', headers: bearer(owner), params: { platform: 'fcm', token: 'x' }, as: :json
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('owner_device_required')
  end

  it 'stores the relay key write-only and checks the relay through a stubbed transport' do
    admin = credit_staff(store, branch, [], extra_permissions: %w[write_pos_topology read_pos_topology])
    headers = bearer(admin)
    put '/api/v3/admin/pos/push_relay_settings', headers: headers, params: { url: 'http://relay.example.test', key: 'k' * 40 }, as: :json
    expect(response).to have_http_status(:unprocessable_content)

    put '/api/v3/admin/pos/push_relay_settings', headers: headers, params: { url: 'https://relay.example.test/push', key: 'k' * 40 }, as: :json
    expect(response).to have_http_status(:ok)
    expect_pos_schema!(response, 'PushRelaySettings')
    expect(response.parsed_body['data']).to include('url' => 'https://relay.example.test/push', 'key_set' => true)
    expect(response.body).not_to include('k' * 40)

    sent = []
    Spree::Pos::Push::RelayClient.transport = lambda { |uri, request_headers, body|
      sent << [uri.to_s, request_headers, JSON.parse(body)]
      [503, '']
    }
    post '/api/v3/admin/pos/push_relay_settings/check', headers: headers, as: :json
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('push_relay_unreachable')

    Spree::Pos::Push::RelayClient.transport = ->(*) { [202, ''] }
    post '/api/v3/admin/pos/push_relay_settings/check', headers: headers, as: :json
    expect(response.parsed_body['data']).to include('last_error' => nil, 'last_delivered_at' => be_present)

    timestamp, signature = sent.first[1].values_at('X-Parkviet-Timestamp', 'X-Parkviet-Signature')
    expect(sent.first[2]).to eq('event' => 'relay.check', 'id' => store.prefixed_id)
    expect(signature).to eq(OpenSSL::HMAC.hexdigest('SHA256', 'k' * 40, "#{timestamp}.#{JSON.generate(sent.first[2])}"))

    get '/api/v3/admin/pos/push_relay_settings', headers: bearer(owner)
    expect(response).to have_http_status(:forbidden)
  end

  it 'delivers only the event and an id, keeps the last error, and is a no-op without a relay' do
    device, = pair_owner_device!(branch)
    registration = Spree::Pos::PushRegistration.create!(store: store, device: device, staff: owner, platform: 'apns', token: 'apns-token')
    sent = []
    Spree::Pos::Push::RelayClient.transport = lambda { |_uri, _headers, body|
      sent << JSON.parse(body)
      [200, '']
    }
    Spree::Pos::PushDeliveryJob.perform_now(registration.id, 'owner_alert.created', 'posowneralert_x')
    expect(sent).to be_empty

    Spree::Pos::PushRelaySetting.create!(store: store, url: 'https://relay.example.test/push', relay_key: 'k' * 40)
    Spree::Pos::PushDeliveryJob.perform_now(registration.id, 'owner_alert.created', 'posowneralert_x')
    expect(sent).to eq([{ 'platform' => 'apns', 'token' => 'apns-token', 'event' => 'owner_alert.created', 'id' => 'posowneralert_x' }])
    expect(registration.reload.last_delivered_at).to be_present

    Spree::Pos::Push::RelayClient.transport = ->(*) { [500, ''] }
    job = Spree::Pos::PushDeliveryJob.new(registration.id, 'owner_alert.created', 'posowneralert_x')
    expect { job.perform(registration.id, 'owner_alert.created', 'posowneralert_x') }.to raise_error(Spree::Pos::Push::RelayClient::Failed)
    expect(registration.reload.last_error).to eq('Failed: relay answered 500')
    expect(Spree::Pos::PushRelaySetting.sole.last_error).to eq('Failed: relay answered 500')
  end
end
