# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../../support/pos_menu_helpers'

# Changing the options of a menu line keeps its base price, merges it into a
# line with the same options, and stops once money locks the order.
RSpec.describe Spree::Pos::Workspaces::UpdateLineModifiers do
  include PosMenuHelpers

  let(:store) { menu_store }
  let(:branch) { menu_branch(store) }
  let(:item) { menu_item!(store, branch, name: 'Trà sữa', price: 30_000) }
  let!(:topping) do
    modifier_group!(store, item, name: 'Topping', options: { 'Trân châu' => 5_000, 'Thạch' => 4_000 }, max: 3, allow_quantity: true)
  end
  let(:sale) { menu_sale(store, branch) }

  def change(line, modifiers, note: nil)
    described_class.call(**editing_args(sale), sale_line_id: line.prefixed_id, modifiers: modifiers, note: note)
  end

  def expect_conflict(reason, &block)
    expect(&block).to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq(reason) }
  end

  it 'replaces the options and prices them again on the base price of the line' do
    add_menu(sale, size(item), modifiers: picks([option(topping, 'Trân châu')]))
    line = menu_lines(sale).sole
    data = change(line, picks([option(topping, 'Thạch'), 2]), note: 'Ít ngọt')
    line.reload
    expect(line).to have_attributes(unit_price: 38_000, line_price: 38_000, note: 'Ít ngọt')
    expect(line.line_item.price).to eq(38_000)
    expect(line.line_modifiers.map { |row| [row.name, row.quantity] }).to eq([['Thạch', 2]])
    expect(data['line_items'].sole['modifiers'].map { |row| row['name'] }).to eq(['Thạch'])
    expect(Spree::Pos::AuditEntry.where(action: 'workspace.item.modifiers').sole.metadata).to include('before' => [{ 'name' => 'Trân châu', 'quantity' => 1 }])
  end

  it 'merges into the line that already has the same options' do
    add_menu(sale, size(item), modifiers: picks([option(topping, 'Thạch')]))
    add_menu(sale, size(item), modifiers: picks([option(topping, 'Trân châu')]), quantity: 2)
    first, second = menu_lines(sale)
    change(second, picks([option(topping, 'Thạch')]))
    line = menu_lines(sale).sole
    expect(line.id).to eq(first.id)
    expect(line).to have_attributes(sale_quantity: 3, base_quantity: 3)
    expect(line.line_item.quantity).to eq(3)
    expect(sale.workspace.reload.order.line_items.count).to eq(1)
  end

  it 'checks the groups again and refuses an ordinary line' do
    add_menu(sale, size(item))
    expect_conflict('modifier_max') { change(menu_lines(sale).sole, picks([option(topping, 'Thạch'), 4])) }

    product = create(:product, store: store, status: 'active', name: 'Nước suối')
    product.default_variant.set_price('VND', 10_000)
    branch.stock_location.restock(product.default_variant, 10)
    Spree::Pos::BranchProduct.create!(branch: branch, product: product)
    add_menu(sale, product.default_variant)
    expect_conflict('modifier_unknown') { change(menu_lines(sale).last, []) }
  end

  it 'refuses a change once a payment locks the order' do
    add_menu(sale, size(item))
    take_tender(sale, 'cash', 30_000)
    expect_conflict('snapshot_locked') { change(menu_lines(sale).sole, picks([option(topping, 'Thạch')])) }
    expect(menu_lines(sale).sole.line_modifiers).to be_empty
  end

  it 'refuses a change where the branch stopped running the menu' do
    add_menu(sale, size(item))
    set_pos_module(branch, 'fnb.menu', false)
    expect_conflict('module_disabled') { change(menu_lines(sale).sole, picks([option(topping, 'Thạch')])) }
  end
end
