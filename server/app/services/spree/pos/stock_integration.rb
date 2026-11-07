# frozen_string_literal: true

module Spree
  module Pos
    # Keeps typed traceability (serial units, lots) and the core shelf of an
    # enrolled (variant, stock location) pair in step.
    #
    # Spree stays the writer of aggregate quantities. Every POS workflow that
    # moves stock of a tracked pair runs its core write inside `writing`, in
    # the same transaction as the typed change. Any other core writer of an
    # enrolled pair (dashboard stock edits, stock feeds/imports, core
    # transfers and receipts, website checkout placement and dispatch, core
    # returns) is refused by the guards installed on Spree::StockMovement and
    # Spree::StockLevel (see the decorators), before the row is written.
    # Releasing an allocation is the one core write let through: it changes
    # no physical stock and lets a core order cancel cleanly.
    module StockIntegration
      STATE_KEY = :spree_pos_trace_writer
      REFUSAL = 'is tracked by serial or lot at this location; change its stock through the POS inventory workflows.'

      module_function

      # Marks core stock writes made by a POS trace workflow.
      def writing
        depth = ActiveSupport::IsolatedExecutionState[STATE_KEY].to_i
        ActiveSupport::IsolatedExecutionState[STATE_KEY] = depth + 1
        yield
      ensure
        ActiveSupport::IsolatedExecutionState[STATE_KEY] = depth
      end

      def writing?
        ActiveSupport::IsolatedExecutionState[STATE_KEY].to_i.positive?
      end

      def enrolled?(variant_id, stock_location_id)
        return false if variant_id.nil? || stock_location_id.nil?

        TraceEnrollment.exists?(variant_id: variant_id, stock_location_id: stock_location_id)
      end

      # The message a refused core writer gets, or nil when the write may go on.
      # Releasing an allocation is let through unless POS still holds sold
      # serial/lot units for that fulfillment: a core cancel would otherwise
      # free the shelf while the typed units stay sold.
      def movement_refusal(movement)
        return nil if writing?

        level = movement.stock_level
        return nil if level.nil? || !TraceCurrent.enrolled?(level.variant_id, level.stock_location_id)
        return nil if movement.kind == 'released' && !committed_trace?(movement.fulfillment_id)

        "#{level.variant&.sku || 'Variant'} #{REFUSAL}"
      end

      def committed_trace?(fulfillment_id)
        return false if fulfillment_id.nil?

        TraceAllocation.where(status: 'committed',
                              fulfillment_item_id: Spree::FulfillmentItem.where(fulfillment_id: fulfillment_id).select(:id)).exists?
      end

      def level_refusal(level)
        return nil if writing? || !TraceCurrent.enrolled?(level.variant_id, level.stock_location_id)

        "#{level.variant&.sku || 'Variant'} #{REFUSAL}"
      end

      def variant_unit(store_id, variant)
        VariantUnit.find_by(store_id: store_id, variant_id: variant.id, status: 'active')
      end

      def tracked_mode(store_id, variant)
        mode = variant_unit(store_id, variant)&.tracked_mode
        %w[serial lot].include?(mode) ? mode : 'none'
      end

      def base_unit_code(variant)
        VariantUnit.find_by(variant_id: variant.id, status: 'active')&.base_unit&.code || 'item'
      end

      def core_on_hand(variant, stock_location)
        Spree::StockLevel.find_by(variant_id: variant.id, stock_location_id: stock_location.id)&.count_on_hand || 0
      end

      # Units the typed records say are on the shelf at the location.
      def typed_on_hand(mode, variant, stock_location)
        if mode == 'lot'
          InventoryLot.where(variant_id: variant.id, stock_location_id: stock_location.id).sum('on_hand + quarantined_quantity').to_i
        else
          units = SerialUnit.where(variant_id: variant.id, stock_location_id: stock_location.id)
          sold_on_shelf = units.where(status: 'sold').
                          where(id: TraceAllocation.where(status: 'committed').select(:serial_unit_id)).count
          units.where(status: SerialUnit::ON_SHELF).count + sold_on_shelf
        end
      end

      # Whether `branch` may sell this tracked variant now, and why not.
      # `memo` (a Hash) lets a reader of many lines ask once per variant.
      def blocked_reason(branch, variant, mode = tracked_mode(branch.store_id, variant), memo: nil)
        return 'not_tracked' if mode == 'none'
        return memo[[branch.id, variant.id, mode]] if memo&.key?([branch.id, variant.id, mode])

        location = branch.stock_location
        reason = if !enrolled?(variant.id, location.id)
                   'not_enrolled'
                 elsif typed_on_hand(mode, variant, location) != core_on_hand(variant, location)
                   'unreconciled'
                 end
        memo[[branch.id, variant.id, mode]] = reason if memo
        reason
      end

      # Raised before a tracked variant goes onto, or is paid on, a sale.
      def ensure_sellable!(branch, variant, mode)
        case blocked_reason(branch, variant, mode)
        when 'not_enrolled'
          raise Conflict.new('Tracked stock of this item has no opening balance at this branch yet.', reason: 'trace_not_enrolled')
        when 'unreconciled'
          raise Conflict.new('Tracked stock of this item does not match the shelf count at this branch; it needs a count first.',
                             reason: 'trace_unreconciled')
        end
      end

      def status(branch, variant, with_lots: true)
        location = branch.stock_location
        mode = tracked_mode(branch.store_id, variant)
        unit = variant_unit(branch.store_id, variant)
        enrolled = mode != 'none' && enrolled?(variant.id, location.id)
        typed = enrolled ? typed_on_hand(mode, variant, location) : nil
        core = core_on_hand(variant, location)
        reason = blocked_reason(branch, variant, mode)
        {
          branch_id: branch.prefixed_id,
          variant_id: variant.prefixed_id, sku: variant.sku, name: variant.product.name, tracked_mode: mode,
          stock_location_id: location.prefixed_id, base_unit: unit&.base_unit&.code || 'item', sale_unit: unit&.sale_unit&.code || 'item',
          enrolled: enrolled, reconciled: enrolled && typed == core, sellable: mode != 'none' && reason.nil?,
          blocked_reason: mode == 'none' ? 'not_tracked' : reason, core_on_hand: core, typed_on_hand: typed,
          lot_selection: branch.lot_selection,
          lots: with_lots && mode == 'lot' ? sellable_lots(variant, location, today(branch)) : [],
          serials_available: mode == 'serial' ? SerialUnit.where(variant_id: variant.id, stock_location_id: location.id, status: 'in_stock').count : 0
        }
      end

      def sellable_lots(variant, location, today)
        rows = FefoAllocator.candidates(variant, location, today).map { |lot| lot.to_pos(today: today) }
        rows.select { |lot| lot[:available].positive? }
      end

      # Detection for writers no guard can see (raw SQL, bulk updates). Both
      # counts are read under a share lock on the stock level, so a trace
      # writer (which holds it for update) is never caught half-way. Each
      # drift episode raises attention once: the signature of the counts is
      # kept until the pair is reconciled again, and a pair whose shelf did
      # not move since the last check is skipped (`skip_unchanged`).
      def check_drift!(enrollment, skip_unchanged: false)
        ApplicationRecord.transaction do
          level = Spree::StockLevel.where(variant_id: enrollment.variant_id, stock_location_id: enrollment.stock_location_id).
                  lock('FOR SHARE').first
          enrollment.lock!
          next if skip_unchanged && enrollment.drift_signature.present? && enrollment.drift_checked_at &&
            (level.nil? || level.updated_at <= enrollment.drift_checked_at)

          typed = typed_on_hand(enrollment.tracked_mode, enrollment.variant, enrollment.stock_location)
          core = level&.count_on_hand || 0
          signature = typed == core ? nil : "#{typed}:#{core}"
          if signature && signature != enrollment.drift_signature
            OutboxEntry.record!(store: enrollment.store, event_type: 'stock.trace_drift', aggregate: enrollment,
                                payload: { 'variant_id' => enrollment.variant.prefixed_id, 'branch_id' => enrollment.branch.prefixed_id,
                                           'typed_on_hand' => typed, 'core_on_hand' => core })
          end
          enrollment.update_columns(drift_signature: signature, drift_checked_at: Time.current)
          signature
        end
      end

      def today(branch)
        Time.current.in_time_zone(branch.timezone).to_date
      end

      # Core shelf movements made on behalf of a typed change.
      def restock!(location, variant, quantity)
        writing { location.restock(variant, quantity) } if quantity.positive?
      end

      def unstock!(location, variant, quantity)
        writing { location.unstock(variant, quantity) } if quantity.positive?
      end

      def adjust!(location, variant, delta, reason)
        return if delta.zero?

        level = Spree::StockLevel.where(variant_id: variant.id, stock_location_id: location.id).lock.first
        writing { location.adjust(variant, delta, reason: reason, stock_level: level) }
      end
    end
  end
end
