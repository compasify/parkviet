# frozen_string_literal: true

require 'spree/api/testing_support/v3/base'
require_relative '../../../support/pos_guest_helpers'
require_relative '../../../support/pos_schema_helpers'

# A guest's phone at a table, over the public guest API: a table's code
# opens a session bound to the table's open order, guests read the menu,
# send orders that wait for staff and call staff. Staff accept or reject
# over the staff API, and the accepted items reach the order and the kitchen.
RSpec.describe 'POS guest API', type: :request do
  include PosGuestHelpers
  include PosSchemaHelpers
  include ActiveSupport::Testing::TimeHelpers

  let(:store) { menu_store }
  let(:branch) { qr_branch(store) }
  let(:cashier) { credit_staff(store, branch, PosCreditHelpers::CASHIER) }
  let(:decider) { credit_staff(store, branch, PosGuestHelpers::DECIDER) }
  let(:table) { table!(area!(branch), name: 'Bàn 3') }
  let!(:item) { menu_item!(store, branch, name: 'Phở bò', price: 55_000) }
  let(:dish) { size(item) }
  let(:code_token) { table_code!(table).last }

  before do
    allow(Spree::Store).to receive(:default).and_return(store)
    Spree::Pos::GuestViewsController::LIMIT_STORE.clear
    table_register!(branch, cashier)
    kitchen_station!(branch, name: 'Bếp', default: true)
  end

  def bearer(user)
    @tokens ||= {}
    @tokens[user.id] ||= begin
      post '/api/v3/admin/auth/login', params: { email: user.email, password: 'secret123' }, as: :json
      response.parsed_body.fetch('token')
    end
    { 'Authorization' => "Bearer #{@tokens[user.id]}" }
  end

  def staff_call(user, verb, path, params = {})
    send(verb, "/api/v3/admin/pos/#{path}", headers: bearer(user).merge('Idempotency-Key' => SecureRandom.uuid), params: params, as: :json)
    response.parsed_body
  end

  def open_guest(token = code_token)
    post '/api/v3/pos_guest/session', params: { table_code: token }, as: :json
    response.parsed_body['data']
  end

  def guest(verb, path, session_token, params = {}, headers = {})
    send(verb, "/api/v3/pos_guest/#{path}", headers: { 'Authorization' => "Guest #{session_token}" }.merge(headers), params: params, as: :json)
    response.parsed_body
  end

  def guest_order(session_token, items, key = SecureRandom.uuid)
    guest(:post, 'guest_orders', session_token, { items: items }, 'Idempotency-Key' => key)
  end

  it 'opens a session at an open table, takes an order that staff accept, and shows it on the order and the kitchen' do
    workspace = open_table(cashier, table).workspace
    opened = open_guest
    expect(response).to have_http_status(:created)
    expect(response.headers['Cache-Control']).to eq('no-store')
    expect(response.headers['Referrer-Policy']).to eq('no-referrer')
    expect_pos_schema!(response, 'GuestSession', file: 'pos-guest.yaml')
    expect(opened).to include('status' => 'open', 'table' => { 'name' => 'Bàn 3', 'kind' => 'table' })
    token = opened.fetch('token')

    menu = guest(:get, 'menu', token)
    expect_pos_schema!(response, 'GuestMenu', file: 'pos-guest.yaml')
    row = menu.dig('data', 'items').sole
    expect(row.keys).not_to include('sku', 'barcode', 'list_price', 'kitchen_category', 'tax_category_id')
    expect(row['variants'].sole).to eq('id' => dish.prefixed_id, 'name' => nil, 'price' => '55000.0', 'price_label' => nil)

    messages = []
    allow(ActionCable.server).to receive(:broadcast) { |_stream, message| messages << message }
    body = guest_order(token, [{ variant_id: dish.prefixed_id, quantity: 2, price: '1000', unit_price: '1000' }])
    expect(response).to have_http_status(:created), response.body
    expect_pos_schema!(response, 'GuestOrder', file: 'pos-guest.yaml')
    expect(body['data']).to include('status' => 'pending', 'quoted_total' => '110000.0')
    expect(messages.map { |message| message[:event] }).to include('guest_order.created')

    pending = staff_call(decider, :get, 'guest_orders', branch_id: branch.prefixed_id)
    expect(response).to have_http_status(:ok)
    expect_pos_schema!(response, 'GuestOrder')
    expect(pending['data'].sole).to include('table_name' => 'Bàn 3 A', 'status' => 'pending', 'quoted_total' => '110000.0')

    accepted = staff_call(decider, :post, "guest_orders/#{pending['data'].sole['id']}/accept")
    expect(response).to have_http_status(:ok), response.body
    expect_pos_schema!(response, 'GuestOrder')
    expect(accepted.dig('meta', 'kitchen_ticket_count')).to eq(1)
    expect(Spree::Pos::SaleLine.where(workspace_id: workspace.id).sole).to have_attributes(sale_quantity: 2, added_by_id: decider.id)
    expect(Spree::Pos::KitchenTicket.where(workspace_id: workspace.id).sole.items.sole.quantity).to eq(2)

    table_view = guest(:get, 'order', token)
    expect_pos_schema!(response, 'GuestTable', file: 'pos-guest.yaml')
    expect(table_view.dig('data', 'lines').sole).to include('name' => 'Phở bò', 'quantity' => '2.0', 'kitchen' => 'sent')
    expect(table_view.dig('data', 'orders').sole).to include('status' => 'accepted')
    expect(table_view.to_json).not_to include(decider.email)
  end

  it 'opens a menu-only session at a table with no open order' do
    opened = open_guest
    expect(opened).to include('status' => 'table_closed')
    token = opened.fetch('token')

    guest(:get, 'menu', token)
    expect(response).to have_http_status(:ok)
    body = guest_order(token, [{ variant_id: dish.prefixed_id }])
    expect(response).to have_http_status(:conflict)
    expect(body.dig('error', 'code')).to eq('table_closed')

    call = guest(:post, 'requests', token, kind: 'call_staff')
    expect(response).to have_http_status(:created)
    expect(guest(:post, 'requests', token, kind: 'call_staff').dig('data', 'id')).to eq(call.dig('data', 'id'))
    guest(:post, 'requests', token, kind: 'request_bill')
    expect(response.parsed_body.dig('error', 'code')).to eq('table_closed')
  end

  it 'refuses an unknown or rotated code, and a session of an earlier opening of the table' do
    open_guest('not-a-real-code-1234')
    expect(response).to have_http_status(:not_found)
    expect(response.parsed_body.dig('error', 'code')).to eq('table_code_invalid')

    first = open_table(cashier, table).workspace
    token = open_guest.fetch('token')
    close_order!(first)
    guest(:get, 'menu', token)
    expect(response).to have_http_status(:unauthorized)
    expect(response.parsed_body.dig('error', 'code')).to eq('session_expired')

    open_table(cashier, table)
    guest_order(token, [{ variant_id: dish.prefixed_id }])
    expect(response).to have_http_status(:unauthorized)

    fresh = open_guest.fetch('token')
    old_code = code_token
    table_code!(table)
    guest(:get, 'menu', fresh)
    expect(response.parsed_body.dig('error', 'code')).to eq('session_expired')
    open_guest(old_code)
    expect(response).to have_http_status(:not_found)
  end

  it 'expires a session after four hours' do
    open_table(cashier, table)
    token = open_guest.fetch('token')
    travel_to(Time.current + 4.hours + 1.minute) do
      guest(:get, 'order', token)
      expect(response.parsed_body.dig('error', 'code')).to eq('session_expired')
    end
  end

  it 'answers item_sold_out for an item sold out at the branch' do
    open_table(cashier, table)
    token = open_guest.fetch('token')
    sold_out!(item)
    body = guest_order(token, [{ variant_id: dish.prefixed_id }])
    expect(response).to have_http_status(:conflict)
    expect(body['error']).to include('code' => 'item_sold_out', 'details' => { 'menu_item_id' => item.prefixed_id })
  end

  it 'requires an idempotency key and replays the same order for the same key' do
    open_table(cashier, table)
    token = open_guest.fetch('token')
    guest(:post, 'guest_orders', token, items: [{ variant_id: dish.prefixed_id }])
    expect(response.parsed_body.dig('error', 'code')).to eq('idempotency_key_required')

    key = SecureRandom.uuid
    first = guest_order(token, [{ variant_id: dish.prefixed_id }], key)
    expect(guest_order(token, [{ variant_id: dish.prefixed_id }], key).dig('data', 'id')).to eq(first.dig('data', 'id'))
  end

  it 'rate limits opening sessions per address and orders per session' do
    10.times { open_guest }
    open_guest
    expect(response).to have_http_status(:too_many_requests)
    expect(response.parsed_body.dig('error', 'code')).to eq('rate_limited')

    Spree::Pos::GuestViewsController::LIMIT_STORE.clear
    open_table(cashier, table)
    token = open_guest.fetch('token')
    5.times { guest_order(token, [{ variant_id: dish.prefixed_id }]) }
    guest_order(token, [{ variant_id: dish.prefixed_id }])
    expect(response).to have_http_status(:too_many_requests)
  end

  it 'never takes a staff token on the guest API, and a guest token never opens the staff API' do
    open_table(cashier, table)
    token = open_guest.fetch('token')

    get '/api/v3/pos_guest/menu', headers: bearer(decider), as: :json
    expect(response).to have_http_status(:unauthorized)
    get '/api/v3/pos_guest/menu', headers: { 'Authorization' => "Bearer #{token}" }, as: :json
    expect(response).to have_http_status(:unauthorized)

    %w[guest_orders guest_requests table_codes context resource_board].each do |path|
      get "/api/v3/admin/pos/#{path}", headers: { 'Authorization' => "Guest #{token}" }, params: { branch_id: branch.prefixed_id }
      expect(response.status).to be_in([401, 403]), "#{path} answered #{response.status}"
    end
  end

  it 'shuts the guest API when the module or the switch is off' do
    open_table(cashier, table)
    token = open_guest.fetch('token')
    set_pos_module(branch, 'fnb.qr_order', false)
    guest(:get, 'menu', token)
    expect(response).to have_http_status(:unauthorized)
    expect(response.parsed_body.dig('error', 'code')).to eq('qr_order_unavailable')
    open_guest
    expect(response).to have_http_status(:not_found)
  end

  it 'lets staff reject with a reason and close a guest request' do
    open_table(cashier, table)
    token = open_guest.fetch('token')
    order_id = guest_order(token, [{ variant_id: dish.prefixed_id }]).dig('data', 'id')
    guest(:post, 'requests', token, kind: 'request_bill')

    staff_call(cashier, :post, "guest_orders/#{order_id}/reject", reason: 'Hết món')
    expect(response).to have_http_status(:forbidden)
    rejected = staff_call(decider, :post, "guest_orders/#{order_id}/reject", reason: 'Hết món')
    expect(rejected.dig('data', 'status')).to eq('rejected')
    expect(guest(:get, 'order', token).dig('data', 'orders').sole).to include('status' => 'rejected', 'reject_reason' => 'Hết món')

    requests = staff_call(cashier, :get, 'guest_requests', branch_id: branch.prefixed_id)
    expect_pos_schema!(response, 'GuestRequest')
    expect(requests['data'].sole).to include('kind' => 'request_bill', 'table_name' => 'Bàn 3')
    staff_call(cashier, :post, "guest_requests/#{requests['data'].sole['id']}/done")
    expect(response).to have_http_status(:ok)
    expect(staff_call(cashier, :get, 'guest_requests', branch_id: branch.prefixed_id)['data']).to be_empty
  end

  it 'issues a table code with its link once, rotates it with an audit and refuses people outside the floor plan' do
    manager = credit_staff(store, branch, PosGuestHelpers::MANAGER)
    key = SecureRandom.uuid
    post '/api/v3/admin/pos/table_codes', headers: bearer(manager).merge('Idempotency-Key' => key), params: { resource_id: table.prefixed_id }, as: :json
    expect(response).to have_http_status(:created), response.body
    expect_pos_schema!(response, 'TableCode')
    meta = response.parsed_body['meta']
    expect(meta['url']).to eq("http://www.example.com/table/t/#{meta['token']}")
    expect(Spree::Pos::TableCode.where(token_digest: Spree::Pos::TableCode.digest(meta['token']))).to exist
    expect(Spree::Pos::CommandReceipt.last.result.to_json).not_to include(meta['token'])

    post '/api/v3/admin/pos/table_codes', headers: bearer(manager).merge('Idempotency-Key' => key), params: { resource_id: table.prefixed_id }, as: :json
    expect(response.parsed_body['meta']).to include('token' => nil, 'url' => nil)

    staff_call(manager, :post, 'table_codes', resource_id: table.prefixed_id)
    expect(Spree::Pos::TableCode.where(resource_id: table.id).pluck(:status)).to contain_exactly('revoked', 'active')
    expect(Spree::Pos::AuditEntry.where(action: 'table_code.rotate').count).to eq(2)

    listing = staff_call(manager, :get, 'table_codes', branch_id: branch.prefixed_id)
    expect_pos_schema!(response, 'TableCodeEntry')
    expect(listing['data'].sole).to include('resource_id' => table.prefixed_id)

    staff_call(cashier, :post, 'table_codes', resource_id: table.prefixed_id)
    expect(response).to have_http_status(:forbidden)
  end
end
