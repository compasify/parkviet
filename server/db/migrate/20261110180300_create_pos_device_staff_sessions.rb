# frozen_string_literal: true

# A staff member signed in on a paired device. The token is a digest. The
# session ends on sign-out, revocation, the 12-hour limit, or branch idle time.
class CreatePosDeviceStaffSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :spree_pos_device_staff_sessions do |t|
      t.references :device, null: false, foreign_key: { to_table: :spree_pos_devices }
      t.bigint :staff_id, null: false
      t.string :token_digest, null: false
      t.datetime :expires_at, null: false
      t.datetime :last_active_at, null: false
      t.datetime :ended_at
      t.string :end_reason
      t.timestamps
    end
    add_index :spree_pos_device_staff_sessions, :token_digest, unique: true
    add_foreign_key :spree_pos_device_staff_sessions, :spree_admin_users, column: :staff_id
  end
end
