# frozen_string_literal: true

# The coach visit an order was sold to, chosen at the counter before the
# order completes. The visit's revenue is read from these orders.
class AddVehicleVisitToSpreePosWorkspaces < ActiveRecord::Migration[8.1]
  def change
    add_reference :spree_pos_workspaces, :vehicle_visit, foreign_key: { to_table: :spree_pos_vehicle_visits }
  end
end
