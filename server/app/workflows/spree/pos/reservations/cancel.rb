# frozen_string_literal: true

module Spree
  module Pos
    module Reservations
      # Ends a waiting booking without seating it: canceled by the guest, or
      # a no-show. Its tables are let go. Deposits stay held; refunding or
      # forfeiting one is its own command with an approval.
      module Cancel
        ENDINGS = %w[canceled no_show].freeze

        module_function

        def call(store:, staff:, key:, reservation_id:, status: 'canceled')
          ending = status.to_s
          raise Conflict.new('Choose canceled or no-show.', reason: 'reservation_invalid') unless ENDINGS.include?(ending)

          payload = { 'command' => 'reservation.cancel', 'reservation_id' => reservation_id.to_s, 'status' => ending }
          reservation = Guard.reservation!(store, reservation_id)
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload,
                               authorize: -> { Guard.manage!(store, staff, reservation.branch) }) do
            reservation.lock!
            Guard.booked!(reservation)
            finish!(reservation, ending)
            AuditEntry.record!(store: store, actor: staff, action: "reservation.#{ending}", subject: reservation,
                               metadata: { deposit_held: reservation.to_pos[:deposit_held] })
            reservation.reload.to_pos
          end
        end

        # Shared with MarkNoShowJob, which has no person to name.
        def finish!(reservation, ending)
          Guard.release!(reservation)
          reservation.update!(status: ending, canceled_at: Time.current, revision: reservation.revision + 1)
          Guard.announce!(reservation.branch, reservation)
        end
      end
    end
  end
end
