# frozen_string_literal: true

require 'spree/api/testing_support/v3/base'
require_relative '../../../support/pos_table_helpers'
require_relative '../../../support/pos_schema_helpers'

# The floor plan is set up by a manager, and the counter reads the live
# floor: each table's state comes from its open orders, in a fixed number
# of queries whatever the number of tables.
RSpec.describe 'POS floor plan and resource board', type: :request do
  include PosTableHelpers
  include PosSchemaHelpers

  let(:store) { menu_store }
  let(:branch) { table_branch(store) }
  let(:cashier) { credit_staff(store, branch, PosCreditHelpers::CASHIER) }
  let(:manager) { credit_staff(store, branch, [Spree::Pos::Capabilities::RESOURCE_MANAGE]) }
  let(:waiter) { credit_staff(store, branch, PosTableHelpers::WAITER) }
  let(:dish) { menu_product!(store, branch, price: 40_000) }

  before { allow(Spree::Store).to receive(:default).and_return(store) }

  def bearer(user)
    post '/api/v3/admin/auth/login', params: { email: user.email, password: 'secret123' }, as: :json
    { 'Authorization' => "Bearer #{response.parsed_body.fetch('token')}" }
  end

  def write(user, verb, path, params = {})
    send(verb, "/api/v3/admin/pos/#{path}", headers: bearer(user).merge('Idempotency-Key' => SecureRandom.uuid), params: params, as: :json)
    response.parsed_body
  end

  it 'lets a manager draw the floor plan, and keeps waiters to marking tables' do
    area = write(manager, :post, 'areas', branch_id: branch.prefixed_id, name: 'Sân vườn', floor_width: 12, floor_height: 8)['data']
    expect(response).to have_http_status(:created), response.body
    expect_pos_schema!(response, 'Area')

    table = write(manager, :post, 'resources', branch_id: branch.prefixed_id, area_id: area['id'], name: 'B1', x: 2, y: 2, w: 2, h: 2,
                                               shape: 'round', capacity: 6)['data']
    expect(response).to have_http_status(:created), response.body
    expect_pos_schema!(response, 'Resource')
    expect(table).to include('shape' => 'round', 'capacity' => 6, 'area_id' => area['id'])

    write(manager, :patch, "resources/#{table['id']}", x: 11)
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('resource_outside_area')

    write(waiter, :post, 'resources', branch_id: branch.prefixed_id, area_id: area['id'], name: 'B2')
    expect(response).to have_http_status(:forbidden)
    write(waiter, :post, "resources/#{table['id']}/manual_status", manual_status: 'cleaning')
    expect(response).to have_http_status(:ok), response.body
    expect(response.parsed_body.dig('data', 'manual_status')).to eq('cleaning')

    get '/api/v3/admin/pos/resources', headers: bearer(waiter), params: { branch_id: branch.prefixed_id }
    expect(response).to have_http_status(:ok)
    expect_pos_schema!(response, 'Resource')
    expect(response.parsed_body['data'].map { |row| row['name'] }).to eq(['B1'])
  end

  it 'keeps the floor plan to branches running resources' do
    set_pos_module(branch, 'resources', false)
    write(manager, :post, 'areas', branch_id: branch.prefixed_id, name: 'Tầng 2')
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('module_disabled')
  end

  describe 'the board' do
    let(:area) { area!(branch, width: 200, height: 200) }
    let!(:tables) { Array.new(80) { |index| table!(area, name: "Bàn #{index + 1}", x: (index % 20) * 2, y: (index / 20) * 2) } }

    before do
      table_register!(branch, cashier)
      kitchen_station!(branch, name: 'Bếp', default: true)
    end

    it 'shows each table’s state from its orders in a fixed number of queries' do
      seated = open_table(waiter, tables[0], guest_count: 3)
      add_dish(seated, dish)
      sent = open_table(cashier, tables[1])
      add_dish(sent, dish)
      kitchen_send(sent)
      asked = open_table(waiter, tables[2])
      add_dish(asked, dish)
      Spree::Pos::Tables::RequestPayment.call(workspace: asked.workspace.reload, staff: waiter, key: SecureRandom.uuid)
      billed = open_table(cashier, tables[3])
      add_dish(billed, dish)
      Spree::Pos::Workspaces::Prebill.call(workspace: billed.workspace.reload, staff: cashier, key: SecureRandom.uuid)
      tables[4].update!(manual_status: 'cleaning')
      tables[5].update!(manual_status: 'out_of_service')

      queries = []
      counter = ->(*, payload) { queries << payload[:sql] unless payload[:name] == 'SCHEMA' || payload[:sql].start_with?('SAVEPOINT', 'RELEASE') }
      board = ActiveSupport::Notifications.subscribed(counter, 'sql.active_record') { Spree::Pos::ResourceState.for(branch) }
      expect(queries.size).to be <= 6, queries.join("\n")

      states = board[:resources].first(7).map { |tile| tile[:state] }
      expect(states).to eq(%w[occupied ordered payment_requested prebilled cleaning out_of_service available])
      expect(board[:resources].size).to eq(80)
      expect(board[:resources].first).to include(guest_count: 3, subtotal: '40000.0', currency: 'VND')
      expect(board[:resources][1][:orders].sole).to include(id: sent.workspace.prefixed_id, table_label: 'A', pending_kitchen_items: 1)

      get '/api/v3/admin/pos/resource_board', headers: bearer(waiter), params: { branch_id: branch.prefixed_id }
      expect(response).to have_http_status(:ok), response.body
      expect_pos_schema!(response, 'ResourceBoard')
    end

    it 'counts each order’s dishes the kitchen has not been told about, after a send too' do
      fresh = open_table(waiter, tables[0])
      add_dish(fresh, dish, quantity: 2)
      sent = open_table(cashier, tables[1])
      add_dish(sent, dish)
      kitchen_send(sent)
      later = menu_product!(store, branch, price: 30_000)
      add_dish(sent, later, quantity: 3)
      # A held course waits for its fire, so it is not unsent yet.
      held = menu_product!(store, branch, price: 20_000)
      add_dish(sent, held)
      Spree::Pos::SaleLine.where(workspace_id: sent.workspace.id, variant_id: held.id).update_all(course: 2, course_status: 'held')

      board = Spree::Pos::ResourceState.for(branch)
      expect(board[:resources][0][:orders].sole).to include(unsent_kitchen_items: 2, pending_kitchen_items: 0)
      expect(board[:resources][1][:orders].sole).to include(unsent_kitchen_items: 3, pending_kitchen_items: 1)

      get '/api/v3/admin/pos/resource_board', headers: bearer(waiter), params: { branch_id: branch.prefixed_id }
      expect(response).to have_http_status(:ok), response.body
      expect_pos_schema!(response, 'ResourceBoard')
      orders = response.parsed_body.dig('data', 'resources').first(2).map { |tile| tile['orders'].sole['unsent_kitchen_items'] }
      expect(orders).to eq([2, 3])
    end

    it 'shows a table edited after its pre-bill and moves it to waiting when the kitchen is late' do
      billed = open_table(cashier, tables[0])
      add_dish(billed, dish)
      Spree::Pos::Workspaces::Prebill.call(workspace: billed.workspace.reload, staff: cashier, key: SecureRandom.uuid)
      add_dish(billed, dish)
      kitchen_send(billed)
      Spree::Pos::KitchenTicket.where(workspace_id: billed.workspace.id).update_all(sent_at: 2.hours.ago)

      tile = Spree::Pos::ResourceState.for(branch)[:resources].first
      expect(tile).to include(state: 'waiting_long', edited_after_prebill: true)
    end
  end
end
