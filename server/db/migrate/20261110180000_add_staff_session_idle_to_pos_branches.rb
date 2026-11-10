# frozen_string_literal: true

# How long a device staff session may sit idle before it ends. The default
# is half an hour; a branch may choose 5 to 240 minutes.
class AddStaffSessionIdleToPosBranches < ActiveRecord::Migration[8.1]
  def change
    add_column :spree_pos_branches, :staff_session_idle_minutes, :integer, null: false, default: 30
  end
end
