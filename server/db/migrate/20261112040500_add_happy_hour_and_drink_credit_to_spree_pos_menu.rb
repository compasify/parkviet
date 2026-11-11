# frozen_string_literal: true

# A time-of-day menu can carry a label shown on its prices ("Happy hour"),
# and a line keeps the label it was priced under. A door ticket is a menu
# item with a drink credit: the guest drinks that much of the allowed
# kitchen categories for free, applied as line discounts of their own source.
class AddHappyHourAndDrinkCreditToSpreePosMenu < ActiveRecord::Migration[8.1]
  def change
    add_column :spree_pos_menu_schedules, :label, :string, limit: 40
    add_column :spree_pos_sale_lines, :price_label, :string, limit: 40

    add_column :spree_pos_menu_items, :drink_credit, :decimal, precision: 19, scale: 4
    add_column :spree_pos_menu_items, :drink_credit_categories, :jsonb, null: false, default: []
    add_check_constraint :spree_pos_menu_items, 'drink_credit IS NULL OR drink_credit > 0', name: 'chk_pos_menu_items_drink_credit'

    add_column :spree_pos_line_discount_intents, :source, :string, null: false, default: 'manual'
    add_check_constraint :spree_pos_line_discount_intents, "source IN ('manual', 'cover_credit')",
                         name: 'chk_pos_line_discount_source'
  end
end
