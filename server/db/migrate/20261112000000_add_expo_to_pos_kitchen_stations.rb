# frozen_string_literal: true

# A kitchen or bar station can hand what it finishes to a pass (an `expo`
# station of the same branch), which checks the plates and sends them out.
# The yellow and red thresholds of a station already exist in minutes.
class AddExpoToPosKitchenStations < ActiveRecord::Migration[8.1]
  def change
    add_reference :spree_pos_kitchen_stations, :expo_station,
                  foreign_key: { to_table: :spree_pos_kitchen_stations, on_delete: :nullify }
    add_check_constraint :spree_pos_kitchen_stations, 'expo_station_id IS NULL OR expo_station_id <> id',
                         name: 'chk_pos_kitchen_stations_expo'
  end
end
