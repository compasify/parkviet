# frozen_string_literal: true

module Spree
  module Pos
    module Kitchen
      # Who works the kitchen of a branch and who sets it up. A kitchen
      # screen (a device paired as `kds` or `expo`) works the kitchen of its
      # own branch as the machine, without a PIN; people need
      # pos.kitchen.operate there. Stations, routes and the send trigger take
      # pos.kitchen.manage, or store administration.
      module Guard
        DEVICE_MODES = %w[kds expo].freeze

        module_function

        def operate!(store, staff, branch)
          access = AccessPolicy.new(store: store, staff: staff)
          return if access.permission?('write_pos_topology')
          return if [Capabilities::OPERATE_KITCHEN, Capabilities::MANAGE_KITCHEN].any? { |key| access.allows?(branch, key) }

          raise CanCan::AccessDenied
        end

        # Handing ready orders over: the kitchen, and the cashier at the
        # counter who calls the numbers.
        def hand_over!(store, staff, branch)
          access = AccessPolicy.new(store: store, staff: staff)
          return if access.permission?('write_pos_topology')
          return if [Capabilities::OPERATE_KITCHEN, Capabilities::MANAGE_KITCHEN, Capabilities::PAYMENT].any? { |key| access.allows?(branch, key) }

          raise CanCan::AccessDenied
        end

        def workspace!(branch, workspace_id)
          Workspace.locate(Workspace.where(branch_id: branch.id), workspace_id) || raise(ActiveRecord::RecordNotFound)
        end

        def manage!(store, staff, branch)
          access = AccessPolicy.new(store: store, staff: staff)
          return if access.permission?('write_pos_topology') || access.allows?(branch, Capabilities::MANAGE_KITCHEN)

          raise CanCan::AccessDenied
        end

        # Reading the setup: managers, and the people who work the kitchen.
        def read_setup!(store, staff, branch)
          access = AccessPolicy.new(store: store, staff: staff)
          return if access.permission?('read_pos_topology')
          return if [Capabilities::MANAGE_KITCHEN, Capabilities::OPERATE_KITCHEN].any? { |key| access.allows?(branch, key) }

          raise CanCan::AccessDenied
        end

        def device!(device)
          raise CanCan::AccessDenied unless DEVICE_MODES.include?(device.mode) && !device.branch.disabled?
        end

        def branch!(store, branch_id)
          Branch.locate(Branch.for_store(store), branch_id) || raise(ActiveRecord::RecordNotFound)
        end

        def station!(branch, station_id)
          KitchenStation.locate(KitchenStation.where(branch_id: branch.id), station_id) || raise(ActiveRecord::RecordNotFound)
        end

        # Several stations of a branch, from an array or a comma list; none
        # named means none chosen (the whole branch).
        def stations!(branch, ids)
          list = (ids.is_a?(Array) ? ids : ids.to_s.split(',')).map(&:to_s).map(&:strip).reject(&:empty?).uniq
          raise Conflict.new('Choose at most 20 stations.', reason: 'kitchen_stations_invalid') if list.size > 20

          list.map { |id| station!(branch, id) }
        end

        # A board narrowed to one way of serving; blank for all.
        def service_mode!(value)
          mode = value.to_s.presence
          return if mode.nil?
          raise Conflict.new('The service mode is unknown.', reason: 'service_mode_invalid') unless Workspace::SERVICE_MODES.include?(mode)

          mode
        end

        def item!(branch, item_id)
          scope = KitchenTicketItem.joins(:kitchen_ticket).where(spree_pos_kitchen_tickets: { branch_id: branch.id })
          KitchenTicketItem.locate(scope, item_id) || raise(ActiveRecord::RecordNotFound)
        end

        def ticket!(branch, ticket_id)
          KitchenTicket.locate(KitchenTicket.where(branch_id: branch.id), ticket_id) || raise(ActiveRecord::RecordNotFound)
        end

        # Item and ticket ids name their branch; staff may act on any branch
        # they hold the capability at.
        def staff_item!(store, staff, item_id)
          item = KitchenTicketItem.find_by_prefix_id(item_id.to_s) || raise(ActiveRecord::RecordNotFound)
          ticket = item.kitchen_ticket
          raise ActiveRecord::RecordNotFound unless ticket.store_id == store.id

          operate!(store, staff, ticket.branch)
          item
        end

        # Handing a dish out: the kitchen, and the people at the pass.
        def serve_item!(store, staff, item_id)
          item = KitchenTicketItem.find_by_prefix_id(item_id.to_s) || raise(ActiveRecord::RecordNotFound)
          ticket = item.kitchen_ticket
          raise ActiveRecord::RecordNotFound unless ticket.store_id == store.id

          access = AccessPolicy.new(store: store, staff: staff)
          return item if access.allows?(ticket.branch, Capabilities::EXPO_OPERATE)

          operate!(store, staff, ticket.branch)
          item
        end

        def staff_ticket!(store, staff, ticket_id)
          ticket = KitchenTicket.locate(KitchenTicket.for_store(store), ticket_id) || raise(ActiveRecord::RecordNotFound)
          operate!(store, staff, ticket.branch)
          ticket
        end
      end
    end
  end
end
