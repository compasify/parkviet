# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../../support/pos_recipe_helpers'

# Saving a recipe writes a new version, checks every ingredient once
# (untracked, a whole number of its stock unit in a unit that measures the
# same thing) and stops the size from keeping its own stock.
RSpec.describe Spree::Pos::Recipes::Save do
  include PosRecipeHelpers

  let(:store) { menu_store }
  let(:branch) { recipe_branch(store) }
  let(:manager) { recipe_manager(store, branch) }
  let(:item) { menu_item!(store, branch, name: 'Cà phê sữa', price: 25_000) }
  let(:variant) { size(item) }
  let(:milk) { ingredient!(store, branch, name: 'Sữa đặc', base: 'ml', cost: 50) }
  let(:coffee) { ingredient!(store, branch, name: 'Cà phê bột', base: 'g', sale: 'kg', ratio: 1, cost: 200_000) }

  def save(rows, owner: variant, confirm: true, staff: manager)
    described_class.call(store: store, staff: staff, key: SecureRandom.uuid, owner: owner, confirm_stock_write_off: confirm,
                         ingredients: rows.map do |ingredient, quantity, unit|
                           { 'variant_id' => ingredient.prefixed_id, 'quantity' => quantity, 'unit_code' => unit }
                         end)
  end

  def expect_conflict(reason, &block)
    expect(&block).to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq(reason) }
  end

  it 'writes a new version each time, keeps the old one, and audits the change' do
    first = save([[milk, '30', 'ml']])
    second = save([[milk, '40', 'ml'], [coffee, '0.02', 'kg']])

    expect(first.dig('active', 'version')).to eq(1)
    expect(second.dig('active', 'version')).to eq(2)
    expect(second['versions'].map { |row| [row['version'], row['active']] }).to eq([[2, true], [1, false]])
    ingredients = second.dig('active', 'ingredients')
    expect(ingredients.map { |row| [row['base_quantity'], row['base_unit']] }).to eq([[40, 'ml'], [20, 'g']])
    # 50/ml × 40 + 200 000/kg = 200/g × 20.
    expect(ingredients.map { |row| row['cost'] }).to eq(%w[2000.0 4000.0])
    expect(second.dig('active', 'estimated_cost')).to eq('6000.0')
    expect(Spree::Pos::Recipe.for_owner(variant).active.count).to eq(1)
    expect(Spree::Pos::RecipeIngredient.where(recipe: Spree::Pos::Recipe.for_owner(variant).find_by(version: 1)).sole.base_quantity).to eq(30)
    expect(Spree::Pos::AuditEntry.where(action: 'recipe.change').count).to eq(2)
  end

  it 'retires the recipe with an empty list' do
    save([[milk, '30', 'ml']])
    result = save([])

    expect(result['active']).to be_nil
    expect(Spree::Pos::Recipe.for_owner(variant).active).to be_empty
  end

  it 'refuses an ingredient tracked by serial or lot' do
    Spree::Pos::VariantUnit.find_by!(variant: milk).update!(tracked_mode: 'lot')

    expect_conflict('recipe_ingredient_tracked') { save([[milk, '30', 'ml']]) }
    expect(Spree::Pos::Recipe.count).to eq(0)
  end

  it 'refuses a unit that measures something else, and a quantity that is not whole stock units' do
    expect_conflict('recipe_unit_dimension') { save([[milk, '30', 'g']]) }
    expect_conflict('recipe_unit_dimension') { save([[milk, '1', 'item']]) }
    expect_conflict('recipe_quantity_inexact') { save([[milk, '0.5', 'ml']]) }
    expect_conflict('recipe_ingredient_duplicate') { save([[milk, '30', 'ml'], [milk, '10', 'ml']]) }
  end

  it 'stops the size keeping its own stock, and asks first while it has stock on hand' do
    expect(shelf(branch, variant)).to eq(100)
    expect_conflict('recipe_variant_has_stock') { save([[milk, '30', 'ml']], confirm: false) }
    expect(variant.reload.track_inventory).to be(true)

    save([[milk, '30', 'ml']])
    expect(variant.reload.track_inventory).to be(false)
  end

  it 'gives an option its own recipe without touching any stock setting' do
    group = modifier_group!(store, item, name: 'Thêm', options: { 'Thêm sữa' => 3_000 })
    result = save([[milk, '15', 'ml']], owner: option(group, 'Thêm sữa'))

    expect(result).to include('owner_type' => 'modifier_option', 'track_inventory' => nil)
    expect(variant.reload.track_inventory).to be(true)
  end

  it 'refuses while no branch of the store runs recipes, and people without inventory management' do
    cashier = credit_staff(store, branch, PosCreditHelpers::CASHIER)
    expect { save([[milk, '30', 'ml']], staff: cashier) }.to raise_error(CanCan::AccessDenied)

    set_pos_module(branch, 'fnb.recipes', false)
    expect_conflict('module_disabled') { save([[milk, '30', 'ml']]) }
  end
end
