# frozen_string_literal: true

module Spree
  module Pos
    # Builds the immutable receipt snapshot of a posted source document from
    # the facts posted with it: SaleLine units and traceability, core line
    # amounts and discounts, receipts by method from allocation children,
    # approved debt from the receivable ledger, return reservations, refund
    # payouts and shift closures. Nothing is recomputed from client input
    # or from configuration that may change later; unit names, branch and
    # staff names are copied in as they are at issue time.
    #
    # Issuing never blocks or rolls back a posting: `issue_safely!` runs in
    # a savepoint inside the posting transaction and, on any error, reports
    # it and lets the posting commit without a snapshot. The next lookup of
    # a posted source without one builds it marked `issued_late`. A return
    # whose entitlement posts after its slip was printed as pending gets a
    # separate `return_supplement` slip.
    class ReceiptBuilder
      UNAVAILABLE = 'receipt_unavailable'
      TYPES = { Workspace => 'sale', ReturnOperation => 'return', RefundRequest => 'refund', ShiftClosure => 'shift_closure' }.freeze
      # Business details of `Spree::Store` printed in a receipt header. The
      # store has no tax code, so none is printed.
      STORE_PROFILE_FIELDS = %w[address contact_phone customer_support_email url facebook instagram].freeze

      # The store's printable details as they stand now, blank ones left out.
      def self.store_profile(store)
        STORE_PROFILE_FIELDS.each_with_object({}) do |field, profile|
          value = store.respond_to?(field) ? store.public_send(field).to_s.strip : ''
          profile[field] = value if value.present?
        end
      end

      def self.issue_safely!(source, actor:, type: nil)
        ReceiptSnapshot.transaction(requires_new: true) { issue!(source, actor: actor, type: type) }
      rescue StandardError => e
        Rails.error.report(e, handled: true, severity: :error,
                              context: { receipt_source: source.class.name, receipt_source_id: source.id, receipt_type: type })
        nil
      end

      def self.issue!(source, actor:, late: false, type: nil)
        type ||= TYPES.fetch(source.class) { raise ArgumentError, "No receipt for #{source.class.name}" }
        existing = ReceiptSnapshot.find_by(source_type: type, source_id: source.id)
        return existing if existing

        attributes = new(type, source).attributes.merge(issued_by: actor, issued_late: late, issued_at: Time.current)
        ReceiptSnapshot.transaction(requires_new: true) { ReceiptSnapshot.create!(attributes) }
      rescue ActiveRecord::RecordNotUnique
        # Only a concurrent issue of this same source is a replay; a clash on
        # the document number is a real error for the caller to report.
        ReceiptSnapshot.find_by(source_type: type, source_id: source.id) || raise
      end

      # After a return's entitlement posted later than its slip: one
      # supplementary slip with the posted credit note and refund figures.
      def self.issue_supplement_safely!(operation, actor:)
        slip = ReceiptSnapshot.find_by(source_type: 'return', source_id: operation.id)
        return if slip.nil? || slip.payload['entitlement_posted']

        issue_safely!(operation, actor: actor, type: 'return_supplement')
      end

      def self.for_source!(source, actor:)
        type = TYPES.fetch(source.class) { raise ArgumentError, "No receipt for #{source.class.name}" }
        raise Conflict.new('This document has no receipt until it is posted.', reason: UNAVAILABLE) unless posted?(type, source)

        ReceiptSnapshot.find_by(source_type: type, source_id: source.id) || issue!(source, actor: actor, late: true)
      end

      def self.posted?(type, record)
        case type
        when 'sale' then record.operational_status == 'completed' && record.order.completed?
        when 'return' then record.status == 'received'
        when 'refund' then record.status == 'confirmed'
        else true
        end
      end

      def initialize(type, record)
        @type = type
        @record = record
      end

      def attributes
        case type
        when 'sale' then sale
        when 'return' then return_slip
        when 'return_supplement' then return_supplement
        when 'refund' then refund_slip
        else closure_slip
        end
      end

      private

      attr_reader :type, :record

      def base(branch, register, number, title, at)
        store = branch.store
        {
          'kind' => type, 'title' => title, 'number' => number,
          'store' => { 'name' => store.name }.merge(self.class.store_profile(store)),
          'branch' => { 'name' => branch.name, 'code' => branch.code, 'return_window_days' => branch.return_window_days },
          'register' => register&.name,
          'timezone' => branch.timezone, 'at' => at&.iso8601
        }
      end

      def sale
        workspace = record
        order = workspace.order
        sale_lines = SaleLine.where(workspace_id: workspace.id).index_by(&:line_item_id)
        @traces = TraceAllocation.sold.where(sale_line_id: sale_lines.values.map(&:id)).includes(:serial_unit, :inventory_lot).
                  order(:id).group_by(&:sale_line_id)
        units = unit_names(workspace.store, sale_lines.values.flat_map { |row| [row.sale_unit_code, row.base_unit_code] })
        lines = order.line_items.includes(:discounts, variant: :product).sort_by(&:id).map do |line|
          sale_line(line, sale_lines[line.id], units)
        end
        payload = base(workspace.branch, workspace.register, order.number, 'PHIẾU BÁN HÀNG', order.completed_at).merge(
          'currency' => order.currency, 'cashier' => StaffName.call(workspace.shift.owner),
          'customer' => customer(workspace.pos_customer),
          'lines' => lines,
          'totals' => {
            'item_total' => money(order.item_total), 'discount_total' => money(order.discounts.sum(:amount)),
            'included_tax_total' => money(order.included_tax_total), 'additional_tax_total' => money(order.additional_tax_total),
            'total' => money(order.total)
          },
          'receipts' => receipts(workspace), 'credit' => credit(order), 'note' => workspace.note.presence
        )
        paid = payload['receipts'].sum { |row| BigDecimal(row['amount']) }
        payload['paid_total'] = money(paid)
        snapshot(workspace.branch, workspace.register, order.number, payload)
      end

      def sale_line(line, sale_line, units)
        discount = line.discounts.to_a.sum(&:amount)
        row = {
          'name' => line.variant.product.name, 'sku' => line.variant.sku.presence,
          'quantity' => line.quantity, 'unit_price' => money(line.price), 'amount' => money(line.amount),
          'discount' => money(discount), 'net_amount' => money(line.amount + discount), 'trace' => []
        }
        return row if sale_line.nil?

        sale_unit = units.fetch(sale_line.sale_unit_code, sale_line.sale_unit_code)
        base_unit = units.fetch(sale_line.base_unit_code, sale_line.base_unit_code)
        quantity = sale_line.sale_quantity.to_s('F').delete_suffix('.0')
        converted = sale_line.sale_unit_code != sale_line.base_unit_code
        row.merge(
          'sale_quantity' => quantity, 'sale_unit' => sale_unit,
          'base_quantity' => sale_line.base_quantity, 'base_unit' => base_unit,
          'unit_price' => money(sale_line.unit_price),
          'conversion' => converted ? "#{quantity} #{sale_unit} = #{sale_line.base_quantity} #{base_unit}" : nil,
          'trace' => trace(sale_line)
        )
      end

      # Serial/IMEI and lot/expiry sold on the line: its committed trace
      # allocations (the posted fact), or the sale line's own recorded codes
      # for lines sold without allocations.
      def trace(sale_line)
        rows = @traces.fetch(sale_line.id, [])
        if rows.any?
          return rows.map do |row|
            { 'serial' => row.serial_unit&.serial, 'lot_code' => row.inventory_lot&.lot_code,
              'expiry_on' => row.inventory_lot&.expiry_on&.iso8601, 'quantity' => row.quantity }.compact
          end
        end
        serials = Array(sale_line.serial_codes).map { |serial| { 'serial' => serial.to_s } }
        lot = sale_line.lot_code.present? ? [{ 'lot_code' => sale_line.lot_code, 'expiry_on' => sale_line.expiry_on&.iso8601 }.compact] : []
        serials + lot
      end

      # Receipts that paid this sale at the counter: allocation children of
      # its own received funds, not later debt collections.
      def receipts(workspace)
        FundsAllocation.where(workspace_id: workspace.id, status: 'active', collection_id: nil).
          includes(received_funds: { tender_attempt: :pos_payment_method }).order(:id).map do |allocation|
          funds = allocation.received_funds
          # A VietQR transfer is recorded as bank money but printed as VietQR.
          method = funds.tender_attempt&.pos_payment_method&.kind == 'vietqr' ? 'vietqr' : funds.kind
          row = { 'method' => method, 'amount' => money(allocation.amount) }
          if funds.kind == 'cash'
            row['handed'] = money(funds.handed_amount)
            row['change'] = money(funds.change_amount)
          else
            row['reference'] = Masking.reference(funds.reference)
          end
          row
        end
      end

      def credit(order)
        debit = ReceivableEntry.where(order_id: order.id, kind: 'debit').order(:id).first
        debit && { 'debt' => money(debit.amount), 'due_on' => debit.due_on&.iso8601 }
      end

      def return_slip
        operation = record
        posted = operation.entitlement_status == 'posted'
        rows = operation.reservations.where.not(status: 'canceled').includes(line_item: { variant: :product }).order(:id)
        lines = rows.map do |row|
          { 'name' => row.line_item.variant.product.name, 'sku' => row.line_item.variant.sku.presence,
            'quantity' => row.received_quantity || row.quantity, 'condition' => row.condition, 'amount' => money(row.total) }
        end
        payload = base(operation.branch, nil, operation.core_return.number, 'PHIẾU TRẢ HÀNG', operation.received_at).merge(
          'currency' => operation.currency, 'cashier' => StaffName.call(operation.receiver || operation.requester),
          'order_number' => operation.order.number, 'reason' => operation.reason,
          'customer' => customer(operation.workspace.pos_customer),
          'lines' => lines,
          'entitlement_posted' => posted, 'entitlement_total' => money(operation.entitlement_total),
          'credit_note_amount' => posted ? money(operation.credit_note_amount) : nil,
          'refund_entitlement' => posted ? money(operation.refund_entitlement) : nil
        )
        snapshot(operation.branch, nil, operation.core_return.number, payload)
      end

      def return_supplement
        operation = record
        number = "#{operation.core_return.number}-BS"
        payload = base(operation.branch, nil, number, 'PHIẾU BỔ SUNG TRẢ HÀNG', operation.posted_at).merge(
          'currency' => operation.currency, 'order_number' => operation.order.number,
          'return_number' => operation.core_return.number, 'customer' => customer(operation.workspace.pos_customer),
          'entitlement_posted' => true, 'entitlement_total' => money(operation.entitlement_total),
          'credit_note_amount' => money(operation.credit_note_amount), 'refund_entitlement' => money(operation.refund_entitlement)
        )
        snapshot(operation.branch, nil, number, payload)
      end

      def refund_slip
        request = record
        number = "HT#{request.id.to_s.rjust(6, '0')}"
        evidence = request.payout_evidences.order(:id).last
        payload = base(request.branch, request.shift&.register, number, 'PHIẾU HOÀN TIỀN', request.confirmed_at).merge(
          'currency' => request.currency, 'cashier' => StaffName.call(request.confirmer),
          'order_number' => request.order.number, 'return_number' => request.return_operation.core_return.number,
          'customer' => customer(request.return_operation.workspace.pos_customer),
          'method' => request.method, 'amount' => money(request.amount),
          'reference' => Masking.reference(evidence&.reference.presence || request.beneficiary_reference)
        )
        snapshot(request.branch, request.shift&.register, number, payload)
      end

      def closure_slip
        closure = record
        number = "DC#{closure.id.to_s.rjust(6, '0')}"
        payload = base(closure.branch, closure.register, number, 'PHIẾU ĐÓNG CA', closure.closed_at).merge(
          'currency' => closure.currency, 'cashier' => StaffName.call(closure.shift.owner),
          'closer' => StaffName.call(closure.closer), 'approver' => StaffName.call(closure.approver),
          'opened_at' => closure.opened_at.iso8601, 'closed_at' => closure.closed_at.iso8601,
          'opening_float' => money(closure.opening_float), 'inflow_total' => money(closure.inflow_total),
          'outflow_total' => money(closure.outflow_total), 'expected' => money(closure.expected),
          'counted' => money(closure.counted), 'variance' => money(closure.variance), 'reason' => closure.reason,
          'breakdown' => closure.breakdown
        )
        snapshot(closure.branch, closure.register, number, payload)
      end

      def snapshot(branch, register, number, payload)
        { store_id: branch.store_id, branch: branch, register: register, source_type: type, source_id: record.id,
          number: number, payload: payload }
      end

      def customer(profile)
        profile && { 'name' => profile.name, 'phone' => profile.phone }
      end

      def unit_names(store, codes)
        UnitDefinition.for_store(store).where(code: codes.compact.uniq).pluck(:code, :name).to_h
      end

      def money(value)
        BigDecimal((value || 0).to_s).to_s('F')
      end
    end
  end
end
