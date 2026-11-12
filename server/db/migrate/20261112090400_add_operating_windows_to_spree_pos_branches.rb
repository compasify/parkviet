# frozen_string_literal: true

# When a branch opens play time, by days of the week (a clock started
# outside is only warned about), and how long a clock may stay paused before
# resuming needs a manager.
class AddOperatingWindowsToSpreePosBranches < ActiveRecord::Migration[8.1]
  def change
    add_column :spree_pos_branches, :operating_windows, :jsonb, null: false, default: []
    add_column :spree_pos_branches, :max_pause_minutes, :integer, null: false, default: 15
    add_check_constraint :spree_pos_branches, "jsonb_typeof(operating_windows) = 'array'", name: 'chk_pos_branches_operating_windows'
    add_check_constraint :spree_pos_branches, 'max_pause_minutes BETWEEN 1 AND 240', name: 'chk_pos_branches_max_pause'
  end
end
