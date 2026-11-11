# frozen_string_literal: true

# The POS menu of a store: categories, items (a Spree product each, sizes are
# its variants), modifier groups and options, combo contents, time-of-day
# menus, per-branch sold-out and favourites, and the snapshots a sale line
# keeps of the options and combo contents it was sold with.
class CreateSpreePosMenuTables < ActiveRecord::Migration[8.1]
  def change
    create_table :spree_pos_menu_categories do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }
      t.string :name, null: false, limit: 80
      t.integer :position, null: false, default: 0
      t.string :color, limit: 16
      t.boolean :active, null: false, default: true
      t.timestamps
    end
    add_index :spree_pos_menu_categories, %i[store_id name], unique: true, name: 'idx_pos_menu_categories_name'

    create_table :spree_pos_menu_items do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }
      t.references :product, null: false, foreign_key: { to_table: :spree_products }
      t.references :menu_category, foreign_key: { to_table: :spree_pos_menu_categories, on_delete: :nullify }
      t.string :kind, null: false, default: 'single'
      t.string :kitchen_category, limit: 40
      t.boolean :cup_label, null: false, default: false
      t.boolean :show_components_on_kds, null: false, default: true
      t.integer :position, null: false, default: 0
      t.boolean :active, null: false, default: true
      t.timestamps
    end
    add_index :spree_pos_menu_items, %i[store_id product_id], unique: true, name: 'idx_pos_menu_items_product'
    add_check_constraint :spree_pos_menu_items, "kind IN ('single', 'combo')", name: 'chk_pos_menu_items_kind'
    add_check_constraint :spree_pos_menu_items, "kitchen_category IS NULL OR kitchen_category ~ '^[a-z_]{2,40}$'",
                         name: 'chk_pos_menu_items_kitchen_category'

    create_table :spree_pos_modifier_groups do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }
      t.string :name, null: false, limit: 80
      t.integer :min_select, null: false, default: 0
      t.integer :max_select, null: false, default: 1
      t.boolean :allow_quantity, null: false, default: false
      t.integer :position, null: false, default: 0
      t.timestamps
    end
    add_check_constraint :spree_pos_modifier_groups, 'min_select >= 0 AND max_select >= 1 AND min_select <= max_select',
                         name: 'chk_pos_modifier_groups_select'

    create_table :spree_pos_modifier_options do |t|
      t.references :modifier_group, null: false, foreign_key: { to_table: :spree_pos_modifier_groups, on_delete: :cascade }
      t.string :name, null: false, limit: 80
      t.decimal :price_delta, precision: 10, scale: 2, null: false, default: 0
      t.references :variant, foreign_key: { to_table: :spree_variants }
      t.boolean :default_selected, null: false, default: false
      t.integer :position, null: false, default: 0
      t.boolean :active, null: false, default: true
      t.timestamps
    end
    add_check_constraint :spree_pos_modifier_options, 'price_delta >= 0', name: 'chk_pos_modifier_options_price'

    create_table :spree_pos_menu_item_modifier_groups do |t|
      t.references :menu_item, null: false, index: false, foreign_key: { to_table: :spree_pos_menu_items, on_delete: :cascade }
      t.references :modifier_group, null: false, foreign_key: { to_table: :spree_pos_modifier_groups, on_delete: :cascade }
      t.integer :position, null: false, default: 0
      t.timestamps
    end
    add_index :spree_pos_menu_item_modifier_groups, %i[menu_item_id modifier_group_id], unique: true,
                                                                                         name: 'idx_pos_menu_item_modifier_groups_pair'

    create_table :spree_pos_combo_components do |t|
      t.references :menu_item, null: false, index: false, foreign_key: { to_table: :spree_pos_menu_items, on_delete: :cascade }
      t.references :variant, null: false, foreign_key: { to_table: :spree_variants }
      t.integer :quantity, null: false, default: 1
      t.timestamps
    end
    add_index :spree_pos_combo_components, %i[menu_item_id variant_id], unique: true, name: 'idx_pos_combo_components_pair'
    add_check_constraint :spree_pos_combo_components, 'quantity > 0', name: 'chk_pos_combo_components_quantity'

    create_table :spree_pos_menu_schedules do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }
      t.references :branch, foreign_key: { to_table: :spree_pos_branches, on_delete: :cascade }
      t.string :name, null: false, limit: 80
      t.integer :days_of_week, array: true, null: false, default: []
      t.time :starts_at, null: false
      t.time :ends_at, null: false
      t.boolean :active, null: false, default: true
      t.timestamps
    end
    add_check_constraint :spree_pos_menu_schedules, 'days_of_week <@ ARRAY[0, 1, 2, 3, 4, 5, 6]',
                         name: 'chk_pos_menu_schedules_days'
    add_check_constraint :spree_pos_menu_schedules, 'starts_at <> ends_at', name: 'chk_pos_menu_schedules_window'

    create_table :spree_pos_menu_schedule_items do |t|
      t.references :menu_schedule, null: false, index: false, foreign_key: { to_table: :spree_pos_menu_schedules, on_delete: :cascade }
      t.references :menu_item, null: false, foreign_key: { to_table: :spree_pos_menu_items, on_delete: :cascade }
      t.references :variant, foreign_key: { to_table: :spree_variants }
      t.decimal :price, precision: 19, scale: 4
      t.boolean :hidden, null: false, default: false
      t.timestamps
    end
    add_index :spree_pos_menu_schedule_items, 'menu_schedule_id, menu_item_id, COALESCE(variant_id, 0)', unique: true,
                                                                                                          name: 'idx_pos_menu_schedule_items_target'
    add_check_constraint :spree_pos_menu_schedule_items, 'price IS NULL OR price >= 0', name: 'chk_pos_menu_schedule_items_price'

    create_table :spree_pos_menu_availabilities do |t|
      t.references :branch, null: false, index: false, foreign_key: { to_table: :spree_pos_branches, on_delete: :cascade }
      t.references :menu_item, null: false, foreign_key: { to_table: :spree_pos_menu_items, on_delete: :cascade }
      t.date :sold_out_on
      t.string :updated_by_type
      t.bigint :updated_by_id
      t.timestamps
    end
    add_index :spree_pos_menu_availabilities, %i[branch_id menu_item_id], unique: true, name: 'idx_pos_menu_availabilities_pair'

    create_table :spree_pos_menu_favorites do |t|
      t.references :branch, null: false, index: false, foreign_key: { to_table: :spree_pos_branches, on_delete: :cascade }
      t.references :menu_item, null: false, foreign_key: { to_table: :spree_pos_menu_items, on_delete: :cascade }
      t.integer :position, null: false, default: 0
      t.timestamps
    end
    add_index :spree_pos_menu_favorites, %i[branch_id menu_item_id], unique: true, name: 'idx_pos_menu_favorites_pair'

    create_table :spree_pos_line_modifiers do |t|
      t.references :sale_line, null: false, foreign_key: { to_table: :spree_pos_sale_lines, on_delete: :cascade }
      t.references :modifier_option, foreign_key: { to_table: :spree_pos_modifier_options, on_delete: :nullify }
      t.string :name, null: false, limit: 80
      t.string :group_name, null: false, limit: 80
      t.decimal :price_delta, precision: 10, scale: 2, null: false, default: 0
      t.integer :quantity, null: false, default: 1
      t.timestamps
    end
    add_check_constraint :spree_pos_line_modifiers, 'quantity > 0 AND price_delta >= 0', name: 'chk_pos_line_modifiers_values'

    create_table :spree_pos_line_components do |t|
      t.references :sale_line, null: false, foreign_key: { to_table: :spree_pos_sale_lines, on_delete: :cascade }
      t.references :variant, null: false, foreign_key: { to_table: :spree_variants }
      t.string :name, null: false, limit: 200
      t.integer :quantity, null: false, default: 1
      t.timestamps
    end
    add_check_constraint :spree_pos_line_components, 'quantity > 0', name: 'chk_pos_line_components_quantity'
  end
end
