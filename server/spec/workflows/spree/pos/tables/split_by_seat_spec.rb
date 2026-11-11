# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../../support/pos_table_helpers'

# One bill per seat: each seat's dishes go to its own order at the table,
# a shared dish goes where the cashier puts it, and an order-wide discount
# is spread so the bills add up to the order they came from.
RSpec.describe Spree::Pos::Tables::SplitBySeat do
  include PosTableHelpers

  let(:store) { menu_store }
  let(:branch) { table_branch(store) }
  let(:cashier) { credit_staff(store, branch, PosCreditHelpers::CASHIER + [Spree::Pos::Capabilities::TABLE_SERVE, Spree::Pos::Capabilities::DISCOUNT]) }
  let(:table) { table!(area!(branch), name: 'Bàn 7') }
  let(:dish) { menu_product!(store, branch, name: 'Cơm gà', price: 40_000) }
  let(:drink) { menu_product!(store, branch, name: 'Nước cam', price: 15_000) }
  let(:salad) { menu_product!(store, branch, name: 'Gỏi', price: 40_000) }

  before { table_register!(branch, cashier) }

  def seated_order
    order = open_table(cashier, table, guest_count: 2)
    Spree::Pos::Workspaces::AppendItems.call(workspace: order.workspace.reload, staff: cashier, key: SecureRandom.uuid, items: [
                                               { 'variant_id' => dish.prefixed_id, 'quantity' => 1, 'seat' => 1 },
                                               { 'variant_id' => drink.prefixed_id, 'quantity' => 2, 'seat' => 2 },
                                               { 'variant_id' => salad.prefixed_id, 'quantity' => 1 }
                                             ])
    order
  end

  def split(order, shared: {})
    described_class.call(**editing_args(order), shared: shared)
  end

  def bills_of(result)
    ([result['workspace']] + result['new_workspaces']).map { |row| Spree::Pos::Workspace.find_by_prefix_id!(row['id']).order.reload }
  end

  it 'gives every seat its bill and the shared dish to the chosen seat' do
    order = seated_order
    salad_line = Spree::Pos::SaleLine.find_by!(workspace_id: order.workspace.id, variant_id: salad.id)

    result = split(order, shared: { salad_line.prefixed_id => 2 })

    first, second = bills_of(result)
    expect(first.item_total).to eq(40_000)
    expect(second.item_total).to eq(70_000)
    expect(Spree::Pos::Workspace.find_by_prefix_id!(result['new_workspaces'].first['id'])).to have_attributes(resource_id: table.id)
  end

  it 'spreads the order discount so the bills add up to the order' do
    order = seated_order
    Spree::Pos::Workspaces::ApplyDiscount.call(**editing_args(order), value_type: 'flat', value: '10000', reason: 'Khách quen')
    before_total = order.workspace.reload.order.reload.total
    expect(before_total).to eq(100_000)

    bills = bills_of(split(order))

    expect(bills.map(&:item_total)).to eq([80_000, 30_000])
    expect(bills.sum(&:total)).to eq(before_total)
    expect(bills.map(&:total)).to eq([72_727, 27_273])
  end

  it 'needs dishes of two seats' do
    order = open_table(cashier, table)
    Spree::Pos::Workspaces::AppendItems.call(workspace: order.workspace.reload, staff: cashier, key: SecureRandom.uuid,
                                             items: [{ 'variant_id' => dish.prefixed_id, 'quantity' => 1, 'seat' => 1 }])

    expect { split(order) }.to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('split_seats_invalid') }
  end
end
