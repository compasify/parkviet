# frozen_string_literal: true

module Spree
  module Pos
    module Reservations
      # Marks a waiting booking as confirmed with the guest. Nothing else
      # changes: its tables, time and deposits stay, and so does its revision,
      # so an approval asked for a deposit still holds. Confirming again
      # answers the booking as it is.
      module Confirm
        module_function

        def call(store:, staff:, key:, reservation_id:)
          payload = { 'command' => 'reservation.confirm', 'reservation_id' => reservation_id.to_s }
          reservation = Guard.reservation!(store, reservation_id)
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload,
                               authorize: -> { Guard.manage!(store, staff, reservation.branch) }) do
            reservation.lock!
            Guard.booked!(reservation)
            if reservation.confirmed_at.nil?
              reservation.update!(confirmed_at: Time.current)
              AuditEntry.record!(store: store, actor: staff, action: 'reservation.confirm', subject: reservation, metadata: {})
              Guard.announce!(reservation.branch, reservation)
            end
            reservation.reload.to_pos
          end
        end
      end
    end
  end
end
