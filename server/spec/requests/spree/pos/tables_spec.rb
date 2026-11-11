# frozen_string_literal: true

require 'spree/api/testing_support/v3/base'
require_relative '../../../support/pos_table_helpers'
require_relative '../../../support/pos_schema_helpers'

# Table service over the staff API: seat guests, order, move, split, merge,
# ask for the bill and take the service charge off.
RSpec.describe 'POS tables API', type: :request do
  include PosTableHelpers
  include PosSchemaHelpers

  let(:store) { menu_store }
  let(:branch) { table_branch(store) }
  let(:cashier) { credit_staff(store, branch, PosCreditHelpers::CASHIER + [Spree::Pos::Capabilities::DISCOUNT]) }
  let(:waiter) { credit_staff(store, branch, PosTableHelpers::WAITER) }
  let(:area) { area!(branch) }
  let(:first_table) { table!(area, name: 'Bàn 1') }
  let(:second_table) { table!(area, name: 'Bàn 2', x: 4) }
  let(:dish) { menu_product!(store, branch, price: 60_000) }
  let(:editor_id) { SecureRandom.uuid }

  before do
    allow(Spree::Store).to receive(:default).and_return(store)
    table_register!(branch, cashier)
  end

  def bearer(user)
    @tokens ||= {}
    @tokens[user.id] ||= begin
      post '/api/v3/admin/auth/login', params: { email: user.email, password: 'secret123' }, as: :json
      response.parsed_body.fetch('token')
    end
    { 'Authorization' => "Bearer #{@tokens[user.id]}" }
  end

  def call(user, path, params = {})
    post "/api/v3/admin/pos/#{path}", headers: bearer(user).merge('Idempotency-Key' => SecureRandom.uuid), params: params, as: :json
    response.parsed_body
  end

  def seat(user, table, **params)
    call(user, "tables/#{table.prefixed_id}/open", { branch_id: branch.prefixed_id, editor_id: editor_id, guest_count: 2 }.merge(params))
  end

  def editing(workspace_id)
    workspace = Spree::Pos::Workspace.find_by_prefix_id!(workspace_id)
    { expected_revision: workspace.revision, lease_generation: workspace.lease_generation, editor_id: editor_id }
  end

  def add_item(user, workspace_id, variant = dish)
    call(user, "workspaces/#{workspace_id}/items", editing(workspace_id).merge(variant_id: variant.prefixed_id, quantity: 1))
  end

  it 'seats guests and lets the waiter order, then refuses a second order unless asked' do
    body = seat(waiter, first_table, guest_count: 4)
    expect(response).to have_http_status(:created), response.body
    expect_pos_schema!(response, 'Workspace')
    id = body.dig('data', 'id')
    expect(body['data']).to include('service_mode' => 'dine_in', 'guest_count' => 4, 'table_label' => 'A')
    expect(body.dig('data', 'resource')).to include('id' => first_table.prefixed_id, 'name' => 'Bàn 1')

    add_item(waiter, id)
    expect(response).to have_http_status(:ok), response.body

    seat(waiter, first_table)
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'details')).to include('reason' => 'table_occupied', 'workspace_ids' => [id])

    seat(waiter, first_table, add_order: true)
    expect(response).to have_http_status(:created)
    expect(response.parsed_body.dig('data', 'table_label')).to eq('B')

    get '/api/v3/admin/pos/workspaces', headers: bearer(waiter), params: { branch_id: branch.prefixed_id, status: 'editing,parked' }
    expect(response.parsed_body['data'].map { |row| row['table_label'] }).to contain_exactly('A', 'B')
  end

  it 'keeps the cashier’s counter orders out of a waiter’s sight' do
    counter = credit_sale(store, branch, price: 10_000, cashier: cashier)
    add_item(waiter, counter.workspace.prefixed_id)
    expect(response).to have_http_status(:not_found)
  end

  it 'moves, splits and merges table orders' do
    id = seat(cashier, first_table).dig('data', 'id')
    add_item(cashier, id)
    add_item(cashier, id, menu_product!(store, branch, price: 20_000))

    call(cashier, "workspaces/#{id}/move", editing(id).merge(resource_id: second_table.prefixed_id))
    expect(response).to have_http_status(:ok), response.body
    expect_pos_schema!(response, 'Workspace')
    expect(response.parsed_body.dig('data', 'resource', 'id')).to eq(second_table.prefixed_id)

    line = response.parsed_body.dig('data', 'line_items').find { |row| row['price'].to_d == 20_000 }
    body = call(cashier, "workspaces/#{id}/split", editing(id).merge(sale_line_ids: [line['sale_line_id']], resource_id: first_table.prefixed_id))
    expect(response).to have_http_status(:ok), response.body
    expect_pos_schema!(response, 'TableSplitOrders')
    split_id = body.dig('data', 'new_workspace', 'id')
    expect(body.dig('data', 'new_workspace', 'resource', 'id')).to eq(first_table.prefixed_id)

    body = call(cashier, "workspaces/#{split_id}/merge", editing(split_id).merge(target_workspace_id: id))
    expect(response).to have_http_status(:ok), response.body
    expect(body.dig('data', 'line_items').size).to eq(2)
    expect(Spree::Pos::Workspace.find_by_prefix_id!(split_id).operational_status).to eq('canceled')
  end

  it 'asks for the bill and takes the service charge off one order' do
    branch.update!(service_charge_rate: BigDecimal('10'))
    id = seat(waiter, first_table).dig('data', 'id')
    add_item(waiter, id)
    expect(response.parsed_body.dig('data', 'service_charge')).to include('amount' => '6000.0', 'waived' => false)

    body = call(waiter, "workspaces/#{id}/payment_request", note: 'Tiền mặt')
    expect(response).to have_http_status(:created), response.body
    expect(body.dig('data', 'payment_request')).to include('status' => 'open', 'note' => 'Tiền mặt')

    call(waiter, "workspaces/#{id}/service_charge", editing(id).merge(waived: true))
    expect(response).to have_http_status(:forbidden)

    # The cashier takes the order over to collect it.
    Spree::Pos::Workspace.find_by_prefix_id!(id).update_column(:lease_expires_at, 1.minute.ago)
    call(cashier, "workspaces/#{id}/lease", editor_id: editor_id)
    expect(response).to have_http_status(:ok), response.body
    body = call(cashier, "workspaces/#{id}/service_charge", editing(id).merge(waived: true))
    expect(response).to have_http_status(:ok), response.body
    expect(body.dig('data', 'service_charge')).to include('amount' => '0.0', 'waived' => true)

    body = call(cashier, "workspaces/#{id}/payment_request/resolve", status: 'done')
    expect(response).to have_http_status(:ok), response.body
    expect(body.dig('data', 'payment_request')).to be_nil
  end
end
