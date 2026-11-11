# frozen_string_literal: true

module Spree
  module Pos
    module Kitchen
      # What a kitchen screen shows, for one or several stations of a branch
      # (every station when none is named: the pass):
      # - `open`: every ticket with an item still to make. Tickets past their
      #   station's red threshold come first, then the oldest.
      # - `held`: held courses waiting for their fire, on a pass or the board of
      #   every station only.
      # - `done`: tickets finished in the last 30 minutes, newest first, for recall.
      # - `all_day`: the open items added up by dish and options, oldest first
      #   inside each dish, for the "by dish" tab and its bump.
      # - `expo`: ready items at the pass, grouped by order. A pass shows what
      #   the stations handing to it (`expo_station_id`) finished; the board
      #   of every station shows every ready item.
      # `service_mode` narrows the board to one way of serving. `server_now`
      # lets the screen run its timers on the server's clock.
      module Board
        # How long a ready item waits at the pass before it leaves the board.
        EXPO_WINDOW = 2.hours

        module_function

        def call(branch:, station: nil, stations: nil, service_mode: nil, now: Workspace.database_now)
          chosen = stations.presence || Array(station).presence
          every = KitchenStation.where(branch_id: branch.id).active.ordered.to_a
          shown = chosen || every
          cutoff = now - KitchenTicket::DONE_WINDOW
          own, fed = tickets((shown | feeders(chosen, every)).map(&:id), service_mode, cutoff).
                     partition { |ticket| shown.any? { |row| row.id == ticket.kitchen_station_id } }
          open, done = own.partition { |ticket| !ticket.done? }
          {
            branch_id: branch.prefixed_id, station: chosen&.one? ? chosen.first.to_pos : nil,
            stations: shown.map(&:to_pos), service_mode: service_mode.presence, server_now: now.iso8601(3),
            open: open.sort_by { |ticket| [late?(ticket, now) ? 0 : 1, ticket.sent_at, ticket.id] }.map(&:to_pos),
            done: recent(done, cutoff).map(&:to_pos), all_day: all_day(open),
            expo: expo(chosen ? fed + own.select { |ticket| ticket.kitchen_station.kind == 'expo' } : own),
            held: chosen.nil? || chosen.any? { |row| row.kind == 'expo' } ? held(branch, service_mode) : []
          }
        end

        # Held courses of the open table orders, waiting at the pass for their
        # fire: one row per order and course, oldest order first. Read from the
        # sale lines, so nothing reaches a station before it is fired.
        def held(branch, service_mode)
          lines = SaleLine.joins(:workspace).where(course_status: 'held').
                  where(spree_pos_workspaces: { branch_id: branch.id, operational_status: Workspace::OPEN_STATUSES }).
                  where.not(spree_pos_workspaces: { resource_id: nil })
          lines = lines.where(spree_pos_workspaces: { service_mode: service_mode }) if service_mode.present?
          lines = lines.includes(:line_item, workspace: :resource).order(:created_at, :id).to_a
          return [] if lines.empty?

          names = CourseLabel.for_branch(branch)
          lines.group_by { |line| [line.workspace_id, line.course] }.map do |(_, course), group|
            workspace = group.first.workspace
            {
              workspace_id: workspace.prefixed_id, resource_name: workspace.resource&.name,
              area_id: Area.prefixed_for(workspace.resource&.area_id), course: course,
              course_name: names[course] || "Lượt #{course}", held_since: group.map(&:created_at).min.iso8601(3),
              lines: group.map do |line|
                { sale_line_id: line.prefixed_id, name: line.line_item.name, quantity: line.sale_quantity.to_s('F'), seat: line.seat }
              end
            }
          end
        end

        # The stations that hand their finished items to a chosen pass.
        def feeders(chosen, every)
          return every if chosen.nil?

          every.select { |row| chosen.any? { |pass| pass.id == row.expo_station_id } }
        end

        def recent(done, cutoff)
          done.select { |ticket| ticket.done_at && ticket.done_at >= cutoff }.sort_by { |ticket| [-ticket.done_at.to_f, -ticket.id] }
        end

        # One query for the tickets with something to show, then their rows.
        def tickets(station_ids, service_mode, cutoff)
          items = KitchenTicketItem.joins(:kitchen_ticket).where(spree_pos_kitchen_tickets: { kitchen_station_id: station_ids })
          items = items.where(spree_pos_kitchen_tickets: { service_mode: service_mode }) if service_mode.present?
          ids = items.where(
            'spree_pos_kitchen_ticket_items.status IN (:open) OR spree_pos_kitchen_ticket_items.ready_at >= :cutoff ' \
            'OR spree_pos_kitchen_ticket_items.served_at >= :cutoff OR spree_pos_kitchen_ticket_items.voided_at >= :cutoff ' \
            "OR (spree_pos_kitchen_ticket_items.status = 'ready' AND spree_pos_kitchen_ticket_items.ready_at >= :expo_cutoff)",
            open: KitchenTicketItem::OPEN, cutoff: cutoff, expo_cutoff: cutoff - (EXPO_WINDOW - KitchenTicket::DONE_WINDOW)
          ).distinct.pluck(:kitchen_ticket_id)
          KitchenTicket.where(id: ids).includes(:kitchen_station, :branch, workspace: :resource, items: :sale_line).to_a
        end

        def late?(ticket, now)
          ticket.sent_at < now - ticket.kitchen_station.late_after_minutes.minutes
        end

        # The same dish with the same options, whatever ticket it is on.
        def all_day_key(item)
          options = Array(item.modifiers).map { |row| [row['name'].to_s, row['quantity'].to_i] }.sort
          Digest::SHA256.hexdigest([item.name, options].to_json)[0, 16]
        end

        def all_day(open)
          rows = open.select { |ticket| ticket.kind == 'fire' }.sort_by { |ticket| [ticket.sent_at, ticket.id] }.flat_map do |ticket|
            ticket.items.select { |item| KitchenTicketItem::OPEN.include?(item.status) }.map { |item| [ticket, item] }
          end
          rows.group_by { |_, item| all_day_key(item) }.map do |key, group|
            first = group.first.last
            {
              key: key, name: first.name, modifiers: first.modifiers,
              quantity: group.sum { |_, item| item.quantity }.to_s('F'),
              oldest_sent_at: group.first.first.sent_at.iso8601(3),
              item_ids: group.map { |_, item| item.prefixed_id }
            }
          end
        end

        # Ready items waiting at the pass, one row per order, oldest first.
        def expo(tickets)
          rows = tickets.select { |ticket| ticket.kind == 'fire' }.flat_map do |ticket|
            ticket.items.select { |item| item.status == 'ready' }.map { |item| [ticket, item] }
          end
          orders = rows.group_by { |ticket, _| ticket.workspace_id }.values.map { |group| expo_order(group) }
          orders.sort_by { |row| row[:ready_since].to_s }
        end

        def expo_order(group)
          ticket = group.first.first
          {
            workspace_id: ticket.workspace.prefixed_id, header: ticket.header, service_mode: ticket.service_mode,
            area_id: Area.prefixed_for(ticket.workspace.resource&.area_id),
            ready_since: group.filter_map { |_, item| item.ready_at }.min&.iso8601(3),
            items: group.map do |row_ticket, item|
              { item: item.to_pos, kitchen_ticket_id: row_ticket.prefixed_id, station_name: row_ticket.kitchen_station.name }
            end
          }
        end
      end
    end
  end
end
