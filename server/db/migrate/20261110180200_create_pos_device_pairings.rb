# frozen_string_literal: true

# A single-use pairing code. Only the SHA-256 digest is stored. device_id
# is set when the code re-pairs a terminal that already exists.
class CreatePosDevicePairings < ActiveRecord::Migration[8.1]
  def change
    create_table :spree_pos_device_pairings do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }
      t.references :branch, null: false, foreign_key: { to_table: :spree_pos_branches }
      t.references :device, foreign_key: { to_table: :spree_pos_devices }
      t.string :mode, null: false
      t.string :code_digest, null: false
      t.datetime :expires_at, null: false
      t.datetime :consumed_at
      t.bigint :created_by_id, null: false
      t.jsonb :attrs, null: false, default: {}
      t.timestamps
    end
    add_index :spree_pos_device_pairings, :code_digest, unique: true
    add_foreign_key :spree_pos_device_pairings, :spree_admin_users, column: :created_by_id
    add_check_constraint :spree_pos_device_pairings,
                         "mode IN ('waiter', 'kds', 'expo', 'kiosk', 'print_station', 'owner', 'bridge')",
                         name: 'chk_pos_device_pairings_mode'
  end
end
