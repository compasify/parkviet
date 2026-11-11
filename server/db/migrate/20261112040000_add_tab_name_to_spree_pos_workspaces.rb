# frozen_string_literal: true

# A bar tab is an open order named after its guest ("Anh Nam áo xanh"), so
# any counter or waiter finds it by name. Open tabs are searched by the
# lower-cased name within their branch. A table's minimum spend can be
# waived on one order; the flag lives on the order like the service charge.
class AddTabNameToSpreePosWorkspaces < ActiveRecord::Migration[8.1]
  def change
    add_column :spree_pos_workspaces, :tab_name, :string, limit: 60
    add_column :spree_pos_workspaces, :minimum_spend_waived, :boolean, null: false, default: false
    add_index :spree_pos_workspaces, 'branch_id, lower(tab_name)', name: 'idx_pos_workspaces_open_tab_name',
                                                                   where: "tab_name IS NOT NULL AND operational_status IN ('editing', 'parked')"
  end
end
