# frozen_string_literal: true

# A waiting booking can be confirmed with the guest: the time it was
# confirmed is kept on the booking; who confirmed it is in the audit.
class AddReservationConfirmation < ActiveRecord::Migration[8.1]
  def change
    add_column :spree_pos_reservations, :confirmed_at, :datetime
  end
end
