# frozen_string_literal: true

require 'spree/api/testing_support/v3/base'
require_relative '../../../support/pos_table_helpers'
require_relative '../../../support/pos_schema_helpers'

# A waiter's phone, signed in with a PIN: it takes orders through the same
# table commands as the counter, hears when its tables' dishes are ready,
# follows tables, prints the checklist and moves a table under a lease.
RSpec.describe 'POS waiter device API', type: :request do
  include PosTableHelpers
  include PosSchemaHelpers

  let(:store) { menu_store }
  let(:branch) { table_branch(store) }
  let(:cashier) { credit_staff(store, branch, PosCreditHelpers::CASHIER) }
  let(:waiter) { credit_staff(store, branch, PosTableHelpers::WAITER) }
  let(:area) { area!(branch) }
  let(:soup) { menu_product!(store, branch, name: 'Phở bò', price: 50_000) }
  let!(:kitchen) { kitchen_station!(branch, name: 'Bếp', default: true) }
  let(:screen) { kitchen_screen!(branch, Spree::Pos::Device.new_token) }
  let(:token) { Spree::Pos::Device.new_token }
  let!(:phone) do
    Spree::Pos::Device.create!(store: store, branch: branch, name: 'Phục vụ 1', mode: 'waiter', platform: 'android',
                               token_digest: Spree::Pos::Device.digest(token))
  end

  before do
    allow(Spree::Store).to receive(:default).and_return(store)
    table_register!(branch, cashier)
  end

  def signed_in(staff)
    membership = Spree::Pos::StaffMembership.find_by!(staff: staff, branch: branch)
    membership.set_pin!('2468')
    post '/api/v3/pos_device/staff_sessions', headers: { 'Authorization' => "Device #{token}" },
                                              params: { membership_id: membership.prefixed_id, pin: '2468' }, as: :json
    expect(response).to have_http_status(:created), response.body
    { 'Authorization' => "Device #{token}", 'X-Pos-Staff-Session' => response.parsed_body.dig('data', 'token') }
  end

  def call(headers, verb, path, params = {})
    send(verb, "/api/v3/admin/pos/#{path}", headers: headers.merge('Idempotency-Key' => SecureRandom.uuid), params: params, as: :json)
    response.parsed_body
  end

  def ready!(workspace)
    Spree::Pos::KitchenTicket.where(workspace_id: workspace.id).find_each do |ticket|
      Spree::Pos::Kitchen::ChangeItemStatus.bump(ticket: ticket, actor: screen)
    end
  end

  it 'opens a table, orders and sends from the phone, then hears the dish is ready' do
    phone_headers = signed_in(waiter)
    table = table!(area, name: 'Bàn 5')
    opened = call(phone_headers, :post, "tables/#{table.prefixed_id}/open", guest_count: 3, editor_id: SecureRandom.uuid,
                                                                            branch_id: branch.prefixed_id)
    expect(response).to have_http_status(:created), response.body
    id = opened.dig('data', 'id')

    call(phone_headers, :post, "workspaces/#{id}/items/append", items: [{ variant_id: soup.prefixed_id, quantity: 2 }],
                                                                append_batch_id: SecureRandom.uuid)
    expect(response).to have_http_status(:ok), response.body
    expect(Spree::Pos::SaleLine.where(added_device_id: phone.id).count).to eq(1)
    call(phone_headers, :post, "workspaces/#{id}/kitchen_sends")
    expect(response).to have_http_status(:created), response.body

    get '/api/v3/admin/pos/devices/current/ready_feed', headers: phone_headers
    expect(response).to have_http_status(:ok), response.body
    expect(response.parsed_body.dig('data', 'items')).to eq([])

    ready!(Spree::Pos::Workspace.find_by_prefix_id!(id))
    get '/api/v3/admin/pos/devices/current/ready_feed', headers: phone_headers
    expect_pos_schema!(response, 'ReadyFeed')
    item = response.parsed_body.dig('data', 'items').sole
    expect(item).to include('table_name' => 'Bàn 5', 'quantity' => '2.0', 'status' => 'ready', 'workspace_id' => id)

    get "/api/v3/admin/pos/workspaces/#{id}", headers: phone_headers
    expect(response).to have_http_status(:ok)
    expect_pos_schema!(response, 'Workspace')
    expect(response.parsed_body.dig('data', 'line_items').sole['kitchen_status']).to eq('ready' => '2.0')
  end

  it 'follows a table someone else serves, and every table of an area on request' do
    phone_headers = signed_in(waiter)
    other = open_table(cashier, table!(area, name: 'Bàn 7'))
    add_dish(other, soup)
    kitchen_send(other)
    ready!(other.workspace)

    get '/api/v3/admin/pos/devices/current/ready_feed', headers: phone_headers
    expect(response.parsed_body.dig('data', 'items')).to eq([])
    get '/api/v3/admin/pos/devices/current/ready_feed', headers: phone_headers, params: { area_id: area.prefixed_id }
    expect(response.parsed_body.dig('data', 'items').size).to eq(1)

    resource_id = other.workspace.resource.prefixed_id
    body = call(phone_headers, :post, 'devices/current/table_pins', resource_id: resource_id)
    expect(response).to have_http_status(:ok), response.body
    expect_pos_schema!(response, 'TablePins')
    expect(body.dig('data', 'pinned')).to eq([resource_id])
    call(phone_headers, :post, 'devices/current/table_pins', resource_id: resource_id)
    expect(Spree::Pos::DeviceTablePin.count).to eq(1)

    get '/api/v3/admin/pos/devices/current/ready_feed', headers: phone_headers
    expect(response.parsed_body.dig('data', 'items').sole['table_name']).to eq('Bàn 7')

    call(phone_headers, :delete, "devices/current/table_pins/#{resource_id}")
    expect(response.parsed_body.dig('data', 'pinned')).to eq([])
    get '/api/v3/admin/pos/devices/current/table_pins', headers: phone_headers
    expect(response.parsed_body['data']).to eq('pinned' => [], 'serving' => [])
  end

  it 'prints the checklist of a table with what came out and what is still to come' do
    phone_headers = signed_in(waiter)
    order = open_table(cashier, table!(area, name: 'Bàn 2'))
    add_dish(order, soup, quantity: 2)
    kitchen_send(order)
    ticket = Spree::Pos::KitchenTicket.where(workspace_id: order.workspace.id).sole
    Spree::Pos::Kitchen::ChangeItemStatus.bump(ticket: ticket, actor: screen)
    Spree::Pos::Kitchen::ChangeItemStatus.serve_order(workspace: order.workspace, actor: screen)

    printer = kitchen_printer!(branch)
    printer.update!(roles: %w[kitchen_ticket checklist])
    body = call(phone_headers, :post, "workspaces/#{order.workspace.prefixed_id}/checklist", printer_id: printer.prefixed_id)
    expect(response).to have_http_status(:created), response.body
    expect_pos_schema!(response, 'ChecklistOutcome')
    texts = body.dig('data', 'document', 'header').flat_map { |block| Array(block['lines']) }
    expect(texts).to include('2 x Phở bò', 'Đã ra 2 · Chưa ra 0')
    expect(Spree::Pos::PrintJob.where(kind: 'checklist', printer: printer).count).to eq(1)
    expect(body.dig('data', 'print_job', 'kind')).to eq('checklist')
  end

  it 'moves a table from the phone under a lease' do
    phone_headers = signed_in(waiter)
    editor_id = SecureRandom.uuid
    table = table!(area, name: 'Bàn 3')
    id = call(phone_headers, :post, "tables/#{table.prefixed_id}/open", editor_id: editor_id, branch_id: branch.prefixed_id).dig('data', 'id')
    target = table!(area, name: 'Bàn 4', x: 4)
    # Move needs this screen's lease, taken again when the order is reopened later.
    claimed = call(phone_headers, :post, "workspaces/#{id}/lease", editor_id: editor_id)
    expect(response).to have_http_status(:ok), response.body
    moved = call(phone_headers, :post, "workspaces/#{id}/move",
                 resource_id: target.prefixed_id, expected_revision: claimed.dig('data', 'revision'),
                 lease_generation: claimed.dig('data', 'lease_generation'), editor_id: editor_id)
    expect(response).to have_http_status(:ok), response.body
    expect(moved.dig('data', 'resource', 'name')).to eq('Bàn 4')
  end

  it 'reads the tables, the menu and the printers the phone works with' do
    phone_headers = signed_in(waiter)
    soup
    table!(area, name: 'Bàn 6')

    get '/api/v3/admin/pos/resource_board', headers: phone_headers, params: { branch_id: branch.prefixed_id }
    expect(response).to have_http_status(:ok), response.body
    expect(response.parsed_body.dig('data', 'resources').map { |row| row['name'] }).to include('Bàn 6')
    get '/api/v3/admin/pos/menu', headers: phone_headers, params: { branch_id: branch.prefixed_id }
    expect(response).to have_http_status(:ok), response.body
    expect(response.parsed_body.dig('data', 'items').map { |row| row['name'] }).to include('Phở bò')
    get '/api/v3/admin/pos/printers', headers: phone_headers, params: { branch_id: branch.prefixed_id }
    expect(response).to have_http_status(:ok), response.body
  end

  it 'refuses a person without pos.table.serve and a device that is not a waiter' do
    clerk = credit_staff(store, branch, [Spree::Pos::Capabilities::OPEN_SHIFT])
    phone_headers = signed_in(clerk)
    order = open_table(cashier, table!(area, name: 'Bàn 9'))

    get '/api/v3/admin/pos/devices/current/ready_feed', headers: phone_headers
    expect(response).to have_http_status(:forbidden)
    call(phone_headers, :post, "workspaces/#{order.workspace.prefixed_id}/items/append", items: [{ variant_id: soup.prefixed_id }])
    expect(response.status).to be_in([403, 404])

    owner_token = Spree::Pos::Device.new_token
    Spree::Pos::Device.create!(store: store, branch: branch, name: 'Chủ', mode: 'owner', platform: 'ios',
                               token_digest: Spree::Pos::Device.digest(owner_token))
    membership = Spree::Pos::StaffMembership.find_by!(staff: waiter, branch: branch)
    membership.set_pin!('1357')
    post '/api/v3/pos_device/staff_sessions', headers: { 'Authorization' => "Device #{owner_token}" },
                                              params: { membership_id: membership.prefixed_id, pin: '1357' }, as: :json
    owner = { 'Authorization' => "Device #{owner_token}", 'X-Pos-Staff-Session' => response.parsed_body.dig('data', 'token') }
    get '/api/v3/admin/pos/devices/current/ready_feed', headers: owner
    expect(response).to have_http_status(:forbidden)
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('device_mode_forbidden')
  end
end
