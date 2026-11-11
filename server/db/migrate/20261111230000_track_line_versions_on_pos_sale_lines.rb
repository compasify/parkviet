# frozen_string_literal: true

# Several people add to one table order at once: every sale line carries its
# own version (edits of a line check it instead of the whole order's
# revision), who added it, from which device and in which batch. The kitchen
# never knows of more than the line still holds once a sent item is voided.
class TrackLineVersionsOnPosSaleLines < ActiveRecord::Migration[8.1]
  def change
    add_column :spree_pos_sale_lines, :row_version, :integer, null: false, default: 0
    add_reference :spree_pos_sale_lines, :added_by, foreign_key: { to_table: :spree_admin_users }, index: false
    add_reference :spree_pos_sale_lines, :added_device, foreign_key: { to_table: :spree_pos_devices }, index: false
    add_column :spree_pos_sale_lines, :append_batch_id, :uuid
    add_index :spree_pos_sale_lines, %i[workspace_id append_batch_id], where: 'append_batch_id IS NOT NULL',
                                                                       name: 'idx_pos_sale_lines_append_batch'
    add_check_constraint :spree_pos_sale_lines, 'kitchen_sent_quantity <= sale_quantity',
                         name: 'chk_pos_sale_lines_kitchen_sent_within_sale'
  end
end
