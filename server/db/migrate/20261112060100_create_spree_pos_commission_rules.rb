# frozen_string_literal: true

# How a rest stop pays coach commission: a fixed amount per visit by vehicle
# type, an amount per guest, or both added up, when the visit brought at
# least `min_guests` guests and `min_revenue` of sales. A rule of one bus
# operator wins over the branch's general rule.
class CreateSpreePosCommissionRules < ActiveRecord::Migration[8.1]
  def change
    create_table :spree_pos_commission_rules do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }, index: false
      t.references :branch, null: false, foreign_key: { to_table: :spree_pos_branches }, index: false
      t.references :bus_operator, foreign_key: { to_table: :spree_pos_bus_operators }
      t.string :name, limit: 120
      t.jsonb :per_vehicle_amounts, null: false, default: {}
      t.decimal :per_guest_amount, precision: 19, scale: 4, null: false, default: 0
      t.integer :min_guests, null: false, default: 0
      t.decimal :min_revenue, precision: 19, scale: 4, null: false, default: 0
      t.date :starts_on
      t.date :ends_on
      t.string :status, null: false, limit: 16, default: 'active'
      t.integer :revision, null: false, default: 0
      t.timestamps
    end
    add_index :spree_pos_commission_rules, %i[branch_id bus_operator_id status], name: 'idx_pos_commission_rules_lookup'
    add_check_constraint :spree_pos_commission_rules,
                         "status IN ('active', 'archived') AND per_guest_amount >= 0 AND min_guests BETWEEN 0 AND 999 AND " \
                         'min_revenue >= 0 AND (starts_on IS NULL OR ends_on IS NULL OR ends_on >= starts_on) AND ' \
                         "jsonb_typeof(per_vehicle_amounts) = 'object'",
                         name: 'chk_pos_commission_rules_values'
    # Something is paid: per guest, or a positive amount for some vehicle type.
    add_check_constraint :spree_pos_commission_rules,
                         "per_guest_amount > 0 OR jsonb_path_exists(per_vehicle_amounts, '$.* ? (@ > 0)')",
                         name: 'chk_pos_commission_rules_pays'
  end
end
