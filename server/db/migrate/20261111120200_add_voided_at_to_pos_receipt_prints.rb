# frozen_string_literal: true

# A print that provably never reached paper is voided instead of counting as
# the original or a copy, so its number can be issued again.
#
# Rolling back restores the full unique index, which fails once a voided print
# shares its copy number with a later one. Delete the voided rows first.
class AddVoidedAtToPosReceiptPrints < ActiveRecord::Migration[8.1]
  def change
    add_column :spree_pos_receipt_prints, :voided_at, :datetime
    remove_index :spree_pos_receipt_prints, column: %i[receipt_snapshot_id copy_number], unique: true,
                                            name: 'idx_pos_receipt_prints_copy'
    add_index :spree_pos_receipt_prints, %i[receipt_snapshot_id copy_number], unique: true, where: 'voided_at IS NULL',
                                                                             name: 'idx_pos_receipt_prints_copy'
  end
end
