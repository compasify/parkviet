# frozen_string_literal: true

# The owner's phone: approval requests a cashier or waiter sends to a
# manager's device instead of having the manager walk to the counter, the
# alerts an owner reads, and the optional push relay that wakes a phone in
# the background. Push tokens and the relay key are encrypted at rest.
class AddOwnerApp < ActiveRecord::Migration[8.1]
  def change
    create_table :spree_pos_approval_requests do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }, index: false
      t.references :branch, null: false, foreign_key: { to_table: :spree_pos_branches }, index: false
      t.references :requester, null: false, foreign_key: { to_table: :spree_admin_users }, index: false
      t.string :action, null: false, limit: 64
      t.string :subject_type, null: false, limit: 64
      t.bigint :subject_id, null: false
      t.string :revision, null: false, limit: 64
      t.decimal :amount, precision: 12, scale: 4
      t.string :currency, limit: 3
      t.string :reason, limit: 200
      t.string :status, null: false, default: 'pending', limit: 16
      t.references :approval, foreign_key: { to_table: :spree_pos_approvals }, index: false
      t.references :decided_by, foreign_key: { to_table: :spree_admin_users }, index: false
      t.datetime :decided_at
      t.datetime :expires_at, null: false
      t.timestamps
    end
    add_index :spree_pos_approval_requests, %i[branch_id status], name: 'idx_pos_approval_requests_branch_status'
    add_index :spree_pos_approval_requests, %i[requester_id status], name: 'idx_pos_approval_requests_requester'
    add_index :spree_pos_approval_requests, :approval_id, unique: true, where: 'approval_id IS NOT NULL',
                                                          name: 'idx_pos_approval_requests_approval'
    add_check_constraint :spree_pos_approval_requests, "status IN ('pending', 'granted', 'declined', 'expired', 'canceled')",
                         name: 'chk_pos_approval_requests_status'
    add_check_constraint :spree_pos_approval_requests, "(status = 'granted') = (approval_id IS NOT NULL)",
                         name: 'chk_pos_approval_requests_granted'
    add_check_constraint :spree_pos_approval_requests, "(status = 'pending') = (decided_at IS NULL)",
                         name: 'chk_pos_approval_requests_decided'
    add_check_constraint :spree_pos_approval_requests, '(amount IS NULL) = (currency IS NULL)',
                         name: 'chk_pos_approval_requests_currency'

    create_table :spree_pos_push_registrations do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }, index: false
      t.references :device, null: false, foreign_key: { to_table: :spree_pos_devices }, index: { unique: true, name: 'idx_pos_push_registrations_device' }
      t.references :staff, null: false, foreign_key: { to_table: :spree_admin_users }, index: false
      t.string :platform, null: false, limit: 8
      t.text :token, null: false
      t.boolean :enabled, null: false, default: true
      t.string :last_error, limit: 200
      t.datetime :last_error_at
      t.datetime :last_delivered_at
      t.timestamps
    end
    add_check_constraint :spree_pos_push_registrations, "platform IN ('fcm', 'apns')", name: 'chk_pos_push_registrations_platform'

    create_table :spree_pos_push_relay_settings do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }, index: { unique: true, name: 'idx_pos_push_relay_settings_store' }
      t.string :url, null: false, limit: 300
      t.text :relay_key, null: false
      t.references :changed_by, foreign_key: { to_table: :spree_admin_users }, index: false
      t.string :last_error, limit: 200
      t.datetime :last_error_at
      t.datetime :last_delivered_at
      t.timestamps
    end

    create_table :spree_pos_owner_alerts do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }, index: false
      t.references :branch, null: false, foreign_key: { to_table: :spree_pos_branches }, index: false
      t.string :kind, null: false, limit: 32
      t.string :dedupe_key, null: false, limit: 120
      t.string :subject_ref, limit: 64
      t.jsonb :details, null: false, default: {}
      t.datetime :occurred_at, null: false
      t.timestamps
    end
    add_index :spree_pos_owner_alerts, %i[branch_id dedupe_key], unique: true, name: 'idx_pos_owner_alerts_dedupe'
    add_index :spree_pos_owner_alerts, %i[branch_id occurred_at], name: 'idx_pos_owner_alerts_branch_time'
    add_check_constraint :spree_pos_owner_alerts,
                         "kind IN ('kitchen_late', 'shift_variance', 'void_burst', 'revenue_milestone', 'print_failed', 'einvoice_failed')",
                         name: 'chk_pos_owner_alerts_kind'
  end
end
