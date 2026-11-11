# frozen_string_literal: true

# An order served at a table: which table, how many guests and, when a table
# holds several orders, the letter printed on its tickets.
class AddTableServiceToPosWorkspaces < ActiveRecord::Migration[8.1]
  def change
    add_reference :spree_pos_workspaces, :resource, foreign_key: { to_table: :spree_pos_resources }, index: false
    add_column :spree_pos_workspaces, :guest_count, :integer
    add_column :spree_pos_workspaces, :table_label, :string, limit: 4
    add_index :spree_pos_workspaces, %i[resource_id operational_status], name: 'idx_pos_workspaces_resource_status'
    add_check_constraint :spree_pos_workspaces, 'guest_count IS NULL OR guest_count BETWEEN 0 AND 999',
                         name: 'chk_pos_workspaces_guest_count'
    add_check_constraint :spree_pos_workspaces, "resource_id IS NULL OR service_mode IN ('dine_in', 'timed')",
                         name: 'chk_pos_workspaces_resource_mode'
  end
end
