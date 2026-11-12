# frozen_string_literal: true

# Cash sales a counter made while it could not reach the server, replayed
# once it could. Each one is recorded once per store (the client's
# offline id) with what the cashier collected; the server prices it again,
# completes it through the ordinary commands, or keeps it for a person to
# review (prices changed, an item ran out, the shift had closed) or reject.
class CreateSpreePosOfflineSales < ActiveRecord::Migration[8.1]
  def change
    create_table :spree_pos_offline_sales do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }, index: false
      t.references :branch, null: false, foreign_key: { to_table: :spree_pos_branches }, index: false
      t.references :register, null: false, foreign_key: { to_table: :spree_pos_registers }, index: false
      t.references :shift, null: false, foreign_key: { to_table: :spree_pos_shifts }, index: false
      t.references :staff, null: false, foreign_key: { to_table: :spree_admin_users }, index: false
      t.uuid :offline_id, null: false
      t.string :provisional_number, null: false, limit: 40
      t.datetime :client_sold_at, null: false
      t.integer :clock_skew_seconds, null: false, default: 0
      t.boolean :clock_check, null: false, default: false
      t.jsonb :payload, null: false, default: {}
      t.decimal :collected_total, precision: 12, scale: 4, null: false
      t.decimal :handed_amount, precision: 12, scale: 4, null: false
      t.string :currency, null: false, limit: 3
      t.string :status, null: false, limit: 16
      t.references :workspace, foreign_key: { to_table: :spree_pos_workspaces }, index: false
      t.string :review_reason, limit: 40
      t.jsonb :review_details, null: false, default: {}
      t.references :resolved_by, foreign_key: { to_table: :spree_admin_users }, index: false
      t.datetime :resolved_at
      t.string :resolution, limit: 32
      t.string :resolution_note, limit: 200
      t.timestamps
    end
    add_index :spree_pos_offline_sales, %i[store_id offline_id], unique: true, name: 'idx_pos_offline_sales_offline_id'
    add_index :spree_pos_offline_sales, %i[branch_id status], name: 'idx_pos_offline_sales_branch_status'
    add_index :spree_pos_offline_sales, :shift_id, name: 'idx_pos_offline_sales_shift'
    add_index :spree_pos_offline_sales, :workspace_id, unique: true, where: 'workspace_id IS NOT NULL',
                                                       name: 'idx_pos_offline_sales_workspace'
    add_check_constraint :spree_pos_offline_sales, "status IN ('completed', 'needs_review', 'rejected')",
                         name: 'chk_pos_offline_sales_status'
    add_check_constraint :spree_pos_offline_sales, 'collected_total >= 0 AND handed_amount >= collected_total',
                         name: 'chk_pos_offline_sales_amounts'
    add_check_constraint :spree_pos_offline_sales,
                         '(resolved_at IS NULL) = (resolution IS NULL) AND (resolved_at IS NULL) = (resolved_by_id IS NULL)',
                         name: 'chk_pos_offline_sales_resolved'
    add_check_constraint :spree_pos_offline_sales,
                         "status <> 'needs_review' OR (review_reason IS NOT NULL AND resolved_at IS NULL)",
                         name: 'chk_pos_offline_sales_review'
    add_check_constraint :spree_pos_offline_sales, "status <> 'rejected' OR resolved_at IS NOT NULL",
                         name: 'chk_pos_offline_sales_rejected'
    add_check_constraint :spree_pos_offline_sales, "status <> 'completed' OR workspace_id IS NOT NULL",
                         name: 'chk_pos_offline_sales_completed'
  end
end
