# frozen_string_literal: true

require_relative 'pos_credit_helpers'

# Menu fixtures built on the real models, and a draft at a branch running
# `fnb.menu`, for workflow and request specs of the menu.
module PosMenuHelpers
  include PosCreditHelpers

  def menu_store
    create(:store, default_currency: 'VND', supported_currencies: 'VND')
  end

  def menu_branch(store, enabled: true)
    branch = credit_branch(store)
    set_pos_module(branch, 'fnb.menu', enabled)
    branch
  end

  # A product on the menu. `sizes` ({ 'M' => 30_000, 'L' => 35_000 }) gives
  # one variant per size, labelled by an option value, the product's default
  # variant being the first; without sizes the default variant sells at `price`.
  def menu_item!(store, branch, name:, price:, sizes: {}, kind: 'single', category: nil)
    product = create(:product, store: store, status: 'active', name: name)
    product.default_variant.set_price(store.default_currency, price)
    if sizes.any?
      size_type = create(:option_type, name: "size-#{SecureRandom.hex(4)}", presentation: 'Size')
      sizes.each_with_index do |(label, amount), index|
        value = create(:option_value, option_type: size_type, name: label.downcase, presentation: label)
        sku = "#{name.parameterize}-#{label.downcase}-#{SecureRandom.hex(3)}"
        variant = if index.zero?
                    product.default_variant.tap { |first| first.update!(sku: sku, option_values: [value]) }
                  else
                    create(:variant, product: product, sku: sku, option_values: [value])
                  end
        variant.set_price(store.default_currency, amount)
      end
    end
    product.reload
    product.variants.each { |variant| branch.stock_location.restock(variant, 100) }
    Spree::Pos::BranchProduct.find_or_create_by!(branch: branch, product: product)
    Spree::Pos::MenuItem.create!(store: store, product: product, kind: kind, menu_category: category)
  end

  def size(item, index = 0)
    item.reload.sizes[index]
  end

  # A group of `options` ({ 'Trân châu' => 5_000 }) offered on `item`.
  def modifier_group!(store, item, name:, options:, min: 0, max: 1, allow_quantity: false, defaults: [])
    group = Spree::Pos::ModifierGroup.create!(store: store, name: name, min_select: min, max_select: max, allow_quantity: allow_quantity)
    options.each_with_index do |(label, delta), index|
      group.modifier_options.create!(name: label, price_delta: delta, position: index, default_selected: defaults.include?(label))
    end
    Spree::Pos::MenuItemModifierGroup.create!(menu_item: item, modifier_group: group, position: item.menu_item_modifier_groups.count)
    item.reload
    group.reload
  end

  def option(group, name)
    group.modifier_options.find_by!(name: name)
  end

  # `[[option, quantity], ...]` as the API takes it.
  def picks(*rows)
    rows.map { |picked, quantity = 1| { 'option_id' => picked.prefixed_id, 'quantity' => quantity } }
  end

  # An open draft with no lines yet, on the cashier's open shift.
  def menu_sale(store, branch)
    cashier = credit_staff(store, branch, PosCreditHelpers::CASHIER)
    editor_id = SecureRandom.uuid
    register = open_drawer(store, branch, cashier)
    created = Spree::Pos::Workspaces::Create.call(store: store, staff: cashier, register_id: register.prefixed_id,
                                                  key: SecureRandom.uuid, editor_id: editor_id)
    PosCreditHelpers::Sale.new(workspace: Spree::Pos::Workspace.find_by_prefix_id!(created['id']), cashier: cashier,
                               editor_id: editor_id, product: nil)
  end

  def add_menu(sale, variant, quantity: 1, modifiers: nil, note: nil, merge: true)
    Spree::Pos::Workspaces::ManageLineItem.add(**editing_args(sale), variant_id: variant.prefixed_id, quantity: quantity,
                                                                     modifiers: modifiers, note: note, merge: merge)
  end

  def menu_lines(sale)
    Spree::Pos::SaleLine.where(workspace_id: sale.workspace.id).order(:id).to_a
  end
end
