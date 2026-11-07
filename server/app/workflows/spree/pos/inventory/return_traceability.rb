# frozen_string_literal: true

module Spree
  module Pos
    module Inventory
      # Serial and lot identity of returned units. A return of a tracked sale
      # line names the serials (each must be one sold on that line and not
      # returned yet) or the lot (needed when the line drew from more than one
      # lot); the units are reserved against the original allocations when
      # the return is prepared, so the same unit cannot come back twice.
      #
      # On receive, resellable units go back to stock at the receiving
      # location (serial in_stock, lot on hand); damaged units and units of an
      # expired lot go to quarantine there. Core restocks only resellable
      # units, so damaged tracked units are restocked here too: they are on
      # the shelf, held, and only a count writes them off.
      class ReturnTraceability
        Pick = Struct.new(:allocation, :quantity, keyword_init: true)

        class << self
          def tracked?(sale_line)
            %w[serial lot].include?(sale_line.tracked_mode)
          end

          # The allocations a return of `quantity` units of the line takes back.
          def plan(sale_line, quantity, serial_codes: [], lot_code: nil, lock: false)
            return [] unless tracked?(sale_line)

            scope = TraceAllocation.where(sale_line_id: sale_line.id, status: TraceAllocation::SOLD).includes(:serial_unit, :inventory_lot).order(:id)
            rows = lock ? scope.lock.to_a : scope.to_a
            sale_line.tracked_mode == 'serial' ? serial_plan(rows, quantity, serial_codes) : lot_plan(rows, quantity, lot_code)
          end

          def reserve!(operation, picks, condition)
            picks.each do |pick|
              allocation = pick.allocation
              allocation.update!(returned_quantity: allocation.returned_quantity + pick.quantity)
              TraceReturn.create!(store_id: operation.store_id, return_operation: operation, trace_allocation: allocation,
                                  quantity: pick.quantity, condition: condition, status: 'reserved')
            end
          end

          def receive!(operation)
            rows = TraceReturn.where(return_operation_id: operation.id,
                                     status: 'reserved').includes(trace_allocation: %i[serial_unit
                                                                                       inventory_lot]).order(:id).to_a
            return if rows.empty?

            location = operation.branch.stock_location
            today = StockIntegration.today(operation.branch)
            rows.each do |row|
              allocation = row.trace_allocation
              resellable = row.condition == 'resellable'
              if allocation.serial_unit
                unit = SerialUnit.lock.find(allocation.serial_unit_id)
                unit.update!(status: resellable ? 'in_stock' : 'quarantined', stock_location: location, returned_at: Time.current,
                             quarantine_reason: resellable ? nil : 'Trả hàng hư hỏng')
              else
                lot = receiving_lot!(allocation.inventory_lot, location)
                if resellable && !lot.expired_on?(today) && lot.status != 'expired'
                  lot.update!(on_hand: lot.on_hand + row.quantity)
                else
                  lot.update!(quarantined_quantity: lot.quarantined_quantity + row.quantity)
                end
                row.return_lot = lot
              end
              row.update!(status: 'received', received_at: Time.current)
              StockIntegration.restock!(location, allocation.variant, row.quantity) unless resellable
            end
          end

          def cancel!(operation)
            TraceReturn.where(return_operation_id: operation.id, status: 'reserved').includes(:trace_allocation).order(:id).each do |row|
              allocation = TraceAllocation.lock.find(row.trace_allocation_id)
              allocation.update!(returned_quantity: allocation.returned_quantity - row.quantity)
              row.update!(status: 'canceled')
            end
          end

          # Typed stock must be open at the receiving location.
          def ensure_receivable!(branch, sale_line)
            return unless tracked?(sale_line)
            return if StockIntegration.enrolled?(sale_line.variant_id, branch.stock_location_id)

            raise Conflict.new('Tracked goods can only come back to a branch where their tracked stock is open.', reason: 'trace_not_enrolled')
          end

          def sold_pos(sale_line)
            return nil unless tracked?(sale_line)

            rows = TraceAllocation.where(sale_line_id: sale_line.id, status: TraceAllocation::SOLD).includes(:serial_unit, :inventory_lot).order(:id)
            { mode: sale_line.tracked_mode, allocations: rows.map(&:to_sold_pos) }
          end

          # `forced_quarantine` marks units of a lot already expired at the
          # receiving branch's date: they go to quarantine whatever the condition.
          def preview_pos(sale_line, picks, branch)
            return nil unless tracked?(sale_line)

            today = StockIntegration.today(branch)
            {
              mode: sale_line.tracked_mode,
              serials: picks.filter_map { |pick| pick.allocation.serial_unit&.serial },
              lots: picks.select { |pick| pick.allocation.inventory_lot }.map do |pick|
                lot = pick.allocation.inventory_lot
                { lot_code: lot.lot_code, expiry_on: lot.expiry_on&.iso8601, quantity: pick.quantity,
                  forced_quarantine: lot.expired_on?(today) }
              end
            }
          end

          private

          def serial_plan(rows, quantity, serial_codes)
            serials = Array(serial_codes).map { |code| SerialUnit.normalize(code) }
            raise Conflict.new('Scan the serial numbers of the returned units.', reason: 'trace_return_detail_required') if serials.empty?
            if serials.length != quantity || serials.uniq.length != serials.length
              raise Conflict.new('Serial numbers must match the returned quantity.',
                                 reason: 'trace_serial_mismatch')
            end

            serials.map do |serial|
              allocation = rows.find { |row| row.serial_unit&.serial == serial }
              raise Conflict.new("Serial #{serial} was not sold on this line.", reason: 'trace_serial_mismatch') if allocation.nil?
              if allocation.returned_quantity >= allocation.quantity
                raise Conflict.new("Serial #{serial} was already returned.",
                                   reason: 'trace_already_returned')
              end

              Pick.new(allocation: allocation, quantity: 1)
            end
          end

          def lot_plan(rows, quantity, lot_code)
            open = rows.select { |row| row.returned_quantity < row.quantity }
            if lot_code.present?
              open = open.select { |row| row.inventory_lot&.lot_code == lot_code.to_s }
              raise Conflict.new("Lot #{lot_code} was not sold on this line or is already returned.", reason: 'trace_lot_mismatch') if open.empty?
            elsif open.map(&:inventory_lot_id).uniq.length > 1
              raise Conflict.new('This line was sold from several lots; choose the lot being returned.', reason: 'trace_return_detail_required')
            end
            left = quantity
            picks = open.filter_map do |row|
              take = [row.quantity - row.returned_quantity, left].min
              next if take <= 0

              left -= take
              Pick.new(allocation: row, quantity: take)
            end
            raise Conflict.new('More units than were sold from this lot.', reason: 'trace_already_returned') if left.positive?

            picks
          end

          # The original lot when it comes back where it was sold; otherwise the
          # same code and expiry at the receiving location, remembering its source.
          def receiving_lot!(lot, location)
            return InventoryLot.lock.find(lot.id) if lot.stock_location_id == location.id

            target = InventoryLot.where(variant_id: lot.variant_id, stock_location_id: location.id, lot_code: lot.lot_code).lock.first
            if target
              if target.expiry_on != lot.expiry_on
                raise Conflict.new("Lot #{lot.lot_code} has another expiry date at this branch.",
                                   reason: 'lot_expiry_mismatch')
              end

              return target
            end
            InventoryLot.create!(store_id: lot.store_id, variant_id: lot.variant_id, stock_location: location, lot_code: lot.lot_code,
                                 expiry_on: lot.expiry_on, source_lot: lot)
          end
        end
      end
    end
  end
end
