# frozen_string_literal: true

module Spree
  module Pos
    module Workspaces
      # Guarded placement + pickup handover. Core `order_complete` accepts a
      # pending payment as coverage, so POS checks its own completed-receipt
      # allocations before calling it and never fakes a receipt.
      class Complete
        # With `credit_approval_id` the unpaid remainder is sold on credit: the
        # approved reservation becomes the order's receivable debit in the same
        # transaction as placement. Only this server path asks core to place an
        # order whose payments do not cover it; clients never pass that flag.
        #
        # `einvoice_buyer` is who the e-invoice is for (Einvoices::Buyer); none
        # means a sale to a consumer. The invoice itself is only queued here.
        def self.call(workspace:, staff:, revision:, lease_generation:, editor_id:, key:, credit_approval_id: nil,
                      einvoice_buyer: nil)
          credit = credit_approval_id.to_s.presence
          buyer = Einvoices::Buyer.normalize!(einvoice_buyer)
          payload = {
            'command' => 'workspace.complete', 'revision' => revision, 'lease_generation' => lease_generation,
            'editor_digest' => Workspace.editor_digest(editor_id)
          }
          payload['credit_approval_id'] = credit if credit
          payload['einvoice_buyer'] = buyer if buyer.any?
          authorize = lambda do
            Tenders::Guard.authorize_editor!(workspace, staff)
            Tenders::Guard.authorize_collect!(workspace, staff)
            authorize_credit!(workspace, staff) if credit
          end
          CommandExecutor.call(store: workspace.store, actor: staff, key: key, payload: payload, workspace: workspace, authorize: authorize) do
            Tenders::Guard.validate_editor!(workspace, staff, revision, lease_generation, editor_id)
            Tenders::Guard.validate_open_shift!(workspace)
            SalesChannel.validate_uncommitted_order!(workspace)
            Tenders::Guard.tracked_guard!(workspace)
            order = workspace.order
            raise Conflict, 'Order has no items.' if order.line_items.empty?
            if TenderAttempt.where(workspace: workspace, status: TenderAttempt::UNRESOLVED).exists?
              raise Conflict, 'Unresolved tender attempts block completion.'
            end

            # A free order takes no receipt at all; giving goods away needs approval
            # authority and is audited separately rather than faking a zero Payment.
            zero_total = order.total.zero?
            if zero_total && !AccessPolicy.new(store: workspace.store, staff: staff).allows?(workspace.branch, Capabilities::APPROVE)
              raise CanCan::AccessDenied
            end

            allocated = FundsAllocation.where(workspace: workspace, status: 'active').sum(:amount)
            debt = credit ? credit_debt!(workspace, allocated) : BigDecimal('0')
            raise Conflict, 'Received funds do not cover the order total.' if allocated + debt < order.total
            raise Conflict, 'Allocated funds exceed the order total.' if allocated > order.total

            payments = order.payments.where(id: FundsAllocation.where(workspace: workspace, status: 'active').select(:payment_id)).to_a
            completed = payments.select { |payment| payment.status == 'completed' }.sum(&:amount)
            raise Conflict, 'Completed receipts do not cover the order total.' if completed + debt < order.total

            ensure_pickup_fulfillment!(workspace)
            unless StrictLocationGuard.call(order: order.reload, branch: workspace.branch)
              raise Conflict, 'Fulfillment does not belong to the branch stock location.'
            end

            entry = Credit::Commit.call(workspace: workspace, staff: staff, approval_id: credit, amount: debt) if credit
            # Core settles payments itself unless told they are pending; the
            # approved debt is the only reason this order may place short.
            # Placement allocates tracked stock too; the reservations become the
            # sale's committed allocations in the same transaction.
            result = StockIntegration.writing do
              Spree.order_complete_workflow.call(order: order.reload, notify_customer: false, payment_pending: debt.positive?)
            end
            raise Conflict, 'Order could not be placed.' unless result.success?
            raise Conflict, 'Order was not placed.' unless order.reload.placed?

            Inventory::AllocateTraceability.commit!(workspace)
            # Ingredients of menu recipes leave the shelf with the sale; a
            # short shelf is recorded, never a reason to refuse it.
            Recipes::Consume.call(workspace: workspace, actor: staff)

            workspace.update!(revision: workspace.revision + 1, operational_status: 'completed')
            AuditEntry.record!(store: workspace.store, actor: staff, subject: workspace, action: audit_action(entry, zero_total),
                               metadata: { order_id: order.prefixed_id, total: order.total.to_s('F'),
                                           receivable_id: entry&.prefixed_id, debt: debt.to_s('F') })
            OutboxEntry.record!(store: workspace.store, event_type: 'workspace.completed', aggregate: workspace,
                                payload: { 'workspace_id' => workspace.prefixed_id, 'order_id' => order.prefixed_id })
            # The e-invoice is queued with the sale and issued after it commits;
            # a provider that is down never stops the sale.
            Einvoices::Enqueue.call(workspace: workspace, staff: staff, buyer: buyer)
            ReceiptBuilder.issue_safely!(workspace, actor: staff) # receipt from the facts above; never blocks the sale
            workspace.to_pos
          end
        rescue Conflict => e
          # The refusal rolled back; the unusable reservations are released and
          # audited on their own so their exposure does not linger.
          Credit::Release.stale!(workspace: workspace, actor: staff) if e.reason == Credit::STALE
          # Credit switched off: the approved exposure is given back at once
          # rather than held until the approval expires.
          release_disabled_credit!(workspace, staff) if credit && e.reason == FeaturePolicy::DISABLED
          raise
        end

        def self.release_disabled_credit!(workspace, staff)
          ApplicationRecord.transaction do
            workspace.lock!
            Credit::Release.call(workspace: workspace, actor: staff, reason: 'feature_disabled')
          end
        end

        def self.authorize_credit!(workspace, staff)
          return if AccessPolicy.new(store: workspace.store, staff: staff).allows?(workspace.branch, Capabilities::CREDIT_SELL)

          raise CanCan::AccessDenied
        end

        def self.audit_action(credit_entry, zero_total)
          return 'workspace.complete_on_credit' if credit_entry
          return 'workspace.complete_zero_total' if zero_total

          'workspace.complete'
        end

        # The credit part is always the whole unpaid remainder, for an
        # identified customer; a free order has nothing to sell on credit.
        def self.credit_debt!(workspace, allocated)
          # Selling on credit can be switched off; paid sales never are.
          # Checked before any write of the command.
          FeaturePolicy.require!(workspace.branch, :credit)
          raise Conflict.new('Credit needs an identified customer.', reason: 'credit_customer_required') if workspace.pos_customer.nil?

          debt = workspace.order.total - allocated
          raise Conflict, 'Nothing remains to sell on credit.' unless debt.positive?

          debt
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
          method = Spree::DeliveryMethod.where(store_id: store.id, deleted_at: nil).
                   where('fulfillment_provider ILIKE ?', '%pickup%').order(:id).first
          return method if method

          Spree::DeliveryMethod.create!(store: store, name: 'POS pickup', fulfillment_provider: 'Spree::FulfillmentProvider::Pickup',
                                        display_on: 'back_end', storefront_visible: false)
        end
      end
    end
  end
end
