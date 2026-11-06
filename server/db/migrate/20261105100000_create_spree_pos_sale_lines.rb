# frozen_string_literal: true

class CreateSpreePosSaleLines < ActiveRecord::Migration[8.1]
  def change
    create_table :spree_pos_units do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }
      t.string :code, null: false, limit: 16
      t.string :name, null: false, limit: 64
      t.string :dimension, null: false, limit: 16
      t.string :base_code, null: false, limit: 16
      t.integer :factor_to_base, null: false
      t.integer :sale_precision, null: false, default: 0
      t.integer :version, null: false, default: 1
      t.string :status, null: false, default: 'active'
      t.timestamps
    end
    add_index :spree_pos_units, [:store_id, :code], unique: true, name: 'idx_pos_units_store_code'
    add_check_constraint :spree_pos_units, "dimension IN ('mass', 'volume', 'count')", name: 'chk_pos_units_dimension'
    add_check_constraint :spree_pos_units, 'factor_to_base > 0 AND sale_precision BETWEEN 0 AND 3', name: 'chk_pos_units_factor'

    create_table :spree_pos_variant_units do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }
      t.references :variant, null: false, foreign_key: { to_table: :spree_variants }, index: { unique: true }
      t.references :sale_unit, null: false, foreign_key: { to_table: :spree_pos_units }
      t.references :base_unit, null: false, foreign_key: { to_table: :spree_pos_units }
      t.references :price_unit, null: false, foreign_key: { to_table: :spree_pos_units }
      t.integer :ratio_numerator, null: false
      t.integer :ratio_denominator, null: false, default: 1
      t.string :tracked_mode, null: false, default: 'none'
      t.integer :version, null: false, default: 1
      t.string :status, null: false, default: 'active'
      t.timestamps
    end
    add_check_constraint :spree_pos_variant_units, "tracked_mode IN ('none', 'serial', 'lot', 'serial_lot')", name: 'chk_pos_variant_units_tracked'
    add_check_constraint :spree_pos_variant_units, 'ratio_numerator > 0 AND ratio_denominator > 0', name: 'chk_pos_variant_units_ratio'

    create_table :spree_pos_sale_lines do |t|
      t.references :workspace, null: false, foreign_key: { to_table: :spree_pos_workspaces }
      t.references :order, null: false, foreign_key: { to_table: :spree_orders }
      t.references :line_item, null: false, foreign_key: { to_table: :spree_line_items, on_delete: :cascade }, index: { unique: true }
      t.references :variant, null: false, foreign_key: { to_table: :spree_variants }
      t.string :kind, null: false, default: 'ordinary'
      t.string :merge_key, null: false, limit: 200
      t.decimal :sale_quantity, precision: 19, scale: 4, null: false
      t.integer :base_quantity, null: false
      t.string :sale_unit_code, null: false, limit: 16, default: 'item'
      t.string :base_unit_code, null: false, limit: 16, default: 'item'
      t.integer :ratio_numerator, null: false, default: 1
      t.integer :ratio_denominator, null: false, default: 1
      t.integer :conversion_version
      t.decimal :unit_price, precision: 19, scale: 4, null: false
      t.decimal :line_price, precision: 19, scale: 4, null: false
      t.string :lot_code, limit: 100
      t.date :expiry_on
      t.jsonb :serial_codes, null: false, default: []
      t.string :tracked_mode, null: false, default: 'none'
      t.uuid :measurement_event_id
      t.timestamps
    end
    add_index :spree_pos_sale_lines, [:workspace_id, :merge_key], name: 'idx_pos_sale_lines_merge'
    add_index :spree_pos_sale_lines, [:workspace_id, :measurement_event_id], unique: true, where: 'measurement_event_id IS NOT NULL', name: 'idx_pos_sale_lines_event'
    add_check_constraint :spree_pos_sale_lines, "kind IN ('ordinary', 'measured', 'tracked')", name: 'chk_pos_sale_lines_kind'
    add_check_constraint :spree_pos_sale_lines, 'base_quantity > 0 AND sale_quantity > 0', name: 'chk_pos_sale_lines_qty'
    add_check_constraint :spree_pos_sale_lines, "tracked_mode IN ('none', 'serial', 'lot', 'serial_lot')", name: 'chk_pos_sale_lines_tracked'

    create_table :spree_pos_line_discount_intents do |t|
      t.references :workspace, null: false, foreign_key: { to_table: :spree_pos_workspaces }
      t.references :sale_line, null: false, foreign_key: { to_table: :spree_pos_sale_lines, on_delete: :cascade }, index: { unique: true }
      t.bigint :actor_id, null: false
      t.string :value_type, null: false
      t.string :value, null: false, limit: 64
      t.string :reason, null: false, limit: 200
      t.timestamps
    end
    add_foreign_key :spree_pos_line_discount_intents, :spree_admin_users, column: :actor_id
    add_check_constraint :spree_pos_line_discount_intents, "value_type IN ('flat', 'percent')", name: 'chk_pos_line_discount_type'

    add_reference :spree_pos_discount_allocations, :line_discount_intent, foreign_key: { to_table: :spree_pos_line_discount_intents, on_delete: :cascade }
    change_column_null :spree_pos_discount_allocations, :discount_intent_id, true
  end
end
