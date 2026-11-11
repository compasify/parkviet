# frozen_string_literal: true

module Spree
  module Pos
    module Kitchen
      # Moves kitchen items along new → preparing → ready → served. A recall
      # takes a ready or served item back to preparing within 30 minutes; a
      # bump makes every open item of a ticket ready; an all-day bump makes
      # the oldest open items of one dish ready, first sent first. Asking for
      # the status an item already has changes nothing, so a screen that
      # retries a tap is safe; any other move that is not listed is refused.
      # Times come from the database clock, never the device. An item that
      # becomes ready keeps how long it took and whether that was past its
      # station's red threshold, for the kitchen timing report.
      module ChangeItemStatus
        RECALL_WINDOW = 30.minutes
        MOVES = {
          'start' => [%w[new], 'preparing'],
          'ready' => [%w[new preparing], 'ready'],
          'serve' => [%w[ready], 'served'],
          'recall' => [%w[ready served], 'preparing']
        }.freeze
        ACTIONS = MOVES.keys.freeze
        MAX_ALL_DAY = 99

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

        # One dish on the all-day view (Board.all_day_key): the oldest open
        # items of it at these stations become ready until `quantity` units
        # are covered. An item counts whole. Answers the tickets that moved.
        def bump_all_day(stations:, key:, actor:, quantity: 1)
          count = quantity.to_i
          raise Conflict.new('Bump between 1 and 99 at once.', reason: 'kitchen_all_day_invalid') unless count.between?(1, MAX_ALL_DAY)

          tickets = KitchenTicketItem.transaction do
            candidates = KitchenTicketItem.joins(:kitchen_ticket).
                         where(spree_pos_kitchen_tickets: { kitchen_station_id: stations.map(&:id), kind: 'fire' }).
                         where(status: KitchenTicketItem::OPEN).
                         order('spree_pos_kitchen_tickets.sent_at', :id).lock('FOR UPDATE OF spree_pos_kitchen_ticket_items').to_a
            matching = candidates.select { |item| Board.all_day_key(item) == key.to_s }
            raise Conflict.new('Nothing of that dish is waiting.', reason: 'kitchen_all_day_empty') if matching.empty?

            now = Workspace.database_now
            covered = BigDecimal('0')
            moved = matching.take_while do |item|
              next false if covered >= count

              covered += item.quantity
              true
            end
            moved.each { |item| apply!(item, 'ready', MOVES['ready'], actor, now) }
            tickets = KitchenTicket.where(id: moved.map(&:kitchen_ticket_id).uniq).includes(:kitchen_station, :workspace, :branch, :items).to_a
            tickets.map(&:workspace_id).uniq.each { |workspace_id| PlatformOrders::MarkReady.after_kitchen(workspace_id) }
            tickets
          end
          tickets.each { |ticket| publish(ticket) }
          tickets
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
          finished_at = item.served_at || item.ready_at
          if action == 'recall' && (finished_at.nil? || finished_at < now - RECALL_WINDOW)
            raise Conflict.new('Items can be recalled for 30 minutes after they are ready.', reason: 'kitchen_recall_expired')
          end

          item.update!(**times(item, action, now), status: to, changed_by: actor)
          audit_recall!(item, actor) if action == 'recall'
          true
        end

        def times(item, action, now)
          case action
          when 'start' then { started_at: now }
          when 'ready' then { started_at: item.started_at || now, ready_at: now }.merge(timing(item, now))
          when 'serve' then { served_at: now }
          when 'recall'
            { ready_at: nil, served_at: nil, prep_seconds: nil, late: false, recalled_at: now, recall_count: item.recall_count + 1 }
          end
        end

        # From the send to ready, against the station's red threshold.
        def timing(item, now)
          ticket = item.kitchen_ticket
          seconds = [(now - ticket.sent_at).round, 0].max
          { prep_seconds: seconds, late: seconds > ticket.kitchen_station.late_after_minutes * 60 }
        end

        # A person who calls a dish back is named in the audit log; a kitchen
        # screen is named on the item itself (changed_by, recall_count).
        def audit_recall!(item, actor)
          return unless actor.is_a?(Spree.admin_user_class)

          ticket = item.kitchen_ticket
          AuditEntry.record!(store: ticket.store, actor: actor, action: 'kitchen.recall', subject: item,
                             metadata: { kitchen_ticket_id: ticket.prefixed_id, workspace_id: ticket.workspace.prefixed_id,
                                         recall_count: item.recall_count })
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
