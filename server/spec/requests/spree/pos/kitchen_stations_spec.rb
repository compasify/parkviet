# frozen_string_literal: true

require 'spree/api/testing_support/v3/base'
require_relative '../../../support/pos_kitchen_helpers'
require_relative '../../../support/pos_schema_helpers'

# A manager sets up the kitchen of a branch: stations, what each makes and
# when orders go to the kitchen. People who only work the kitchen read it.
RSpec.describe 'POS kitchen setup API', type: :request do
  include PosKitchenHelpers
  include PosSchemaHelpers

  let(:store) { menu_store }
  let(:branch) { kitchen_branch(store) }
  let(:manager) { credit_staff(store, branch, [Spree::Pos::Capabilities::MANAGE_KITCHEN]) }
  let(:cook) { credit_staff(store, branch, [Spree::Pos::Capabilities::OPERATE_KITCHEN]) }

  before { allow(Spree::Store).to receive(:default).and_return(store) }

  def bearer(user)
    post '/api/v3/admin/auth/login', params: { email: user.email, password: 'secret123' }, as: :json
    { 'Authorization' => "Bearer #{response.parsed_body.fetch('token')}" }
  end

  def write(verb, path, user, params = {})
    send(verb, path, headers: bearer(user).merge('Idempotency-Key' => SecureRandom.uuid), params: params, as: :json)
    response.parsed_body
  end

  it 'adds, changes and lists stations, keeping one default per branch' do
    printer = kitchen_printer!(branch)
    body = write(:post, '/api/v3/admin/pos/kitchen_stations', manager,
                 branch_id: branch.prefixed_id, name: 'Bếp nóng', kind: 'prep', is_default: true, printer_id: printer.prefixed_id)
    expect(response).to have_http_status(:created), response.body
    expect_pos_schema!(response, 'KitchenStation')
    expect(body['data']).to include('name' => 'Bếp nóng', 'printer_id' => printer.prefixed_id, 'is_default' => true,
                                    'warn_after_minutes' => 8, 'late_after_minutes' => 15)
    first = body['data']['id']

    second = write(:post, '/api/v3/admin/pos/kitchen_stations', manager,
                   branch_id: branch.prefixed_id, name: 'Bar', kind: 'bar', is_default: true, position: 1)['data']['id']
    expect(Spree::Pos::KitchenStation.find_by_prefix_id(first).is_default).to be(false)

    write(:patch, "/api/v3/admin/pos/kitchen_stations/#{second}", manager, warn_after_minutes: 5, late_after_minutes: 10)
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body['data']).to include('warn_after_minutes' => 5, 'late_after_minutes' => 10)

    write(:patch, "/api/v3/admin/pos/kitchen_stations/#{second}", manager, warn_after_minutes: 20, late_after_minutes: 10)
    expect(response).to have_http_status(:unprocessable_content).or have_http_status(:conflict)

    get '/api/v3/admin/pos/kitchen_stations', headers: bearer(cook), params: { branch_id: branch.prefixed_id }
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body['data'].map { |row| row['name'] }).to eq(['Bếp nóng', 'Bar'])
    expect(Spree::Pos::AuditEntry.where(subject_type: 'Spree::Pos::KitchenStation').count).to be >= 3
  end

  it 'routes a product or a category to a station once per service mode' do
    station = kitchen_station!(branch, name: 'Bar', kind: 'bar')
    item = menu_item!(store, branch, name: 'Cà phê', price: 25_000)

    body = write(:post, '/api/v3/admin/pos/station_routes', manager,
                 branch_id: branch.prefixed_id, kitchen_station_id: station.prefixed_id, product_id: item.product.prefixed_id)
    expect(response).to have_http_status(:created), response.body
    expect_pos_schema!(response, 'StationRoute')
    expect(body['data']).to include('product_name' => 'Cà phê', 'service_mode' => nil)

    write(:post, '/api/v3/admin/pos/station_routes', manager,
          branch_id: branch.prefixed_id, kitchen_station_id: station.prefixed_id, product_id: item.product.prefixed_id)
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('station_route_taken')

    write(:post, '/api/v3/admin/pos/station_routes', manager,
          branch_id: branch.prefixed_id, kitchen_station_id: station.prefixed_id, kitchen_category: 'drinks', service_mode: 'takeaway')
    expect(response).to have_http_status(:created)

    get '/api/v3/admin/pos/station_routes', headers: bearer(manager), params: { branch_id: branch.prefixed_id }
    expect(response.parsed_body['data'].size).to eq(2)

    write(:delete, "/api/v3/admin/pos/station_routes/#{body['data']['id']}", manager)
    expect(response).to have_http_status(:ok)
    expect(Spree::Pos::StationRoute.where(branch_id: branch.id).count).to eq(1)
  end

  it 'refuses to remove a station that has tickets' do
    station = kitchen_station!(branch, name: 'Bếp', default: true)
    branch.update!(kitchen_send_trigger: 'manual')
    sale = menu_sale(store, branch)
    add_menu(sale, size(menu_item!(store, branch, name: 'Bún chả', price: 40_000)))
    kitchen_send(sale)

    write(:delete, "/api/v3/admin/pos/kitchen_stations/#{station.prefixed_id}", manager)
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('kitchen_station_in_use')
    expect(station.reload).to be_persisted
  end

  it 'reads and changes when orders go to the kitchen' do
    get '/api/v3/admin/pos/kitchen_settings', headers: bearer(cook), params: { branch_id: branch.prefixed_id }
    expect(response).to have_http_status(:ok)
    expect_pos_schema!(response, 'KitchenSettings')
    expect(response.parsed_body['data']).to include('kitchen_send_trigger' => 'on_complete', 'module_enabled' => true)

    write(:put, '/api/v3/admin/pos/kitchen_settings', manager, branch_id: branch.prefixed_id, kitchen_send_trigger: 'manual')
    expect(response).to have_http_status(:ok)
    expect(branch.reload.kitchen_send_trigger).to eq('manual')

    write(:put, '/api/v3/admin/pos/kitchen_settings', manager, branch_id: branch.prefixed_id, kitchen_send_trigger: 'sometimes')
    expect(response.status).to be >= 400
    expect(branch.reload.kitchen_send_trigger).to eq('manual')
  end

  it 'reads and changes the void reasons of the branch, audited' do
    get '/api/v3/admin/pos/kitchen_settings', headers: bearer(cook), params: { branch_id: branch.prefixed_id }
    expect(response.parsed_body.dig('data', 'void_reasons')).to eq(%w[khach_doi_y het_mon nhap_nham lam_hong])

    body = write(:put, '/api/v3/admin/pos/kitchen_settings', manager, branch_id: branch.prefixed_id, void_reasons: %w[het_mon do_nguoi])
    expect(response).to have_http_status(:ok)
    expect_pos_schema!(response, 'KitchenSettings')
    expect(body['data']['void_reasons']).to eq(%w[het_mon do_nguoi])
    expect(branch.reload.void_reasons).to eq(%w[het_mon do_nguoi])
    expect(branch.kitchen_send_trigger).to eq('on_complete')
    audit = Spree::Pos::AuditEntry.find_by!(action: 'kitchen.void_reasons')
    expect(audit.metadata).to include('after' => %w[het_mon do_nguoi])

    [%w[khac], %w[Hết món], %w[a a]].each do |reasons|
      body = write(:put, '/api/v3/admin/pos/kitchen_settings', manager, branch_id: branch.prefixed_id, void_reasons: reasons)
      expect(body.dig('error', 'details', 'reason')).to eq('void_reasons_invalid')
    end
    write(:put, '/api/v3/admin/pos/kitchen_settings', cook, branch_id: branch.prefixed_id, void_reasons: [])
    expect(response).to have_http_status(:forbidden)
    expect(branch.reload.void_reasons).to eq(%w[het_mon do_nguoi])
  end

  it 'needs pos.kitchen.manage to change the setup and the kitchen on to add stations' do
    write(:post, '/api/v3/admin/pos/kitchen_stations', cook, branch_id: branch.prefixed_id, name: 'Bếp')
    expect(response).to have_http_status(:forbidden)
    write(:put, '/api/v3/admin/pos/kitchen_settings', cook, branch_id: branch.prefixed_id, kitchen_send_trigger: 'manual')
    expect(response).to have_http_status(:forbidden)

    cashier = credit_staff(store, branch, PosCreditHelpers::CASHIER)
    get '/api/v3/admin/pos/kitchen_stations', headers: bearer(cashier), params: { branch_id: branch.prefixed_id }
    expect(response).to have_http_status(:forbidden)

    set_pos_module(branch, 'fnb.kitchen', false)
    write(:post, '/api/v3/admin/pos/kitchen_stations', manager, branch_id: branch.prefixed_id, name: 'Bếp')
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('module_disabled')
    expect(Spree::Pos::KitchenStation.count).to eq(0)
  end
end
