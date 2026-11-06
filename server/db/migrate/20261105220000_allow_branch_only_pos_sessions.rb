# frozen_string_literal: true

class AllowBranchOnlyPosSessions < ActiveRecord::Migration[8.1]
  def change
    change_column_null :spree_pos_shifts, :register_id, true
    change_column_null :spree_pos_workspaces, :register_id, true
    add_index :spree_pos_shifts, [:store_id, :branch_id, :owner_id], unique: true,
              where: "status = 'open' AND register_id IS NULL",
              name: 'idx_spree_pos_shifts_one_open_branch_owner'
  end
end
