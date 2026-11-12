# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../../support/pos_guest_helpers'

# A guest's order from the table QR: priced on the server, waiting for staff,
# accepted through the table's ordinary add command and sent to the kitchen.
RSpec.describe 'Spree::Pos::GuestOrders', type: :model do
  include PosGuestHelpers

  let(:store) { menu_store }
  let(:branch) { qr_branch(store) }
  let(:cashier) { credit_staff(store, branch, PosCreditHelpers::CASHIER) }
  let(:decider) { credit_staff(store, branch, PosGuestHelpers::DECIDER) }
  let(:table) { table!(area!(branch), name: 'Bàn 7') }
  let(:item) { menu_item!(store, branch, name: 'Trà đào', price: 30_000) }
  let(:dish) { size(item) }
  let!(:station) { kitchen_station!(branch, name: 'Bar', default: true) }

  before do
    table_register!(branch, cashier)
  end

  def opened_session
    order = open_table(cashier, table)
    _, token = table_code!(table)
    session, = guest_session!(token)
    [session, order.workspace]
  end

  it 'prices the items on the server and keeps them off the order until accepted' do
    group = modifier_group!(store, item, name: 'Topping', options: { 'Thạch' => 5_000 }, max: 2)
    session, workspace = opened_session
    rows = [{ 'variant_id' => dish.prefixed_id, 'quantity' => 2, 'price' => '1', 'unit_price' => '1',
              'modifiers' => picks([option(group, 'Thạch')]) }]

    order = submit_guest_order(session, rows)

    expect(order.status).to eq('pending')
    expect(order.items.sole).to include('unit_price' => '35000.0', 'amount' => '70000.0', 'quantity' => 2)
    expect(order.quoted_total).to eq(70_000)
    expect(Spree::Pos::SaleLine.where(workspace_id: workspace.id)).to be_empty
  end

  it 'returns the same order for the same key and refuses the key with other items' do
    session, = opened_session
    key = SecureRandom.uuid
    first = submit_guest_order(session, guest_items(dish), key: key)
    expect(submit_guest_order(session, guest_items(dish), key: key).id).to eq(first.id)
    expect { submit_guest_order(session, guest_items(dish, quantity: 3), key: key) }.
      to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('idempotency_key_reused') }
    expect(Spree::Pos::GuestOrder.count).to eq(1)
  end

  it 'refuses a sold-out item, an item closed to guests and a fourth pending order' do
    session, = opened_session
    sold_out!(item)
    expect { submit_guest_order(session, guest_items(dish)) }.
      to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('item_sold_out') }

    hidden = menu_item!(store, branch, name: 'Rượu', price: 200_000)
    hidden.update!(qr_orderable: false)
    expect { submit_guest_order(session, guest_items(size(hidden))) }.
      to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('item_unavailable') }

    tea = size(menu_item!(store, branch, name: 'Trà chanh', price: 20_000))
    3.times { submit_guest_order(session, guest_items(tea)) }
    expect { submit_guest_order(session, guest_items(tea)) }.
      to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('too_many_pending') }
  end

  it 'accepts through the ordinary add command, as the person accepting, and sends only the new lines' do
    session, workspace = opened_session
    waiter_line = Spree::Pos::Workspaces::AppendItems.call(workspace: workspace, staff: cashier, key: SecureRandom.uuid,
                                                           items: [{ 'variant_id' => size(menu_item!(store, branch, name: 'Bánh', price: 10_000)).prefixed_id }])
    order = submit_guest_order(session, guest_items(dish, quantity: 2))
    expect(Spree::Pos::Workspaces::AppendItems).to receive(:call).and_call_original

    result = Spree::Pos::GuestOrders::Accept.call(guest_order: order, staff: decider, key: SecureRandom.uuid)

    expect(result.dig('guest_order', 'status')).to eq('accepted')
    added = Spree::Pos::SaleLine.where(workspace_id: workspace.id, append_batch_id: order.append_batch_id).sole
    expect(added).to have_attributes(added_by_id: decider.id, sale_quantity: 2, kitchen_sent_quantity: 2, unit_price: 30_000)
    unsent = Spree::Pos::SaleLine.find_by_prefix_id!(waiter_line['sale_line_ids'].sole)
    expect(unsent.kitchen_sent_quantity).to eq(0)
    ticket = Spree::Pos::KitchenTicket.where(workspace_id: workspace.id).sole
    expect(ticket.kitchen_station_id).to eq(station.id)
    expect(Spree::Pos::AuditEntry.where(action: 'guest_order.accept', actor_id: decider.id).count).to eq(1)
    expect { Spree::Pos::GuestOrders::Accept.call(guest_order: order.reload, staff: decider, key: SecureRandom.uuid) }.
      to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('guest_order_decided') }
  end

  it 'leaves out an item sold out since the guest sent it, and rejects when nothing is left' do
    session, workspace = opened_session
    other = size(menu_item!(store, branch, name: 'Cà phê', price: 25_000))
    order = submit_guest_order(session, guest_items(dish) + guest_items(other))
    lone = submit_guest_order(session, guest_items(dish))
    sold_out!(item)

    Spree::Pos::GuestOrders::Accept.call(guest_order: order, staff: decider, key: SecureRandom.uuid)

    expect(order.reload.items.map { |row| [row['name'], row['outcome'], row['reason']] }).
      to eq([['Trà đào', 'left_out', 'item_sold_out'], ['Cà phê', 'added', nil]])
    expect(Spree::Pos::SaleLine.where(workspace_id: workspace.id).sole.variant_id).to eq(other.id)

    Spree::Pos::GuestOrders::Accept.call(guest_order: lone, staff: decider, key: SecureRandom.uuid)
    expect(lone.reload).to have_attributes(status: 'rejected', reject_reason: 'item_sold_out')
  end

  it 'rejects with a reason the guest reads, and only for people allowed to decide' do
    session, = opened_session
    order = submit_guest_order(session, guest_items(dish))
    expect { Spree::Pos::GuestOrders::Reject.call(guest_order: order, staff: cashier, key: SecureRandom.uuid, reason: 'Hết ly') }.
      to raise_error(CanCan::AccessDenied)

    Spree::Pos::GuestOrders::Reject.call(guest_order: order, staff: decider, key: SecureRandom.uuid, reason: 'Hết ly')

    expect(order.reload.to_guest).to include(status: 'rejected', reject_reason: 'Hết ly')
    expect(Spree::Pos::AuditEntry.where(action: 'guest_order.reject').sole.metadata).to include('reason' => 'Hết ly')
  end

  it 'expires a pending order once the table order has closed' do
    session, workspace = opened_session
    order = submit_guest_order(session, guest_items(dish))
    close_order!(workspace)

    expect(order.reload.effective_status).to eq('expired')
    result = Spree::Pos::GuestOrders::Accept.call(guest_order: order, staff: decider, key: SecureRandom.uuid)
    expect(result.dig('guest_order', 'status')).to eq('expired')
  end

  describe 'straight to the kitchen' do
    before { branch.update!(qr_order_mode: 'direct_to_kitchen', qr_order_auto_limit: 100_000, qr_order_auto_max_items: 3) }

    it 'adds an order within the limits on behalf of the table shift owner' do
      session, workspace = opened_session
      order = submit_guest_order(session, guest_items(dish, quantity: 2))

      expect(order).to have_attributes(status: 'accepted', automatic: true, decided_by_id: cashier.id)
      expect(Spree::Pos::SaleLine.where(workspace_id: workspace.id).sole.kitchen_sent_quantity).to eq(2)
      expect(Spree::Pos::AuditEntry.where(action: 'guest_order.accept').sole.metadata).to include('automatic' => true)
    end

    it 'leaves an order above the amount or item limit pending' do
      session, workspace = opened_session
      expect(submit_guest_order(session, guest_items(dish, quantity: 4)).status).to eq('pending')
      expect(submit_guest_order(session, guest_items(size(menu_item!(store, branch, name: 'Lẩu', price: 150_000)))).status).to eq('pending')
      expect(Spree::Pos::SaleLine.where(workspace_id: workspace.id)).to be_empty
    end
  end
end
