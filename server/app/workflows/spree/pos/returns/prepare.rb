# frozen_string_literal: true

module Spree
  module Pos
    module Returns
      # Opens a return of handed-over units of a placed POS sale at the staff
      # member's branch. Quantities are reserved per immutable SaleLine under
      # the SaleLine row locks, in sequence, each with its cumulative
      # entitlement delta; core `Spree::Returns::Create` records the same units
      # against the original fulfillment items (and re-checks them under the
      # order lock). Nothing is restocked and no money is granted here.
      #
      # Cross-branch, out-of-window and damaged returns wait for an approval.
      # `preview` computes the same plan without locks or writes.
      class Prepare
        CONDITIONS = %w[resellable damaged].freeze
        MAX_LINES = 100

        def self.call(store:, staff:, key:, branch_id:, order_id:, lines:, reason:)
          rows = normalize(lines)
          payload = { 'command' => 'return.prepare', 'branch_id' => branch_id.to_s, 'order_id' => order_id.to_s,
                      'lines' => rows, 'reason' => reason.to_s.strip }
          authorize = -> { Guard.authorize_return!(store, staff, Guard.branch!(store, branch_id)) }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: authorize) do
            branch = Guard.branch!(store, branch_id)
            FeaturePolicy.require!(branch, :returns)
            raise Conflict, 'A return reason is required.' if reason.to_s.strip.blank?

            workspace = Guard.sale!(store, order_id)
            plan = build(workspace: workspace, branch: branch, rows: rows, lock: true)
            operation = persist!(store: store, staff: staff, branch: branch, workspace: workspace, plan: plan,
                                 reason: reason.to_s.strip[0, 200])
            AuditEntry.record!(store: store, actor: staff, action: 'return.prepare', subject: operation,
                               metadata: { order_id: workspace.order.prefixed_id, entitlement: operation.entitlement_total.to_s('F'),
                                           requires_approval: operation.requires_approval })
            OutboxEntry.record!(store: store, event_type: 'return.prepared', aggregate: operation,
                                payload: { 'return_id' => operation.prefixed_id })
            operation.to_pos
          end
        end

        # Read-only plan for the wizard; the same arithmetic as `call`.
        def self.preview(store:, staff:, branch_id:, order_id:, lines:)
          branch = Guard.branch!(store, branch_id)
          Guard.authorize_return!(store, staff, branch)
          workspace = Guard.sale!(store, order_id)
          plan = build(workspace: workspace, branch: branch, rows: normalize(lines), lock: false)
          serialize(plan)
        end

        def self.normalize(lines)
          list = lines.respond_to?(:to_unsafe_h) ? lines.to_unsafe_h.values : Array(lines)
          rows = list.map do |row|
            row = (row.respond_to?(:to_unsafe_h) ? row.to_unsafe_h : row.to_h).with_indifferent_access
            quantity = row[:quantity]
            quantity = Integer(quantity.to_s, 10) if quantity.to_s.match?(/\A\d{1,9}\z/)
            serials = row[:serial_codes].respond_to?(:map) ? row[:serial_codes].map(&:to_s) : []
            # No default here: tracked goods need an explicit condition (see build).
            { 'sale_line_id' => row[:sale_line_id].to_s, 'quantity' => quantity, 'condition' => row[:condition].to_s.presence,
              'serial_codes' => serials, 'lot_code' => row[:lot_code].to_s.strip.presence }
          end
          raise Conflict, 'At least one line is required.' if rows.empty?
          raise Conflict, 'Too many lines in one return.' if rows.length > MAX_LINES
          raise Conflict, 'Each sale line can appear once per return.' if rows.map { |row| row['sale_line_id'] }.uniq.length != rows.length

          rows.each do |row|
            unless row['quantity'].is_a?(Integer) && row['quantity'].positive?
              raise Conflict,
                    'Return quantity must be a positive whole number of base units.'
            end
            raise Conflict, 'Condition is invalid.' unless row['condition'].nil? || CONDITIONS.include?(row['condition'])
          end
          rows
        end

        Plan = Struct.new(:workspace, :branch, :order, :lines, :cross_branch, :out_of_window, :damaged, :total, :split,
                          keyword_init: true) do
          def requires_approval
            cross_branch || out_of_window || damaged
          end
        end
        # One sale line of the return. A line shipped in several fulfillment
        # items is returned in chunks, one per item, each a reservation at its
        # own position in the line's sequence; together they cover exactly
        # `cumulative_before..cumulative_after`.
        PlanLine = Struct.new(:sale_line, :line_item, :quantity, :condition, :chunks,
                              :cumulative_before, :cumulative_after, :delta, :original, :used, :reserved, :remaining,
                              :trace_picks, keyword_init: true)
        Chunk = Struct.new(:fulfillment_item, :quantity, :sequence, :before, :after, :delta, keyword_init: true)

        def self.build(workspace:, branch:, rows:, lock:)
          raise Conflict.new('Returns are not enabled at this branch.', reason: 'returns_disabled') unless branch.returns_enabled?

          order = workspace.order
          raise Conflict, 'Order is not placed.' unless order.completed? && !order.canceled?
          raise Conflict, 'Order currency does not match the store.' if order.currency != workspace.store.default_currency

          ids = rows.map { |row| SaleLine.locate(SaleLine.where(workspace_id: workspace.id), row['sale_line_id'])&.id }
          raise ActiveRecord::RecordNotFound if ids.any?(&:nil?)

          sale_lines = (lock ? Guard.lock_sale_lines!(ids) : SaleLine.where(id: ids).to_a).index_by(&:id)
          entitlement = ReturnEntitlement.new(order)
          lines = rows.each_with_index.map do |row, index|
            sale_line = sale_lines.fetch(ids[index])
            Inventory::ReturnTraceability.ensure_receivable!(branch, sale_line)
            if row['condition'].nil?
              # Tracked units go back to stock or quarantine on the cashier's
              # explicit word; the preview may still show a resellable estimate.
              if lock && Inventory::ReturnTraceability.tracked?(sale_line)
                raise Conflict.new('Choose the condition of the returned tracked units.', reason: 'trace_condition_required')
              end

              row = row.merge('condition' => 'resellable')
            end
            line = plan_line(sale_line, row, entitlement)
            # Serial/lot identity of the returned units, from the original allocations.
            line.trace_picks = Inventory::ReturnTraceability.plan(sale_line, line.quantity, serial_codes: row['serial_codes'],
                                                                                            lot_code: row['lot_code'], lock: lock)
            line
          end
          total = lines.sum(BigDecimal('0')) { |line| line.delta.total }
          Plan.new(workspace: workspace, branch: branch, order: order, lines: lines,
                   cross_branch: workspace.branch_id != branch.id, out_of_window: Guard.out_of_window?(order, branch),
                   damaged: lines.any? { |line| line.condition == 'damaged' }, total: total, split: Guard.split(order, total))
        end

        def self.plan_line(sale_line, row, entitlement)
          line_item = sale_line.line_item
          existing = ReturnReservation.where(sale_line_id: sale_line.id)
          holding = existing.holding.to_a
          returned = holding.sum(&:quantity)
          quantity = row['quantity']
          remaining = sale_line.base_quantity - returned
          if quantity > remaining
            raise Conflict.new("Only #{[remaining, 0].max} units of this line can still be returned.",
                               reason: 'exceeds_returnable')
          end

          chunks = chunks_for(sale_line, quantity, returned, (existing.maximum(:sequence) || 0) + 1, entitlement)
          used = holding.select { |item| item.status == 'posted' }.sum(BigDecimal('0'), &:total)
          reserved = holding.select { |item| item.status == 'reserved' }.sum(BigDecimal('0'), &:total)
          PlanLine.new(
            sale_line: sale_line, line_item: line_item, quantity: quantity, condition: row['condition'], chunks: chunks,
            cumulative_before: returned, cumulative_after: returned + quantity,
            delta: entitlement.delta(line_item, sale_line.base_quantity, returned, returned + quantity),
            original: entitlement.original(line_item), used: used, reserved: reserved, remaining: remaining
          )
        end

        # Only units that actually left the shelf can come back to it. Units
        # are taken from the line's shipped fulfillment items in id order, each
        # up to what core still lets come back from that item.
        def self.chunks_for(sale_line, quantity, returned, sequence, entitlement)
          items = Spree::FulfillmentItem.joins(:fulfillment).
                  where(line_item_id: sale_line.line_item_id, order_id: sale_line.order_id).
                  where(spree_fulfillments: { status: 'fulfilled' }).order(:id).to_a
          raise Conflict.new('These goods were not handed over yet.', reason: 'not_handed_over') if items.empty?

          taken = Spree::ReturnLineItem.joins(:return).where(fulfillment_item_id: items.map(&:id)).
                  where.not(Spree::Return.table_name => { status: 'canceled' }).group(:fulfillment_item_id).sum(:quantity)
          left = quantity
          position = returned
          chunks = items.filter_map do |item|
            take = [item.quantity.to_i - taken.fetch(item.id, 0), left].min
            next if take <= 0

            left -= take
            chunk = Chunk.new(fulfillment_item: item, quantity: take, sequence: sequence, before: position, after: position + take,
                              delta: entitlement.delta(sale_line.line_item, sale_line.base_quantity, position, position + take))
            position += take
            sequence += 1
            chunk
          end
          if left.positive?
            raise Conflict.new("Only #{quantity - left} handed-over units of this line can still be returned.",
                               reason: 'exceeds_returnable')
          end

          chunks
        end

        def self.persist!(store:, staff:, branch:, workspace:, plan:, reason:)
          order = plan.order
          result = Spree::Returns::Create.call(
            order: order, stock_location: branch.stock_location, memo: reason, created_by: staff,
            items: plan.lines.flat_map { |line| line.chunks.map { |chunk| { fulfillment_item: chunk.fulfillment_item, quantity: chunk.quantity } } }
          )
          raise Conflict.new(Guard.core_error(result, 'Core return was refused.'), reason: 'core_return_refused') unless result.success?

          core = result.value
          operation = ReturnOperation.create!(
            store: store, branch: branch, sale_branch: workspace.branch, workspace: workspace, order: order,
            core_return: core, requester: staff, reason: reason, currency: order.currency,
            status: plan.requires_approval ? 'pending_approval' : 'ready', entitlement_status: 'pending',
            cross_branch: plan.cross_branch, out_of_window: plan.out_of_window, damaged: plan.damaged,
            requires_approval: plan.requires_approval, entitlement_total: plan.total
          )
          core_lines = core.return_line_items.index_by(&:fulfillment_item_id)
          plan.lines.each do |line|
            line.chunks.each do |chunk|
              ReturnReservation.create!(
                store: store, return_operation: operation, sale_line: line.sale_line, line_item: line.line_item,
                fulfillment_item: chunk.fulfillment_item, return_line_item: core_lines.fetch(chunk.fulfillment_item.id),
                quantity: chunk.quantity, sequence: chunk.sequence, cumulative_before: chunk.before,
                cumulative_after: chunk.after, condition: line.condition, status: 'reserved', **chunk.delta.to_h
              )
            end
            Inventory::ReturnTraceability.reserve!(operation, line.trace_picks, line.condition)
          end
          operation
        end

        def self.serialize(plan)
          {
            order_id: plan.order.prefixed_id, order_number: plan.order.number, currency: plan.order.currency,
            sale_branch_id: plan.workspace.branch.prefixed_id, branch_id: plan.branch.prefixed_id,
            cross_branch: plan.cross_branch, out_of_window: plan.out_of_window, damaged: plan.damaged,
            requires_approval: plan.requires_approval,
            entitlement_total: plan.total.to_s('F'), credit_note: plan.split[:credit_note].to_s('F'),
            refund: plan.split[:refund].to_s('F'),
            # Value returned that is neither credited to debt nor refundable:
            # nothing was received for it beyond what other returns already got.
            unrefundable: (plan.total - plan.split[:credit_note] - plan.split[:refund]).to_s('F'),
            lines: plan.lines.map do |line|
              {
                sale_line_id: line.sale_line.prefixed_id, quantity: line.quantity, condition: line.condition,
                sold_quantity: line.sale_line.base_quantity, cumulative_before: line.cumulative_before,
                cumulative_after: line.cumulative_after, remaining_before: line.remaining,
                original: line.original.to_pos, used: line.used.to_s('F'), reserved: line.reserved.to_s('F'),
                this_time: line.delta.to_pos,
                trace: Inventory::ReturnTraceability.preview_pos(line.sale_line, line.trace_picks, plan.branch)
              }
            end
          }
        end
      end
    end
  end
end
