# frozen_string_literal: true

# Shift close, cashbook, late-cash reconciliation and report exports.
#
# - Shifts carry a revision and the pending blind count so a variance approval
#   is bound to one count; closing writes an immutable ShiftClosure snapshot.
# - Branches get the variance threshold a manager configures.
# - Cash movements gain manual kinds (cash in/out, safe drop) and the inflow a
#   late-cash reconciliation posts when new physical cash enters a drawer.
# - CashReconciliation links a closed shift's variance and/or held cash to its
#   custody outcome without rewriting the closed snapshot.
# - ExportRequest tracks asynchronous CSV exports with a TTL.
class CreateSpreePosShiftClosures < ActiveRecord::Migration[8.0]
  MOVEMENT_KINDS = %w[receipt payout cash_in cash_out safe_drop reconciliation_inflow].freeze

  def change
    change_table :spree_pos_shifts, bulk: true do |t|
      t.integer :revision, null: false, default: 0
      t.decimal :closing_counted, precision: 19, scale: 4
      t.string :closing_reason, limit: 200
      t.bigint :closing_counted_by_id
      t.datetime :closing_counted_at
      t.datetime :closed_at
    end
    add_check_constraint :spree_pos_shifts, 'closing_counted IS NULL OR closing_counted >= 0', name: 'chk_pos_shifts_closing_counted'

    add_column :spree_pos_branches, :variance_threshold, :decimal, precision: 19, scale: 4
    add_check_constraint :spree_pos_branches, 'variance_threshold IS NULL OR variance_threshold >= 0', name: 'chk_pos_branches_variance_threshold'

    create_table :spree_pos_shift_closures do |t|
      t.references :store, null: false, index: true
      t.references :branch, null: false, index: false
      t.references :register, index: true
      t.references :shift, null: false, index: { unique: true }
      t.references :closer, null: false, index: true
      t.references :approver, index: false
      t.references :approval, index: false
      t.string :currency, limit: 16, null: false
      t.decimal :opening_float, precision: 19, scale: 4, null: false
      t.decimal :inflow_total, precision: 19, scale: 4, null: false
      t.decimal :outflow_total, precision: 19, scale: 4, null: false
      t.decimal :expected, precision: 19, scale: 4, null: false
      t.decimal :counted, precision: 19, scale: 4, null: false
      t.decimal :variance, precision: 19, scale: 4, null: false
      t.decimal :variance_threshold, precision: 19, scale: 4
      t.string :reason, limit: 200
      t.bigint :cutoff_movement_id
      t.integer :movement_count, null: false, default: 0
      t.jsonb :breakdown, null: false, default: {}
      t.datetime :opened_at, null: false
      t.datetime :closed_at, null: false
      t.timestamps
    end
    add_index :spree_pos_shift_closures, %i[branch_id closed_at], name: 'idx_pos_shift_closures_branch_closed'
    add_check_constraint :spree_pos_shift_closures, 'variance = counted - expected', name: 'chk_pos_shift_closures_variance'
    add_check_constraint :spree_pos_shift_closures, 'expected = opening_float + inflow_total - outflow_total',
                         name: 'chk_pos_shift_closures_expected'
    add_check_constraint :spree_pos_shift_closures, 'counted >= 0 AND inflow_total >= 0 AND outflow_total >= 0',
                         name: 'chk_pos_shift_closures_amounts'

    create_table :spree_pos_cash_reconciliations do |t|
      t.references :store, null: false, index: true
      t.references :branch, null: false, index: true
      t.references :shift_closure, index: true
      t.references :received_funds, index: { unique: true, where: 'received_funds_id IS NOT NULL' }
      t.references :target_shift, index: true
      t.references :actor, null: false, index: true
      t.string :outcome, limit: 32, null: false
      t.decimal :amount, precision: 19, scale: 4, null: false
      t.string :currency, limit: 16, null: false
      t.string :reason, limit: 200, null: false
      t.string :custody_reference, limit: 120
      t.timestamps
    end
    add_check_constraint :spree_pos_cash_reconciliations,
                         "outcome IN ('in_opening_float', 'safe', 'handed_over', 'new_physical_inflow')",
                         name: 'chk_pos_cash_reconciliations_outcome'
    add_check_constraint :spree_pos_cash_reconciliations, 'amount > 0', name: 'chk_pos_cash_reconciliations_amount'
    add_check_constraint :spree_pos_cash_reconciliations, 'shift_closure_id IS NOT NULL OR received_funds_id IS NOT NULL',
                         name: 'chk_pos_cash_reconciliations_source'
    add_check_constraint :spree_pos_cash_reconciliations,
                         "(outcome = 'new_physical_inflow' AND target_shift_id IS NOT NULL) OR " \
                         "outcome = 'in_opening_float' OR " \
                         "(outcome IN ('safe', 'handed_over') AND target_shift_id IS NULL)",
                         name: 'chk_pos_cash_reconciliations_target'

    change_table :spree_pos_cash_movements, bulk: true do |t|
      t.string :reason, limit: 200
      t.string :evidence_reference, limit: 120
      t.references :cash_reconciliation, index: { unique: true, where: 'cash_reconciliation_id IS NOT NULL' }
    end
    remove_check_constraint :spree_pos_cash_movements,
                            "kind::text = ANY (ARRAY['receipt'::character varying::text, 'payout'::character varying::text])",
                            name: 'chk_pos_cash_movements_kind'
    add_check_constraint :spree_pos_cash_movements, "kind IN (#{MOVEMENT_KINDS.map { |kind| "'#{kind}'" }.join(', ')})",
                         name: 'chk_pos_cash_movements_kind'
    add_check_constraint :spree_pos_cash_movements,
                         "(kind IN ('receipt', 'cash_in', 'reconciliation_inflow') AND amount > 0) OR " \
                         "(kind IN ('payout', 'cash_out', 'safe_drop') AND amount < 0)",
                         name: 'chk_pos_cash_movements_sign'
    add_check_constraint :spree_pos_cash_movements,
                         "kind NOT IN ('cash_in', 'cash_out', 'safe_drop') OR reason IS NOT NULL",
                         name: 'chk_pos_cash_movements_reason'

    add_index :spree_pos_received_funds, %i[branch_id received_at], name: 'idx_pos_received_funds_branch_received'

    create_table :spree_pos_export_requests do |t|
      t.references :store, null: false, index: true
      t.references :branch, null: false, index: true
      t.references :requester, null: false, index: true
      t.string :report_type, limit: 32, null: false
      t.jsonb :filters, null: false, default: {}
      t.string :status, limit: 16, null: false, default: 'queued'
      t.integer :row_count
      t.string :error_message, limit: 200
      t.datetime :expires_at, null: false
      t.datetime :completed_at
      t.timestamps
    end
    add_index :spree_pos_export_requests, %i[status expires_at], name: 'idx_pos_export_requests_expiry'
    add_check_constraint :spree_pos_export_requests,
                         "status IN ('queued', 'processing', 'ready', 'failed', 'expired')",
                         name: 'chk_pos_export_requests_status'
    add_check_constraint :spree_pos_export_requests,
                         "report_type IN ('sales', 'receipts', 'cashbook', 'receivables', 'closures')",
                         name: 'chk_pos_export_requests_report'
  end
end
