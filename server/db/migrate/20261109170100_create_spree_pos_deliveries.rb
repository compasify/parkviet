# frozen_string_literal: true

# One row per sale marked for delivery. The order itself completes like any
# sale; this row only tracks the delivery: who takes it, the delivery fee
# (an order-level Spree::Fee, so totals stay core's), and whether it was
# delivered. Two statuses, `pending` (Chờ giao) and `delivered` (Đã giao).
class CreateSpreePosDeliveries < ActiveRecord::Migration[8.1]
  def change
    create_table :spree_pos_deliveries do |t|
      t.references :store, null: false, index: false, foreign_key: { to_table: :spree_stores }
      t.references :branch, null: false, index: false, foreign_key: { to_table: :spree_pos_branches }
      t.references :workspace, null: false, index: { unique: true }, foreign_key: { to_table: :spree_pos_workspaces }
      t.references :order, null: false, index: { unique: true }, foreign_key: { to_table: :spree_orders }
      # The fee row on the order; nil without a fee.
      t.references :fee, null: true, index: false, foreign_key: { to_table: :spree_fees, on_delete: :nullify }
      t.string :status, limit: 20, null: false, default: 'pending'
      t.string :deliverer, limit: 80
      t.decimal :fee_amount, precision: 10, scale: 2, null: false, default: 0
      t.datetime :delivered_at
      t.bigint :delivered_by_id
      t.bigint :created_by_id, null: false
      t.timestamps
    end
    add_index :spree_pos_deliveries, %i[branch_id status delivered_at], name: 'idx_pos_deliveries_branch_status'
    add_foreign_key :spree_pos_deliveries, :spree_admin_users, column: :delivered_by_id
    add_foreign_key :spree_pos_deliveries, :spree_admin_users, column: :created_by_id
    add_check_constraint :spree_pos_deliveries, "status IN ('pending', 'delivered')", name: 'chk_pos_deliveries_status'
    add_check_constraint :spree_pos_deliveries, 'fee_amount >= 0', name: 'chk_pos_deliveries_fee'
    add_check_constraint :spree_pos_deliveries, "(status = 'delivered') = (delivered_at IS NOT NULL)",
                         name: 'chk_pos_deliveries_delivered_at'
  end
end
