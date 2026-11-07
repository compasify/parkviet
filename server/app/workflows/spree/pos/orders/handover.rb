# frozen_string_literal: true

module Spree
  module Pos
    module Orders
      # Pickup handover: strict branch location + placed order + core
      # fulfillment workflow. Stock leaves the shelf once, in core, when the
      # fulfillment ships; a fulfilled fulfillment is never shipped again, so a
      # retried handover, a later collection or a reprint moves no stock.
      #
      # Goods at the counter are physically there, so a system shelf that is
      # short does not stop the sale: the fulfillment stays allocated and the
      # shortfall is recorded as a stock discrepancy for reconciliation, never
      # forced below zero or covered by an invented receipt. Once the shelf is
      # corrected, `ReconcileHandover` (a resolver at the branch) or the recovery
      # job dispatches it under the same locks and rules, once.
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
            dispatch!(workspace: workspace, staff: staff, action: 'order.handover')
          end
        end

        # Ships every unfulfilled fulfillment the shelf covers and records the
        # rest. Callers hold the workspace lock (CommandExecutor or the job).
        def self.dispatch!(workspace:, staff:, action:)
          raise Conflict, 'Workspace is not completed.' unless workspace.operational_status == 'completed'

          order = workspace.order
          raise Conflict, 'Order is not placed.' unless order.placed?
          unless StrictLocationGuard.call(order: order, branch: workspace.branch)
            raise Conflict, 'Fulfillment does not belong to the branch stock location.'
          end

          fulfillments = order.fulfillments.to_a
          raise Conflict, 'Order has no fulfillment.' if fulfillments.empty?

          on_credit = approved_credit_covers?(order)
          # Goods only leave against money received or approved credit; a
          # shortfall is never recorded for an order that could not ship anyway.
          raise Conflict.new('Order is not paid or covered by approved credit.', reason: 'not_covered') unless on_credit || paid?(order)

          gaps = []
          shipped = []
          fulfillments.each do |fulfillment|
            next if fulfillment.fulfilled?

            shortfall = shelf_shortfall(fulfillment)
            if shortfall.any?
              gaps.concat(record_shortfall!(workspace, fulfillment, shortfall, staff))
              next
            end
            # Core refuses an unpaid dispatch unless forced. Only an approved
            # credit debit that covers the unpaid part may force it; the shelf
            # was checked above under the stock-row locks.
            result = Spree.fulfillment_fulfill_workflow.call(fulfillment: fulfillment, notify_customer: false, force: on_credit)
            raise Conflict, 'Fulfillment could not be handed over.' unless result.success?

            shipped << fulfillment
            StockDiscrepancy.open_now.where(fulfillment_id: fulfillment.id).find_each do |gap|
              gap.update!(status: 'resolved', resolved_at: Time.current)
            end
          end
          short = gaps.any?
          # Nothing left to ship: a repeated handover or reconcile is a no-op.
          return workspace.to_pos.merge(stock_discrepancies: []) if shipped.empty? && !short

          AuditEntry.record!(store: workspace.store, actor: staff, action: short ? "#{action}_short" : action, subject: workspace,
                             metadata: { order_id: order.prefixed_id, shipped: shipped.map(&:prefixed_id),
                                         stock_discrepancies: gaps.map(&:prefixed_id) })
          OutboxEntry.record!(store: workspace.store, event_type: short ? 'order.handover_short' : 'order.handed_over',
                              aggregate: workspace,
                              payload: { 'workspace_id' => workspace.prefixed_id, 'order_id' => order.prefixed_id })
          gaps.each do |gap|
            OutboxEntry.record_once!(store_id: workspace.store_id, event_type: 'stock.discrepancy', aggregate: gap,
                                     payload: { 'discrepancy_id' => gap.prefixed_id, 'order_id' => order.prefixed_id })
          end
          workspace.to_pos.merge(stock_discrepancies: StockDiscrepancy.open_now.where(order_id: order.id).map(&:to_pos))
        end

        def self.paid?(order)
          order.payments.where(status: 'completed').sum(:amount) >= order.total
        end

        def self.approved_credit_covers?(order)
          debit = ReceivableEntry.find_by(order_id: order.id, kind: 'debit')
          return false if debit.nil?

          order.payments.where(status: 'completed').sum(:amount) + debit.amount >= order.total
        end

        # The stock rows stay locked (in id order, the order core reads them)
        # until the handover commits, so two handovers of the last unit cannot
        # both pass this check and drive the shelf negative.
        # Returns { variant_id => [needed, on_hand] } for every short variant.
        def self.shelf_shortfall(fulfillment)
          items = fulfillment.fulfillment_items.to_a
          raise Conflict, 'Backordered goods cannot be handed over.' if items.any?(&:backordered?)

          needed = items.select { |item| item.variant.track_inventory? }.group_by(&:variant_id).
                   transform_values { |rows| rows.sum(&:quantity) }
          return {} if needed.empty?

          levels = Spree::StockLevel.where(stock_location_id: fulfillment.stock_location_id, variant_id: needed.keys).
                   order(:id).lock.to_a.group_by(&:variant_id).transform_values(&:first)
          needed.each_with_object({}) do |(variant_id, quantity), short|
            level = levels[variant_id]
            # Like core, a location that keeps no level for the variant is not checked.
            short[variant_id] = [quantity, level.count_on_hand] if level && level.count_on_hand < quantity
          end
        end

        # One open discrepancy per fulfillment and variant; a retried handover
        # that is still short refreshes nothing and records nothing twice.
        def self.record_shortfall!(workspace, fulfillment, shortfall, staff)
          shortfall.map do |variant_id, (needed, on_hand)|
            StockDiscrepancy.open_now.find_by(fulfillment_id: fulfillment.id, variant_id: variant_id) ||
              StockDiscrepancy.create!(
                store: workspace.store, branch: workspace.branch, workspace: workspace, order: workspace.order,
                fulfillment: fulfillment, variant_id: variant_id, stock_location_id: fulfillment.stock_location_id,
                actor: staff, needed: needed, on_hand: on_hand, status: 'open', checked_at: Time.current
              )
          end
        end
      end
    end
  end
end
