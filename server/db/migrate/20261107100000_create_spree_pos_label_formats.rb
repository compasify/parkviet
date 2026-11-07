# frozen_string_literal: true

# In-store scale labels (EAN-13 with an embedded weight or price) are read only
# through a per-branch format; SKUs opt in with a label code, and every sale line
# keeps the label and the format version it was read with.
class CreateSpreePosLabelFormats < ActiveRecord::Migration[8.1]
  def change
    create_table :spree_pos_label_formats do |t|
      t.references :store, null: false
      t.references :branch, null: false
      t.string :name, null: false
      t.string :prefix, null: false
      t.string :kind, null: false
      t.integer :item_code_length, null: false
      t.integer :value_length, null: false
      t.integer :value_decimals, null: false, default: 0
      t.string :value_unit_code
      t.decimal :price_tolerance, precision: 19, scale: 4, null: false, default: 0
      t.integer :version, null: false, default: 1
      t.string :status, null: false, default: 'active'
      t.timestamps
    end
    add_index :spree_pos_label_formats, %i[branch_id prefix], unique: true, where: "status = 'active'", name: 'idx_pos_label_formats_active_prefix'
    add_check_constraint :spree_pos_label_formats, "kind IN ('weight', 'price')", name: 'chk_pos_label_formats_kind'
    add_check_constraint :spree_pos_label_formats, "status IN ('active', 'disabled')", name: 'chk_pos_label_formats_status'
    add_check_constraint :spree_pos_label_formats,
                         'char_length(prefix) + item_code_length + value_length = 12 AND item_code_length > 0 AND value_length > 0',
                         name: 'chk_pos_label_formats_layout'

    add_column :spree_pos_variant_units, :label_code, :string
    add_index :spree_pos_variant_units, %i[store_id label_code], unique: true, where: 'label_code IS NOT NULL',
                                                                 name: 'idx_pos_variant_units_label_code'

    add_column :spree_pos_sale_lines, :label_barcode, :string
    add_column :spree_pos_sale_lines, :label_format_id, :bigint
    add_column :spree_pos_sale_lines, :label_format_version, :integer
  end
end
