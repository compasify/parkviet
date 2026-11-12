# frozen_string_literal: true

# Devices no longer pair in a bridge mode. Both the device and its pending
# pairing accept only the remaining modes.
class RemoveBridgeModeFromSpreePosDevices < ActiveRecord::Migration[8.1]
  OLD_MODES = "mode IN ('waiter', 'kds', 'expo', 'kiosk', 'print_station', 'owner', 'bridge')"
  NEW_MODES = "mode IN ('waiter', 'kds', 'expo', 'kiosk', 'print_station', 'owner')"
  CONSTRAINTS = {
    spree_pos_devices: 'chk_pos_devices_mode',
    spree_pos_device_pairings: 'chk_pos_device_pairings_mode'
  }.freeze

  def up
    replace_constraints(NEW_MODES)
  end

  def down
    replace_constraints(OLD_MODES)
  end

  private

  def replace_constraints(expression)
    CONSTRAINTS.each do |table, name|
      remove_check_constraint table, name: name
      add_check_constraint table, expression, name: name
    end
  end
end
