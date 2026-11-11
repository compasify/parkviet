# frozen_string_literal: true

# Pre-bills printed for an order, counted on the server so a second print or
# a cancel needs an approval, and a waiter's request that a table pays.
class CreateSpreePosPrebillPrintsAndPaymentRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :spree_pos_prebill_prints do |t|
      t.references :workspace, null: false, foreign_key: { to_table: :spree_pos_workspaces }, index: false
      t.integer :revision, null: false
      t.integer :sequence, null: false
      t.references :staff, null: false, foreign_key: { to_table: :spree_admin_users }
      t.references :approval, foreign_key: { to_table: :spree_pos_approvals }
      t.string :status, null: false, default: 'current'
      t.decimal :total, precision: 12, scale: 2, null: false
      t.string :currency, null: false, limit: 3
      t.timestamps
    end
    add_index :spree_pos_prebill_prints, %i[workspace_id sequence], unique: true, name: 'idx_pos_prebill_prints_sequence'
    add_check_constraint :spree_pos_prebill_prints, "status IN ('current', 'superseded', 'canceled')",
                         name: 'chk_pos_prebill_prints_status'

    create_table :spree_pos_payment_requests do |t|
      t.references :workspace, null: false, foreign_key: { to_table: :spree_pos_workspaces }, index: false
      t.references :requested_by, null: false, foreign_key: { to_table: :spree_admin_users }
      t.references :device, foreign_key: { to_table: :spree_pos_devices }
      t.references :resolved_by, foreign_key: { to_table: :spree_admin_users }
      t.string :status, null: false, default: 'open'
      t.string :note, limit: 200
      t.datetime :resolved_at
      t.timestamps
    end
    add_index :spree_pos_payment_requests, :workspace_id, name: 'idx_pos_payment_requests_workspace'
    add_index :spree_pos_payment_requests, :workspace_id, unique: true, where: "status = 'open'",
                                                          name: 'idx_pos_payment_requests_open'
    add_check_constraint :spree_pos_payment_requests, "status IN ('open', 'done', 'canceled')",
                         name: 'chk_pos_payment_requests_status'
  end
end
