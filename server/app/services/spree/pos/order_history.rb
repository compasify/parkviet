# frozen_string_literal: true

module Spree
  module Pos
    # Read model of placed POS sales for the Orders screen. Every figure comes
    # from its own ledger: the original total from the order, receipts and
    # refunds from allocation children and core Refunds, debt from the
    # receivable ledger, entitlement from return reservations, stock from
    # fulfillments, restocks and recorded shortfalls. Nothing is derived from
    # core amount_due or payment_status.
    class OrderHistory
      STATUSES = %w[all debt returned refund_pending].freeze

      def initialize(store:, branch:)
        @store = store
        @branch = branch
      end

      # Completed workspaces of the branch, filtered server-side. Dates are
      # calendar days in the branch timezone.
      def scope(number: nil, from: nil, to: nil, register_id: nil, cashier_id: nil, status: nil)
        relation = Workspace.for_store(store).where(branch_id: branch.id, operational_status: 'completed').
                   joins(:order).includes(:order, :register, :pos_customer, shift: :owner)
        if number.present?
          term = ActiveRecord::Base.sanitize_sql_like(number.to_s.strip.upcase.first(64))
          relation = relation.where('UPPER(spree_orders.number) LIKE ?', "%#{term}%")
        end
        zone = ActiveSupport::TimeZone[branch.timezone] || Time.zone
        relation = relation.where(spree_orders: { completed_at: zone.parse(from.to_s).beginning_of_day.. }) if date?(from)
        relation = relation.where(spree_orders: { completed_at: ..zone.parse(to.to_s).end_of_day }) if date?(to)
        if register_id.present?
          register = Register.locate(Register.for_store(store).where(branch_id: branch.id), register_id)
          relation = relation.where(register_id: register&.id || 0)
        end
        if cashier_id.present?
          staff = Spree.admin_user_class.find_by_prefix_id(cashier_id.to_s)
          relation = relation.where(shift_id: Shift.where(owner_id: staff&.id || 0).select(:id))
        end
        filter_status(relation, status.presence || 'all').order('spree_orders.completed_at DESC, spree_pos_workspaces.id DESC')
      end

      # List rows with every per-order figure loaded in a few batched queries.
      def rows(workspaces, mask:)
        lookups = lookups_for(workspaces.map(&:order_id))
        workspaces.map { |workspace| row(workspace, mask: mask, lookups: lookups) }
      end

      def row(workspace, mask:, lookups: nil)
        lookups ||= lookups_for([workspace.order_id])
        order = workspace.order
        debt = lookups[:debt][order.id]
        {
          id: order.prefixed_id, number: order.number, workspace_id: workspace.prefixed_id,
          order_source: workspace.order_source,
          placed_at: order.completed_at&.iso8601, register: workspace.register&.name,
          cashier: staff_name(workspace.shift.owner), cashier_id: workspace.shift.owner.prefixed_id,
          customer: customer(workspace, mask),
          currency: order.currency, total: money(order.total), paid: money(lookups[:paid][order.id]),
          debt: debt.nil? ? nil : money(debt),
          returned: lookups[:returned].include?(order.id),
          refund_pending: lookups[:refund_pending].include?(order.id)
        }
      end

      # `mask` hides customer contact details, `mask_references` payment
      # references (receipt and beneficiary references).
      def detail(workspace, mask:, mask_references: true)
        order = workspace.order
        entitlement = ReturnEntitlement.new(order)
        sale_lines = SaleLine.where(workspace_id: workspace.id).includes(line_item: { variant: :product }).order(:id).to_a
        reservations = ReturnReservation.where(sale_line_id: sale_lines.map(&:id)).where.not(status: 'canceled').to_a.group_by(&:sale_line_id)
        shipped = Spree::FulfillmentItem.joins(:fulfillment).where(order_id: order.id, spree_fulfillments: { status: 'fulfilled' }).
                  pluck(:line_item_id).to_set
        operations = ReturnOperation.where(order_id: order.id).includes(:branch, :sale_branch, :order, :core_return, :requester,
                                                                        :approval, :refund_requests).order(:id).to_a
        allocations = FundsAllocation.where(order_id: order.id).includes(:received_funds, :payment).order(:id).to_a
        refunds = RefundRequest.where(order_id: order.id).includes(:order, :return_operation, :received_funds, :funds_allocation,
                                                                   :branch, :requester, :confirmer, :shift, :refund,
                                                                   :approval, :payout_evidences).order(:id).to_a
        receivable = ReceivableEntry.where(order_id: order.id).order(:id).to_a
        row(workspace, mask: mask).merge(
          sale_branch_id: workspace.branch.prefixed_id,
          totals: {
            original_total: money(order.total), item_total: money(order.item_total),
            discount_total: money(order.discounts.sum(:amount)), tax_total: money(order.additional_tax_total + order.included_tax_total)
          },
          lines: sale_lines.map { |sale_line| line(sale_line, entitlement, reservations.fetch(sale_line.id, []), shipped) },
          entitlement: {
            used: money(operations.select { |op| op.entitlement_status == 'posted' }.sum(&:entitlement_total)),
            reserved: money(operations.select { |op| %w[pending awaiting_predecessor].include?(op.entitlement_status) }.sum(&:entitlement_total)),
            credit_notes: money(operations.sum(&:credit_note_amount)), refund_entitlement: money(operations.sum(&:refund_entitlement))
          },
          receipts: allocations.map { |allocation| receipt(allocation, mask_references) },
          refunds: refunds.map { |refund| refund.to_pos(mask: mask_references) },
          credit: credit(receivable),
          returns: operations.map(&:to_row),
          exchanges: ExchangeOperation.where(return_operation_id: operations.map(&:id)).or(
            ExchangeOperation.where(replacement_workspace_id: workspace.id)
          ).map(&:to_pos),
          stock: stock(order, operations),
          timeline: timeline(order, allocations, receivable, operations, refunds)
        )
      end

      private

      attr_reader :store, :branch

      def date?(value)
        value.to_s.match?(/\A\d{4}-\d{2}-\d{2}\z/) && Date.valid_date?(*value.to_s.split('-').map(&:to_i))
      end

      def filter_status(relation, status)
        raise Conflict, 'Status filter is invalid.' unless STATUSES.include?(status)

        case status
        when 'debt'
          open = ReceivableEntry.group(:order_id).having(Arel.sql("SUM(#{ReceivableEntry::SIGNED_SQL}) > 0")).select(:order_id)
          relation.where(order_id: open)
        when 'returned'
          relation.where(order_id: ReturnOperation.where.not(status: 'canceled').select(:order_id))
        when 'refund_pending'
          relation.where(order_id: RefundRequest.reserving.select(:order_id))
        else relation
        end
      end

      def paid(order)
        FundsAllocation.where(order_id: order.id, status: 'active').sum(:amount)
      end

      def line(sale_line, entitlement, rows, shipped)
        posted = rows.select { |row| row.status == 'posted' }
        held = rows.sum(&:quantity)
        line_item = sale_line.line_item
        {
          sale_line_id: sale_line.prefixed_id, name: line_item.variant.product.name, sku: line_item.variant.sku,
          sale_quantity: sale_line.sale_quantity.to_s('F'), sale_unit: sale_line.sale_unit_code,
          base_quantity: sale_line.base_quantity, base_unit: sale_line.base_unit_code, unit_price: sale_line.unit_price.to_s('F'),
          lot_code: sale_line.lot_code, serial_codes: Array(sale_line.serial_codes),
          trace: Inventory::ReturnTraceability.sold_pos(sale_line),
          original: entitlement.original(line_item).to_pos,
          returned_quantity: held, posted_quantity: posted.sum(&:quantity),
          returnable_quantity: shipped.include?(line_item.id) ? sale_line.base_quantity - held : 0,
          handed_over: shipped.include?(line_item.id),
          entitlement_used: money(posted.sum(BigDecimal('0'), &:total)),
          entitlement_reserved: money((rows - posted).sum(BigDecimal('0'), &:total))
        }
      end

      def lookups_for(order_ids)
        {
          paid: FundsAllocation.where(order_id: order_ids, status: 'active').group(:order_id).sum(:amount),
          debt: ReceivableEntry.where(order_id: order_ids).group(:order_id).sum(Arel.sql(ReceivableEntry::SIGNED_SQL)),
          returned: ReturnOperation.where(order_id: order_ids).where.not(status: 'canceled').distinct.pluck(:order_id).to_set,
          refund_pending: RefundRequest.reserving.where(order_id: order_ids).distinct.pluck(:order_id).to_set
        }
      end

      def receipt(allocation, mask_references)
        funds = allocation.received_funds
        refunded = allocation.payment_id ? Spree::Refund.where(payment_id: allocation.payment_id).sum(:amount) : BigDecimal('0')
        {
          allocation_id: allocation.prefixed_id, funds_id: funds.prefixed_id, kind: funds.kind, status: allocation.status,
          amount: money(allocation.amount), refunded: money(refunded),
          refund_reserved: money(RefundRequest.reserving.where(funds_allocation_id: allocation.id).sum(:amount)),
          refundable: money(allocation.refundable), collection: allocation.collection_id.present?,
          reference: mask_references ? Masking.reference(funds.reference) : funds.reference, received_at: funds.received_at&.iso8601
        }
      end

      def credit(entries)
        return nil if entries.none? { |entry| entry.kind == 'debit' }

        sums = entries.group_by(&:kind).transform_values { |rows| rows.sum(&:amount) }
        {
          debt: money(sums['debit']), credit_notes: money(sums['credit_note']),
          collected: money(sums.fetch('collection', 0) - sums.fetch('collection_reversal', 0)),
          balance: money(ReceivableEntry.balance_sum(ReceivableEntry.where(id: entries.map(&:id)))),
          due_on: entries.find { |entry| entry.kind == 'debit' }&.due_on&.iso8601
        }
      end

      def stock(order, operations)
        restocked = ReturnReservation.where(return_operation_id: operations.map(&:id)).where.not(status: 'canceled')
        {
          location_id: branch.stock_location.prefixed_id,
          fulfillments: order.fulfillments.order(:id).map do |fulfillment|
            { id: fulfillment.prefixed_id, status: fulfillment.status, location_id: fulfillment.stock_location.prefixed_id,
              fulfilled_at: fulfillment.fulfilled_at&.iso8601 }
          end,
          restocked_quantity: restocked.sum(:restocked_quantity),
          damaged_quantity: restocked.sum(:received_quantity) - restocked.sum(:restocked_quantity),
          discrepancies: StockDiscrepancy.where(order_id: order.id).order(:id).map(&:to_pos)
        }
      end

      def timeline(order, allocations, receivable, operations, refunds)
        # Each event carries a stable id: the fact it comes from plus the kind.
        event = lambda { |source, at, kind, amount, reference = nil|
          { id: "#{source.prefixed_id}:#{kind}", at: at, kind: kind, amount: amount, reference: reference }
        }
        events = [event.call(order, order.completed_at, 'placed', money(order.total))]
        allocations.each { |row| events << event.call(row, row.created_at, row.collection_id ? 'collection' : 'receipt', money(row.amount)) }
        order.fulfillments.where(status: 'fulfilled').find_each { |row| events << event.call(row, row.fulfilled_at, 'handed_over', nil) }
        receivable.each { |row| events << event.call(row, row.created_at, "receivable_#{row.kind}", money(row.amount)) }
        operations.each do |op|
          number = op.core_return.number
          events << event.call(op, op.created_at, 'return_prepared', money(op.entitlement_total), number)
          events << event.call(op, op.received_at, 'return_received', nil, number) if op.received_at
          events << event.call(op, op.canceled_at, 'return_canceled', nil, number) if op.canceled_at
        end
        refunds.each do |row|
          events << event.call(row, row.created_at, 'refund_requested', money(row.amount))
          events << event.call(row, row.confirmed_at, 'refund_paid', money(row.amount)) if row.confirmed_at
          events << event.call(row, row.resolved_at, "refund_#{row.status}", money(row.amount)) if row.resolved_at
        end
        events.select { |event| event[:at] }.sort_by { |event| event[:at] }.map { |event| event.merge(at: event[:at].iso8601) }
      end

      def customer(workspace, mask)
        profile = workspace.pos_customer
        return nil if profile.nil?

        ReceivableProjection.customer(profile, mask)
      end

      def staff_name(staff)
        staff.try(:full_name).presence || staff.email.to_s.split('@').first
      end

      def money(value)
        BigDecimal((value || 0).to_s).to_s('F')
      end
    end
  end
end
