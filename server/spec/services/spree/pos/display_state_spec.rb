# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../support/pos_counter_service_helpers'

# A customer display in call board mode shows the branch's call numbers of
# the business day: preparing while the kitchen works, ready once every item
# is done, gone once handed over or after the pickup window.
RSpec.describe Spree::Pos::DisplayState do
  include PosCounterServiceHelpers
  include ActiveSupport::Testing::TimeHelpers

  let(:store) { menu_store }
  let(:branch) { counter_branch(store) }
  let(:coffee) { menu_item!(store, branch, name: 'Cà phê', price: 20_000) }
  let(:tea) { menu_item!(store, branch, name: 'Trà', price: 25_000) }
  let!(:bar) { kitchen_station!(branch, name: 'Bar', default: true) }
  let(:first) { menu_sale(store, branch) }
  let(:session) do
    bound = Spree::Pos::Displays::Bind.call(store: store, staff: first.cashier, shift_id: first.workspace.shift.prefixed_id)
    row = Spree::Pos::DisplaySession.find_by_prefix_id!(bound[:session][:id])
    Spree::Pos::Displays::Pin.set_mode(store: store, staff: first.cashier, key: SecureRandom.uuid, session_id: row.prefixed_id,
                                       expected_generation: row.generation, mode: 'call_board')
    row.reload
  end

  def board
    described_class.call(session.reload).slice(:state, :order, :payment, :preparing, :ready)
  end

  def sold(sale, *items)
    items.each { |item| add_menu(sale, size(item)) }
    pay_and_complete(sale)
    sale
  end

  def tickets(sale)
    Spree::Pos::KitchenTicket.where(workspace_id: sale.workspace.id).to_a
  end

  it 'moves a number from preparing to ready and off the board when it is handed over' do
    sold(first, coffee, tea)
    sold(menu_sale(store, branch), coffee)
    expect(board).to eq(state: 'call_board', order: nil, payment: nil, preparing: [{ number: 1 }, { number: 2 }], ready: [])

    item = tickets(first).first.items.first
    Spree::Pos::Kitchen::ChangeItemStatus.call(item: item, action: 'ready', actor: first.cashier)
    expect(board[:preparing]).to eq([{ number: 1 }, { number: 2 }])

    tickets(first).each { |ticket| Spree::Pos::Kitchen::ChangeItemStatus.bump(ticket: ticket, actor: first.cashier) }
    expect(board[:preparing]).to eq([{ number: 2 }])
    expect(board[:ready]).to match([{ number: 1, guest_name: nil, ready_at: a_kind_of(String) }])

    Spree::Pos::Kitchen::ChangeItemStatus.serve_order(workspace: first.workspace, actor: first.cashier)
    expect(board[:ready]).to eq([])
    expect(tickets(first).flat_map(&:items).map(&:status).uniq).to eq(['served'])
  end

  it 'shows the guest name of a ready number and drops it after the pickup window' do
    add_menu(first, size(coffee))
    Spree::Pos::Workspaces::SetGuestName.call(**editing_args(first), guest_name: 'Lan')
    pay_and_complete(first)
    tickets(first).each { |ticket| Spree::Pos::Kitchen::ChangeItemStatus.bump(ticket: ticket, actor: first.cashier) }
    expect(board[:ready]).to match([{ number: 1, guest_name: 'Lan', ready_at: a_kind_of(String) }])

    branch.update!(cup_label_settings: { 'pickup_minutes' => 5 })
    later = Spree::Pos::Workspace.database_now + 6.minutes
    expect(Spree::Pos::CallBoard.call(branch: branch, now: later)[:ready]).to eq([])
    expect(Spree::Pos::CallBoard.call(branch: branch, now: later - 2.minutes)[:ready].map { |row| row[:number] }).to eq([1])
  end

  it 'leaves out canceled orders, other business days and orders without a call number' do
    sold(first, coffee)
    canceled = menu_sale(store, branch)
    branch.update!(kitchen_send_trigger: 'manual')
    add_menu(canceled, size(coffee))
    kitchen_send(canceled)
    Spree::Pos::Workspaces::ChangeStatus.call(**editing_args(canceled), status: 'canceled')
    expect(board[:preparing]).to eq([{ number: 1 }])

    tomorrow = Spree::Pos::Workspace.database_now + 1.day
    expect(Spree::Pos::CallBoard.call(branch: branch, now: tomorrow)).to eq(preparing: [], ready: [])
  end

  it 'never shows an order in call board mode, and the order mode is unchanged' do
    expect(board).to include(state: 'call_board', preparing: [], ready: [])
    Spree::Pos::Displays::Pin.set_mode(store: store, staff: first.cashier, key: SecureRandom.uuid, session_id: session.prefixed_id,
                                       expected_generation: session.generation, mode: 'order')
    expect(described_class.call(session.reload)).to include(state: 'idle', order: nil, payment: nil)
    expect(described_class.call(session.reload)).not_to include(:preparing)
  end
end
