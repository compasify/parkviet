# frozen_string_literal: true

# Tracked goods are either serial- or lot-tracked. Sale lines still carrying
# the retired combined mode become serial lines (their serial numbers are the
# identity that was enforced), and both columns refuse it from now on.
#
# Enrollments remember the last drift they raised attention for, so a pair
# that drifts again after being reconciled raises a new alert while an
# unchanged drift is not re-checked every minute.
class TightenPosTrackedModes < ActiveRecord::Migration[8.1]
  def up
    execute "UPDATE spree_pos_sale_lines SET tracked_mode = 'serial' WHERE tracked_mode = 'serial_lot'"
    execute "UPDATE spree_pos_variant_units SET tracked_mode = 'serial' WHERE tracked_mode = 'serial_lot'"
    remove_check_constraint :spree_pos_sale_lines, name: 'chk_pos_sale_lines_tracked'
    add_check_constraint :spree_pos_sale_lines, "tracked_mode IN ('none', 'serial', 'lot')", name: 'chk_pos_sale_lines_tracked'
    remove_check_constraint :spree_pos_variant_units, name: 'chk_pos_variant_units_tracked'
    add_check_constraint :spree_pos_variant_units, "tracked_mode IN ('none', 'serial', 'lot')", name: 'chk_pos_variant_units_tracked'

    add_column :spree_pos_trace_enrollments, :drift_signature, :string, limit: 64
    add_column :spree_pos_trace_enrollments, :drift_checked_at, :datetime
  end

  def down
    remove_column :spree_pos_trace_enrollments, :drift_checked_at
    remove_column :spree_pos_trace_enrollments, :drift_signature
    remove_check_constraint :spree_pos_variant_units, name: 'chk_pos_variant_units_tracked'
    add_check_constraint :spree_pos_variant_units, "tracked_mode IN ('none', 'serial', 'lot', 'serial_lot')", name: 'chk_pos_variant_units_tracked'
    remove_check_constraint :spree_pos_sale_lines, name: 'chk_pos_sale_lines_tracked'
    add_check_constraint :spree_pos_sale_lines, "tracked_mode IN ('none', 'serial', 'lot', 'serial_lot')", name: 'chk_pos_sale_lines_tracked'
  end
end
