# frozen_string_literal: true

require 'spree/api/testing_support/v3/base'
require_relative '../../../support/pos_table_helpers'
require_relative '../../../support/pos_schema_helpers'

# Several people working one table over the staff API: waiters and the
# cashier add batches without a lease, edit unsent lines by their version,
# send the difference to the kitchen and void sent items with a reason.
RSpec.describe 'POS table kitchen API', type: :request do
  include PosTableHelpers
  include PosSchemaHelpers

  let(:store) { menu_store }
  let(:branch) { table_branch(store) }
  let(:cashier) { credit_staff(store, branch, PosCreditHelpers::CASHIER) }
  let(:waiter) { credit_staff(store, branch, PosTableHelpers::WAITER) }
  let(:other_waiter) { credit_staff(store, branch, PosTableHelpers::WAITER) }
  let(:area) { area!(branch) }
  let(:dish) { menu_product!(store, branch, name: 'Bún chả', price: 45_000) }
  let(:order) { open_table(cashier, table!(area, name: 'Bàn 1')) }
  let(:id) { order.workspace.prefixed_id }

  before do
    allow(Spree::Store).to receive(:default).and_return(store)
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

  def call(user, verb, path, params = {}, key = SecureRandom.uuid)
    send(verb, "/api/v3/admin/pos/#{path}", headers: bearer(user).merge('Idempotency-Key' => key), params: params, as: :json)
    response.parsed_body
  end

  def append(user, quantity = 1)
    call(user, :post, "workspaces/#{id}/items/append", items: [{ variant_id: dish.prefixed_id, quantity: quantity }],
                                                       append_batch_id: SecureRandom.uuid)
  end

  it 'lets two waiters and the cashier add to one table without a lease, then sends only the difference' do
    [waiter, other_waiter, cashier].each do |user|
      append(user)
      expect(response).to have_http_status(:ok), response.body
    end
    expect_pos_schema!(response, 'Workspace')
    expect(response.parsed_body.dig('meta', 'sale_line_ids').size).to eq(1)
    expect(response.parsed_body.dig('data', 'line_items').map { |line| line['pending_kitchen_quantity'] }).to eq(%w[1.0 1.0 1.0])

    key = SecureRandom.uuid
    body = call(waiter, :post, "workspaces/#{id}/kitchen_sends", {}, key)
    expect(response).to have_http_status(:created), response.body
    expect(body.dig('meta', 'ticket_count')).to eq(1)
    expect(body.dig('data', 'kitchen_sends').sole).to include('sequence' => 1, 'staff_id' => waiter.prefixed_id)
    expect_pos_schema!(response, 'Workspace')

    replay = call(waiter, :post, "workspaces/#{id}/kitchen_sends", {}, key)
    expect(replay.dig('meta', 'ticket_count')).to eq(1)
    expect(Spree::Pos::KitchenTicket.where(workspace_id: order.workspace.id).count).to eq(1)

    call(other_waiter, :post, "workspaces/#{id}/kitchen_sends")
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.dig('meta', 'ticket_count')).to eq(0)

    append(other_waiter, 2)
    body = call(cashier, :post, "workspaces/#{id}/kitchen_sends")
    expect(body.dig('meta', 'tickets').sole['items'].sole).to include('quantity' => '2.0')

    history = call(cashier, :get, "workspaces/#{id}/kitchen_history")
    expect(response).to have_http_status(:ok)
    expect(history.dig('data', 'entries').map { |entry| entry['sequence'] }).to eq([1, 2])
    errors = JSONSchemer.schema(pos_component_schema('KitchenHistoryResult')).validate(history).to_a
    expect(errors).to eq([])
  end

  it 'tells each line the kitchen send that first carried it, and keeps it after a void' do
    first = append(waiter, 2).dig('meta', 'sale_line_ids').first
    call(waiter, :post, "workspaces/#{id}/kitchen_sends")
    second = append(other_waiter).dig('meta', 'sale_line_ids').first
    call(cashier, :post, "workspaces/#{id}/kitchen_sends")
    unsent = append(waiter).dig('meta', 'sale_line_ids').first

    voider = credit_staff(store, branch, PosTableHelpers::WAITER + [Spree::Pos::Capabilities::KITCHEN_VOID])
    call(voider, :post, "workspaces/#{id}/sale_lines/#{first}/kitchen_voids", quantity: 1, reason_code: 'het_mon')
    expect(response).to have_http_status(:created), response.body

    body = call(cashier, :get, "workspaces/#{id}")
    expect(response).to have_http_status(:ok), response.body
    expect_pos_schema!(response, 'Workspace')
    sequences = body.dig('data', 'line_items').to_h { |line| [line['sale_line_id'], line['kitchen_send_sequence']] }
    expect(sequences).to eq(first => 1, second => 2, unsent => nil)
  end

  it 'refuses a counter order with not_table_order' do
    sale = menu_sale(store, branch)
    call(sale.cashier, :post, "workspaces/#{sale.workspace.prefixed_id}/items/append", items: [{ variant_id: dish.prefixed_id }])
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('not_table_order')
  end

  it 'edits unsent lines by version and sends a changed line back to the client' do
    line_id = append(waiter, 2).dig('meta', 'sale_line_ids').first
    line = Spree::Pos::SaleLine.find_by_prefix_id!(line_id)

    call(cashier, :patch, "workspaces/#{id}/sale_lines/#{line_id}", row_version: line.row_version, quantity: 3)
    expect(response).to have_http_status(:ok), response.body
    expect_pos_schema!(response, 'Workspace')

    call(waiter, :patch, "workspaces/#{id}/sale_lines/#{line_id}", row_version: line.row_version, quantity: 1)
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'details')).to include('reason' => 'line_changed')
    expect(response.parsed_body.dig('error', 'details', 'sale_line')).to include('row_version' => line.row_version + 1)

    call(waiter, :post, "workspaces/#{id}/kitchen_sends")
    call(waiter, :patch, "workspaces/#{id}/sale_lines/#{line_id}", row_version: line.reload.row_version, quantity: 1)
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('line_sent')
    call(waiter, :delete, "workspaces/#{id}/sale_lines/#{line_id}?row_version=#{line.row_version}")
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('line_sent')
  end

  it 'voids a sent item only with an approval or the void capability' do
    line_id = append(waiter, 2).dig('meta', 'sale_line_ids').first
    call(waiter, :post, "workspaces/#{id}/kitchen_sends")

    call(waiter, :post, "workspaces/#{id}/sale_lines/#{line_id}/kitchen_voids", quantity: 1, reason_code: 'het_mon')
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('approval_required')

    voider = credit_staff(store, branch, PosTableHelpers::WAITER + [Spree::Pos::Capabilities::KITCHEN_VOID])
    body = call(voider, :post, "workspaces/#{id}/sale_lines/#{line_id}/kitchen_voids", quantity: 1, reason_code: 'het_mon')
    expect(response).to have_http_status(:created), response.body
    expect(body.dig('meta', 'kitchen_void')).to include('quantity' => '1.0', 'reason_code' => 'het_mon')
    errors = JSONSchemer.schema(pos_component_schema('KitchenVoidResult')).validate(body).to_a
    expect(errors).to eq([])
    expect(body['data']['line_items'].sole).to include('quantity' => 1, 'kitchen_sent_quantity' => '1.0')
  end
end
