# frozen_string_literal: true

# A paired terminal. The bearer token is stored only as a digest. Revoking
# the row makes that token fail at once. kitchen_station_id stays without a
# foreign key until kitchen stations exist.
class CreatePosDevices < ActiveRecord::Migration[8.1]
  def change
    create_table :spree_pos_devices do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }
      t.references :branch, null: false, foreign_key: { to_table: :spree_pos_branches }
      t.references :register, foreign_key: { to_table: :spree_pos_registers }
      t.bigint :kitchen_station_id
      t.string :name, null: false
      t.string :mode, null: false
      t.string :platform, null: false
      t.string :app_version
      t.string :token_digest, null: false
      t.integer :generation, null: false, default: 0
      t.string :status, null: false, default: 'active'
      t.datetime :last_seen_at
      t.bigint :paired_by_id
      t.bigint :revoked_by_id
      t.datetime :revoked_at
      t.jsonb :settings, null: false, default: {}
      t.timestamps
    end
    add_index :spree_pos_devices, :token_digest, unique: true
    add_foreign_key :spree_pos_devices, :spree_admin_users, column: :paired_by_id
    add_foreign_key :spree_pos_devices, :spree_admin_users, column: :revoked_by_id
    add_check_constraint :spree_pos_devices,
                         "mode IN ('waiter', 'kds', 'expo', 'kiosk', 'print_station', 'owner', 'bridge')",
                         name: 'chk_pos_devices_mode'
    add_check_constraint :spree_pos_devices, "platform IN ('android', 'ios', 'web')", name: 'chk_pos_devices_platform'
    add_check_constraint :spree_pos_devices, "status IN ('active', 'revoked')", name: 'chk_pos_devices_status'
  end
end
