# frozen_string_literal: true

module Spree
  module Pos
    module Inventory
      # Reservation lifecycle of serial units and lots for sale lines.
      #
      # - A serial is reserved when it is scanned into a draft; lots are
      #   reserved FEFO when payment is prepared (`ensure!`). Both are bound to
      #   the draft and expire after TraceAllocation::TTL unless a command on
      #   the draft refreshes them; while a payment holds the snapshot they do
      #   not expire. Parking or canceling a draft releases them, so parked
      #   tabs never pin stock.
      # - Placement commits the reservations (serials become sold), handover
      #   consumes them and takes lot units off the lot; the core shelf moves
      #   in the same transaction through core placement and fulfillment.
      #
      # Callers hold the workspace lock. Serial rows are locked in serial
      # order and lot rows in id order, so concurrent counters serialize on
      # the unit they both want and one of them is refused.
      class AllocateTraceability
        class << self
          def reserve_serials!(workspace:, sale_line:, serials:)
            now = Workspace.database_now
            Guard.lock_levels!(sale_line.variant, [workspace.branch.stock_location])
            serials.sort.each do |serial|
              unit = SerialUnit.where(store_id: workspace.store_id, variant_id: sale_line.variant_id, serial: serial).lock.first
              reserve_unit!(workspace, sale_line, unit, serial, now)
            end
          end

          # Makes every tracked line of the draft hold its serials/lots.
          # `hold: true` is used by payment commands: the reservation then
          # lasts until the draft completes, parks or cancels.
          def ensure!(workspace, hold:)
            now = Workspace.database_now
            expires_at = hold ? nil : now + TraceAllocation::TTL
            lines = tracked_lines(workspace)
            return if lines.empty?

            Spree::StockLevel.where(variant_id: lines.map(&:variant_id).uniq, stock_location_id: workspace.branch.stock_location_id).
              order(:id).lock.load
            lines.each do |sale_line|
              StockIntegration.ensure_sellable!(workspace.branch, sale_line.variant, sale_line.tracked_mode)
              if sale_line.tracked_mode == 'serial'
                ensure_serials!(workspace, sale_line, now)
              else
                ensure_lots!(workspace, sale_line, now)
              end
              TraceAllocation.where(sale_line_id: sale_line.id, status: 'reserved').
                update_all(expires_at: expires_at, lease_generation: workspace.lease_generation, updated_at: Time.current)
            end
          end

          # Every command on a draft keeps its live reservations alive.
          def refresh!(workspace)
            return unless workspace.operational_status == 'editing'

            now = Workspace.database_now
            TraceAllocation.where(workspace_id: workspace.id, status: 'reserved').where('expires_at > ?', now).
              update_all(expires_at: now + TraceAllocation::TTL, updated_at: Time.current)
          end

          def release!(workspace)
            TraceAllocation.where(workspace_id: workspace.id, status: 'reserved').order(:id).each { |row| release_allocation!(row) }
          end

          def release_line!(sale_line)
            TraceAllocation.where(sale_line_id: sale_line.id, status: 'reserved').order(:id).each { |row| release_allocation!(row) }
          end

          # Placement: reservations become the sale's committed allocations,
          # adding up to each line's base quantity.
          def commit!(workspace)
            location_id = workspace.branch.stock_location_id
            lines = SaleLine.where(workspace_id: workspace.id).includes(:variant).order(:id).to_a
            items = Spree::FulfillmentItem.where(order_id: workspace.order_id).to_a.group_by(&:line_item_id)
            lines.each do |sale_line|
              tracked = %w[serial lot].include?(sale_line.tracked_mode)
              # Backstop: an enrolled variant never leaves untracked.
              if !tracked && StockIntegration.enrolled?(sale_line.variant_id, location_id)
                raise Conflict.new('A tracked item is on this sale without serial or lot allocation.', reason: 'trace_allocation_missing')
              end
              next unless tracked

              rows = TraceAllocation.where(sale_line_id: sale_line.id, status: 'reserved').order(:id).to_a
              if rows.empty?
                raise Conflict.new('A tracked item is on this sale without serial or lot allocation.', reason: 'trace_allocation_missing')
              end
              if rows.sum(&:quantity) != sale_line.base_quantity
                raise Conflict.new('Tracked goods lost their reservation.',
                                   reason: 'trace_serial_released')
              end

              item = line_fulfillment_item!(items[sale_line.line_item_id], sale_line)
              rows.each do |row|
                row.update!(status: 'committed', committed_at: Time.current, expires_at: nil, fulfillment_item_id: item.id)
                row.serial_unit&.update!(status: 'sold')
              end
            end
          end

          # Handover of a shipped fulfillment: lot units leave their lots. A lot
          # that no longer holds them (changed outside the guarded paths) stops
          # the handover with a conflict instead of a database error.
          def consume!(fulfillment)
            rows = TraceAllocation.where(status: 'committed', fulfillment_item_id: fulfillment.fulfillment_items.select(:id)).order(:id).to_a
            lots = InventoryLot.where(id: rows.filter_map(&:inventory_lot_id).uniq.sort).order(:id).lock.index_by(&:id)
            rows.each do |row|
              if row.inventory_lot_id
                lot = lots.fetch(row.inventory_lot_id)
                if lot.on_hand < row.quantity
                  raise Conflict.new("Lot #{lot.lot_code} holds only #{lot.on_hand} of the #{row.quantity} units sold; it needs a count first.",
                                     reason: 'trace_lot_short', details: { lot_id: lot.prefixed_id, on_hand: lot.on_hand, needed: row.quantity })
                end

                lot.update!(on_hand: lot.on_hand - row.quantity)
              end
              row.update!(status: 'consumed', consumed_at: Time.current)
            end
          end

          # Recovery: expired reservations are released; reservations held by
          # a payment that no longer holds the snapshot get a TTL again. Locks
          # in the writers' order (stock level, serial unit, allocation); a
          # failing row is logged and the sweep goes on.
          def expire_stale!
            now = Workspace.database_now
            TraceAllocation.where(status: 'reserved').where(expires_at: ...now).order(:id).limit(500).each do |row|
              ApplicationRecord.transaction do
                Spree::StockLevel.where(variant_id: row.variant_id, stock_location_id: row.stock_location_id).lock.load
                SerialUnit.where(id: row.serial_unit_id).lock.load if row.serial_unit_id
                row.lock!
                release_allocation!(row) if row.status == 'reserved' && row.expires_at && row.expires_at < now
              end
            rescue StandardError => e
              Rails.logger.error("[pos] trace reservation expiry failed for allocation #{row.id}: #{e.class}: #{e.message}")
            end
            TraceAllocation.where(status: 'reserved', expires_at: nil).distinct.pluck(:workspace_id).each do |workspace_id|
              ApplicationRecord.transaction do
                workspace = Workspace.lock.find(workspace_id)
                next if workspace.operational_status == 'completed' || workspace.snapshot_locked?

                TraceAllocation.where(workspace_id: workspace.id, status: 'reserved', expires_at: nil).
                  update_all(expires_at: now + TraceAllocation::TTL, updated_at: Time.current)
              end
            end
          end

          # `memo` caches the per-variant sellability check across the lines of
          # one read.
          def line_trace(sale_line, branch, now: Workspace.database_now, memo: nil, completed: nil)
            mode = sale_line.tracked_mode
            return nil unless %w[serial lot].include?(mode)

            rows = TraceAllocation.where(sale_line_id: sale_line.id).where.not(status: 'released').
                   includes(:serial_unit, :inventory_lot).order(:id).to_a
            live = rows.select { |row| row.live?(now) }
            complete = live.sum(&:quantity) == sale_line.base_quantity
            issue = nil
            preview = []
            completed = sale_line.workspace.operational_status == 'completed' if completed.nil?
            if !complete && !completed
              reason = StockIntegration.blocked_reason(branch, sale_line.variant, mode, memo: memo)
              issue = "trace_#{reason}" if reason
              if issue.nil? && mode == 'serial'
                issue = 'trace_serial_released'
              elsif issue.nil?
                issue, preview = lot_preview(sale_line, branch, now)
              end
            end
            { mode: mode, complete: complete, issue: issue, allocations: live.map(&:to_pos), preview: preview }
          end

          def workspace_trace(_workspace, traces)
            issues = traces.filter_map do |sale_line_id, trace|
              { sale_line_id: sale_line_id, reason: trace[:issue] } if trace && trace[:issue]
            end
            { ready: issues.empty?, issues: issues }
          end

          private

          # The line ships in exactly one fulfillment item that carries its
          # whole base quantity, so allocations can point at it.
          def line_fulfillment_item!(items, sale_line)
            items = Array(items)
            return items.first if items.one? && items.first.quantity == sale_line.base_quantity

            raise Conflict.new('Tracked goods must ship as one fulfillment line of their full quantity.', reason: 'trace_fulfillment_mismatch')
          end

          def tracked_lines(workspace)
            SaleLine.where(workspace_id: workspace.id, tracked_mode: %w[serial lot]).includes(:variant).order(:id).to_a
          end

          def reserve_unit!(workspace, sale_line, unit, serial, now)
            location_id = workspace.branch.stock_location_id
            unavailable = ->(why) { raise Conflict.new("Serial #{serial} #{why}", reason: 'trace_serial_unavailable') }
            unavailable.call('is not in this branch stock.') if unit.nil? || unit.stock_location_id != location_id
            current = TraceAllocation.where(serial_unit_id: unit.id, status: TraceAllocation::SOLD + ['reserved']).order(:id).last
            if current&.status == 'reserved'
              if current.live?(now)
                if current.workspace_id == workspace.id
                  raise Conflict.new("Serial #{serial} is already on this order.",
                                     reason: 'trace_serial_duplicate')
                end

                unavailable.call('is held by another counter.')
              end
              release_allocation!(current)
              unit.reload
            end
            unavailable.call("is #{unit.status.tr('_', ' ')}.") unless unit.status == 'in_stock'

            TraceAllocation.create!(
              store_id: workspace.store_id, workspace: workspace, sale_line: sale_line, order_id: workspace.order_id,
              variant_id: sale_line.variant_id, stock_location_id: location_id, serial_unit: unit, quantity: 1,
              status: 'reserved', lease_generation: workspace.lease_generation, expires_at: now + TraceAllocation::TTL
            )
            unit.update!(status: 'reserved')
          end

          def ensure_serials!(workspace, sale_line, now)
            Array(sale_line.serial_codes).sort.each do |serial|
              rows = TraceAllocation.joins(:serial_unit).where(sale_line_id: sale_line.id, status: 'reserved').
                     where(spree_pos_serial_units: { serial: serial }).to_a
              next if rows.any? { |row| row.live?(now) }

              unit = SerialUnit.where(store_id: workspace.store_id, variant_id: sale_line.variant_id, serial: serial).lock.first
              begin
                reserve_unit!(workspace, sale_line, unit, serial, now)
              rescue Conflict => e
                raise Conflict.new("#{e.message} Remove the line and scan another unit.", reason: 'trace_serial_released')
              end
            end
          end

          def ensure_lots!(workspace, sale_line, now)
            branch = workspace.branch
            today = StockIntegration.today(branch)
            rows = TraceAllocation.where(sale_line_id: sale_line.id, status: 'reserved').includes(:inventory_lot).to_a
            valid = rows.all? do |row|
              row.live?(now) && row.inventory_lot.status == 'active' && !row.inventory_lot.expired_on?(today)
            end
            return if valid && rows.sum(&:quantity) == sale_line.base_quantity

            rows.each { |row| release_allocation!(row) }
            picked = picked_lot(sale_line, branch)
            picks = FefoAllocator.call(variant: sale_line.variant, stock_location: branch.stock_location,
                                       quantity: sale_line.base_quantity, today: today, lock: true, lot: picked, now: now)
            picks.each do |pick|
              TraceAllocation.create!(
                store_id: workspace.store_id, workspace: workspace, sale_line: sale_line, order_id: workspace.order_id,
                variant_id: sale_line.variant_id, stock_location_id: branch.stock_location_id, inventory_lot: pick.lot,
                quantity: pick.quantity, status: 'reserved', lease_generation: workspace.lease_generation,
                expires_at: now + TraceAllocation::TTL, picked: picked.present?
              )
            end
          end

          def picked_lot(sale_line, branch)
            return nil if sale_line.lot_code.blank?

            InventoryLot.find_by(variant_id: sale_line.variant_id, stock_location_id: branch.stock_location_id, lot_code: sale_line.lot_code)
          end

          def lot_preview(sale_line, branch, now)
            picks = FefoAllocator.call(variant: sale_line.variant, stock_location: branch.stock_location, quantity: sale_line.base_quantity,
                                       today: StockIntegration.today(branch), lot: picked_lot(sale_line, branch), now: now)
            [nil, picks.map { |pick| { lot_code: pick.lot.lot_code, expiry_on: pick.lot.expiry_on&.iso8601, quantity: pick.quantity } }]
          rescue Conflict => e
            [e.reason || 'trace_insufficient', []]
          end

          def release_allocation!(row)
            row.update!(status: 'released', released_at: Time.current, expires_at: nil)
            unit = row.serial_unit
            unit.update!(status: 'in_stock') if unit && unit.status == 'reserved'
          end
        end
      end
    end
  end
end
