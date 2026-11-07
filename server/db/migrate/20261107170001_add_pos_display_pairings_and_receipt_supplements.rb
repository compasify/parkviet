# frozen_string_literal: true

# - A return whose credit note / refund entitlement posts after it was
#   received gets a supplementary slip of its own (source type
#   `return_supplement`, linked to the return), so the first slip never
#   stays "pending" as the only document.
# - A separate customer display pairs with a short single-use code instead
#   of a typed token: the code is stored only as a digest, expires and is
#   exchanged once for the display token on the device itself.
class AddPosDisplayPairingsAndReceiptSupplements < ActiveRecord::Migration[8.0]
  def up
    remove_check_constraint :spree_pos_receipt_snapshots, name: 'chk_pos_receipt_snapshots_source_type'
    add_check_constraint :spree_pos_receipt_snapshots,
                         "source_type IN ('sale', 'return', 'return_supplement', 'refund', 'shift_closure')",
                         name: 'chk_pos_receipt_snapshots_source_type'

    create_table :spree_pos_display_pairings do |t|
      t.references :store, null: false, index: false
      t.references :display_session, null: false, index: true
      t.references :created_by, null: false, index: false
      t.string :code_digest, limit: 64, null: false
      t.datetime :expires_at, null: false
      t.datetime :used_at
      t.timestamps
    end
    add_index :spree_pos_display_pairings, :code_digest, unique: true, name: 'idx_pos_display_pairings_code'
  end

  def down
    drop_table :spree_pos_display_pairings
    remove_check_constraint :spree_pos_receipt_snapshots, name: 'chk_pos_receipt_snapshots_source_type'
    add_check_constraint :spree_pos_receipt_snapshots, "source_type IN ('sale', 'return', 'refund', 'shift_closure')",
                         name: 'chk_pos_receipt_snapshots_source_type'
  end
end
