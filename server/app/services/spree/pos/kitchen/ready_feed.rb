# frozen_string_literal: true

module Spree
  module Pos
    module Kitchen
      # The dishes a waiter hears about: items of open table orders that
      # became ready or were served in the last 30 minutes, on the tables the
      # waiter serves. Those are the tables the signed-in person added to and
      # the tables the device follows (DeviceTablePin); with `area_id`, every
      # table of that area instead. Newest first. The waiter's screen reads it
      # again on every `kitchen_ticket.updated` and whenever it opens, so a
      # socket lost in the background loses nothing.
      module ReadyFeed
        WINDOW = 30.minutes
        LIMIT = 100

        module_function

        def call(device:, staff:, area_id: nil, now: Workspace.database_now)
          branch = device.branch
          tables = Workspace.where(branch_id: branch.id, operational_status: Workspace::OPEN_STATUSES).where.not(resource_id: nil)
          tables = if area_id.present?
                     area = Area.locate(Area.where(branch_id: branch.id), area_id) || raise(ActiveRecord::RecordNotFound)
                     tables.where(resource_id: Resource.where(area_id: area.id).select(:id))
                   else
                     tables.where(resource_id: DeviceTablePin.where(device_id: device.id).select(:resource_id)).
                       or(tables.where(id: SaleLine.where(added_by_id: staff.id).select(:workspace_id)))
                   end
          cutoff = now - WINDOW
          items = KitchenTicketItem.joins(:kitchen_ticket).
                  where(spree_pos_kitchen_tickets: { kind: 'fire', workspace_id: tables.select(:id) }).
                  where('spree_pos_kitchen_ticket_items.ready_at >= :cutoff OR spree_pos_kitchen_ticket_items.served_at >= :cutoff',
                        cutoff: cutoff).
                  where(status: %w[ready served]).
                  includes(kitchen_ticket: [:kitchen_station, { workspace: :resource }]).
                  order(Arel.sql('COALESCE(spree_pos_kitchen_ticket_items.served_at, spree_pos_kitchen_ticket_items.ready_at) DESC'), id: :desc).
                  limit(LIMIT).to_a
          { branch_id: branch.prefixed_id, server_now: now.iso8601(3), area_id: area_id.presence, items: items.map { |item| row(item) } }
        end

        def row(item)
          ticket = item.kitchen_ticket
          workspace = ticket.workspace
          {
            id: item.prefixed_id, name: item.name, quantity: item.quantity.to_s('F'), modifiers: item.modifiers, status: item.status,
            ready_at: item.ready_at&.iso8601(3), served_at: item.served_at&.iso8601(3), station_name: ticket.kitchen_station.name,
            workspace_id: workspace.prefixed_id, table_label: workspace.table_label,
            resource_id: workspace.resource.prefixed_id, table_name: workspace.resource.name
          }
        end
      end
    end
  end
end
