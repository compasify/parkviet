# frozen_string_literal: true

module Spree
  module Pos
    module Reservations
      # Bookings still waiting past their time plus the branch's grace
      # minutes become no-shows and let their tables go. Only the status
      # changes: a deposit stays held until someone refunds or forfeits it
      # with an approval. One booking's trouble never stops the others.
      class MarkNoShowJob < ApplicationJob
        queue_as :default

        def perform(limit: 500)
          now = Workspace.database_now
          late = Reservation.joins(:branch).where(status: 'booked').
                 where("spree_pos_reservations.starts_at + make_interval(mins => spree_pos_branches.reservation_grace_minutes) < ?", now).
                 order(:starts_at).limit(limit).pluck(:id)
          late.each do |id|
            Reservation.transaction do
              reservation = Reservation.lock.find(id)
              next unless reservation.status == 'booked'

              Cancel.finish!(reservation, 'no_show')
            end
          rescue StandardError => e
            Rails.error.report(e, handled: true, context: { pos_reservation_id: id })
          end
        end
      end
    end
  end
end
