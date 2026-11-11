# frozen_string_literal: true

# Table orders are booked on the open shift of one chosen register. The
# service charge is a percentage of the items after discounts, taxed under
# its own tax category.
class AddTableRegisterAndServiceChargeToPosBranches < ActiveRecord::Migration[8.1]
  def change
    add_reference :spree_pos_branches, :table_register, foreign_key: { to_table: :spree_pos_registers, on_delete: :nullify }
    add_column :spree_pos_branches, :service_charge_rate, :decimal, precision: 5, scale: 2
    add_column :spree_pos_branches, :service_charge_applies_to, :jsonb, null: false, default: ['dine_in']
    add_reference :spree_pos_branches, :service_charge_tax_category, foreign_key: { to_table: :spree_tax_categories, on_delete: :nullify }
    add_check_constraint :spree_pos_branches, 'service_charge_rate IS NULL OR (service_charge_rate > 0 AND service_charge_rate <= 50)',
                         name: 'chk_pos_branches_service_charge_rate'

    add_column :spree_pos_workspaces, :service_charge_waived, :boolean, null: false, default: false
  end
end
