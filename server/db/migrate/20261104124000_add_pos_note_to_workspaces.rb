# frozen_string_literal: true

class AddPosNoteToWorkspaces < ActiveRecord::Migration[8.1]
  def change
    add_column :spree_pos_workspaces, :note, :text
    add_check_constraint :spree_pos_workspaces, 'note IS NULL OR char_length(note) <= 1000', name: 'chk_pos_workspace_note_length'
  end
end
