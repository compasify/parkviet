# frozen_string_literal: true

module Spree
  module Pos
    module GuestOrders
      # Shared rules of ordering from the table QR: whether a branch takes
      # guests' orders at all, who decides on them and who reads them.
      module Guard
        MODULE = 'fnb.qr_order'
        FEATURE = 'qr_order'

        module_function

        # The module of the branch and the store's switch, both on.
        def enabled?(branch)
          !branch.disabled? && ModulePolicy.enabled?(branch, MODULE) && FeaturePolicy.enabled?(branch, FEATURE)
        end

        def require!(branch)
          return if enabled?(branch)

          raise Conflict.new('This branch does not take orders from the table QR.', reason: 'qr_order_unavailable')
        end

        # Accepting or rejecting a guest's order.
        def decide!(store, staff, branch)
          policy = AccessPolicy.new(store: store, staff: staff)
          allowed = policy.allows?(branch, Capabilities::GUEST_ORDER_DECIDE) && policy.permission?('write_pos_orders')
          raise CanCan::AccessDenied if branch.disabled? || !allowed
        end

        # Reading guests' orders and requests, and closing a request: who
        # decides, who serves tables and the cashiers.
        def read!(store, staff, branch)
          policy = AccessPolicy.new(store: store, staff: staff)
          allowed = [Capabilities::GUEST_ORDER_DECIDE, Capabilities::TABLE_SERVE, Capabilities::OPEN_SHIFT].any? do |capability|
            policy.allows?(branch, capability)
          end
          raise CanCan::AccessDenied unless allowed
        end

        # Managing the table codes: who runs the floor plan or the branch.
        def codes!(store, staff, branch)
          policy = AccessPolicy.new(store: store, staff: staff)
          allowed = policy.permission?('write_pos_topology') || policy.allows?(branch, Capabilities::RESOURCE_MANAGE) ||
                    policy.allows?(branch, Capabilities::MANAGE)
          raise CanCan::AccessDenied unless allowed
        end

        # The table's order a new guest session joins: the oldest order open
        # at the table that seats guests (dine-in or a timed room).
        def open_order(resource)
          Workspace.where(resource_id: resource.id, operational_status: Workspace::OPEN_STATUSES,
                          service_mode: Workspace::RESOURCE_MODES).order(:id).first
        end
      end
    end
  end
end
