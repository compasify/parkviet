# frozen_string_literal: true

class CreateSpreePosWorkspaces < ActiveRecord::Migration[8.1]
  def change
    create_table :spree_pos_workspaces do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }
      t.references :branch, null: false, foreign_key: { to_table: :spree_pos_branches }
      t.references :register, null: false, foreign_key: { to_table: :spree_pos_registers }
      t.references :shift, null: false, foreign_key: { to_table: :spree_pos_shifts }
      t.references :order, null: false, foreign_key: { to_table: :spree_orders }, index: { unique: true }
      t.integer :revision, null: false, default: 0
      t.integer :lease_generation, null: false, default: 0
      t.bigint :lease_holder_id
      t.datetime :lease_expires_at
      t.string :operational_status, null: false, default: 'editing'
      t.timestamps
    end
    add_index :spree_pos_workspaces, :lease_holder_id
    add_foreign_key :spree_pos_workspaces, :spree_admin_users, column: :lease_holder_id
    add_check_constraint :spree_pos_workspaces,
                         "operational_status IN ('editing', 'parked', 'canceled')",
                         name: 'chk_spree_pos_workspaces_status'

    create_table :spree_pos_command_receipts do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }
      t.references :workspace, foreign_key: { to_table: :spree_pos_workspaces }
      t.bigint :actor_id, null: false
      t.string :idempotency_key, null: false
      t.string :digest, null: false
      t.jsonb :result, null: false, default: {}
      t.timestamps
    end
    add_index :spree_pos_command_receipts, [:store_id, :actor_id, :idempotency_key],
              unique: true, name: 'idx_spree_pos_command_receipts_actor_key'
    add_foreign_key :spree_pos_command_receipts, :spree_admin_users, column: :actor_id
  end
end
