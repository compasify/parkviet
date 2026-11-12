# frozen_string_literal: true

# Time as a unit dimension, for billing play time: the minute is the base
# unit (`phut`, what a timed line's quantity counts) and the hour (`gio`,
# 60 minutes) the unit it is sold and invoiced in. Every store gets both.
class AddTimeDimensionToPosUnitDefinitions < ActiveRecord::Migration[8.1]
  def up
    remove_check_constraint :spree_pos_units, name: 'chk_pos_units_dimension'
    add_check_constraint :spree_pos_units, "dimension IN ('mass', 'volume', 'count', 'time')", name: 'chk_pos_units_dimension'
    execute <<~SQL.squish
      INSERT INTO spree_pos_units (store_id, code, name, dimension, base_code, factor_to_base, sale_precision, status, version, created_at, updated_at)
      SELECT s.id, u.code, u.name, 'time', 'phut', u.factor, u.precision, 'active', 1, NOW(), NOW()
      FROM spree_stores s
      CROSS JOIN (VALUES ('phut', 'Phút', 1, 0), ('gio', 'Giờ', 60, 3)) AS u(code, name, factor, precision)
      ON CONFLICT (store_id, code) DO NOTHING
    SQL
  end

  def down
    execute "DELETE FROM spree_pos_units WHERE dimension = 'time'"
    remove_check_constraint :spree_pos_units, name: 'chk_pos_units_dimension'
    add_check_constraint :spree_pos_units, "dimension IN ('mass', 'volume', 'count')", name: 'chk_pos_units_dimension'
  end
end
