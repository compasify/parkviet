# frozen_string_literal: true

class AllowPosItemDiscountOverrides < ActiveRecord::Migration[8.1]
  def change
    remove_check_constraint :spree_pos_line_discount_intents, name: 'chk_pos_line_discount_type', expression: "value_type IN ('flat', 'percent', 'unit_price')"
    add_check_constraint :spree_pos_line_discount_intents, "value_type IN ('flat', 'percent', 'unit_price', 'item_flat', 'item_percent')", name: 'chk_pos_line_discount_type'
  end
end
