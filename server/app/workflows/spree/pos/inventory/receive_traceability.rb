# frozen_string_literal: true

module Spree
  module Pos
    module Inventory
      # Goods arriving at a branch for a tracked variant: new serial units or
      # lot quantities, and the same total restocked on the core shelf, in one
      # transaction. A lot code already at the location adds to that lot only
      # when its expiry matches; an already expired lot is refused.
      class ReceiveTraceability
        def self.call(store:, staff:, key:, branch_id:, variant_id:, serials: nil, lots: nil)
          serial_rows = Guard.serials!(serials)
          lot_rows = Guard.lot_rows!(lots)
          payload = { 'command' => 'inventory.receive', 'branch_id' => branch_id.to_s, 'variant_id' => variant_id.to_s,
                      'serials' => serial_rows, 'lots' => lot_rows.map { |row| row.merge(expiry_on: row[:expiry_on]&.iso8601).stringify_keys } }
          authorize = -> { Guard.authorize!(store, staff, Guard.branch!(store, branch_id)) }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: authorize) do
            branch = Guard.branch!(store, branch_id)
            # No retail.traceability gate: a receipt only ever restocks a
            # variant that is already tracked (`mode!` refuses `none`) and
            # already enrolled at the branch (`reconciled!`). Turning the
            # module off stops new setup (opening balances, switching a SKU
            # into tracking), not more stock for SKUs tracked before.
            variant = Guard.variant!(store, branch, variant_id)
            mode = Guard.mode!(store, variant)
            location = branch.stock_location
            Guard.lock_levels!(variant, [location])
            Guard.reconciled!(branch, variant, mode)
            raise Conflict.new('Nothing to receive.', reason: 'nothing_to_receive') if serial_rows.empty? && lot_rows.empty?
            if mode == 'serial' ? lot_rows.any? : serial_rows.any?
              raise Conflict.new("This item is tracked by #{mode}.",
                                 reason: 'trace_mode_mismatch')
            end

            quantity = if mode == 'serial'
                         receive_serials!(store, variant, location,
                                          serial_rows)
                       else
                         receive_lots!(store, branch, variant, location, lot_rows)
                       end
            StockIntegration.restock!(location, variant, quantity)
            Guard.finish!(store, staff, 'inventory.received', branch,
                          variant_id: variant.prefixed_id, quantity: quantity, serials: serial_rows,
                          lots: lot_rows.map { |row| row[:lot_code] })
            StockIntegration.status(branch, variant)
          end
        end

        def self.receive_serials!(store, variant, location, serials)
          taken = SerialUnit.where(store_id: store.id, variant_id: variant.id, serial: serials).pluck(:serial)
          raise Conflict.new("Serial #{taken.first} already exists.", reason: 'serial_exists') if taken.any?

          serials.each { |serial| SerialUnit.create!(store: store, variant: variant, stock_location: location, serial: serial) }
          serials.length
        end

        def self.receive_lots!(store, branch, variant, location, rows)
          today = StockIntegration.today(branch)
          rows.sum do |row|
            raise Conflict.new("Lot #{row[:lot_code]} is already expired.", reason: 'lot_expired') if row[:expiry_on] && row[:expiry_on] < today

            lot = InventoryLot.where(variant_id: variant.id, stock_location_id: location.id, lot_code: row[:lot_code]).lock.first
            if lot
              raise Conflict.new("Lot #{lot.lot_code} has another expiry date.", reason: 'lot_expiry_mismatch') if lot.expiry_on != row[:expiry_on]
              # New goods never silently join a lot on hold.
              raise Conflict.new("Lot #{lot.lot_code} is quarantined.", reason: 'lot_quarantined') if lot.status == 'quarantined'

              lot.update!(received_quantity: lot.received_quantity + row[:quantity], on_hand: lot.on_hand + row[:quantity])
            else
              InventoryLot.create!(store: store, variant: variant, stock_location: location, lot_code: row[:lot_code],
                                   expiry_on: row[:expiry_on], received_quantity: row[:quantity], on_hand: row[:quantity])
            end
            row[:quantity]
          end
        end
      end
    end
  end
end
