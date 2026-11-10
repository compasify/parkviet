# frozen_string_literal: true

# Wrong PINs on one device for one membership. Five inside 15 minutes lock
# that pair. The rows are the lock; nothing else stores a lock flag.
class CreatePosDevicePinFailures < ActiveRecord::Migration[8.1]
  def change
    create_table :spree_pos_device_pin_failures do |t|
      t.references :device, null: false, foreign_key: { to_table: :spree_pos_devices }
      t.references :staff_membership, null: false, foreign_key: { to_table: :spree_pos_staff_memberships }
      t.datetime :failed_at, null: false
      t.timestamps
    end
    add_index :spree_pos_device_pin_failures, %i[device_id staff_membership_id failed_at],
              name: 'idx_pos_device_pin_failures_lookup'
  end
end
