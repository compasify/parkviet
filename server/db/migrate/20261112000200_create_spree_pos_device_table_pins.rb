# frozen_string_literal: true

# Tables a waiter's device follows: it hears when their dishes are ready,
# besides the tables its signed-in person added to.
class CreateSpreePosDeviceTablePins < ActiveRecord::Migration[8.1]
  def change
    create_table :spree_pos_device_table_pins do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }, index: false
      t.references :device, null: false, foreign_key: { to_table: :spree_pos_devices, on_delete: :cascade }, index: false
      t.references :resource, null: false, foreign_key: { to_table: :spree_pos_resources, on_delete: :cascade }
      t.references :staff, foreign_key: { to_table: :spree_admin_users }
      t.timestamps
    end
    add_index :spree_pos_device_table_pins, %i[device_id resource_id], unique: true, name: 'idx_pos_device_table_pins_pair'
  end
end
