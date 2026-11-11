# frozen_string_literal: true

require 'spree/api/testing_support/v3/base'
require_relative '../../../support/pos_platform_helpers'
require_relative '../../../support/pos_schema_helpers'

# Delivery platform orders over HTTP: the counter enters, readies, hands
# over and cancels them; branch setup turns the platforms on and sets their
# rates; reconciliation settles what the platforms paid and reads the
# platform report. Every response matches pos-staff.yaml.
RSpec.describe 'POS platform orders API', type: :request do
  include PosPlatformHelpers
  include PosSchemaHelpers

  let(:store) { menu_store }
  let(:branch) { platform_branch(store, rate: 25) }
  let(:counter) { platform_counter(store, branch) }
  let(:milk_tea) { menu_item!(store, branch, name: 'Trà sữa', price: 30_000) }
  let!(:kitchen) { kitchen_station!(branch, name: 'Bar', kind: 'bar', default: true) }

  before { allow(Spree::Store).to receive(:default).and_return(store) }

  def token_for(user)
    @tokens ||= {}
    @tokens[user.id] ||= begin
      post '/api/v3/admin/auth/login', params: { email: user.email, password: 'secret123' }, as: :json
      response.parsed_body.fetch('token')
    end
  end

  def call(user, verb, path, body = {}, key: SecureRandom.uuid, **params)
    body = body.merge(params)
    headers = { 'Authorization' => "Bearer #{token_for(user)}" }
    headers['Idempotency-Key'] = key unless verb == :get
    send(verb, "/api/v3/admin/pos/#{path}", headers: headers, params: body, as: verb == :get ? nil : :json)
    response.parsed_body
  end

  def enter(ref: 'GF-5001', key: SecureRandom.uuid, price: 39_000)
    call(counter.cashier, :post, 'platform_orders', {
           editor_id: counter.editor_id, register_id: counter.register.prefixed_id, platform: 'grabfood',
           platform_order_ref: ref, pickup_code: 'B07', note: 'Gọi trước khi đến',
           lines: [{ variant_id: size(milk_tea).prefixed_id, quantity: 2, platform_price: price.to_s }]
         }, key: key)
  end

  it 'enters an order at the counter, lists it as open and refuses the same code twice' do
    key = SecureRandom.uuid
    body = enter(key: key)
    expect(response).to have_http_status(:created), response.body
    expect_pos_schema!(response, 'PlatformOrder')
    expect(body['data']).to include('platform' => 'grabfood', 'platform_order_ref' => 'GF-5001', 'pickup_code' => 'B07',
                                    'status' => 'accepted', 'gross_amount' => '78000.0', 'commission_amount' => '19500.0',
                                    'net_amount' => '58500.0', 'order_number' => 1)
    expect(body.dig('data', 'items').sole).to include('name' => 'Trà sữa', 'quantity' => '2.0')
    expect(enter(key: key)).to eq(body)

    enter
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'details')).to include('reason' => 'platform_order_duplicate',
                                                                    'platform_order_id' => body.dig('data', 'id'))

    list = call(counter.cashier, :get, 'platform_orders', branch_id: branch.prefixed_id)
    expect(response).to have_http_status(:ok)
    expect_pos_schema!(response, 'PlatformOrder')
    expect(list['data'].map { |row| row['id'] }).to eq([body.dig('data', 'id')])
    expect(call(counter.cashier, :get, 'platform_orders', branch_id: branch.prefixed_id, status: 'completed')['data']).to eq([])

    call(counter.cashier, :get, 'platform_orders', branch_id: branch.prefixed_id, status: 'everything')
    expect(response).to have_http_status(:unprocessable_content)
    call(counter.cashier, :get, 'platform_orders', branch_id: branch.prefixed_id, from: '11/11/2026')
    expect(response).to have_http_status(:unprocessable_content)

    # The counter's tabs leave platform orders to their own tray.
    tabs = call(counter.cashier, :get, 'workspaces', branch_id: branch.prefixed_id, platform: 'exclude')
    expect(response).to have_http_status(:ok)
    expect(tabs['data'].map { |row| row['id'] }).not_to include(body.dig('data', 'workspace_id'))
  end

  it 'readies, hands over and settles an order, then reports and exports it' do
    id = enter.dig('data', 'id')
    call(counter.cashier, :post, "platform_orders/#{id}/ready")
    expect(response).to have_http_status(:ok), response.body
    expect_pos_schema!(response, 'PlatformOrder')
    expect(response.parsed_body.dig('data', 'status')).to eq('ready')

    call(counter.cashier, :post, "platform_orders/#{id}/complete", editor_id: counter.editor_id)
    expect(response).to have_http_status(:ok), response.body
    expect_pos_schema!(response, 'PlatformOrder')
    expect(response.parsed_body.dig('data', 'status')).to eq('completed')

    resolver = credit_staff(store, branch, [Spree::Pos::Capabilities::RESOLVE, Spree::Pos::Capabilities::REPORT_READ,
                                            Spree::Pos::Capabilities::REPORT_EXPORT])
    call(counter.cashier, :post, 'platform_orders/settle', branch_id: branch.prefixed_id, orders: [{ id: id }])
    expect(response).to have_http_status(:forbidden)

    unsettled = call(resolver, :get, 'platform_orders', branch_id: branch.prefixed_id, status: 'unsettled')
    expect(unsettled['data'].map { |row| row['id'] }).to eq([id])
    settled = call(resolver, :post, 'platform_orders/settle', branch_id: branch.prefixed_id, reference: 'GRAB-0311',
                                                              orders: [{ id: id, commission_amount: '18000' }])
    expect(response).to have_http_status(:ok), response.body
    expect_pos_schema!(response, 'PlatformOrder')
    expect(settled['data'].sole).to include('commission_amount' => '18000.0', 'net_amount' => '60000.0',
                                            'settlement_reference' => 'GRAB-0311')

    second = enter(ref: 'GF-5002', price: 30_000).dig('data', 'id')
    call(counter.cashier, :post, "platform_orders/#{second}/complete", editor_id: counter.editor_id)
    expect(response).to have_http_status(:ok), response.body

    today = Spree::Pos::PlatformOrder.find_by_prefix_id!(id).workspace.business_date.iso8601
    report = call(resolver, :get, 'reports/platforms', branch_id: branch.prefixed_id, from: today, to: today)
    expect(response).to have_http_status(:ok), response.body
    expect_pos_schema!(response, 'PlatformReportRow')
    expect(report['data'].sole).to include('business_date' => today, 'platform' => 'grabfood', 'orders' => 2,
                                           'gross' => '138000.0', 'commission' => '33000.0', 'net' => '105000.0',
                                           'unsettled' => '45000.0', 'commission_estimated' => '15000.0',
                                           'commission_actual' => '18000.0')
    expect(report.dig('meta', 'summary')).to include('orders' => 2, 'net' => '105000.0', 'unsettled' => '45000.0')
    other = call(resolver, :get, 'reports/platforms', branch_id: branch.prefixed_id, from: today, to: today, platform: 'shopeefood')
    expect(other['data']).to eq([])

    created = call(resolver, :post, 'exports', branch_id: branch.prefixed_id, report_type: 'platforms',
                                               filters: { from: today, to: today })
    expect(response).to have_http_status(:accepted), response.body
    export = Spree::Pos::ExportRequest.find_by_prefix_id!(created.dig('data', 'id'))
    Spree::Pos::GenerateExportJob.perform_now(export.id)
    expect(export.reload).to have_attributes(status: 'ready', row_count: 1)
  end

  it 'cancels an order the kitchen has with an approval' do
    id = enter.dig('data', 'id')
    call(counter.cashier, :post, "platform_orders/#{id}/cancel", editor_id: counter.editor_id)
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('approval_required')

    manager = platform_counter(store, branch, capabilities: PosCreditHelpers::MANAGER + [Spree::Pos::Capabilities::TAKEOVER])
    call(manager.cashier, :post, "platform_orders/#{id}/cancel", editor_id: manager.editor_id, reason: 'Khách hủy')
    expect(response).to have_http_status(:ok), response.body
    expect_pos_schema!(response, 'PlatformOrder')
    expect(response.parsed_body['data']).to include('status' => 'canceled', 'cancel_reason' => 'Khách hủy')

    call(counter.cashier, :post, "platform_orders/#{id}/ready")
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('platform_order_canceled')
  end

  it 'shows and changes the platforms of a branch for branch setup only' do
    settings = call(counter.cashier, :get, 'platform_settings', branch_id: branch.prefixed_id)
    expect(response).to have_http_status(:ok), response.body
    expect_pos_schema!(response, 'PlatformSettings')
    expect(settings.dig('data', 'module_enabled')).to be(true)
    expect(settings.dig('data', 'platforms').map { |row| [row['platform'], row['status'], row['commission_rate']] }).
      to eq([%w[grabfood active 25.0], %w[shopeefood disabled 0.0]])

    call(counter.cashier, :put, 'platform_settings', branch_id: branch.prefixed_id, platform: 'shopeefood', status: 'active',
                                                     commission_rate: '20')
    expect(response).to have_http_status(:forbidden)

    manager = credit_staff(store, branch, [Spree::Pos::Capabilities::MANAGE])
    call(manager, :put, 'platform_settings', branch_id: branch.prefixed_id, platform: 'shopeefood', status: 'active',
                                             commission_rate: '20.5')
    expect(response).to have_http_status(:ok), response.body
    expect_pos_schema!(response, 'PlatformSetting')
    expect(response.parsed_body['data']).to include('status' => 'active', 'commission_rate' => '20.5')
    expect(Spree::Pos::AuditEntry.where(action: 'platform_setting.change').count).to eq(1)

    call(manager, :put, 'platform_settings', branch_id: branch.prefixed_id, platform: 'shopeefood', status: 'active',
                                             commission_rate: '120')
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('platform_rate_invalid')

    set_pos_module(branch, 'fnb.delivery_platforms', false)
    call(manager, :put, 'platform_settings', branch_id: branch.prefixed_id, platform: 'grabfood', status: 'active',
                                             commission_rate: '25')
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('module_disabled')
    call(manager, :put, 'platform_settings', branch_id: branch.prefixed_id, platform: 'grabfood', status: 'disabled',
                                             commission_rate: '25')
    expect(response).to have_http_status(:ok)
  end
end
