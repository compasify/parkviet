# frozen_string_literal: true

module Spree
  module Pos
    module Orders
      # Minimal pickup handover: strict branch location + placed order +
      # core fulfillment workflow. Stock effect happens once in core.
      class Handover
        def self.call(workspace:, staff:, key:)
          payload = { 'command' => 'order.handover', 'workspace_id' => workspace.prefixed_id }
          authorize = lambda do
            policy = AccessPolicy.new(store: workspace.store, staff: staff)
            raise CanCan::AccessDenied if workspace.branch.disabled? || workspace.register&.disabled? ||
              workspace.shift.owner_id != staff.id || !policy.permission?('write_pos_orders') ||
              !policy.allows?(workspace.branch, Capabilities::PAYMENT)
          end
          CommandExecutor.call(store: workspace.store, actor: staff, key: key, payload: payload, workspace: workspace, authorize: authorize) do
            raise Conflict, 'Workspace is not completed.' unless workspace.operational_status == 'completed'

            order = workspace.order
            raise Conflict, 'Order is not placed.' unless order.placed?
            unless StrictLocationGuard.call(order: order, branch: workspace.branch)
              raise Conflict, 'Fulfillment does not belong to the branch stock location.'
            end

            fulfillments = order.fulfillments.to_a
            raise Conflict, 'Order has no fulfillment.' if fulfillments.empty?

            fulfillments.each do |fulfillment|
              next if fulfillment.fulfilled?

              result = Spree.fulfillment_fulfill_workflow.call(fulfillment: fulfillment, notify_customer: false)
              raise Conflict, 'Fulfillment could not be handed over.' unless result.success?
            end
            AuditEntry.record!(store: workspace.store, actor: staff, action: 'order.handover', subject: workspace,
                               metadata: { order_id: order.prefixed_id })
            OutboxEntry.record!(store: workspace.store, event_type: 'order.handed_over', aggregate: workspace,
                                payload: { 'workspace_id' => workspace.prefixed_id, 'order_id' => order.prefixed_id })
            workspace.to_pos
          end
        end
      end
    end
  end
end
