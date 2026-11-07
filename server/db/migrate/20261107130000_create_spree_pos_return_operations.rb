# frozen_string_literal: true

# Returns, refunds and exchanges at the counter.
#
# A return operation is one customer return against one placed POS order. Its
# reservations hold returned quantities per immutable SaleLine, in sequence,
# together with the cumulative entitlement delta each one grants. A refund
# request consumes the original receipt through one allocation child and only
# becomes a core Refund once the payout is confirmed with evidence. Exchanges
# link a return operation to the replacement sale; both legs keep their own
# documents. Stock shortages at handover are recorded for reconciliation
# instead of blocking the counter or forcing stock negative.
class CreateSpreePosReturnOperations < ActiveRecord::Migration[8.1]
  def change
    # Null keeps returns off at a branch until a manager sets a window.
    add_column :spree_pos_branches, :return_window_days, :integer
    add_check_constraint :spree_pos_branches, 'return_window_days IS NULL OR (return_window_days >= 0 AND return_window_days <= 3650)',
                         name: 'chk_pos_branches_return_window'

    create_table :spree_pos_return_operations do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }
      # Receiving branch: where the goods come back and are restocked.
      t.references :branch, null: false, foreign_key: { to_table: :spree_pos_branches }
      t.references :sale_branch, null: false, foreign_key: { to_table: :spree_pos_branches }
      t.references :workspace, null: false, foreign_key: { to_table: :spree_pos_workspaces }
      t.references :order, null: false, foreign_key: { to_table: :spree_orders }
      t.references :core_return, null: false, foreign_key: { to_table: :spree_returns }, index: { unique: true }
      t.references :requester, null: false
      t.references :receiver
      t.references :approval, foreign_key: { to_table: :spree_pos_approvals }
      t.string :status, null: false, default: 'ready', limit: 32
      t.string :entitlement_status, null: false, default: 'pending', limit: 32
      t.string :reason, null: false, limit: 200
      t.boolean :cross_branch, null: false, default: false
      t.boolean :out_of_window, null: false, default: false
      t.boolean :damaged, null: false, default: false
      t.boolean :requires_approval, null: false, default: false
      t.integer :revision, null: false, default: 1
      t.decimal :entitlement_total, precision: 19, scale: 4, null: false, default: 0
      t.decimal :credit_note_amount, precision: 19, scale: 4, null: false, default: 0
      t.decimal :refund_entitlement, precision: 19, scale: 4, null: false, default: 0
      t.string :currency, null: false, limit: 16
      t.datetime :received_at
      t.datetime :posted_at
      t.datetime :canceled_at
      t.timestamps
    end
    add_foreign_key :spree_pos_return_operations, :spree_admin_users, column: :requester_id
    add_foreign_key :spree_pos_return_operations, :spree_admin_users, column: :receiver_id
    add_index :spree_pos_return_operations, [:store_id, :status], name: 'idx_pos_return_operations_status'
    add_index :spree_pos_return_operations, [:order_id, :status], name: 'idx_pos_return_operations_order'
    add_check_constraint :spree_pos_return_operations, "status IN ('pending_approval', 'ready', 'received', 'canceled')",
                         name: 'chk_pos_return_operations_status'
    add_check_constraint :spree_pos_return_operations, "entitlement_status IN ('pending', 'awaiting_predecessor', 'posted', 'canceled')",
                         name: 'chk_pos_return_operations_entitlement'
    add_check_constraint :spree_pos_return_operations,
                         'entitlement_total >= 0 AND credit_note_amount >= 0 AND refund_entitlement >= 0 AND ' \
                         'credit_note_amount + refund_entitlement <= entitlement_total',
                         name: 'chk_pos_return_operations_amounts'

    create_table :spree_pos_return_reservations do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }
      t.references :return_operation, null: false, foreign_key: { to_table: :spree_pos_return_operations }
      t.references :sale_line, null: false, foreign_key: { to_table: :spree_pos_sale_lines }
      t.references :line_item, null: false, foreign_key: { to_table: :spree_line_items }
      t.references :fulfillment_item, null: false, foreign_key: { to_table: :spree_fulfillment_items }
      t.references :return_line_item, null: false, foreign_key: { to_table: :spree_return_line_items }, index: { unique: true }
      # Base units, the unit the immutable SaleLine and core fulfillment use.
      t.integer :quantity, null: false
      t.integer :sequence, null: false
      t.integer :cumulative_before, null: false
      t.integer :cumulative_after, null: false
      t.string :condition, null: false, limit: 16
      t.string :status, null: false, default: 'reserved', limit: 16
      t.decimal :total, precision: 19, scale: 4, null: false
      t.decimal :net, precision: 19, scale: 4, null: false
      t.decimal :tax, precision: 19, scale: 4, null: false
      t.decimal :discount, precision: 19, scale: 4, null: false
      t.decimal :gross, precision: 19, scale: 4, null: false
      t.integer :received_quantity, null: false, default: 0
      t.integer :restocked_quantity, null: false, default: 0
      t.timestamps
    end
    add_index :spree_pos_return_reservations, [:sale_line_id, :sequence], unique: true, name: 'idx_pos_return_reservations_sequence'
    add_index :spree_pos_return_reservations, [:return_operation_id, :sale_line_id], unique: true,
                                                                                     name: 'idx_pos_return_reservations_line'
    add_check_constraint :spree_pos_return_reservations, "status IN ('reserved', 'posted', 'canceled')",
                         name: 'chk_pos_return_reservations_status'
    add_check_constraint :spree_pos_return_reservations, "condition IN ('resellable', 'damaged')",
                         name: 'chk_pos_return_reservations_condition'
    add_check_constraint :spree_pos_return_reservations,
                         'quantity > 0 AND cumulative_before >= 0 AND cumulative_after = cumulative_before + quantity',
                         name: 'chk_pos_return_reservations_quantity'
    add_check_constraint :spree_pos_return_reservations,
                         'total >= 0 AND net >= 0 AND tax >= 0 AND discount >= 0 AND gross >= 0 AND ' \
                         'total = net + tax AND gross - discount = net',
                         name: 'chk_pos_return_reservations_components'
    add_check_constraint :spree_pos_return_reservations,
                         'received_quantity >= 0 AND received_quantity <= quantity AND ' \
                         'restocked_quantity >= 0 AND restocked_quantity <= received_quantity',
                         name: 'chk_pos_return_reservations_receipt'

    create_table :spree_pos_refund_requests do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }
      # Paying branch: the branch of the return, where the money leaves.
      t.references :branch, null: false, foreign_key: { to_table: :spree_pos_branches }
      t.references :return_operation, null: false, foreign_key: { to_table: :spree_pos_return_operations }
      t.references :funds_allocation, null: false, foreign_key: { to_table: :spree_pos_funds_allocations }
      t.references :received_funds, null: false, foreign_key: { to_table: :spree_pos_received_funds }
      t.references :payment, null: false, foreign_key: { to_table: :spree_payments }
      t.references :order, null: false, foreign_key: { to_table: :spree_orders }
      t.references :requester, null: false
      t.references :confirmer
      t.references :approval, foreign_key: { to_table: :spree_pos_approvals }
      t.references :shift, foreign_key: { to_table: :spree_pos_shifts }
      t.references :refund, foreign_key: { to_table: :spree_refunds }, index: { unique: true }
      t.string :method, null: false, limit: 16
      t.string :status, null: false, default: 'reserved', limit: 16
      t.decimal :amount, precision: 19, scale: 4, null: false
      t.string :currency, null: false, limit: 16
      t.integer :revision, null: false, default: 1
      t.string :beneficiary_reference, limit: 120
      t.datetime :confirmed_at
      t.datetime :resolved_at
      t.timestamps
    end
    add_foreign_key :spree_pos_refund_requests, :spree_admin_users, column: :requester_id
    add_foreign_key :spree_pos_refund_requests, :spree_admin_users, column: :confirmer_id
    add_index :spree_pos_refund_requests, [:funds_allocation_id, :status], name: 'idx_pos_refund_requests_allocation'
    add_index :spree_pos_refund_requests, [:store_id, :branch_id, :status], name: 'idx_pos_refund_requests_branch'
    add_check_constraint :spree_pos_refund_requests, "method IN ('cash', 'bank_manual')", name: 'chk_pos_refund_requests_method'
    add_check_constraint :spree_pos_refund_requests, "status IN ('reserved', 'unknown', 'confirmed', 'failed', 'canceled')",
                         name: 'chk_pos_refund_requests_status'
    add_check_constraint :spree_pos_refund_requests, 'amount > 0', name: 'chk_pos_refund_requests_amount'
    add_check_constraint :spree_pos_refund_requests, "(status = 'confirmed') = (refund_id IS NOT NULL)",
                         name: 'chk_pos_refund_requests_refund'

    # Payout evidence and cash movements are shared with liability payouts:
    # one evidence ledger, one drawer ledger.
    change_column_null :spree_pos_payout_evidences, :liability_payout_id, true
    add_reference :spree_pos_payout_evidences, :refund_request, foreign_key: { to_table: :spree_pos_refund_requests }
    add_check_constraint :spree_pos_payout_evidences, '(liability_payout_id IS NULL) <> (refund_request_id IS NULL)',
                         name: 'chk_pos_payout_evidences_subject'
    add_reference :spree_pos_cash_movements, :refund_request, foreign_key: { to_table: :spree_pos_refund_requests }

    create_table :spree_pos_exchange_operations do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }
      t.references :branch, null: false, foreign_key: { to_table: :spree_pos_branches }
      t.references :return_operation, null: false, foreign_key: { to_table: :spree_pos_return_operations }, index: { unique: true }
      t.references :replacement_workspace, null: false, foreign_key: { to_table: :spree_pos_workspaces }, index: { unique: true }
      t.references :actor, null: false
      t.timestamps
    end
    add_foreign_key :spree_pos_exchange_operations, :spree_admin_users, column: :actor_id

    # Counter sales continue when the system shelf is short; the shortfall is
    # kept for whoever reconciles stock, and the fulfillment stays allocated
    # until it can be dispatched without driving the shelf negative.
    create_table :spree_pos_stock_discrepancies do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }
      t.references :branch, null: false, foreign_key: { to_table: :spree_pos_branches }
      t.references :workspace, null: false, foreign_key: { to_table: :spree_pos_workspaces }
      t.references :order, null: false, foreign_key: { to_table: :spree_orders }
      t.references :fulfillment, null: false, foreign_key: { to_table: :spree_fulfillments }
      t.references :variant, null: false, foreign_key: { to_table: :spree_variants }
      t.references :stock_location, null: false, foreign_key: { to_table: :spree_stock_locations }
      t.references :actor, null: false
      t.integer :needed, null: false
      t.integer :on_hand, null: false
      t.string :status, null: false, default: 'open', limit: 16
      t.datetime :checked_at, null: false
      t.datetime :resolved_at
      t.timestamps
    end
    add_foreign_key :spree_pos_stock_discrepancies, :spree_admin_users, column: :actor_id
    add_index :spree_pos_stock_discrepancies, [:fulfillment_id, :variant_id], unique: true, where: "status = 'open'",
                                                                              name: 'idx_pos_stock_discrepancies_open'
    add_check_constraint :spree_pos_stock_discrepancies, "status IN ('open', 'resolved')", name: 'chk_pos_stock_discrepancies_status'
    add_check_constraint :spree_pos_stock_discrepancies, 'needed > 0', name: 'chk_pos_stock_discrepancies_needed'
  end
end
