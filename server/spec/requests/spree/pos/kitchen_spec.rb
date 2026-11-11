# frozen_string_literal: true

require 'spree/api/testing_support/v3/base'
require_relative '../../../support/pos_kitchen_helpers'
require_relative '../../../support/pos_schema_helpers'

# The cashier sends an order; the kitchen screen sees it on the server's
# clock, works it item by item and bumps it; people with the kitchen
# capability do the same on the admin API.
RSpec.describe 'POS kitchen API', type: :request do
  include PosKitchenHelpers
  include PosSchemaHelpers
  include ActionCable::TestHelper

  let(:store) { menu_store }
  let(:branch) { kitchen_branch(store, trigger: 'manual') }
  let(:item) { menu_item!(store, branch, name: 'Cơm tấm', price: 45_000) }
  let!(:station) { kitchen_station!(branch, name: 'Bếp', default: true) }
  let(:token) { Spree::Pos::Device.new_token }
  let!(:screen) { kitchen_screen!(branch, token) }
  let(:device) { { 'Authorization' => "Device #{token}" } }
  let(:sale) { menu_sale(store, branch) }

  before { allow(Spree::Store).to receive(:default).and_return(store) }

  def bearer(user)
    post '/api/v3/admin/auth/login', params: { email: user.email, password: 'secret123' }, as: :json
    { 'Authorization' => "Bearer #{response.parsed_body.fetch('token')}" }
  end

  def send_order(headers = bearer(sale.cashier))
    workspace = sale.workspace.reload
    post "/api/v3/admin/pos/workspaces/#{workspace.prefixed_id}/kitchen_sends",
         headers: headers.merge('Idempotency-Key' => SecureRandom.uuid),
         params: { expected_revision: workspace.revision, lease_generation: workspace.lease_generation, editor_id: sale.editor_id },
         as: :json
    response.parsed_body
  end

  it 'sends an order from the counter and shows it on the kitchen screen' do
    add_menu(sale, size(item), quantity: 2, note: 'Thêm mỡ hành')
    body = send_order
    expect(response).to have_http_status(:created), response.body
    expect_pos_schema!(response, 'Workspace')
    expect(body.dig('data', 'line_items', 0, 'kitchen_sent_quantity')).to eq('2.0')
    ticket = body.dig('meta', 'tickets').sole
    expect(JSONSchemer.schema(pos_component_schema('KitchenTicket')).validate(ticket).to_a).to eq([])

    get '/api/v3/pos_device/kitchen/board', headers: device
    expect(response).to have_http_status(:ok), response.body
    expect_pos_schema!(response, 'KitchenBoard')
    board = response.parsed_body['data']
    # No station chosen on the screen yet: every station of the branch.
    expect(board['station']).to be_nil
    expect(board['stations'].map { |row| row['id'] }).to eq([station.prefixed_id])
    expect(board['open'].map { |row| row['id'] }).to eq([ticket['id']])
    expect(board['open'].sole['items'].sole).to include('name' => 'Cơm tấm', 'quantity' => '2.0', 'note' => 'Thêm mỡ hành', 'status' => 'new')
    expect(Time.iso8601(board['server_now'])).to be_within(1.minute).of(Time.current)

    get "/api/v3/admin/pos/workspaces/#{sale.workspace.prefixed_id}/kitchen_tickets", headers: bearer(sale.cashier)
    expect(response).to have_http_status(:ok)
    expect_pos_schema!(response, 'KitchenTicket')
    expect(response.parsed_body['data'].map { |row| row['sequence'] }).to eq([1])

    # Nothing left: an empty send.
    expect(send_order.dig('meta', 'tickets')).to eq([])
  end

  it 'works items and bumps tickets from the kitchen screen without a PIN' do
    add_menu(sale, size(item))
    add_menu(sale, size(item), note: 'Ít cơm')
    ticket = send_order.dig('meta', 'tickets').sole
    first, second = ticket['items'].map { |row| row['id'] }

    put '/api/v3/pos_device/kitchen/station', headers: device, params: { station_id: station.prefixed_id }, as: :json
    expect(response).to have_http_status(:ok)
    expect_pos_schema!(response, 'Device')
    expect(screen.reload.kitchen_station).to eq(station)

    post "/api/v3/pos_device/kitchen/items/#{first}/start", headers: device
    expect(response).to have_http_status(:ok), response.body
    expect_pos_schema!(response, 'KitchenTicket')
    expect(response.parsed_body.dig('data', 'items', 0, 'status')).to eq('preparing')
    expect(Spree::Pos::KitchenTicketItem.find_by_prefix_id(first).changed_by).to eq(screen)

    post "/api/v3/pos_device/kitchen/items/#{first}/serve", headers: device
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('kitchen_status_invalid')

    expect do
      post "/api/v3/pos_device/kitchen/tickets/#{ticket['id']}/bump", headers: device
    end.to have_broadcasted_to(Spree::Pos::Realtime.stream_name(branch)).with(hash_including(event: 'kitchen_ticket.updated'))
    expect(response.parsed_body.dig('data', 'done')).to be(true)

    get '/api/v3/pos_device/kitchen/board', headers: device
    board = response.parsed_body['data']
    expect(board['open']).to eq([])
    expect(board['done'].map { |row| row['id'] }).to eq([ticket['id']])

    post "/api/v3/pos_device/kitchen/items/#{second}/recall", headers: device
    expect(response).to have_http_status(:ok)
    get '/api/v3/pos_device/kitchen/board', headers: device
    expect(response.parsed_body.dig('data', 'open').map { |row| row['id'] }).to eq([ticket['id']])
  end

  it 'lists the stations and what a station makes, with today\'s sold-out state' do
    bar = kitchen_station!(branch, name: 'Bar', kind: 'bar', position: 1)
    tea = menu_item!(store, branch, name: 'Trà đá', price: 5_000)
    station_route!(bar, product: tea.product)
    item

    get '/api/v3/pos_device/kitchen/stations', headers: device
    expect(response).to have_http_status(:ok)
    expect_pos_schema!(response, 'KitchenStation')
    expect(response.parsed_body['data'].map { |row| row['name'] }).to eq(%w[Bếp Bar])

    get '/api/v3/pos_device/kitchen/menu_items', headers: device, params: { station_id: bar.prefixed_id }
    expect(response).to have_http_status(:ok)
    expect_pos_schema!(response, 'KitchenMenuItem')
    expect(response.parsed_body['data'].map { |row| row['name'] }).to eq(['Trà đá'])

    get '/api/v3/pos_device/kitchen/menu_items', headers: device, params: { station_id: station.prefixed_id }
    expect(response.parsed_body['data'].map { |row| row['name'] }).to eq(['Cơm tấm'])
  end

  it 'keeps other device modes and other branches off the kitchen' do
    other_token = Spree::Pos::Device.new_token
    kitchen_screen!(branch, other_token, mode: 'print_station')
    get '/api/v3/pos_device/kitchen/board', headers: { 'Authorization' => "Device #{other_token}" }
    expect(response).to have_http_status(:forbidden)

    add_menu(sale, size(item))
    ticket = send_order.dig('meta', 'tickets').sole
    far = kitchen_branch(store, trigger: 'manual')
    far_token = Spree::Pos::Device.new_token
    kitchen_screen!(far, far_token)
    post "/api/v3/pos_device/kitchen/tickets/#{ticket['id']}/bump", headers: { 'Authorization' => "Device #{far_token}" }
    expect(response).to have_http_status(:not_found)
    expect(Spree::Pos::KitchenTicket.find_by_prefix_id(ticket['id']).done?).to be(false)
  end

  it 'lets people with the kitchen capability work the board on the admin API, and nobody else' do
    add_menu(sale, size(item))
    ticket = send_order.dig('meta', 'tickets').sole
    cook = credit_staff(store, branch, [Spree::Pos::Capabilities::OPERATE_KITCHEN])

    get '/api/v3/admin/pos/kitchen/board', headers: bearer(cook), params: { branch_id: branch.prefixed_id, station_id: station.prefixed_id }
    expect(response).to have_http_status(:ok), response.body
    expect_pos_schema!(response, 'KitchenBoard')
    expect(response.parsed_body.dig('data', 'open').size).to eq(1)

    post "/api/v3/admin/pos/kitchen/items/#{ticket['items'].sole['id']}/ready", headers: bearer(cook)
    expect(response).to have_http_status(:ok)
    expect(Spree::Pos::KitchenTicketItem.find_by_prefix_id(ticket['items'].sole['id'])).to have_attributes(status: 'ready', changed_by: cook)

    get '/api/v3/admin/pos/kitchen/board', headers: bearer(sale.cashier), params: { branch_id: branch.prefixed_id }
    expect(response).to have_http_status(:forbidden)
    post "/api/v3/admin/pos/kitchen/tickets/#{ticket['id']}/bump", headers: bearer(sale.cashier)
    expect(response).to have_http_status(:forbidden)
  end

  it 'refuses the send button when the kitchen is off at the branch' do
    set_pos_module(branch, 'fnb.kitchen', false)
    add_menu(sale, size(item))
    send_order
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('module_disabled')
  end
end
