# frozen_string_literal: true

module Spree
  module Pos
    module Inventory
      # Moves tracked units between two branch stock locations at once: the
      # serial units (or lot quantities) change location and the core shelf of
      # both locations moves by the same total, in one transaction. Only free
      # units move: a serial held by a draft or sold, and lot units reserved
      # or committed to sales, stay. A lot keeps its code and expiry at the
      # destination and remembers the lot it came from.
      class TransferTraceability
        def self.call(store:, staff:, key:, from_branch_id:, to_branch_id:, variant_id:, serials: nil, lots: nil)
          serial_rows = Guard.serials!(serials)
          lot_rows = Guard.rows_of(lots).map { |row| { lot_id: row[:lot_id].to_s, quantity: Guard.quantity!(row[:quantity]) } }
          payload = { 'command' => 'inventory.transfer', 'from_branch_id' => from_branch_id.to_s, 'to_branch_id' => to_branch_id.to_s,
                      'variant_id' => variant_id.to_s, 'serials' => serial_rows, 'lots' => lot_rows.map(&:stringify_keys) }
          authorize = lambda do
            Guard.authorize!(store, staff, Guard.branch!(store, from_branch_id))
            Guard.authorize!(store, staff, Guard.branch!(store, to_branch_id))
          end
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: authorize) do
            source = Guard.branch!(store, from_branch_id)
            target = Guard.branch!(store, to_branch_id)
            if source.stock_location_id == target.stock_location_id
              raise Conflict.new('Choose two branches with different stock locations.',
                                 reason: 'same_location')
            end

            variant = Guard.variant!(store, source, variant_id)
            Guard.variant!(store, target, variant_id)
            mode = Guard.mode!(store, variant)
            from = source.stock_location
            to = target.stock_location
            Guard.lock_levels!(variant, [from, to])
            Guard.reconciled!(source, variant, mode)
            Guard.reconciled!(target, variant, mode)
            raise Conflict.new('Nothing to transfer.', reason: 'nothing_to_transfer') if serial_rows.empty? && lot_rows.empty?
            if mode == 'serial' ? lot_rows.any? : serial_rows.any?
              raise Conflict.new("This item is tracked by #{mode}.",
                                 reason: 'trace_mode_mismatch')
            end

            quantity = if mode == 'serial'
                         move_serials!(store, variant, from, to, serial_rows)
                       else
                         move_lots!(store, variant, from, to, lot_rows)
                       end
            StockIntegration.unstock!(from, variant, quantity)
            StockIntegration.restock!(to, variant, quantity)
            Guard.finish!(store, staff, 'inventory.transferred', source,
                          variant_id: variant.prefixed_id, to_branch_id: target.prefixed_id, quantity: quantity,
                          serials: serial_rows, lots: lot_rows.map { |row| row[:lot_id] })
            { branch_id: source.prefixed_id, from: StockIntegration.status(source, variant), to: StockIntegration.status(target, variant) }
          end
        end

        def self.move_serials!(store, variant, from, to, serials)
          units = SerialUnit.where(store_id: store.id, variant_id: variant.id, serial: serials).order(:serial).lock.to_a
          serials.each do |serial|
            unit = units.find { |row| row.serial == serial }
            unless unit && unit.stock_location_id == from.id && unit.status == 'in_stock'
              raise Conflict.new("Serial #{serial} is not free stock at the source branch.", reason: 'serial_unavailable')
            end
          end
          units.each { |unit| unit.update!(stock_location: to) }
          units.length
        end

        def self.move_lots!(store, variant, from, to, rows)
          ids = rows.map { |row| Guard.lot!(store, row[:lot_id], from, variant).id }
          raise Conflict.new('Each lot can appear once.', reason: 'duplicate_lot') if ids.uniq.length != ids.length

          lots = InventoryLot.where(id: ids.sort).order(:id).lock.index_by(&:id)
          now = Workspace.database_now
          rows.each_with_index.sum do |row, index|
            lot = lots.fetch(ids[index])
            raise Conflict.new("Lot #{lot.lot_code} is quarantined.", reason: 'lot_quarantined') unless lot.status == 'active'

            free = lot.available(now)
            if free < row[:quantity]
              raise Conflict.new("Only #{[free, 0].max} units of lot #{lot.lot_code} are free to move.", reason: 'trace_insufficient')
            end

            lot.update!(on_hand: lot.on_hand - row[:quantity])
            arrive!(store, variant, to, lot, row[:quantity])
            row[:quantity]
          end
        end

        def self.arrive!(store, variant, to, lot, quantity)
          target = InventoryLot.where(variant_id: variant.id, stock_location_id: to.id, lot_code: lot.lot_code).lock.first
          if target
            if target.expiry_on != lot.expiry_on
              raise Conflict.new("Lot #{lot.lot_code} has another expiry date at the destination.",
                                 reason: 'lot_expiry_mismatch')
            end
            raise Conflict.new("Lot #{lot.lot_code} is quarantined at the destination.", reason: 'lot_quarantined') if target.status == 'quarantined'

            target.update!(on_hand: target.on_hand + quantity, received_quantity: target.received_quantity + quantity)
          else
            InventoryLot.create!(store: store, variant: variant, stock_location: to, lot_code: lot.lot_code, expiry_on: lot.expiry_on,
                                 received_quantity: quantity, on_hand: quantity, source_lot: lot)
          end
        end
      end
    end
  end
end
