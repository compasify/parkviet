# frozen_string_literal: true

# The bottle-keeping book of a bar: a guest's unfinished bottle kept under
# a code written on its label. It records levels only and never money; the
# bottle was sold on an ordinary line. Its history only grows.
class CreateSpreePosBottleKeeps < ActiveRecord::Migration[8.1]
  def change
    create_table :spree_pos_bottle_keeps do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }, index: false
      t.references :branch, null: false, foreign_key: { to_table: :spree_pos_branches }, index: false
      t.references :customer_profile, foreign_key: { to_table: :spree_pos_customers }
      t.string :guest_name, limit: 120
      t.string :phone, limit: 32
      t.references :variant, null: false, foreign_key: { to_table: :spree_variants }
      t.string :code, null: false, limit: 16
      t.integer :level_percent, null: false
      t.date :kept_on, null: false
      t.date :expires_on, null: false
      t.references :source_order, foreign_key: { to_table: :spree_orders }
      t.references :source_sale_line, foreign_key: { to_table: :spree_pos_sale_lines, on_delete: :nullify }
      t.string :note, limit: 200
      t.string :status, null: false, default: 'kept'
      # Approvals of a level correction are bound to this version.
      t.integer :revision, null: false, default: 0
      t.references :created_by, null: false, foreign_key: { to_table: :spree_admin_users }
      t.datetime :closed_at
      t.timestamps
    end
    add_index :spree_pos_bottle_keeps, %i[branch_id code], unique: true, name: 'idx_pos_bottle_keeps_code'
    add_index :spree_pos_bottle_keeps, %i[branch_id phone], name: 'idx_pos_bottle_keeps_phone'
    add_index :spree_pos_bottle_keeps, %i[branch_id status expires_on], name: 'idx_pos_bottle_keeps_expiry'
    add_check_constraint :spree_pos_bottle_keeps,
                         "status IN ('kept', 'finished', 'expired', 'returned') AND level_percent BETWEEN 0 AND 100 AND " \
                         'expires_on >= kept_on',
                         name: 'chk_pos_bottle_keeps_values'

    create_table :spree_pos_bottle_keep_events do |t|
      t.references :bottle_keep, null: false, foreign_key: { to_table: :spree_pos_bottle_keeps }
      t.string :kind, null: false
      t.integer :level_before
      t.integer :level_after, null: false
      t.integer :ml
      t.references :workspace, foreign_key: { to_table: :spree_pos_workspaces, on_delete: :nullify }
      t.references :approval, foreign_key: { to_table: :spree_pos_approvals }
      t.references :actor, null: false, foreign_key: { to_table: :spree_admin_users }
      t.string :note, limit: 200
      t.datetime :created_at, null: false
    end
    add_check_constraint :spree_pos_bottle_keep_events,
                         "kind IN ('open', 'pour', 'adjust', 'expire', 'return') AND level_after BETWEEN 0 AND 100 AND " \
                         '(level_before IS NULL OR level_before BETWEEN 0 AND 100) AND (ml IS NULL OR ml > 0)',
                         name: 'chk_pos_bottle_keep_events_values'

    # How long a kept bottle stays before it expires.
    add_column :spree_pos_branches, :bottle_keep_days, :integer, null: false, default: 90
    add_check_constraint :spree_pos_branches, 'bottle_keep_days BETWEEN 1 AND 3650', name: 'chk_pos_branches_bottle_keep_days'
  end
end
