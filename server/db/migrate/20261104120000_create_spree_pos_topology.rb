# frozen_string_literal: true

class CreateSpreePosTopology < ActiveRecord::Migration[8.1]
  def change
    create_table :spree_pos_branches do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }
      t.references :stock_location, null: false, foreign_key: { to_table: :spree_stock_locations }
      t.bigint :receiving_stock_location_id
      t.string :name, null: false
      t.string :code, null: false
      t.string :timezone, null: false
      t.jsonb :receiving_config, null: false, default: {}
      t.string :status, null: false, default: 'active'
      t.datetime :disabled_at
      t.timestamps
    end
    add_index :spree_pos_branches, [:store_id, :code], unique: true
    add_foreign_key :spree_pos_branches, :spree_stock_locations, column: :receiving_stock_location_id
    add_check_constraint :spree_pos_branches, "status IN ('active', 'disabled')", name: 'chk_spree_pos_branches_status'

    create_table :spree_pos_registers do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }
      t.references :branch, null: false, foreign_key: { to_table: :spree_pos_branches }
      t.string :name, null: false
      t.string :code, null: false
      t.string :status, null: false, default: 'active'
      t.datetime :disabled_at
      t.timestamps
    end
    add_index :spree_pos_registers, [:store_id, :code], unique: true
    add_check_constraint :spree_pos_registers, "status IN ('active', 'disabled')", name: 'chk_spree_pos_registers_status'

    create_table :spree_pos_staff_memberships do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }
      t.references :branch, null: false, foreign_key: { to_table: :spree_pos_branches }
      t.bigint :staff_id, null: false
      t.jsonb :capabilities, null: false, default: []
      t.string :status, null: false, default: 'active'
      t.datetime :disabled_at
      t.timestamps
    end
    add_index :spree_pos_staff_memberships, [:store_id, :branch_id, :staff_id], unique: true, name: 'idx_spree_pos_memberships_staff_branch'
    add_index :spree_pos_staff_memberships, :staff_id
    add_foreign_key :spree_pos_staff_memberships, :spree_admin_users, column: :staff_id
    add_check_constraint :spree_pos_staff_memberships, "status IN ('active', 'disabled')", name: 'chk_spree_pos_memberships_status'

    create_table :spree_pos_shifts do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }
      t.references :branch, null: false, foreign_key: { to_table: :spree_pos_branches }
      t.references :register, null: false, foreign_key: { to_table: :spree_pos_registers }
      t.bigint :owner_id, null: false
      t.decimal :opening_float, precision: 19, scale: 4, null: false
      t.string :currency, null: false
      t.string :status, null: false, default: 'open'
      t.datetime :opened_at, null: false
      t.timestamps
    end
    add_index :spree_pos_shifts, :register_id, unique: true, where: "status = 'open'", name: 'idx_spree_pos_shifts_one_open_register'
    add_index :spree_pos_shifts, :owner_id
    add_foreign_key :spree_pos_shifts, :spree_admin_users, column: :owner_id
    add_check_constraint :spree_pos_shifts, 'opening_float >= 0', name: 'chk_spree_pos_shifts_opening_float_nonnegative'
    add_check_constraint :spree_pos_shifts, "status IN ('open', 'closed')", name: 'chk_spree_pos_shifts_status'

    create_table :spree_pos_audit_entries do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }
      t.bigint :actor_id, null: false
      t.string :action, null: false
      t.string :subject_type, null: false
      t.bigint :subject_id, null: false
      t.jsonb :metadata, null: false, default: {}
      t.timestamps
    end
    add_index :spree_pos_audit_entries, [:subject_type, :subject_id]
    add_foreign_key :spree_pos_audit_entries, :spree_admin_users, column: :actor_id

    create_table :spree_pos_approvals do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }
      t.references :branch, null: false, foreign_key: { to_table: :spree_pos_branches }
      t.bigint :approver_id, null: false
      t.bigint :requester_id, null: false
      t.string :action, null: false
      t.decimal :amount, precision: 19, scale: 4
      t.string :currency
      t.string :revision, null: false
      t.string :subject_type
      t.bigint :subject_id
      t.datetime :expires_at, null: false
      t.datetime :revoked_at
      t.datetime :consumed_at
      t.string :status, null: false, default: 'active'
      t.timestamps
    end
    add_index :spree_pos_approvals, [:store_id, :action]
    add_foreign_key :spree_pos_approvals, :spree_admin_users, column: :approver_id
    add_foreign_key :spree_pos_approvals, :spree_admin_users, column: :requester_id
    add_check_constraint :spree_pos_approvals, "status IN ('active', 'revoked', 'consumed')", name: 'chk_spree_pos_approvals_status'
  end
end
