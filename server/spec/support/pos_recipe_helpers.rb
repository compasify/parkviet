# frozen_string_literal: true

require_relative 'pos_menu_helpers'

# Ingredients and recipes built on the real models, at a branch running
# `fnb.menu`, `fnb.recipes` and `retail.units`, for recipe workflow,
# completion and request specs.
module PosRecipeHelpers
  include PosMenuHelpers

  def recipe_branch(store, enabled: true)
    branch = menu_branch(store)
    set_pos_module(branch, 'retail.units', true)
    set_pos_module(branch, 'fnb.recipes', enabled)
    branch
  end

  def recipe_manager(store, branch)
    credit_staff(store, branch, [Spree::Pos::Capabilities::INVENTORY_MANAGE, Spree::Pos::Capabilities::MANAGE_MENU])
  end

  # A stocked ingredient counted in `base` (ml, g, chai, item). `sale` and
  # `ratio` give it a pack it is bought in (1 case = 24 chai); `cost` is
  # its cost price per that pack, or per stock unit without one.
  def ingredient!(store, branch, name:, base: 'ml', sale: nil, ratio: 1, stock: 1_000, cost: nil)
    Spree::Pos::UnitDefinition.ensure_defaults!(store)
    product = create(:product, store: store, status: 'active', name: name)
    variant = product.default_variant
    variant.update!(sku: "#{name.parameterize}-#{SecureRandom.hex(3)}", cost_price: cost)
    unit = ->(code) { Spree::Pos::UnitDefinition.find_by!(store: store, code: code) }
    Spree::Pos::VariantUnit.create!(store: store, variant: variant, sale_unit: unit.call(sale || base), base_unit: unit.call(base),
                                    price_unit: unit.call(sale || base), ratio_numerator: ratio, ratio_denominator: 1)
    Spree::Pos::BranchProduct.find_or_create_by!(branch: branch, product: product)
    branch.stock_location.restock(variant, stock) if stock.positive?
    variant
  end

  # Saves a recipe of `owner` straight through the workflow.
  def recipe!(store, staff, owner, rows, confirm: true)
    Spree::Pos::Recipes::Save.call(store: store, staff: staff, key: SecureRandom.uuid, owner: owner, confirm_stock_write_off: confirm,
                                   ingredients: rows.map do |variant, quantity, unit|
                                     { 'variant_id' => variant.prefixed_id, 'quantity' => quantity.to_s, 'unit_code' => unit }
                                   end)
  end

  def shelf(branch, variant)
    branch.stock_location.stock_level(variant)&.reload&.count_on_hand || 0
  end

  def pay_and_complete(sale)
    take_tender(sale, 'cash', sale.workspace.reload.order.total.to_i)
    Spree::Pos::Workspaces::Complete.call(**editing_args(sale))
  end
end
