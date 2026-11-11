# frozen_string_literal: true

# The call number an order gets the first time it is sent to the kitchen or
# completed, unique per branch and business date, and the name the counter
# calls out with it.
class AddCallNumberAndGuestNameToSpreePosWorkspaces < ActiveRecord::Migration[8.1]
  def change
    add_column :spree_pos_workspaces, :order_number, :integer
    add_column :spree_pos_workspaces, :guest_name, :string, limit: 60
    add_index :spree_pos_workspaces, %i[branch_id business_date order_number], unique: true,
                                                                               where: 'order_number IS NOT NULL',
                                                                               name: 'idx_pos_workspaces_order_number'
    add_check_constraint :spree_pos_workspaces, 'order_number IS NULL OR order_number > 0', name: 'chk_pos_workspaces_order_number'
  end
end
