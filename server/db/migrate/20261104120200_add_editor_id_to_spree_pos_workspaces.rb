# frozen_string_literal: true

class AddEditorIdToSpreePosWorkspaces < ActiveRecord::Migration[8.1]
  def change
    add_column :spree_pos_workspaces, :lease_editor_digest, :string
  end
end
