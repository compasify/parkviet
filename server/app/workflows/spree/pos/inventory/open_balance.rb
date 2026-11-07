# frozen_string_literal: true

module Spree
  module Pos
    module Inventory
      # Opens a tracked variant for typed stock at a branch location. The
      # serials or lots counted on the shelf must add up to the core count
      # there, under the stock level lock; otherwise nothing is recorded and
      # the variant stays unsellable at the branch until the core count is
      # corrected (outside POS, which is still allowed before enrollment) or
      # the count is redone.
      class OpenBalance
        def self.call(store:, staff:, key:, branch_id:, variant_id:, serials: nil, lots: nil)
          serial_rows = Guard.serials!(serials)
          lot_rows = Guard.lot_rows!(lots)
          payload = { 'command' => 'inventory.open_balance', 'branch_id' => branch_id.to_s, 'variant_id' => variant_id.to_s,
                      'serials' => serial_rows, 'lots' => lot_rows.map { |row| row.merge(expiry_on: row[:expiry_on]&.iso8601).stringify_keys } }
          authorize = -> { Guard.authorize!(store, staff, Guard.branch!(store, branch_id)) }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: authorize) do
            branch = Guard.branch!(store, branch_id)
            FeaturePolicy.require!(branch, :traceability)
            variant = Guard.variant!(store, branch, variant_id)
            # Same share lock as a first sale takes: the tracked mode cannot be
            # reconfigured while the balance opens.
            Spree::Variant.where(id: variant.id).lock('FOR SHARE').load
            mode = Guard.mode!(store, variant)
            location = branch.stock_location
            level = Guard.lock_levels!(variant, [location]).first
            if StockIntegration.enrolled?(variant.id, location.id)
              raise Conflict.new('Tracked stock of this item is already open at this branch.', reason: 'already_enrolled')
            end
            # Placed orders still holding units here would ship without serials or lots.
            if level&.allocated_count&.positive?
              raise Conflict.new("#{level.allocated_count} units here are still allocated to placed orders; hand them over first.",
                                 reason: 'enrollment_allocated', details: { allocated_count: level.allocated_count })
            end

            if mode == 'serial' ? lot_rows.any? : serial_rows.any?
              raise Conflict.new("This item is tracked by #{mode}.", reason: 'trace_mode_mismatch')
            end

            typed = mode == 'serial' ? serial_rows.length : lot_rows.sum { |row| row[:quantity] }
            core = level&.count_on_hand || 0
            if typed != core
              raise Conflict.new("Opening balance #{typed} does not match the shelf count #{core}.",
                                 reason: 'opening_unreconciled', details: { typed_on_hand: typed, core_on_hand: core })
            end

            create_units!(store, variant, location, mode, serial_rows, lot_rows)
            enrollment = TraceEnrollment.create!(store: store, variant: variant, stock_location: location, branch: branch,
                                                 opened_by: staff, tracked_mode: mode, opening_quantity: typed)
            Guard.finish!(store, staff, 'inventory.opened', enrollment,
                          variant_id: variant.prefixed_id, branch_id: branch.prefixed_id, quantity: typed, mode: mode)
            StockIntegration.status(branch, variant)
          end
        end

        def self.create_units!(store, variant, location, mode, serial_rows, lot_rows)
          if mode == 'serial'
            taken = SerialUnit.where(store_id: store.id, variant_id: variant.id, serial: serial_rows).pluck(:serial)
            raise Conflict.new("Serial #{taken.first} already exists.", reason: 'serial_exists') if taken.any?

            serial_rows.each { |serial| SerialUnit.create!(store: store, variant: variant, stock_location: location, serial: serial) }
          else
            lot_rows.each do |row|
              InventoryLot.create!(store: store, variant: variant, stock_location: location, lot_code: row[:lot_code],
                                   expiry_on: row[:expiry_on], received_quantity: row[:quantity], on_hand: row[:quantity])
            end
          end
        end
      end
    end
  end
end
