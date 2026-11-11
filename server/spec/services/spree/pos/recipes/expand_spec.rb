# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../../support/pos_recipe_helpers'

# What one sale line uses, in each ingredient's stock unit: the size's
# recipe, every option picked times its quantity, and every combo part.
RSpec.describe Spree::Pos::Recipes::Expand do
  include PosRecipeHelpers

  let(:store) { menu_store }
  let(:branch) { recipe_branch(store) }
  let(:manager) { recipe_manager(store, branch) }
  let(:sale) { menu_sale(store, branch) }
  let(:milk) { ingredient!(store, branch, name: 'Sữa tươi', base: 'ml') }
  let(:pearls) { ingredient!(store, branch, name: 'Trân châu', base: 'g') }
  let(:item) { menu_item!(store, branch, name: 'Trà sữa', price: 30_000, sizes: { 'M' => 30_000, 'L' => 36_000 }) }

  def rows(line)
    described_class.call(line.reload).map { |entry| [entry.ingredient_variant_id, entry.base_quantity, entry.source_key] }.sort
  end

  it 'takes the recipe of the size sold, times the line quantity' do
    recipe!(store, manager, size(item, 0), [[milk, 150, 'ml']])
    recipe!(store, manager, size(item, 1), [[milk, '0.2', 'l']])
    add_menu(sale, size(item, 1), quantity: 2)

    expect(rows(menu_lines(sale).sole)).to eq([[milk.id, 400, 'variant']])
  end

  it 'adds each option picked, times its quantity and the line quantity' do
    topping = modifier_group!(store, item, name: 'Topping', options: { 'Trân châu' => 5_000, 'Kem' => 7_000 }, max: 3,
                                           allow_quantity: true)
    pick = option(topping, 'Trân châu')
    recipe!(store, manager, size(item, 0), [[milk, 150, 'ml']])
    recipe!(store, manager, pick, [[pearls, 30, 'g'], [milk, 10, 'ml']])
    add_menu(sale, size(item, 0), quantity: 2, modifiers: picks([pick, 2], [option(topping, 'Kem')]))

    key = "modifier:#{pick.prefixed_id}"
    expect(rows(menu_lines(sale).sole)).to eq([[milk.id, 40, key], [milk.id, 300, 'variant'], [pearls.id, 120, key]].sort)
  end

  it 'takes each combo part from its own recipe, or one stock unit of a stocked part' do
    burger = menu_item!(store, branch, name: 'Bánh mì', price: 20_000)
    bread = ingredient!(store, branch, name: 'Bánh', base: 'item')
    recipe!(store, manager, size(burger), [[bread, 1, 'item']])
    water = ingredient!(store, branch, name: 'Nước suối', base: 'chai')
    combo = menu_item!(store, branch, name: 'Combo sáng', price: 35_000, kind: 'combo')
    combo.combo_components.create!(variant: size(burger), quantity: 2)
    combo.combo_components.create!(variant: water, quantity: 1)
    add_menu(sale, size(combo), quantity: 3)

    expect(rows(menu_lines(sale).sole)).to eq([[bread.id, 6, "component:#{size(burger).prefixed_id}"],
                                               [water.id, 3, "component:#{water.prefixed_id}"]].sort)
  end

  it 'converts a pack of the ingredient to its stock unit (1 thùng = 24 chai)' do
    syrup = ingredient!(store, branch, name: 'Siro', base: 'chai', sale: 'case', ratio: 24)
    recipe!(store, manager, size(item, 0), [[syrup, 1, 'case'], [milk, '0.25', 'l']])
    add_menu(sale, size(item, 0))

    expect(rows(menu_lines(sale).sole)).to eq([[milk.id, 250, 'variant'], [syrup.id, 24, 'variant']].sort)
  end

  it 'uses nothing for a line whose size has no recipe' do
    add_menu(sale, size(item, 0))

    expect(rows(menu_lines(sale).sole)).to eq([])
  end
end
