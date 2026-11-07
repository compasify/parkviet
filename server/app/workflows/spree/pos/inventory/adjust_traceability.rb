# frozen_string_literal: true

module Spree
  module Pos
    module Inventory
      # Stock count of one tracked variant at a branch: counted lot
      # quantities, serials missing from the shelf, removed serials found
      # again. Units held by drafts or sold but not handed over cannot be
      # counted away. A negative change, or a positive one above the branch
      # threshold (every positive one when no threshold is set), waits for an
      # action-bound approval from another person; applying re-checks that
      # the shelf still matches what was counted and changes the typed
      # records and the core shelf together, once.
      class AdjustTraceability
        APPROVAL_TTL = 30.minutes

        class << self
          def create(store:, staff:, key:, branch_id:, variant_id:, reason:, lots: nil, missing_serials: nil, found_serials: nil)
            lot_rows = Guard.rows_of(lots).map do |row|
              counted = row[:counted].to_s.strip.empty? ? nil : Guard.count!(row[:counted])
              held = row[:counted_quarantined].to_s.strip.empty? ? nil : Guard.count!(row[:counted_quarantined])
              raise Conflict.new('Each lot row needs a counted quantity.', reason: 'quantity_invalid') if counted.nil? && held.nil?

              { 'lot_id' => row[:lot_id].to_s, 'counted' => counted, 'counted_quarantined' => held }
            end
            missing = Guard.serials!(missing_serials)
            found = Guard.serials!(found_serials)
            payload = { 'command' => 'inventory.adjust', 'branch_id' => branch_id.to_s, 'variant_id' => variant_id.to_s,
                        'reason' => reason.to_s.strip, 'lots' => lot_rows, 'missing' => missing, 'found' => found }
            authorize = -> { Guard.authorize!(store, staff, Guard.branch!(store, branch_id)) }
            CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: authorize) do
              raise Conflict.new('A reason is required.', reason: 'reason_required') if reason.to_s.strip.blank?

              branch = Guard.branch!(store, branch_id)
              variant = Guard.variant!(store, branch, variant_id)
              mode = Guard.mode!(store, variant)
              location = branch.stock_location
              Guard.lock_levels!(variant, [location])
              unless StockIntegration.enrolled?(variant.id, location.id)
                raise Conflict.new('Record an opening balance for this item at this branch first.', reason: 'trace_not_enrolled')
              end

              lines = plan!(store, variant, location, mode, lot_rows, missing, found)
              delta = shelf_change(variant, location, mode, lines)
              raise Conflict.new('The count changes nothing.', reason: 'count_no_change') if delta.zero? && lines.all? { |line| line['delta'].zero? }

              adjustment = InventoryAdjustment.create!(
                store: store, branch: branch, variant: variant, stock_location: location, requester: staff,
                reason: reason.to_s.strip[0, 200], lines: lines, delta: delta,
                requires_approval: approval_needed?(branch, lines, delta), status: 'pending_approval'
              )
              apply!(adjustment, staff) unless adjustment.requires_approval
              AuditEntry.record!(store: store, actor: staff, action: 'inventory.count', subject: adjustment,
                                 metadata: { delta: delta, requires_approval: adjustment.requires_approval })
              adjustment.reload.to_pos
            end
          end

          def approve(store:, staff:, key:, adjustment_id:)
            payload = { 'command' => 'inventory.adjust.approve', 'adjustment_id' => adjustment_id.to_s }
            authorize = lambda do
              adjustment = adjustment!(store, adjustment_id)
              raise CanCan::AccessDenied unless AccessPolicy.new(store: store, staff: staff).allows?(adjustment.branch, Capabilities::APPROVE)
            end
            CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: authorize) do
              adjustment = adjustment!(store, adjustment_id)
              adjustment.lock!
              unless adjustment.status == 'pending_approval'
                raise Conflict.new('Only a count waiting for approval can be approved.',
                                   reason: 'not_pending')
              end
              raise Conflict.new('You cannot approve your own count.', reason: 'self_approval') if adjustment.requester_id == staff.id

              approval = Approval.create!(
                store: store, branch: adjustment.branch, approver: staff, requester: adjustment.requester,
                subject_type: adjustment.class.name, subject_id: adjustment.id, action: InventoryAdjustment::ACTION,
                revision: adjustment.revision.to_s, expires_at: Time.current + APPROVAL_TTL, status: 'active'
              )
              adjustment.update!(approval: approval)
              AuditEntry.record!(store: store, actor: staff, action: 'inventory.count.approve', subject: adjustment,
                                 metadata: { approval_id: approval.prefixed_id })
              adjustment.to_pos
            end
          end

          def apply(store:, staff:, key:, adjustment_id:, approval_id: nil)
            payload = { 'command' => 'inventory.adjust.apply', 'adjustment_id' => adjustment_id.to_s, 'approval_id' => approval_id.to_s.presence }
            authorize = -> { Guard.authorize!(store, staff, adjustment!(store, adjustment_id).branch) }
            CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: authorize) do
              adjustment = adjustment!(store, adjustment_id)
              adjustment.lock!
              raise Conflict.new('This count was already applied.', reason: 'already_applied') if adjustment.status == 'applied'
              raise Conflict.new('This count was canceled.', reason: 'adjustment_canceled') if adjustment.status == 'canceled'

              approval = if approval_id.present?
                           Approval.locate(Approval.for_store(store).where(branch_id: adjustment.branch_id),
                                           approval_id)
                         else
                           adjustment.approval
                         end
              raise Conflict.new('This count needs an approval.', reason: 'approval_required') if approval.nil?

              Guard.lock_levels!(adjustment.variant, [adjustment.stock_location])
              approval.consume!(action: InventoryAdjustment::ACTION, amount: nil, currency: nil, revision: adjustment.revision,
                                subject: adjustment, requester: staff)
              apply!(adjustment.reload, staff)
              adjustment.reload.to_pos
            end
          end

          def cancel(store:, staff:, key:, adjustment_id:, reason:)
            payload = { 'command' => 'inventory.adjust.cancel', 'adjustment_id' => adjustment_id.to_s, 'reason' => reason.to_s.strip }
            authorize = lambda do
              adjustment = adjustment!(store, adjustment_id)
              policy = AccessPolicy.new(store: store, staff: staff)
              allowed = policy.allows?(adjustment.branch, Capabilities::APPROVE) ||
                (adjustment.requester_id == staff.id && policy.allows?(adjustment.branch, Capabilities::INVENTORY_MANAGE))
              raise CanCan::AccessDenied unless allowed
            end
            CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: authorize) do
              raise Conflict.new('A reason is required.', reason: 'reason_required') if reason.to_s.strip.blank?

              adjustment = adjustment!(store, adjustment_id)
              adjustment.lock!
              unless adjustment.status == 'pending_approval'
                raise Conflict.new('Only a count waiting for approval can be canceled.',
                                   reason: 'not_pending')
              end

              adjustment.update!(status: 'canceled', canceled_at: Time.current, revision: adjustment.revision + 1)
              AuditEntry.record!(store: store, actor: staff, action: 'inventory.count.cancel', subject: adjustment,
                                 metadata: { reason: reason.to_s.strip })
              adjustment.to_pos
            end
          end

          def adjustment!(store, adjustment_id)
            adjustment = InventoryAdjustment.locate(InventoryAdjustment.for_store(store), adjustment_id)
            raise ActiveRecord::RecordNotFound if adjustment.nil?

            adjustment
          end

          private

          # Units held by drafts or placed orders cannot be counted away.
          def ensure_holds_covered!(lot, counted)
            held = lot.holds
            return if counted >= held[:reserved] + held[:committed]

            raise Conflict.new("Lot #{lot.lot_code} has #{held[:reserved] + held[:committed]} units held by sales.",
                               reason: 'trace_count_below_held', details: { held: held[:reserved] + held[:committed] })
          end

          def approval_needed?(branch, lines, delta)
            lowered = lines.any? do |line|
              line['delta'].negative? || line['on_hand_delta'].to_i.negative? || line['quarantined_delta'].to_i.negative?
            end
            return true if delta.negative? || lowered

            branch.adjustment_approval_threshold.nil? ? delta.positive? : delta > branch.adjustment_approval_threshold
          end

          # What the core shelf changes by: the counted typed total minus the
          # shelf now. Equal to the typed change while the pair is reconciled;
          # a count of a drifted pair also brings the shelf back in line.
          def shelf_change(variant, location, mode, lines)
            typed_after = StockIntegration.typed_on_hand(mode, variant, location) + lines.sum { |line| line['delta'] }
            typed_after - StockIntegration.core_on_hand(variant, location)
          end

          def plan!(store, variant, location, mode, lot_rows, missing, found)
            if mode == 'lot'
              raise Conflict.new('This item is tracked by lot.', reason: 'trace_mode_mismatch') if missing.any? || found.any?

              ids = lot_rows.map { |row| Guard.lot!(store, row['lot_id'], location, variant).id }
              raise Conflict.new('Each lot can appear once.', reason: 'duplicate_lot') if ids.uniq.length != ids.length

              lots = InventoryLot.where(id: ids.sort).order(:id).lock.index_by(&:id)
              lot_rows.each_with_index.map do |row, index|
                lot = lots.fetch(ids[index])
                counted = row['counted'] || lot.on_hand
                held_after = row['counted_quarantined'] || lot.quarantined_quantity
                ensure_holds_covered!(lot, counted)
                on_hand_delta = counted - lot.on_hand
                held_delta = held_after - lot.quarantined_quantity
                { 'kind' => 'lot', 'lot_id' => lot.prefixed_id, 'lot_code' => lot.lot_code, 'before' => lot.on_hand,
                  'after' => counted, 'quarantined_before' => lot.quarantined_quantity, 'quarantined_after' => held_after,
                  'quarantined_delta' => held_delta, 'on_hand_delta' => on_hand_delta, 'delta' => on_hand_delta + held_delta }
              end
            else
              raise Conflict.new('This item is tracked by serial.', reason: 'trace_mode_mismatch') if lot_rows.any?
              raise Conflict.new('A serial cannot be both missing and found.', reason: 'duplicate_serial') if missing.intersect?(found)

              units = SerialUnit.where(store_id: store.id, variant_id: variant.id, serial: missing + found).lock.index_by(&:serial)
              rows = missing.map do |serial|
                unit = units[serial]
                unless unit && unit.stock_location_id == location.id && %w[in_stock quarantined].include?(unit.status)
                  raise Conflict.new("Serial #{serial} is not free stock at this branch.", reason: 'serial_unavailable')
                end

                { 'kind' => 'serial', 'serial' => serial, 'before' => 1, 'after' => 0, 'delta' => -1 }
              end
              rows + found.map do |serial|
                unit = units[serial]
                unless unit && unit.stock_location_id == location.id && unit.status == 'removed'
                  raise Conflict.new("Serial #{serial} is not a removed unit of this branch; receive new units instead.",
                                     reason: 'serial_unavailable')
                end

                { 'kind' => 'serial', 'serial' => serial, 'before' => 0, 'after' => 1, 'delta' => 1 }
              end
            end
          end

          def apply!(adjustment, staff)
            mode = StockIntegration.tracked_mode(adjustment.store_id, adjustment.variant)
            if shelf_change(adjustment.variant, adjustment.stock_location, mode, adjustment.lines) != adjustment.delta
              raise Conflict.new('The shelf changed since it was counted; count again.', reason: 'count_stale')
            end

            adjustment.lines.each do |line|
              if line['kind'] == 'lot'
                lot = InventoryLot.lock.find_by!(id: InventoryLot.find_by_prefix_id!(line['lot_id']).id)
                if lot.on_hand != line['before'] || lot.quarantined_quantity != (line['quarantined_before'] || lot.quarantined_quantity)
                  raise Conflict.new("Lot #{lot.lot_code} changed since it was counted; count again.",
                                     reason: 'count_stale')
                end
                # Sales may have reserved units since the count was made.
                ensure_holds_covered!(lot, line['after'])

                lot.update!(on_hand: line['after'], quarantined_quantity: line['quarantined_after'] || lot.quarantined_quantity)
              else
                unit = SerialUnit.lock.find_by!(store_id: adjustment.store_id, variant_id: adjustment.variant_id, serial: line['serial'])
                expected = line['delta'].negative? ? %w[in_stock quarantined] : %w[removed]
                unless expected.include?(unit.status) && unit.stock_location_id == adjustment.stock_location_id
                  raise Conflict.new("Serial #{unit.serial} changed since it was counted; count again.", reason: 'count_stale')
                end

                unit.update!(status: line['delta'].negative? ? 'removed' : 'in_stock')
              end
            end
            StockIntegration.adjust!(adjustment.stock_location, adjustment.variant, adjustment.delta, "POS count: #{adjustment.reason}")
            adjustment.update!(status: 'applied', applier: staff, applied_at: Time.current)
            Guard.finish!(adjustment.store, staff, 'inventory.adjusted', adjustment,
                          adjustment_id: adjustment.prefixed_id, variant_id: adjustment.variant.prefixed_id, delta: adjustment.delta)
          end
        end
      end
    end
  end
end
