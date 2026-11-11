# frozen_string_literal: true

# Areas (floors, rooms of the restaurant) and the tables, rooms and billiard
# tables in them. A resource's busy state is computed from the open orders
# that point at it; only cleaning and out of service are stored by hand.
class CreateSpreePosAreasAndResources < ActiveRecord::Migration[8.1]
  def change
    create_table :spree_pos_areas do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }
      t.references :branch, null: false, foreign_key: { to_table: :spree_pos_branches }
      t.string :name, null: false, limit: 80
      t.integer :position, null: false, default: 0
      t.string :status, null: false, default: 'active'
      t.integer :floor_width, null: false, default: 24
      t.integer :floor_height, null: false, default: 16
      t.timestamps
    end
    add_index :spree_pos_areas, %i[branch_id name], unique: true, where: "status = 'active'", name: 'idx_pos_areas_name'
    add_check_constraint :spree_pos_areas, "status IN ('active', 'archived')", name: 'chk_pos_areas_status'
    add_check_constraint :spree_pos_areas, 'floor_width BETWEEN 4 AND 200 AND floor_height BETWEEN 4 AND 200',
                         name: 'chk_pos_areas_floor'

    create_table :spree_pos_resources do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }
      t.references :branch, null: false, foreign_key: { to_table: :spree_pos_branches }
      t.references :area, null: false, foreign_key: { to_table: :spree_pos_areas }
      t.string :kind, null: false, default: 'table'
      t.string :name, null: false, limit: 40
      t.integer :capacity, null: false, default: 4
      t.string :shape, null: false, default: 'rect'
      t.integer :x, null: false, default: 0
      t.integer :y, null: false, default: 0
      t.integer :w, null: false, default: 2
      t.integer :h, null: false, default: 2
      t.integer :rotation, null: false, default: 0
      t.string :manual_status, null: false, default: 'available'
      t.string :resource_type_code, limit: 40
      t.string :status, null: false, default: 'active'
      t.integer :position, null: false, default: 0
      t.timestamps
    end
    add_index :spree_pos_resources, %i[branch_id name], unique: true, where: "status = 'active'", name: 'idx_pos_resources_name'
    add_check_constraint :spree_pos_resources, "kind IN ('table', 'room', 'billiard', 'vip')", name: 'chk_pos_resources_kind'
    add_check_constraint :spree_pos_resources, "shape IN ('rect', 'round')", name: 'chk_pos_resources_shape'
    add_check_constraint :spree_pos_resources, "status IN ('active', 'archived')", name: 'chk_pos_resources_status'
    add_check_constraint :spree_pos_resources, "manual_status IN ('available', 'cleaning', 'out_of_service')",
                         name: 'chk_pos_resources_manual_status'
    add_check_constraint :spree_pos_resources,
                         'capacity BETWEEN 0 AND 999 AND x >= 0 AND y >= 0 AND w BETWEEN 1 AND 50 AND h BETWEEN 1 AND 50 ' \
                         'AND rotation BETWEEN 0 AND 359',
                         name: 'chk_pos_resources_geometry'
  end
end
