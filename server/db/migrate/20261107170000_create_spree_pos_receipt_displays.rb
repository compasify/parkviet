# frozen_string_literal: true

# Immutable POS receipts and the customer display.
#
# - A receipt snapshot is written once per source document (sale, return,
#   refund, shift closure) from posted facts; it is never updated. Every
#   print of it is a separate row: the first is the original, later ones are
#   numbered copies.
# - A display session binds one customer screen to a staff member's open
#   shift. Its bearer token is stored only as a digest; the generation
#   increments on every bind, pin and clear, and the display acknowledges the
#   generation it rendered.
# - Branches may set the display freshness window (seconds); unset means the
#   default window.
class CreateSpreePosReceiptDisplays < ActiveRecord::Migration[8.0]
  def change
    create_table :spree_pos_receipt_snapshots do |t|
      t.references :store, null: false, index: false
      t.references :branch, null: false, index: false
      t.references :register, index: false
      t.references :issued_by, index: false
      t.string :source_type, limit: 32, null: false
      t.bigint :source_id, null: false
      t.string :number, limit: 64, null: false
      t.jsonb :payload, null: false, default: {}
      t.boolean :issued_late, null: false, default: false
      t.datetime :issued_at, null: false
      t.timestamps
    end
    add_index :spree_pos_receipt_snapshots, %i[source_type source_id], unique: true, name: 'idx_pos_receipt_snapshots_source'
    add_index :spree_pos_receipt_snapshots, %i[store_id source_type number], unique: true, name: 'idx_pos_receipt_snapshots_number'
    add_index :spree_pos_receipt_snapshots, %i[branch_id number], name: 'idx_pos_receipt_snapshots_branch_number'
    add_check_constraint :spree_pos_receipt_snapshots, "source_type IN ('sale', 'return', 'refund', 'shift_closure')",
                         name: 'chk_pos_receipt_snapshots_source_type'

    create_table :spree_pos_receipt_prints do |t|
      t.references :store, null: false, index: false
      t.references :receipt_snapshot, null: false, index: false
      t.references :actor, null: false, index: false
      t.integer :copy_number, null: false
      t.datetime :created_at, null: false
    end
    add_index :spree_pos_receipt_prints, %i[receipt_snapshot_id copy_number], unique: true, name: 'idx_pos_receipt_prints_copy'
    add_check_constraint :spree_pos_receipt_prints, 'copy_number >= 0', name: 'chk_pos_receipt_prints_copy_number'

    create_table :spree_pos_display_sessions do |t|
      t.references :store, null: false, index: false
      t.references :branch, null: false, index: false
      t.references :register, index: false
      t.references :shift, null: false, index: false
      t.references :staff, null: false, index: false
      t.string :token_digest, limit: 64, null: false
      t.datetime :token_expires_at, null: false
      t.integer :generation, null: false, default: 1
      t.references :pinned_workspace, index: false
      t.references :pinned_tender_attempt, index: false
      t.datetime :pinned_at
      t.bigint :state_sequence, null: false, default: 0
      t.datetime :last_seen_at
      t.integer :acked_generation
      t.datetime :acked_at
      t.datetime :revoked_at
      t.string :revoke_reason, limit: 32
      t.timestamps
    end
    add_index :spree_pos_display_sessions, :token_digest, unique: true, name: 'idx_pos_display_sessions_token'
    add_index :spree_pos_display_sessions, :shift_id, unique: true, where: 'revoked_at IS NULL', name: 'idx_pos_display_sessions_live_shift'
    add_check_constraint :spree_pos_display_sessions, 'generation >= 1', name: 'chk_pos_display_sessions_generation'
    add_check_constraint :spree_pos_display_sessions, 'pinned_tender_attempt_id IS NULL OR pinned_workspace_id IS NOT NULL',
                         name: 'chk_pos_display_sessions_attempt_pin'

    add_column :spree_pos_branches, :display_freshness_ttl_seconds, :integer
    add_check_constraint :spree_pos_branches, 'display_freshness_ttl_seconds IS NULL OR display_freshness_ttl_seconds BETWEEN 5 AND 120',
                         name: 'chk_pos_branches_display_freshness'
  end
end
