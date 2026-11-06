# frozen_string_literal: true

class AddCompletedToSpreePosWorkspaces < ActiveRecord::Migration[8.1]
  def change
    remove_check_constraint :spree_pos_workspaces, name: 'chk_spree_pos_workspaces_status'
    add_check_constraint :spree_pos_workspaces,
                         "operational_status IN ('editing', 'parked', 'canceled', 'completed')",
                         name: 'chk_spree_pos_workspaces_status'
  end
end
