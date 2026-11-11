# frozen_string_literal: true

require 'spree/api/testing_support/v3/base'
require_relative '../../../support/pos_counter_service_helpers'
require_relative '../../../support/pos_schema_helpers'

# Counter service over HTTP: the cashier names the guest, the customer
# display switches to the call board and reads the numbers over its own
# token, the counter's pickup queue hands orders over, cup labels print
# again, and a kitchen manager sets the labels up.
RSpec.describe 'POS counter service API', type: :request do
  include PosCounterServiceHelpers
  include PosSchemaHelpers

  let(:store) { menu_store }
  let(:branch) { counter_branch(store) }
  let(:coffee) { cup_item!(store, branch, name: 'Cà phê', price: 20_000) }
  let!(:bar) { kitchen_station!(branch, name: 'Bar', default: true) }
  let(:sale) { menu_sale(store, branch) }

  before { allow(Spree::Store).to receive(:default).and_return(store) }

  def bearer(user)
    @bearers ||= {}
    @bearers[user.id] ||= begin
      post '/api/v3/admin/auth/login', params: { email: user.email, password: 'secret123' }, as: :json
      { 'Authorization' => "Bearer #{response.parsed_body.fetch('token')}" }
    end
  end

  def call(user, verb, path, body = {}, key: SecureRandom.uuid)
    send(verb, "/api/v3/admin/pos/#{path}", headers: bearer(user).merge('Idempotency-Key' => key),
                                            params: verb == :get ? body : body, as: verb == :get ? nil : :json)
    response.parsed_body
  end

  def editing(sale)
    workspace = sale.workspace.reload
    { expected_revision: workspace.revision, lease_generation: workspace.lease_generation, editor_id: sale.editor_id }
  end

  def display_state(token)
    get '/api/v3/pos_display/state', headers: { 'Authorization' => "Display #{token}" }
    response.parsed_body['data']
  end

  describe 'guest name' do
    it 'sets and clears the name on an open order and refuses it where neither module runs' do
      add_menu(sale, size(coffee))
      body = call(sale.cashier, :post, "workspaces/#{sale.workspace.prefixed_id}/guest_name", editing(sale).merge(guest_name: '  Chị  Lan '))
      expect(response).to have_http_status(:ok), response.body
      expect_pos_schema!(response, 'Workspace')
      expect(body['data']).to include('guest_name' => 'Chị Lan', 'order_number' => nil)
      expect(Spree::Pos::AuditEntry.where(action: 'workspace.guest_name.set').count).to eq(1)

      call(sale.cashier, :post, "workspaces/#{sale.workspace.prefixed_id}/guest_name", editing(sale).merge(guest_name: 'x' * 61))
      expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('guest_name_invalid')

      call(sale.cashier, :post, "workspaces/#{sale.workspace.prefixed_id}/guest_name", editing(sale).merge(guest_name: ''))
      expect(response.parsed_body.dig('data', 'guest_name')).to be_nil

      set_pos_module(branch, 'fnb.order_number', false)
      set_pos_module(branch, 'fnb.cup_label', false)
      call(sale.cashier, :post, "workspaces/#{sale.workspace.prefixed_id}/guest_name", editing(sale).merge(guest_name: 'Lan'))
      expect(response).to have_http_status(:conflict)
      expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('module_disabled')
    end
  end

  describe 'call board display' do
    def bind
      body = call(sale.cashier, :post, 'display_sessions', { shift_id: sale.workspace.shift.prefixed_id })
      [body['data'], body['token']]
    end

    def set_mode(session, mode)
      generation = Spree::Pos::DisplaySession.find_by_prefix_id!(session['id']).generation
      call(sale.cashier, :post, "display_sessions/#{session['id']}/mode", { mode: mode, expected_generation: generation })
    end

    it 'switches to the call board, shows numbers by kitchen status, and hands an order over from the queue' do
      session, token = bind
      body = set_mode(session, 'call_board')
      expect(response).to have_http_status(:ok), response.body
      expect(body['data']).to include('mode' => 'call_board', 'pinned_workspace_id' => nil)

      add_menu(sale, size(coffee))
      call(sale.cashier, :post, "display_sessions/#{session['id']}/pin",
           { workspace_id: sale.workspace.prefixed_id, expected_generation: body.dig('data', 'generation') })
      expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('display_call_board')

      pay_and_complete(sale)
      state = display_state(token)
      expect(state).to include('state' => 'call_board', 'order' => nil, 'preparing' => [{ 'number' => 1 }], 'ready' => [])

      queue = call(sale.cashier, :get, 'kitchen/orders', { branch_id: branch.prefixed_id })
      expect(response).to have_http_status(:ok), response.body
      expect_pos_schema!(response, 'CallBoard')
      expect(queue.dig('data', 'preparing')).to eq([{ 'number' => 1, 'workspace_id' => sale.workspace.prefixed_id }])

      ticket = Spree::Pos::KitchenTicket.find_by!(workspace_id: sale.workspace.id)
      Spree::Pos::Kitchen::ChangeItemStatus.bump(ticket: ticket, actor: sale.cashier)
      expect(display_state(token)['ready'].map { |row| row['number'] }).to eq([1])

      served = call(sale.cashier, :post, "kitchen/orders/#{sale.workspace.prefixed_id}/serve")
      expect(response).to have_http_status(:ok), response.body
      expect(served.dig('data', 'tickets', 0, 'items', 0, 'status')).to eq('served')
      expect(display_state(token)).to include('preparing' => [], 'ready' => [])
      # Handed over twice: nothing more to serve.
      expect(call(sale.cashier, :post, "kitchen/orders/#{sale.workspace.prefixed_id}/serve").dig('data', 'tickets')).to eq([])
    end

    it 'needs call numbers for the call board and refuses an unknown mode' do
      session, = bind
      set_mode(session, 'menu')
      expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('display_mode_invalid')

      set_pos_module(branch, 'fnb.order_number', false)
      set_mode(session, 'call_board')
      expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('module_disabled')
      expect(Spree::Pos::DisplaySession.find_by_prefix_id!(session['id']).mode).to eq('order')
    end

    it 'lets the kitchen screen hand an order over' do
      token = Spree::Pos::Device.new_token
      kitchen_screen!(branch, token)
      add_menu(sale, size(coffee))
      pay_and_complete(sale)
      ticket = Spree::Pos::KitchenTicket.find_by!(workspace_id: sale.workspace.id)
      Spree::Pos::Kitchen::ChangeItemStatus.bump(ticket: ticket, actor: sale.cashier)

      post "/api/v3/pos_device/kitchen/orders/#{sale.workspace.prefixed_id}/serve", headers: { 'Authorization' => "Device #{token}" },
                                                                                 as: :json
      expect(response).to have_http_status(:ok), response.body
      expect(ticket.items.reload.map(&:status)).to eq(['served'])
      expect(ticket.reload.header).to include('order_number' => 1)
    end
  end

  describe 'cup labels' do
    let(:manager) { credit_staff(store, branch, [Spree::Pos::Capabilities::MANAGE_KITCHEN]) }

    it 'sets up the label printer, size and fields, and prints a test label' do
      printer = cup_printer!(branch)
      branch.update!(cup_label_printer: nil)
      body = call(manager, :get, 'cup_label_settings', { branch_id: branch.prefixed_id })
      expect(response).to have_http_status(:ok), response.body
      expect_pos_schema!(response, 'CupLabelSettings')
      expect(body['data']).to include('printer_id' => nil, 'size' => '50x30', 'pickup_minutes' => 15, 'module_enabled' => true)

      body = call(manager, :put, 'cup_label_settings', { branch_id: branch.prefixed_id, printer_id: printer.prefixed_id, size: '40x30',
                                                         fields: %w[call_number guest_name], pickup_minutes: 10 })
      expect(response).to have_http_status(:ok), response.body
      expect(body['data']).to include('printer_id' => printer.prefixed_id, 'size' => '40x30', 'fields' => %w[call_number guest_name],
                                      'pickup_minutes' => 10)
      expect(Spree::Pos::AuditEntry.where(action: 'cup_label.settings').count).to eq(1)

      call(manager, :put, 'cup_label_settings', { branch_id: branch.prefixed_id, size: '99x99' })
      expect(response.parsed_body.dig('error', 'details')).to include('reason' => 'cup_label_settings_invalid', 'field' => 'size')

      job = call(manager, :post, 'cup_label_settings/test', { branch_id: branch.prefixed_id })['data']
      expect(response).to have_http_status(:created), response.body
      document = Spree::Pos::PrintJob.find_by_prefix_id!(job['id']).document
      expect(document['page']['label']).to eq('width_mm' => 40, 'height_mm' => 30)
      expect(document['header'].flat_map { |block| block['lines'] }).to eq(['Số 1 · 1/1', 'Trà sữa (L)', 'Lan'])

      call(sale.cashier, :put, 'cup_label_settings', { branch_id: branch.prefixed_id, size: '58x40' })
      expect(response).to have_http_status(:forbidden)
    end

    it 'prints the labels of an order again for the cashier' do
      cup_printer!(branch)
      add_menu(sale, size(coffee), quantity: 2)
      pay_and_complete(sale)
      line = Spree::Pos::SaleLine.find_by!(workspace_id: sale.workspace.id)
      body = call(sale.cashier, :post, "workspaces/#{sale.workspace.prefixed_id}/cup_labels", { sale_line_id: line.prefixed_id })
      expect(response).to have_http_status(:created), response.body
      expect(body.dig('data', 'jobs').size).to eq(2)
      expect(cup_jobs(sale).count).to eq(4)
    end
  end
end
