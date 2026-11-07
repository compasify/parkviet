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

            on_credit = approved_credit_covers?(order)
            fulfillments.each do |fulfillment|
              next if fulfillment.fulfilled?

              # Core refuses an unpaid dispatch unless forced. Only an approved
              # credit debit that covers the unpaid part may force it, and only
              # after POS has checked backorders and the shelf itself.
              ensure_shelf!(fulfillment) if on_credit
              result = Spree.fulfillment_fulfill_workflow.call(fulfillment: fulfillment, notify_customer: false, force: on_credit)
              raise Conflict, 'Fulfillment could not be handed over.' unless result.success?
            end
            AuditEntry.record!(store: workspace.store, actor: staff, action: 'order.handover', subject: workspace,
                               metadata: { order_id: order.prefixed_id })
            OutboxEntry.record!(store: workspace.store, event_type: 'order.handed_over', aggregate: workspace,
                                payload: { 'workspace_id' => workspace.prefixed_id, 'order_id' => order.prefixed_id })
            workspace.to_pos
          end
        end

        def self.approved_credit_covers?(order)
          debit = ReceivableEntry.find_by(order_id: order.id, kind: 'debit')
          return false if debit.nil?

          order.payments.where(status: 'completed').sum(:amount) + debit.amount >= order.total
        end

        # The stock rows stay locked (in id order, the order core reads them)
        # until the handover commits, so two forced handovers of the last unit
        # cannot both pass this check and drive the shelf negative.
        def self.ensure_shelf!(fulfillment)
          items = fulfillment.fulfillment_items.to_a
          raise Conflict, 'Backordered goods cannot be handed over.' if items.any?(&:backordered?)

          needed = items.select { |item| item.variant.track_inventory? }.group_by(&:variant_id).
                   transform_values { |rows| rows.sum(&:quantity) }
          return if needed.empty?

          levels = Spree::StockLevel.where(stock_location_id: fulfillment.stock_location_id, variant_id: needed.keys).
                   order(:id).lock.to_a.group_by(&:variant_id).transform_values(&:first)
          needed.each do |variant_id, quantity|
            level = levels[variant_id]
            # Like core, a location that keeps no level for the variant is not checked.
            raise Conflict, 'Not enough stock on the shelf to hand over.' if level && level.count_on_hand < quantity
          end
        end
      end
    end
  end
end
