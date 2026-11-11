# frozen_string_literal: true

require 'spree/api/testing_support/v3/base'
require_relative '../../../support/pos_table_helpers'
require_relative '../../../support/pos_schema_helpers'

# The full kitchen screen over the device API: several stations on one
# screen, the "by dish" bump, the pass, and a kitchen screen that cannot
# take orders even with a staff session open for a sold-out mark.
RSpec.describe 'POS kitchen board API', type: :request do
  include PosTableHelpers
  include PosSchemaHelpers

  let(:store) { menu_store }
  let(:branch) { table_branch(store) }
  let(:cashier) { credit_staff(store, branch, PosCreditHelpers::CASHIER) }
  let(:area) { area!(branch) }
  let(:soup) { menu_product!(store, branch, name: 'Phở bò', price: 50_000) }
  let(:tea) { menu_item!(store, branch, name: 'Trà đá', price: 5_000) }
  let!(:pass) { kitchen_station!(branch, name: 'Ra món', kind: 'expo', position: 2) }
  let!(:kitchen) { kitchen_station!(branch, name: 'Bếp', default: true) }
  let!(:bar) { kitchen_station!(branch, name: 'Bar', kind: 'bar', position: 1) }
  let(:token) { Spree::Pos::Device.new_token }
  let!(:screen) { kitchen_screen!(branch, token, station: kitchen) }
  let(:device) { { 'Authorization' => "Device #{token}" } }

  before do
    allow(Spree::Store).to receive(:default).and_return(store)
    table_register!(branch, cashier)
    station_route!(bar, product: tea.product)
    kitchen.update!(expo_station: pass)
  end

  def sent_table(name, *variants)
    order = open_table(cashier, table!(area, name: name))
    Spree::Pos::Workspaces::AppendItems.call(workspace: order.workspace, staff: cashier, key: SecureRandom.uuid,
                                             items: variants.map { |variant| { 'variant_id' => variant.prefixed_id, 'quantity' => 1 } })
    Spree::Pos::Kitchen::Send.command(workspace: order.workspace.reload, staff: cashier, key: SecureRandom.uuid,
                                      revision: order.workspace.revision, lease_generation: order.workspace.lease_generation,
                                      editor_id: order.editor_id)
    order
  end

  it 'shows two stations on one screen, bumps a dish by the all-day view and hands it to the pass' do
    first = sent_table('Bàn 1', soup, size(tea))
    sent_table('Bàn 2', soup)

    get '/api/v3/pos_device/kitchen/board', headers: device, params: { station_ids: [kitchen.prefixed_id, bar.prefixed_id].join(',') }
    expect(response).to have_http_status(:ok), response.body
    expect_pos_schema!(response, 'KitchenBoard')
    board = response.parsed_body['data']
    expect(board['stations'].map { |row| row['name'] }).to eq(%w[Bếp Bar])
    expect(board['open'].size).to eq(3)
    dish = board['all_day'].find { |row| row['quantity'] == '2.0' }
    expect(dish['item_ids'].size).to eq(2)

    post '/api/v3/pos_device/kitchen/all_day/bump', headers: device,
                                                    params: { station_ids: [kitchen.prefixed_id], key: dish['key'], quantity: 1 }, as: :json
    expect(response).to have_http_status(:ok), response.body
    expect_pos_schema!(response, 'KitchenTicket')
    moved = response.parsed_body['data'].sole
    expect(moved['workspace_id']).to eq(first.workspace.prefixed_id)
    expect(moved['items'].sole).to include('status' => 'ready', 'late' => false)
    expect(moved['items'].sole['prep_seconds']).to be >= 0

    get '/api/v3/pos_device/kitchen/board', headers: device, params: { station_id: pass.prefixed_id }
    expect_pos_schema!(response, 'KitchenBoard')
    expo = response.parsed_body.dig('data', 'expo').sole
    expect(expo['workspace_id']).to eq(first.workspace.prefixed_id)
    expect(expo['header']['table']).to start_with('Bàn 1')
    item_id = expo['items'].sole.dig('item', 'id')

    post "/api/v3/pos_device/kitchen/items/#{item_id}/serve", headers: device
    expect(response).to have_http_status(:ok)
    get '/api/v3/pos_device/kitchen/board', headers: device, params: { station_id: pass.prefixed_id }
    expect(response.parsed_body.dig('data', 'expo')).to eq([])

    # Called back from the pass within 30 minutes.
    post "/api/v3/pos_device/kitchen/items/#{item_id}/recall", headers: device
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.dig('data', 'items').find { |row| row['id'] == item_id }).to include('status' => 'preparing', 'recall_count' => 1)
  end

  it 'refuses an unknown service mode and a dish with nothing waiting' do
    get '/api/v3/pos_device/kitchen/board', headers: device, params: { service_mode: 'drive_in' }
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('service_mode_invalid')

    post '/api/v3/pos_device/kitchen/all_day/bump', headers: device, params: { key: 'nothing' }, as: :json
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('kitchen_all_day_empty')
  end

  it 'keeps a kitchen screen with a staff session off the selling API' do
    order = sent_table('Bàn 3', soup)
    cook = credit_staff(store, branch, PosCreditHelpers::CASHIER + [Spree::Pos::Capabilities::TABLE_SERVE])
    membership = Spree::Pos::StaffMembership.find_by!(staff: cook, branch: branch)
    membership.set_pin!('2468')
    post '/api/v3/pos_device/staff_sessions', headers: device, params: { membership_id: membership.prefixed_id, pin: '2468' }, as: :json
    expect(response).to have_http_status(:created), response.body
    signed = device.merge('X-Pos-Staff-Session' => response.parsed_body.dig('data', 'token'))

    key = SecureRandom.uuid
    post "/api/v3/admin/pos/workspaces/#{order.workspace.prefixed_id}/items/append", headers: signed.merge('Idempotency-Key' => key),
                                                                                     params: { items: [{ variant_id: soup.prefixed_id }] }, as: :json
    expect(response).to have_http_status(:forbidden)
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('device_mode_forbidden')

    # The sold-out mark it opened the session for still works.
    get '/api/v3/admin/pos/context', headers: signed
    expect(response).to have_http_status(:ok)
  end
end
