# frozen_string_literal: true

# Where a POS sale came from: at the counter (default), Facebook, Zalo or
# elsewhere. A fixed list, so the sales report can group by it.
class AddOrderSourceToSpreePosWorkspaces < ActiveRecord::Migration[8.1]
  def change
    add_column :spree_pos_workspaces, :order_source, :string, limit: 20, null: false, default: 'counter'
    add_check_constraint :spree_pos_workspaces, "order_source IN ('counter', 'facebook', 'zalo', 'other')",
                         name: 'chk_pos_workspace_order_source'
  end
end
