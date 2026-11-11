# frozen_string_literal: true

# How much of a sale line the kitchen has been told about, and when a branch
# tells the kitchen: when the sale completes, or when the cashier presses
# "send to kitchen".
class AddKitchenColumnsToSpreePosSaleLinesAndBranches < ActiveRecord::Migration[8.1]
  def change
    add_column :spree_pos_sale_lines, :kitchen_sent_quantity, :decimal, precision: 19, scale: 4, null: false, default: 0
    add_check_constraint :spree_pos_sale_lines, 'kitchen_sent_quantity >= 0', name: 'chk_pos_sale_lines_kitchen_sent'

    add_column :spree_pos_branches, :kitchen_send_trigger, :string, null: false, default: 'on_complete'
    add_check_constraint :spree_pos_branches, "kitchen_send_trigger IN ('on_complete', 'manual')",
                         name: 'chk_pos_branches_kitchen_send_trigger'
  end
end
