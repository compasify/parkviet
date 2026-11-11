# frozen_string_literal: true

module Spree
  module Pos
    module PlatformOrders
      # A platform order is ready for the driver once the kitchen has made
      # all of it: the kitchen screen's last bump marks it, and a cashier can
      # mark it by hand (a branch without a kitchen screen). Ready changes no
      # money; the order completes when the driver picks it up.
      module MarkReady
        module_function

        def call(platform_order:, staff:, key:)
          workspace = platform_order.workspace
          payload = { 'command' => 'platform_order.ready', 'platform_order_id' => platform_order.prefixed_id }
          CommandExecutor.call(store: workspace.store, actor: staff, key: key, payload: payload, workspace: workspace,
                               authorize: -> { Guard.counter!(workspace, staff) }) do
            platform_order.lock!
            case platform_order.status
            when 'accepted'
              platform_order.update!(status: 'ready', ready_at: Workspace.database_now)
              AuditEntry.record!(store: workspace.store, actor: staff, action: 'platform_order.ready', subject: workspace,
                                 metadata: { platform_order_id: platform_order.prefixed_id })
            when 'ready' then nil
            else raise Guard.closed!(platform_order)
            end
            platform_order.to_pos
          end
        end

        # From the kitchen, inside the transaction that moved an item: the
        # order turns ready when every item of every ticket is done and at
        # least one was made, and back to accepted when the kitchen recalls
        # an item of an order the driver has not taken yet. The kitchen
        # screen is a device, not a person, so the order's ready time is the
        # record.
        def after_kitchen(workspace_id)
          order = PlatformOrder.lock.find_by(workspace_id: workspace_id, status: PlatformOrder::OPEN)
          return if order.nil?

          items = KitchenTicketItem.joins(:kitchen_ticket).where(spree_pos_kitchen_tickets: { workspace_id: workspace_id })
          open = items.where(status: KitchenTicketItem::OPEN).exists?
          if order.status == 'ready'
            order.update!(status: 'accepted', ready_at: nil) if open
          elsif !open && items.where(status: %w[ready served]).exists?
            order.update!(status: 'ready', ready_at: Workspace.database_now)
          end
        end
      end
    end
  end
end
