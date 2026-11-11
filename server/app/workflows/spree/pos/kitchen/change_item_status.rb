# frozen_string_literal: true

module Spree
  module Pos
    module Kitchen
      # Moves kitchen items along new → preparing → ready → served. A recall
      # takes a ready item back to preparing within 30 minutes; a bump makes
      # every open item of a ticket ready. Asking for the status an item
      # already has changes nothing, so a screen that retries a tap is safe;
      # any other move that is not listed is refused. Times come from the
      # database clock, never the device.
      module ChangeItemStatus
        RECALL_WINDOW = 30.minutes
        MOVES = {
          'start' => [%w[new], 'preparing'],
          'ready' => [%w[new preparing], 'ready'],
          'serve' => [%w[ready], 'served'],
          'recall' => [%w[ready], 'preparing']
        }.freeze
        ACTIONS = MOVES.keys.freeze

        module_function

        # `actor` is the kitchen screen (Device) or the staff member.
        def call(item:, action:, actor:)
          move = MOVES[action.to_s]
          raise Conflict.new('That kitchen action is unknown.', reason: 'kitchen_action_invalid') if move.nil?

          changed = KitchenTicketItem.transaction do
            item.lock!
            apply!(item, action.to_s, move, actor, Workspace.database_now).tap do |moved|
              PlatformOrders::MarkReady.after_kitchen(item.kitchen_ticket.workspace_id) if moved
            end
          end
          publish(item.kitchen_ticket) if changed
          item
        end

        # Every new or preparing item of the ticket becomes ready at once.
        def bump(ticket:, actor:)
          changed = KitchenTicketItem.transaction do
            items = KitchenTicketItem.where(kitchen_ticket_id: ticket.id).order(:id).lock.to_a
            now = Workspace.database_now
            moved = items.select { |item| KitchenTicketItem::OPEN.include?(item.status) }.each do |item|
              apply!(item, 'ready', MOVES['ready'], actor, now)
            end.any?
            # A delivery platform's order is ready for its driver.
            PlatformOrders::MarkReady.after_kitchen(ticket.workspace_id) if moved
            moved
          end
          publish(ticket) if changed
          ticket.items.reset
          ticket
        end

        # "Handed over": every ready item of the order becomes served, on
        # every ticket, and the call number leaves the board. Items still
        # being made stay as they are; an order with nothing ready changes
        # nothing, so a second tap is safe.
        def serve_order(workspace:, actor:)
          changed = KitchenTicketItem.transaction do
            items = KitchenTicketItem.joins(:kitchen_ticket).where(spree_pos_kitchen_tickets: { workspace_id: workspace.id }).
                    where(status: 'ready').order(:id).lock.to_a
            now = Workspace.database_now
            items.each { |item| apply!(item, 'serve', MOVES['serve'], actor, now) }
            KitchenTicket.where(id: items.map(&:kitchen_ticket_id).uniq).includes(:kitchen_station, :workspace, :branch).to_a
          end
          changed.each { |ticket| publish(ticket) }
          changed
        end

        def apply!(item, action, move, actor, now)
          from, to = move
          return false if item.status == to && action != 'recall'
          unless from.include?(item.status)
            raise Conflict.new("A #{item.status} item cannot be moved to #{to}.", reason: 'kitchen_status_invalid',
                                                                                  details: { status: item.status })
          end
          if action == 'recall' && (item.ready_at.nil? || item.ready_at < now - RECALL_WINDOW)
            raise Conflict.new('Items can be recalled for 30 minutes after they are ready.', reason: 'kitchen_recall_expired')
          end

          item.update!(**times(item, action, now), status: to, changed_by: actor)
          true
        end

        def times(item, action, now)
          case action
          when 'start' then { started_at: now }
          when 'ready' then { started_at: item.started_at || now, ready_at: now }
          when 'serve' then { served_at: now }
          when 'recall' then { ready_at: nil }
          end
        end

        def publish(ticket)
          Realtime.publish(ticket.branch, 'kitchen_ticket.updated',
                           id: ticket.prefixed_id, refs: { workspace_id: ticket.workspace.prefixed_id,
                                                           kitchen_station_id: ticket.kitchen_station.prefixed_id })
        end
      end
    end
  end
end
