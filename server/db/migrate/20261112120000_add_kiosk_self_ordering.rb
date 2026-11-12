# frozen_string_literal: true

# Self-ordering kiosks: a kiosk is a register of its own kind, worked by a
# service account tied to the paired device, whose sales carry their own
# order source. A branch sets how long a kiosk waits for a touch, how long
# its bank QR stays open and whether its unpaid orders reach the kitchen.
class AddKioskSelfOrdering < ActiveRecord::Migration[8.1]
  SOURCE_CHECK = 'chk_pos_workspace_order_source'
  SOURCES = %w[counter facebook zalo other grabfood shopeefood].freeze

  def up
    add_column :spree_pos_registers, :kind, :string, null: false, default: 'counter', limit: 16
    add_check_constraint :spree_pos_registers, "kind IN ('counter', 'kiosk')", name: 'chk_pos_registers_kind'

    add_column :spree_pos_staff_memberships, :service_account, :boolean, null: false, default: false
    add_reference :spree_pos_staff_memberships, :device, null: true, index: { unique: true, name: 'idx_pos_memberships_device' }
    add_check_constraint :spree_pos_staff_memberships, 'service_account = (device_id IS NOT NULL)', name: 'chk_pos_memberships_service_device'

    add_column :spree_pos_branches, :kiosk_idle_seconds, :integer, null: false, default: 60
    add_column :spree_pos_branches, :kiosk_qr_timeout_seconds, :integer, null: false, default: 180
    add_column :spree_pos_branches, :kiosk_kitchen_before_payment, :boolean, null: false, default: false
    add_check_constraint :spree_pos_branches, 'kiosk_idle_seconds BETWEEN 15 AND 600', name: 'chk_pos_branches_kiosk_idle'
    add_check_constraint :spree_pos_branches, 'kiosk_qr_timeout_seconds BETWEEN 60 AND 900', name: 'chk_pos_branches_kiosk_qr_timeout'

    replace_source_check(SOURCES + %w[kiosk])
  end

  def down
    replace_source_check(SOURCES)
    remove_check_constraint :spree_pos_branches, name: 'chk_pos_branches_kiosk_qr_timeout'
    remove_check_constraint :spree_pos_branches, name: 'chk_pos_branches_kiosk_idle'
    remove_column :spree_pos_branches, :kiosk_kitchen_before_payment
    remove_column :spree_pos_branches, :kiosk_qr_timeout_seconds
    remove_column :spree_pos_branches, :kiosk_idle_seconds
    remove_check_constraint :spree_pos_staff_memberships, name: 'chk_pos_memberships_service_device'
    remove_reference :spree_pos_staff_memberships, :device, index: { unique: true, name: 'idx_pos_memberships_device' }
    remove_column :spree_pos_staff_memberships, :service_account
    remove_check_constraint :spree_pos_registers, name: 'chk_pos_registers_kind'
    remove_column :spree_pos_registers, :kind
  end

  private

  def replace_source_check(values)
    remove_check_constraint :spree_pos_workspaces, name: SOURCE_CHECK
    list = values.map { |value| connection.quote(value) }.join(', ')
    add_check_constraint :spree_pos_workspaces, "order_source IN (#{list})", name: SOURCE_CHECK
  end
end
