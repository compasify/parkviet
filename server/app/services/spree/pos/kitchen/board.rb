# frozen_string_literal: true

module Spree
  module Pos
    module Kitchen
      # What a kitchen screen shows: every ticket of the station with an item
      # still to make, oldest first, and the tickets finished in the last 30
      # minutes, newest first, for recall. Without a station, every station of
      # the branch (the pass). `server_now` lets the screen run its timers on
      # the server's clock.
      module Board
        module_function

        def call(branch:, station: nil, now: Workspace.database_now)
          stations = station ? [station] : KitchenStation.where(branch_id: branch.id).active.ordered.to_a
          ids = stations.map(&:id)
          cutoff = now - KitchenTicket::DONE_WINDOW
          items = KitchenTicketItem.joins(:kitchen_ticket).where(spree_pos_kitchen_tickets: { kitchen_station_id: ids })
          open_ids = items.where(status: KitchenTicketItem::OPEN).distinct.pluck(:kitchen_ticket_id)
          recent_ids = items.where('spree_pos_kitchen_ticket_items.ready_at >= :cutoff OR spree_pos_kitchen_ticket_items.served_at >= :cutoff ' \
                                   'OR spree_pos_kitchen_ticket_items.voided_at >= :cutoff', cutoff: cutoff).
                       distinct.pluck(:kitchen_ticket_id)
          tickets = KitchenTicket.where(id: open_ids | recent_ids).includes(:kitchen_station, :workspace, :branch, items: :sale_line).to_a
          open, done = tickets.partition { |ticket| !ticket.done? }
          done.select! { |ticket| ticket.done_at && ticket.done_at >= cutoff }
          {
            branch_id: branch.prefixed_id, station: station&.to_pos, stations: stations.map(&:to_pos),
            server_now: now.iso8601(3),
            open: open.sort_by { |ticket| [ticket.sent_at, ticket.id] }.map(&:to_pos),
            done: done.sort_by { |ticket| [-ticket.done_at.to_f, -ticket.id] }.map(&:to_pos)
          }
        end
      end
    end
  end
end
