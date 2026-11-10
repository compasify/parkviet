# frozen_string_literal: true

# Scale label formats become store-wide and are assigned to branches. The
# old branch_id stays as the branch a format was first made for; every
# existing format is assigned to that branch, so parsing does not change.
# Prefix uniqueness now holds over a branch's assigned active formats and
# is checked by the application under a branch lock.
class ShareSpreePosLabelFormats < ActiveRecord::Migration[8.1]
  def up
    change_column_null :spree_pos_label_formats, :branch_id, true
    remove_index :spree_pos_label_formats, name: 'idx_pos_label_formats_active_prefix'

    create_table :spree_pos_branch_label_formats do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }
      t.references :branch, null: false, index: false, foreign_key: { to_table: :spree_pos_branches }
      t.references :label_format, null: false, foreign_key: { to_table: :spree_pos_label_formats }
      t.timestamps
    end
    add_index :spree_pos_branch_label_formats, %i[branch_id label_format_id], unique: true,
                                                                              name: 'idx_pos_branch_label_formats_unique'

    execute <<~SQL.squish
      INSERT INTO spree_pos_branch_label_formats (store_id, branch_id, label_format_id, created_at, updated_at)
      SELECT store_id, branch_id, id, NOW(), NOW() FROM spree_pos_label_formats WHERE branch_id IS NOT NULL
    SQL
  end

  def down
    drop_table :spree_pos_branch_label_formats
    execute 'DELETE FROM spree_pos_label_formats WHERE branch_id IS NULL'
    change_column_null :spree_pos_label_formats, :branch_id, false
    add_index :spree_pos_label_formats, %i[branch_id prefix], unique: true, where: "status = 'active'",
                                                              name: 'idx_pos_label_formats_active_prefix'
  end
end
