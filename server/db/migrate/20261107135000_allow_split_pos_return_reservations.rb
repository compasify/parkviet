# frozen_string_literal: true

# A sale line shipped in several fulfillment items is returned as one chunk
# per item, each its own reservation in the line's sequence. The pair
# (return, sale line) therefore stops being unique; the sequence per sale
# line and the return line item per reservation stay unique.
class AllowSplitPosReturnReservations < ActiveRecord::Migration[8.1]
  def change
    remove_index :spree_pos_return_reservations, [:return_operation_id, :sale_line_id], unique: true,
                                                                                        name: 'idx_pos_return_reservations_line'
    add_index :spree_pos_return_reservations, [:return_operation_id, :sale_line_id], name: 'idx_pos_return_reservations_line'
  end
end
