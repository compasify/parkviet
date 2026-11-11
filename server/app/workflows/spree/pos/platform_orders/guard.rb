# frozen_string_literal: true

module Spree
  module Pos
    module PlatformOrders
      # Who works platform orders. The counter enters, readies, hands over
      # and cancels them; settling what the platforms paid is money
      # reconciliation (pos.payment.resolve); the branch's platforms and
      # rates are branch setup (pos.topology.manage). Store administrators
      # may do all of it.
      module Guard
        module_function

        def counter!(workspace, staff)
          access = AccessPolicy.new(store: workspace.store, staff: staff)
          return if access.permission?('write_pos_orders') && access.allows?(workspace.branch, Capabilities::OPEN_SHIFT)

          raise CanCan::AccessDenied
        end

        def read!(store, staff, branch)
          access = AccessPolicy.new(store: store, staff: staff)
          return if access.permission?('read_pos_topology')
          return if [Capabilities::OPEN_SHIFT, Capabilities::RESOLVE, Capabilities::MANAGE].any? { |key| access.allows?(branch, key) }

          raise CanCan::AccessDenied
        end

        def settle!(store, staff, branch)
          access = AccessPolicy.new(store: store, staff: staff)
          return if access.permission?('write_pos_topology') || access.allows?(branch, Capabilities::RESOLVE)

          raise CanCan::AccessDenied
        end

        def manage!(store, staff, branch)
          access = AccessPolicy.new(store: store, staff: staff)
          return if access.permission?('write_pos_topology') || access.allows?(branch, Capabilities::MANAGE)

          raise CanCan::AccessDenied
        end

        # The refusal for an order that is no longer open.
        def closed!(order)
          reason = order.status == 'completed' ? 'platform_order_completed' : 'platform_order_canceled'
          Conflict.new("This platform order is #{order.status}.", reason: reason)
        end
      end
    end
  end
end
