# frozen_string_literal: true

# Two-person drawer outflows, count cutoffs by movement id and export scope.
#
# - A cash out or safe drop is first requested (with an evidence reference)
#   and posts its CashMovement only when another person confirms it.
# - The blind count records the last movement id it covered, so a later
#   movement makes it stale by id rather than by clock.
# - An export remembers whether it was built with branch-wide report access,
#   so downloading it needs that access again.
class AddPosCashMovementRequests < ActiveRecord::Migration[8.0]
  def change
    create_table :spree_pos_cash_movement_requests do |t|
      t.references :store, null: false, index: true
      t.references :branch, null: false, index: false
      t.references :shift, null: false, index: true
      t.references :requester, null: false, index: true
      t.references :confirmer, index: false
      t.references :cash_movement, index: { unique: true, where: 'cash_movement_id IS NOT NULL' }
      t.string :kind, limit: 16, null: false
      t.string :status, limit: 16, null: false, default: 'requested'
      t.decimal :amount, precision: 19, scale: 4, null: false
      t.string :currency, limit: 16, null: false
      t.string :reason, limit: 200, null: false
      t.string :evidence_reference, limit: 120, null: false
      t.string :resolution_note, limit: 200
      t.datetime :resolved_at
      t.timestamps
    end
    add_index :spree_pos_cash_movement_requests, %i[branch_id status], name: 'idx_pos_cash_movement_requests_branch'
    add_check_constraint :spree_pos_cash_movement_requests, "kind IN ('cash_out', 'safe_drop')",
                         name: 'chk_pos_cash_movement_requests_kind'
    add_check_constraint :spree_pos_cash_movement_requests, "status IN ('requested', 'confirmed', 'canceled')",
                         name: 'chk_pos_cash_movement_requests_status'
    add_check_constraint :spree_pos_cash_movement_requests, 'amount > 0', name: 'chk_pos_cash_movement_requests_amount'
    add_check_constraint :spree_pos_cash_movement_requests, "(status = 'confirmed') = (cash_movement_id IS NOT NULL)",
                         name: 'chk_pos_cash_movement_requests_movement'

    add_column :spree_pos_shifts, :closing_cutoff_movement_id, :bigint
    add_column :spree_pos_export_requests, :full_scope, :boolean, null: false, default: false
  end
end
