# frozen_string_literal: true

module Spree
  module Pos
    module Orders
      # Finishes a handover that was short: after the shelf was corrected with
      # a stock document, a resolver at the branch dispatches the fulfillments
      # still allocated, under the same stock-row locks and credit rule as the
      # counter handover. The cashier's shift may be long closed, so this does
      # not require the shift owner.
      class ReconcileHandover
        def self.call(store:, staff:, key:, order_id:)
          payload = { 'command' => 'order.reconcile_handover', 'order_id' => order_id.to_s }
          workspace = Returns::Guard.sale!(store, order_id)
          authorize = lambda do
            policy = AccessPolicy.new(store: store, staff: staff)
            raise CanCan::AccessDenied if workspace.branch.disabled? || !policy.permission?('write_pos_orders') ||
              !policy.allows?(workspace.branch, Capabilities::RESOLVE)
          end
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, workspace: workspace, authorize: authorize) do
            Handover.dispatch!(workspace: workspace, staff: staff, action: 'order.handover_reconcile')
          end
        end
      end
    end
  end
end
