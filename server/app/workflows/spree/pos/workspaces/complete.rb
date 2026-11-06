# frozen_string_literal: true

module Spree
  module Pos
    module Workspaces
      # Guarded placement + pickup handover. Core `order_complete` accepts a
      # pending payment as coverage, so POS checks its own completed-receipt
      # allocations before calling it and never fakes a receipt.
      class Complete
        def self.call(workspace:, staff:, revision:, lease_generation:, editor_id:, key:)
          payload = {
            'command' => 'workspace.complete', 'revision' => revision, 'lease_generation' => lease_generation,
            'editor_digest' => Workspace.editor_digest(editor_id)
          }
          authorize = lambda do
            Tenders::Guard.authorize_editor!(workspace, staff)
            Tenders::Guard.authorize_collect!(workspace, staff)
          end
          CommandExecutor.call(store: workspace.store, actor: staff, key: key, payload: payload, workspace: workspace, authorize: authorize) do
            Tenders::Guard.validate_editor!(workspace, staff, revision, lease_generation, editor_id)
            Tenders::Guard.validate_open_shift!(workspace)
            Tenders::Guard.tracked_guard!(workspace)
            order = workspace.order
            raise Conflict, 'Order has no items.' if order.line_items.empty?
            if TenderAttempt.where(workspace: workspace, status: %w[prepared unknown failed]).exists?
              raise Conflict, 'Unresolved tender attempts block completion.'
            end

            allocated = FundsAllocation.where(workspace: workspace, status: 'active').sum(:amount)
            raise Conflict, 'Received funds do not cover the order total.' if allocated < order.total
            raise Conflict, 'Allocated funds exceed the order total.' if allocated > order.total

            payments = order.payments.where(id: FundsAllocation.where(workspace: workspace, status: 'active').select(:payment_id)).to_a
            completed = payments.select { |payment| payment.status == 'completed' }.sum(&:amount)
            raise Conflict, 'Completed receipts do not cover the order total.' if completed < order.total

            ensure_pickup_fulfillment!(workspace)
            unless StrictLocationGuard.call(order: order.reload, branch: workspace.branch)
              raise Conflict, 'Fulfillment does not belong to the branch stock location.'
            end

            result = Spree.order_complete_workflow.call(order: order.reload, notify_customer: false)
            raise Conflict, 'Order could not be placed.' unless result.success?
            raise Conflict, 'Order was not placed.' unless order.reload.placed?

            workspace.update!(revision: workspace.revision + 1, operational_status: 'completed')
            AuditEntry.record!(store: workspace.store, actor: staff, action: 'workspace.complete', subject: workspace,
                               metadata: { order_id: order.prefixed_id, total: order.total.to_s('F') })
            OutboxEntry.record!(store: workspace.store, event_type: 'workspace.completed', aggregate: workspace,
                                payload: { 'workspace_id' => workspace.prefixed_id, 'order_id' => order.prefixed_id })
            workspace.to_pos
          end
        end

        def self.ensure_pickup_fulfillment!(workspace)
          order = workspace.order
          return if order.fulfillments.exists?

          location = workspace.branch.stock_location
          fulfillment = order.fulfillments.create!(stock_location: location, cost: 0)
          method = pickup_method!(workspace.store)
          rate = fulfillment.add_delivery_method(method)
          fulfillment.update!(selected_shipping_rate_id: rate.id)
          line_map = SaleLine.where(workspace: workspace).index_by(&:line_item_id)
          order.line_items.each do |line|
            quantity = line_map[line.id]&.base_quantity || line.quantity
            fulfillment.fulfillment_items.create!(variant: line.variant, line_item: line, order: order, quantity: quantity, status: 'on_hand')
          end
          order.reload
        end

        def self.pickup_method!(store)
          method = Spree::DeliveryMethod.where(store_id: store.id, deleted_at: nil)
                                        .where('fulfillment_provider ILIKE ?', '%pickup%').order(:id).first
          return method if method

          Spree::DeliveryMethod.create!(store: store, name: 'POS pickup', fulfillment_provider: 'Spree::FulfillmentProvider::Pickup',
                                        display_on: 'back_end', storefront_visible: false)
        end
      end
    end
  end
end
