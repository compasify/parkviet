# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../../support/pos_recipe_helpers'
require_relative '../../../../support/pos_return_helpers'

# Completing a sale at a branch running recipes takes the ingredients of
# every line off the shelf, once, in stock units; a short shelf never stops
# the sale and leaves a discrepancy for the next count. Returns of made
# items put no ingredient back, and retail returns restock as before.
RSpec.describe Spree::Pos::Workspaces::Complete do
  include PosRecipeHelpers
  include PosReturnHelpers

  let(:store) { menu_store }
  let(:branch) { recipe_branch(store) }
  let(:manager) { recipe_manager(store, branch) }
  let(:item) { menu_item!(store, branch, name: 'Trà sữa', price: 30_000, sizes: { 'M' => 30_000, 'L' => 36_000 }) }
  let(:milk) { ingredient!(store, branch, name: 'Sữa tươi', base: 'ml', stock: 1_000, cost: 40) }
  let(:pearls) { ingredient!(store, branch, name: 'Trân châu', base: 'g', stock: 500, cost: 100) }
  let(:topping) do
    modifier_group!(store, item, name: 'Topping', options: { 'Trân châu' => 5_000 }, max: 3, allow_quantity: true)
  end
  let(:sale) { menu_sale(store, branch) }

  before do
    recipe!(store, manager, size(item, 0), [[milk, 150, 'ml']])
    recipe!(store, manager, size(item, 1), [[milk, 200, 'ml']])
    recipe!(store, manager, option(topping, 'Trân châu'), [[pearls, 30, 'g']])
  end

  def consumptions
    Spree::Pos::RecipeConsumption.where(workspace_id: sale.workspace.id)
  end

  it 'takes the ingredients of every size and option off the shelf in stock units' do
    add_menu(sale, size(item, 1), quantity: 2, modifiers: picks([option(topping, 'Trân châu'), 2]))
    add_menu(sale, size(item, 0))
    pay_and_complete(sale)

    expect(shelf(branch, milk)).to eq(1_000 - 400 - 150)
    expect(shelf(branch, pearls)).to eq(500 - 120)
    expect(consumptions.pluck(:ingredient_variant_id, :base_quantity, :recipe_version, :unit_cost).sort).
      to eq([[milk.id, 150, 1, BigDecimal('40')], [milk.id, 400, 1, BigDecimal('40')], [pearls.id, 120, 1, BigDecimal('100')]])
    expect(consumptions.pluck(:business_date).uniq).to eq([sale.workspace.reload.business_date])
    movements = Spree::StockMovement.joins(:stock_level).where(spree_stock_levels: { variant_id: milk.id }, kind: 'adjusted')
    expect(movements.pluck(:quantity)).to eq([-550])
    # The sizes keep no stock of their own once they have a recipe.
    expect(size(item, 1).track_inventory).to be(false)
  end

  it 'consumes once when the completion is replayed or tried again' do
    add_menu(sale, size(item, 1))
    take_tender(sale, 'cash', 36_000)
    args = editing_args(sale)
    described_class.call(**args)
    described_class.call(**args)
    expect { described_class.call(**editing_args(sale)) }.to raise_error(Spree::Pos::Conflict)
    Spree::Pos::Recipes::Consume.call(workspace: sale.workspace.reload, actor: sale.cashier)

    expect(shelf(branch, milk)).to eq(800)
    expect(consumptions.count).to eq(1)
  end

  it 'completes a sale the shelf cannot cover, empties the shelf and records the rest' do
    low = ingredient!(store, branch, name: 'Sữa đặc', base: 'ml', stock: 50)
    recipe!(store, manager, size(item, 0), [[low, 80, 'ml']])
    add_menu(sale, size(item, 0))
    pay_and_complete(sale)

    expect(sale.workspace.reload.operational_status).to eq('completed')
    expect(shelf(branch, low)).to eq(0)
    gap = Spree::Pos::StockDiscrepancy.find_by!(workspace_id: sale.workspace.id, variant_id: low.id)
    expect(gap).to have_attributes(source: 'recipe', needed: 80, on_hand: 50, status: 'open')
    expect(consumptions.sole.base_quantity).to eq(80)

    # Handing the order over leaves the ingredient gap for the count.
    hand_over(sale)
    expect(gap.reload.status).to eq('open')
  end

  it 'takes nothing while the branch does not run recipes' do
    set_pos_module(branch, 'fnb.recipes', false)
    add_menu(sale, size(item, 1))
    pay_and_complete(sale)

    expect(shelf(branch, milk)).to eq(1_000)
    expect(consumptions).to be_empty
  end

  it 'records stock.low when the shelf goes below the branch threshold' do
    Spree::Pos::StockAlert.create!(store: store, branch: branch, variant: milk, min_quantity: 900)
    add_menu(sale, size(item, 1))
    pay_and_complete(sale)

    entry = Spree::Pos::AuditEntry.find_by!(action: 'stock.low')
    expect(entry.metadata).to include('variant_id' => milk.prefixed_id, 'on_hand' => 800, 'min_quantity' => 900)

    second = menu_sale(store, branch)
    add_menu(second, size(item, 1))
    pay_and_complete(second)
    expect(Spree::Pos::AuditEntry.where(action: 'stock.low').count).to eq(1)
  end

  describe 'returns' do
    let(:returner) { credit_staff(store, branch, PosReturnHelpers::RETURNS) }

    before { branch.update!(return_window_days: 30) }

    it 'puts no ingredient back for a made item, and restocks a retail item as before' do
      add_menu(sale, size(item, 1))
      pay_and_complete(sale)
      hand_over(sale)
      return_and_receive(store, returner, branch, sale, quantity: 1)

      expect(shelf(branch, milk)).to eq(800)
      expect(Spree::Pos::RecipeConsumption.where(workspace_id: sale.workspace.id).sum(:base_quantity)).to eq(200)

      product = stocked_product(store, branch, price: 10_000, stock: 5)
      retail = paid_sale(store, branch, cashier: returner, price: 10_000, product: product)
      expect(on_hand(branch, product)).to eq(4)
      return_and_receive(store, returner, branch, retail, quantity: 1)
      expect(on_hand(branch, product)).to eq(5)
    end
  end
end
