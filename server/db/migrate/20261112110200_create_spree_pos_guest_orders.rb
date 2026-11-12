# frozen_string_literal: true

# What a guest asked for from their phone: a request waiting for staff, never
# a change of the order itself. Prices are the server's quote at submission;
# accepting adds the items through the table's ordinary add command.
class CreateSpreePosGuestOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :spree_pos_guest_orders do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }, index: false
      t.references :branch, null: false, foreign_key: { to_table: :spree_pos_branches }, index: false
      t.references :guest_session, null: false, foreign_key: { to_table: :spree_pos_guest_sessions }, index: false
      t.references :workspace, null: false, foreign_key: { to_table: :spree_pos_workspaces }
      t.references :resource, null: false, foreign_key: { to_table: :spree_pos_resources }, index: false
      t.string :status, null: false, default: 'pending', limit: 16
      t.jsonb :items, null: false, default: []
      t.decimal :quoted_total, precision: 19, scale: 4, null: false
      t.string :currency, null: false, limit: 3
      t.integer :item_count, null: false
      t.string :idempotency_key, null: false, limit: 200
      t.string :request_digest, null: false, limit: 64
      t.uuid :append_batch_id, null: false
      t.boolean :automatic, null: false, default: false
      t.references :decided_by, foreign_key: { to_table: :spree_admin_users }, index: false
      t.datetime :decided_at
      t.string :reject_reason, limit: 200
      t.timestamps
    end
    add_index :spree_pos_guest_orders, %i[guest_session_id idempotency_key], unique: true, name: 'idx_pos_guest_orders_key'
    add_index :spree_pos_guest_orders, %i[branch_id status], name: 'idx_pos_guest_orders_branch_status'
    add_check_constraint :spree_pos_guest_orders, "status IN ('pending', 'accepted', 'rejected', 'expired')",
                         name: 'chk_pos_guest_orders_status'
    add_check_constraint :spree_pos_guest_orders, 'quoted_total >= 0', name: 'chk_pos_guest_orders_total'
    add_check_constraint :spree_pos_guest_orders, 'item_count BETWEEN 1 AND 50', name: 'chk_pos_guest_orders_item_count'
    add_check_constraint :spree_pos_guest_orders, "jsonb_typeof(items) = 'array'", name: 'chk_pos_guest_orders_items'
    add_check_constraint :spree_pos_guest_orders, "(status = 'pending') = (decided_at IS NULL)", name: 'chk_pos_guest_orders_decided'
  end
end
