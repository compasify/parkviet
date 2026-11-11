# frozen_string_literal: true

# Kitchen and bar stations of a branch, where each menu item is cooked, and
# the tickets sent to them. A ticket is written once and never changed; only
# the status of its items moves. A device paired as a kitchen screen now
# points at a real station.
class CreateSpreePosKitchenTables < ActiveRecord::Migration[8.1]
  def change
    create_table :spree_pos_kitchen_stations do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }
      t.references :branch, null: false, foreign_key: { to_table: :spree_pos_branches }
      t.string :name, null: false, limit: 80
      t.string :kind, null: false, default: 'prep'
      t.references :printer, foreign_key: { to_table: :spree_pos_printers, on_delete: :nullify }
      t.boolean :kds_enabled, null: false, default: true
      t.boolean :is_default, null: false, default: false
      t.integer :warn_after_minutes, null: false, default: 8
      t.integer :late_after_minutes, null: false, default: 15
      t.integer :position, null: false, default: 0
      t.boolean :active, null: false, default: true
      t.timestamps
    end
    add_index :spree_pos_kitchen_stations, :branch_id, unique: true, where: 'is_default', name: 'idx_pos_kitchen_stations_default'
    add_index :spree_pos_kitchen_stations, %i[branch_id name], unique: true, name: 'idx_pos_kitchen_stations_name'
    add_check_constraint :spree_pos_kitchen_stations, "kind IN ('prep', 'bar', 'expo')", name: 'chk_pos_kitchen_stations_kind'
    add_check_constraint :spree_pos_kitchen_stations,
                         'warn_after_minutes > 0 AND late_after_minutes >= warn_after_minutes AND late_after_minutes <= 240',
                         name: 'chk_pos_kitchen_stations_minutes'

    create_table :spree_pos_station_routes do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }
      t.references :branch, null: false, foreign_key: { to_table: :spree_pos_branches }
      t.references :kitchen_station, null: false, foreign_key: { to_table: :spree_pos_kitchen_stations, on_delete: :cascade }
      t.references :product, foreign_key: { to_table: :spree_products, on_delete: :cascade }
      t.string :kitchen_category, limit: 40
      t.string :service_mode
      t.timestamps
    end
    # NULLs are equal here: one route per product or category and service
    # mode, "every mode" included.
    add_index :spree_pos_station_routes,
              "branch_id, COALESCE(product_id, 0), COALESCE(kitchen_category, ''), COALESCE(service_mode, '')",
              unique: true, name: 'idx_pos_station_routes_target'
    add_check_constraint :spree_pos_station_routes, '(product_id IS NULL) <> (kitchen_category IS NULL)',
                         name: 'chk_pos_station_routes_target'
    add_check_constraint :spree_pos_station_routes,
                         "service_mode IS NULL OR service_mode IN ('counter', 'dine_in', 'takeaway', 'delivery', 'tab', 'timed')",
                         name: 'chk_pos_station_routes_mode'

    create_table :spree_pos_kitchen_tickets do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }
      t.references :branch, null: false, foreign_key: { to_table: :spree_pos_branches }
      t.references :workspace, null: false, foreign_key: { to_table: :spree_pos_workspaces }
      t.references :kitchen_station, null: false, foreign_key: { to_table: :spree_pos_kitchen_stations }
      t.integer :sequence, null: false
      t.string :kind, null: false, default: 'fire'
      t.string :send_key, null: false, limit: 200
      t.string :service_mode, null: false
      t.date :business_date, null: false
      t.jsonb :header, null: false, default: {}
      t.string :sent_by_type
      t.bigint :sent_by_id
      t.datetime :sent_at, null: false
      t.timestamps
    end
    add_index :spree_pos_kitchen_tickets, %i[workspace_id send_key kitchen_station_id], unique: true, name: 'idx_pos_kitchen_tickets_send'
    add_index :spree_pos_kitchen_tickets, %i[workspace_id sequence], unique: true, name: 'idx_pos_kitchen_tickets_sequence'
    add_index :spree_pos_kitchen_tickets, %i[kitchen_station_id sent_at], name: 'idx_pos_kitchen_tickets_board'
    add_check_constraint :spree_pos_kitchen_tickets, "kind IN ('fire', 'void')", name: 'chk_pos_kitchen_tickets_kind'

    create_table :spree_pos_kitchen_ticket_items do |t|
      t.references :kitchen_ticket, null: false, foreign_key: { to_table: :spree_pos_kitchen_tickets, on_delete: :cascade }
      t.references :sale_line, null: false, foreign_key: { to_table: :spree_pos_sale_lines }
      t.string :name, null: false
      t.jsonb :modifiers, null: false, default: []
      t.jsonb :components, null: false, default: []
      t.string :note, limit: 200
      t.decimal :quantity, precision: 19, scale: 4, null: false
      t.string :status, null: false, default: 'new'
      t.datetime :started_at
      t.datetime :ready_at
      t.datetime :served_at
      t.datetime :voided_at
      t.string :changed_by_type
      t.bigint :changed_by_id
      t.timestamps
    end
    add_check_constraint :spree_pos_kitchen_ticket_items, "status IN ('new', 'preparing', 'ready', 'served', 'voided')",
                         name: 'chk_pos_kitchen_ticket_items_status'
    add_check_constraint :spree_pos_kitchen_ticket_items, 'quantity > 0', name: 'chk_pos_kitchen_ticket_items_qty'

    add_foreign_key :spree_pos_devices, :spree_pos_kitchen_stations, column: :kitchen_station_id, on_delete: :nullify
    add_index :spree_pos_devices, :kitchen_station_id
  end
end
