# frozen_string_literal: true

# A customer display shows one pinned order (`order`) or the branch's call
# numbers (`call_board`).
class AddModeToSpreePosDisplaySessions < ActiveRecord::Migration[8.1]
  def change
    add_column :spree_pos_display_sessions, :mode, :string, limit: 16, null: false, default: 'order'
    add_check_constraint :spree_pos_display_sessions, "mode IN ('order', 'call_board')", name: 'chk_pos_display_sessions_mode'
  end
end
