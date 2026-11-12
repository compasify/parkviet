# frozen_string_literal: true

# Ordering from the table QR: how a branch takes guests' orders (staff
# approve each one, or orders within a limit go straight to the kitchen),
# which menu items guests may order, and the store switch that turns it on.
class AddQrOrderSettings < ActiveRecord::Migration[8.1]
  FEATURE_CHECK = 'chk_pos_feature_flags_feature'
  FEATURES = %w[credit returns refunds exchanges traceability customer_display cash_moves exports vietqr edit_lease
                quick_credit delivery].freeze

  def up
    add_column :spree_pos_branches, :qr_order_mode, :string, null: false, default: 'staff_approval', limit: 24
    add_column :spree_pos_branches, :qr_order_auto_limit, :decimal, precision: 19, scale: 4
    add_column :spree_pos_branches, :qr_order_auto_max_items, :integer, null: false, default: 10
    add_check_constraint :spree_pos_branches, "qr_order_mode IN ('staff_approval', 'direct_to_kitchen')", name: 'chk_pos_branches_qr_order_mode'
    add_check_constraint :spree_pos_branches, 'qr_order_auto_limit IS NULL OR qr_order_auto_limit > 0', name: 'chk_pos_branches_qr_order_limit'
    add_check_constraint :spree_pos_branches, 'qr_order_auto_max_items BETWEEN 1 AND 50', name: 'chk_pos_branches_qr_order_max_items'
    add_column :spree_pos_menu_items, :qr_orderable, :boolean, null: false, default: true
    replace_feature_check(FEATURES + %w[qr_order])
  end

  def down
    execute "DELETE FROM spree_pos_feature_flags WHERE feature = 'qr_order'"
    replace_feature_check(FEATURES)
    remove_column :spree_pos_menu_items, :qr_orderable
    remove_check_constraint :spree_pos_branches, name: 'chk_pos_branches_qr_order_max_items'
    remove_check_constraint :spree_pos_branches, name: 'chk_pos_branches_qr_order_limit'
    remove_check_constraint :spree_pos_branches, name: 'chk_pos_branches_qr_order_mode'
    remove_column :spree_pos_branches, :qr_order_auto_max_items
    remove_column :spree_pos_branches, :qr_order_auto_limit
    remove_column :spree_pos_branches, :qr_order_mode
  end

  private

  def replace_feature_check(values)
    remove_check_constraint :spree_pos_feature_flags, name: FEATURE_CHECK
    list = values.map { |value| connection.quote(value) }.join(', ')
    add_check_constraint :spree_pos_feature_flags, "feature IN (#{list})", name: FEATURE_CHECK
  end
end
