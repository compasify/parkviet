# frozen_string_literal: true

class CreateSpreePosFinancialPrimitives < ActiveRecord::Migration[8.1]
  def change
    create_table :spree_pos_payment_methods do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }
      t.string :code, null: false, limit: 32
      t.string :name, null: false, limit: 120
      t.string :kind, null: false, limit: 32
      t.string :payment_method_type, limit: 120
      t.bigint :payment_method_id
      t.string :status, null: false, default: 'active'
      t.integer :position, null: false, default: 0
      t.jsonb :metadata, null: false, default: {}
      t.timestamps
    end
    add_index :spree_pos_payment_methods, [:store_id, :code], unique: true, name: 'idx_pos_payment_methods_store_code'
    add_index :spree_pos_payment_methods, [:store_id, :status, :position], name: 'idx_pos_payment_methods_active'
    add_check_constraint :spree_pos_payment_methods, "kind IN ('cash', 'bank_manual')", name: 'chk_pos_payment_methods_kind'
    add_check_constraint :spree_pos_payment_methods, "status IN ('active', 'disabled')", name: 'chk_pos_payment_methods_status'

    create_table :spree_pos_tender_attempts do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }
      t.references :workspace, null: false, foreign_key: { to_table: :spree_pos_workspaces }
      t.references :branch, null: false, foreign_key: { to_table: :spree_pos_branches }
      t.references :register, null: false, foreign_key: { to_table: :spree_pos_registers }
      t.references :shift, null: false, foreign_key: { to_table: :spree_pos_shifts }
      t.references :pos_payment_method, null: false, foreign_key: { to_table: :spree_pos_payment_methods }
      t.references :actor, null: false
      t.string :status, null: false, default: 'prepared'
      t.decimal :amount, precision: 19, scale: 4, null: false
      t.decimal :order_total_snapshot, precision: 19, scale: 4, null: false
      t.string :currency, null: false, limit: 16
      t.integer :workspace_revision, null: false
      t.jsonb :snapshot, null: false, default: {}
      t.datetime :confirmed_at
      t.datetime :canceled_at
      t.timestamps
    end
    add_foreign_key :spree_pos_tender_attempts, :spree_admin_users, column: :actor_id
    add_index :spree_pos_tender_attempts, [:workspace_id, :status], name: 'idx_pos_tender_attempts_workspace_status'
    add_check_constraint :spree_pos_tender_attempts, "status IN ('prepared', 'confirmed', 'canceled', 'unknown', 'failed')", name: 'chk_pos_tender_attempts_status'
    add_check_constraint :spree_pos_tender_attempts, 'amount > 0 AND order_total_snapshot >= 0', name: 'chk_pos_tender_attempts_amount'

    create_table :spree_pos_receipt_evidences do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }
      t.references :tender_attempt, null: false, foreign_key: { to_table: :spree_pos_tender_attempts }
      t.references :actor, null: false
      t.string :kind, null: false, limit: 32
      t.string :reference, limit: 120
      t.string :receiving_account, limit: 120
      t.string :terminal_ref, limit: 120
      t.datetime :attested_at, null: false
      t.jsonb :metadata, null: false, default: {}
      t.timestamps
    end
    add_foreign_key :spree_pos_receipt_evidences, :spree_admin_users, column: :actor_id
    add_index :spree_pos_receipt_evidences, [:tender_attempt_id, :created_at], name: 'idx_pos_receipt_evidences_attempt'
    add_check_constraint :spree_pos_receipt_evidences, "kind IN ('cash_count', 'bank_manual', 'external_card')", name: 'chk_pos_receipt_evidences_kind'

    create_table :spree_pos_received_funds do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }
      t.references :workspace, foreign_key: { to_table: :spree_pos_workspaces }
      t.references :branch, null: false, foreign_key: { to_table: :spree_pos_branches }
      t.references :register, null: false, foreign_key: { to_table: :spree_pos_registers }
      t.references :shift, null: false, foreign_key: { to_table: :spree_pos_shifts }
      t.references :tender_attempt, foreign_key: { to_table: :spree_pos_tender_attempts }
      t.references :actor, null: false
      t.string :kind, null: false, limit: 32
      t.string :status, null: false, default: 'received'
      t.decimal :handed_amount, precision: 19, scale: 4, null: false
      t.decimal :applied_amount, precision: 19, scale: 4, null: false
      t.decimal :change_amount, precision: 19, scale: 4, null: false, default: 0
      t.decimal :received_net, precision: 19, scale: 4, null: false
      t.string :currency, null: false, limit: 16
      t.string :reference, limit: 120
      t.datetime :received_at, null: false
      t.timestamps
    end
    add_foreign_key :spree_pos_received_funds, :spree_admin_users, column: :actor_id
    add_index :spree_pos_received_funds, [:tender_attempt_id], unique: true, where: 'tender_attempt_id IS NOT NULL', name: 'idx_pos_received_funds_attempt'
    add_index :spree_pos_received_funds, [:workspace_id, :status], name: 'idx_pos_received_funds_workspace'
    add_index :spree_pos_received_funds, [:shift_id, :status], name: 'idx_pos_received_funds_shift'
    add_check_constraint :spree_pos_received_funds, "kind IN ('cash', 'bank_manual')", name: 'chk_pos_received_funds_kind'
    add_check_constraint :spree_pos_received_funds, "status IN ('received', 'attention')", name: 'chk_pos_received_funds_status'
    add_check_constraint :spree_pos_received_funds, 'handed_amount >= 0 AND applied_amount >= 0 AND change_amount >= 0 AND received_net >= 0', name: 'chk_pos_received_funds_amounts'

    create_table :spree_pos_funds_allocations do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }
      t.references :received_funds, null: false, foreign_key: { to_table: :spree_pos_received_funds }
      t.references :workspace, null: false, foreign_key: { to_table: :spree_pos_workspaces }
      t.bigint :order_id, null: false
      t.bigint :payment_id
      t.string :status, null: false, default: 'active'
      t.decimal :amount, precision: 19, scale: 4, null: false
      t.string :currency, null: false, limit: 16
      t.datetime :reversed_at
      t.timestamps
    end
    add_foreign_key :spree_pos_funds_allocations, :spree_orders, column: :order_id
    add_foreign_key :spree_pos_funds_allocations, :spree_payments, column: :payment_id
    add_index :spree_pos_funds_allocations, [:received_funds_id, :status], name: 'idx_pos_funds_allocations_funds'
    add_index :spree_pos_funds_allocations, [:workspace_id, :status], name: 'idx_pos_funds_allocations_workspace'
    add_index :spree_pos_funds_allocations, [:payment_id], unique: true, where: 'payment_id IS NOT NULL', name: 'idx_pos_funds_allocations_payment'
    add_check_constraint :spree_pos_funds_allocations, "status IN ('active', 'reversed')", name: 'chk_pos_funds_allocations_status'
    add_check_constraint :spree_pos_funds_allocations, 'amount > 0', name: 'chk_pos_funds_allocations_amount'

    create_table :spree_pos_liability_payouts do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }
      t.references :received_funds, null: false, foreign_key: { to_table: :spree_pos_received_funds }
      t.references :branch, null: false, foreign_key: { to_table: :spree_pos_branches }
      t.references :requester, null: false
      t.string :status, null: false, default: 'requested'
      t.decimal :amount, precision: 19, scale: 4, null: false
      t.string :currency, null: false, limit: 16
      t.string :beneficiary_name, null: false, limit: 120
      t.string :beneficiary_reference, limit: 120
      t.string :reason, null: false, limit: 200
      t.datetime :confirmed_at
      t.datetime :resolved_at
      t.timestamps
    end
    add_foreign_key :spree_pos_liability_payouts, :spree_admin_users, column: :requester_id
    add_index :spree_pos_liability_payouts, [:received_funds_id, :status], name: 'idx_pos_liability_payouts_funds'
    add_check_constraint :spree_pos_liability_payouts, "status IN ('requested', 'reserved', 'unknown', 'confirmed', 'failed', 'canceled')", name: 'chk_pos_liability_payouts_status'
    add_check_constraint :spree_pos_liability_payouts, 'amount > 0', name: 'chk_pos_liability_payouts_amount'

    create_table :spree_pos_cash_movements do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }
      t.references :branch, null: false, foreign_key: { to_table: :spree_pos_branches }
      t.references :register, null: false, foreign_key: { to_table: :spree_pos_registers }
      t.references :shift, null: false, foreign_key: { to_table: :spree_pos_shifts }
      t.references :received_funds, foreign_key: { to_table: :spree_pos_received_funds }
      t.references :liability_payout, foreign_key: { to_table: :spree_pos_liability_payouts }
      t.references :actor, null: false
      t.string :kind, null: false, limit: 32
      t.decimal :amount, precision: 19, scale: 4, null: false
      t.string :currency, null: false, limit: 16
      t.string :source_type, null: false, limit: 64
      t.bigint :source_id, null: false
      t.timestamps
    end
    add_foreign_key :spree_pos_cash_movements, :spree_admin_users, column: :actor_id
    add_index :spree_pos_cash_movements, [:source_type, :source_id, :kind], unique: true, name: 'idx_pos_cash_movements_source'
    add_index :spree_pos_cash_movements, [:shift_id, :kind], name: 'idx_pos_cash_movements_shift'
    add_check_constraint :spree_pos_cash_movements, "kind IN ('receipt', 'payout')", name: 'chk_pos_cash_movements_kind'

    create_table :spree_pos_payout_evidences do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }
      t.references :liability_payout, null: false, foreign_key: { to_table: :spree_pos_liability_payouts }
      t.references :actor, null: false
      t.string :kind, null: false, limit: 32
      t.string :reference, limit: 120
      t.datetime :attested_at, null: false
      t.jsonb :metadata, null: false, default: {}
      t.timestamps
    end
    add_foreign_key :spree_pos_payout_evidences, :spree_admin_users, column: :actor_id
    add_index :spree_pos_payout_evidences, [:liability_payout_id, :created_at], name: 'idx_pos_payout_evidences_payout'
    add_check_constraint :spree_pos_payout_evidences, "kind IN ('cash_count', 'bank_manual', 'failed_no_effect')", name: 'chk_pos_payout_evidences_kind'

    create_table :spree_pos_outbox_entries do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }
      t.string :event_type, null: false, limit: 64
      t.string :aggregate_type, null: false, limit: 64
      t.bigint :aggregate_id, null: false
      t.jsonb :payload, null: false, default: {}
      t.string :status, null: false, default: 'pending'
      t.integer :attempts, null: false, default: 0
      t.datetime :available_at, null: false
      t.datetime :processed_at
      t.text :last_error
      t.timestamps
    end
    add_index :spree_pos_outbox_entries, [:status, :available_at], name: 'idx_pos_outbox_dispatch'
    add_check_constraint :spree_pos_outbox_entries, "status IN ('pending', 'processing', 'processed', 'failed')", name: 'chk_pos_outbox_status'
  end
end
