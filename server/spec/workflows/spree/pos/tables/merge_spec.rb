# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../../support/pos_table_helpers'

RSpec.describe Spree::Pos::Tables::Merge do
  include PosTableHelpers

  let(:store) { menu_store }
  let(:branch) { table_branch(store) }
  let(:cashier) { credit_staff(store, branch, PosCreditHelpers::CASHIER) }
  let(:area) { area!(branch) }
  let(:dish) { menu_product!(store, branch, price: 40_000) }

  before { table_register!(branch, cashier) }

  def seated(name, x:, quantity:, guests: 2)
    order = open_table(cashier, table!(area, name: name, x: x), guest_count: guests)
    add_dish(order, dish, quantity: quantity)
    order
  end

  def merge(source, target)
    described_class.call(**editing_args(source), target_workspace_id: target.workspace.prefixed_id)
  end

  it 'moves every line to the target, sums the guests and cancels the source' do
    source = seated('Bàn 1', x: 0, quantity: 1, guests: 2)
    target = seated('Bàn 2', x: 4, quantity: 2, guests: 3)

    result = merge(source, target)

    expect(result['id']).to eq(target.workspace.prefixed_id)
    expect(target.workspace.reload).to have_attributes(guest_count: 5)
    expect(target.workspace.order.reload.item_total).to eq(120_000)
    expect(source.workspace.reload.operational_status).to eq('canceled')
    expect(source.workspace.order.reload.line_items).to be_empty
    expect(Spree::Pos::AuditEntry.where(action: 'table.merge', subject_id: target.workspace.id).count).to eq(1)
  end

  it 'refuses while either order is locked by a tender' do
    source = seated('Bàn 1', x: 0, quantity: 1)
    target = seated('Bàn 2', x: 4, quantity: 1)
    prepare_cash(target, 10_000)

    expect { merge(source, target) }.to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('snapshot_locked') }
    expect(source.workspace.reload.operational_status).to eq('editing')

    other = seated('Bàn 3', x: 8, quantity: 1)
    prepare_cash(source, 10_000)
    expect { merge(source, other) }.to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('snapshot_locked') }
  end

  it 'refuses orders holding discounts' do
    source = seated('Bàn 1', x: 0, quantity: 1)
    target = seated('Bàn 2', x: 4, quantity: 1)
    Spree::Pos::DiscountIntent.create!(workspace: source.workspace, actor: cashier, value_type: 'percent', value: '10', reason: 'Khách quen')
    expect { merge(source, target) }.to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('discount_present') }
    expect(target.workspace.order.reload.line_items.count).to eq(1)
  end

  it 'refuses merging an order into itself' do
    source = seated('Bàn 1', x: 0, quantity: 1)
    expect { merge(source, source) }.to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('same_order') }
  end
end
