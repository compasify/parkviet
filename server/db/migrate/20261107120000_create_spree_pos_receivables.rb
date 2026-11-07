# frozen_string_literal: true

# Credit sales and receivables. A credit account is off until a manager
# configures it; an approved reservation holds exposure until the sale
# commits it into an immutable debit entry. Collections are one actual
# receipt (a ReceivedFunds parent) allocated to one or more debtor orders.
class CreateSpreePosReceivables < ActiveRecord::Migration[8.1]
  def change
    create_table :spree_pos_credit_accounts do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }
      t.references :customer_profile, null: false, foreign_key: { to_table: :spree_pos_customers }
      # Home branch: credit terms are administered by credit managers there.
      t.references :branch, null: false, foreign_key: { to_table: :spree_pos_branches }
      t.decimal :credit_limit, precision: 19, scale: 4, null: false
      t.integer :due_days, null: false
      t.string :status, null: false, default: 'active', limit: 16
      t.string :currency, null: false, limit: 16
      t.references :updated_by, null: false
      t.timestamps
    end
    add_foreign_key :spree_pos_credit_accounts, :spree_admin_users, column: :updated_by_id
    add_index :spree_pos_credit_accounts, [:store_id, :customer_profile_id, :currency], unique: true,
                                                                                        name: 'idx_pos_credit_accounts_customer'
    add_check_constraint :spree_pos_credit_accounts, "status IN ('active', 'suspended')", name: 'chk_pos_credit_accounts_status'
    add_check_constraint :spree_pos_credit_accounts, 'credit_limit >= 0 AND due_days >= 0', name: 'chk_pos_credit_accounts_terms'

    create_table :spree_pos_credit_reservations do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }
      t.references :credit_account, null: false, foreign_key: { to_table: :spree_pos_credit_accounts }
      t.references :workspace, null: false, foreign_key: { to_table: :spree_pos_workspaces }
      t.references :approval, null: false, foreign_key: { to_table: :spree_pos_approvals }, index: { unique: true }
      t.references :customer_profile, null: false, foreign_key: { to_table: :spree_pos_customers }
      t.decimal :amount, precision: 19, scale: 4, null: false
      t.string :currency, null: false, limit: 16
      t.integer :workspace_revision, null: false
      t.string :status, null: false, default: 'active', limit: 16
      t.string :released_reason, limit: 64
      t.datetime :committed_at
      t.datetime :released_at
      t.timestamps
    end
    add_index :spree_pos_credit_reservations, [:credit_account_id, :status], name: 'idx_pos_credit_reservations_account'
    add_index :spree_pos_credit_reservations, [:workspace_id], unique: true, where: "status = 'active'",
                                                               name: 'idx_pos_credit_reservations_one_active'
    add_check_constraint :spree_pos_credit_reservations, "status IN ('active', 'committed', 'released')",
                         name: 'chk_pos_credit_reservations_status'
    add_check_constraint :spree_pos_credit_reservations, 'amount > 0', name: 'chk_pos_credit_reservations_amount'

    # A cashier's request for a manager to approve the unpaid remainder of one
    # workspace revision on credit. It stops being actionable once the
    # workspace moves to another revision.
    create_table :spree_pos_credit_requests do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }
      t.references :branch, null: false, foreign_key: { to_table: :spree_pos_branches }
      t.references :workspace, null: false, foreign_key: { to_table: :spree_pos_workspaces }
      t.references :customer_profile, null: false, foreign_key: { to_table: :spree_pos_customers }
      t.references :requester, null: false
      t.references :decided_by
      t.references :credit_reservation, foreign_key: { to_table: :spree_pos_credit_reservations }
      t.decimal :amount, precision: 19, scale: 4, null: false
      t.string :currency, null: false, limit: 16
      t.integer :workspace_revision, null: false
      t.string :status, null: false, default: 'pending', limit: 16
      t.string :reason, limit: 200
      t.datetime :decided_at
      t.timestamps
    end
    add_foreign_key :spree_pos_credit_requests, :spree_admin_users, column: :requester_id
    add_foreign_key :spree_pos_credit_requests, :spree_admin_users, column: :decided_by_id
    add_index :spree_pos_credit_requests, [:workspace_id, :workspace_revision], unique: true,
                                                                                name: 'idx_pos_credit_requests_revision'
    add_index :spree_pos_credit_requests, [:branch_id, :status], name: 'idx_pos_credit_requests_branch'
    add_check_constraint :spree_pos_credit_requests, "status IN ('pending', 'approved', 'rejected', 'stale')",
                         name: 'chk_pos_credit_requests_status'
    add_check_constraint :spree_pos_credit_requests, 'amount > 0', name: 'chk_pos_credit_requests_amount'

    create_table :spree_pos_collections do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }
      t.references :credit_account, null: false, foreign_key: { to_table: :spree_pos_credit_accounts }
      t.references :received_funds, null: false, foreign_key: { to_table: :spree_pos_received_funds }, index: { unique: true }
      t.references :branch, null: false, foreign_key: { to_table: :spree_pos_branches }
      t.references :actor, null: false
      t.string :note, limit: 200
      t.timestamps
    end
    add_foreign_key :spree_pos_collections, :spree_admin_users, column: :actor_id

    add_reference :spree_pos_funds_allocations, :collection, foreign_key: { to_table: :spree_pos_collections }

    create_table :spree_pos_receivable_entries do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }
      t.references :credit_account, null: false, foreign_key: { to_table: :spree_pos_credit_accounts }
      t.references :branch, null: false, foreign_key: { to_table: :spree_pos_branches }
      t.bigint :order_id, null: false
      t.references :workspace, null: false, foreign_key: { to_table: :spree_pos_workspaces }
      t.references :credit_reservation, foreign_key: { to_table: :spree_pos_credit_reservations }
      t.references :funds_allocation, foreign_key: { to_table: :spree_pos_funds_allocations }
      t.references :actor, null: false
      t.string :kind, null: false, limit: 32
      t.decimal :amount, precision: 19, scale: 4, null: false
      t.string :currency, null: false, limit: 16
      t.date :due_on
      t.string :source_type, limit: 64
      t.bigint :source_id
      t.jsonb :metadata, null: false, default: {}
      t.datetime :created_at, null: false
    end
    add_foreign_key :spree_pos_receivable_entries, :spree_orders, column: :order_id
    add_foreign_key :spree_pos_receivable_entries, :spree_admin_users, column: :actor_id
    add_index :spree_pos_receivable_entries, [:credit_account_id, :order_id], name: 'idx_pos_receivable_entries_account_order'
    add_index :spree_pos_receivable_entries, [:order_id], unique: true, where: "kind = 'debit'",
                                                          name: 'idx_pos_receivable_entries_one_debit'
    add_index :spree_pos_receivable_entries, [:funds_allocation_id, :kind], unique: true, where: 'funds_allocation_id IS NOT NULL',
                                                                            name: 'idx_pos_receivable_entries_allocation'
    add_index :spree_pos_receivable_entries, [:source_type, :source_id], unique: true,
                                                                         where: "kind = 'credit_note'",
                                                                         name: 'idx_pos_receivable_entries_credit_note_source'
    add_check_constraint :spree_pos_receivable_entries,
                         "kind IN ('debit', 'credit_note', 'collection', 'collection_reversal')",
                         name: 'chk_pos_receivable_entries_kind'
    add_check_constraint :spree_pos_receivable_entries, 'amount > 0', name: 'chk_pos_receivable_entries_amount'
    add_check_constraint :spree_pos_receivable_entries,
                         "(kind = 'debit') = (due_on IS NOT NULL AND credit_reservation_id IS NOT NULL)",
                         name: 'chk_pos_receivable_entries_debit'
    add_check_constraint :spree_pos_receivable_entries,
                         "(kind IN ('collection', 'collection_reversal')) = (funds_allocation_id IS NOT NULL)",
                         name: 'chk_pos_receivable_entries_allocation'
    add_check_constraint :spree_pos_receivable_entries,
                         "kind <> 'credit_note' OR (source_type IS NOT NULL AND source_id IS NOT NULL)",
                         name: 'chk_pos_receivable_entries_credit_note'
  end
end
