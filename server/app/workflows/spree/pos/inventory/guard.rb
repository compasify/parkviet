# frozen_string_literal: true

module Spree
  module Pos
    module Inventory
      # Shared lookups, input parsing and locks of the typed stock commands.
      # Lock order for every trace writer of a (variant, location) pair:
      #   workspace -> core stock level(s) by id -> lots by id / serial units -> sale lines.
      module Guard
        module_function

        MAX_ROWS = 500

        def authorize!(store, staff, branch, capability = Capabilities::INVENTORY_MANAGE)
          policy = AccessPolicy.new(store: store, staff: staff)
          raise CanCan::AccessDenied if branch.disabled? || !policy.permission?('write_pos_orders') || !policy.allows?(branch, capability)
        end

        def branch!(store, branch_id)
          branch = Branch.locate(Branch.for_store(store), branch_id)
          raise ActiveRecord::RecordNotFound if branch.nil?

          branch
        end

        def variant!(store, branch, variant_id)
          variant = Spree::Variant.find_by_prefix_id(variant_id.to_s)
          raise ActiveRecord::RecordNotFound if variant.nil? || variant.product.nil? || variant.product.store_id != store.id
          raise ActiveRecord::RecordNotFound unless BranchProduct.exists?(branch_id: branch.id, product_id: variant.product_id)

          variant
        end

        def mode!(store, variant)
          mode = StockIntegration.tracked_mode(store.id, variant)
          raise Conflict.new('This item is not tracked by serial or lot.', reason: 'not_tracked') if mode == 'none'
          raise Conflict.new('Tracked items need stock tracking turned on in the catalog.', reason: 'not_tracked') unless variant.track_inventory?

          mode
        end

        # Typed stock may only change from a reconciled state.
        def reconciled!(branch, variant, mode)
          case StockIntegration.blocked_reason(branch, variant, mode)
          when 'not_enrolled'
            raise Conflict.new('Record an opening balance for this item at this branch first.', reason: 'trace_not_enrolled')
          when 'unreconciled'
            raise Conflict.new('Tracked stock does not match the shelf count; reconcile it with a count first.', reason: 'trace_unreconciled')
          end
        end

        def lock_levels!(variant, locations)
          Spree::StockLevel.where(variant_id: variant.id, stock_location_id: locations.map(&:id)).order(:id).lock.to_a
        end

        def serials!(list)
          rows = Array(list).map { |value| SerialUnit.normalize(value) }
          raise Conflict.new('Too many rows in one command.', reason: 'too_many_rows') if rows.length > MAX_ROWS
          raise Conflict.new('Each serial number can appear once.', reason: 'trace_serial_duplicate') if rows.uniq.length != rows.length

          rows
        end

        def quantity!(value)
          number = value.is_a?(Integer) ? value : (Integer(value.to_s, 10) if value.to_s.match?(/\A\d{1,10}\z/))
          unless number&.positive? && number <= UnitNormalizer::MAX_BASE_QUANTITY
            raise Conflict.new('Quantity must be a positive whole number of base units.', reason: 'quantity_invalid')
          end

          number
        end

        def count!(value)
          number = value.is_a?(Integer) ? value : (Integer(value.to_s, 10) if value.to_s.match?(/\A\d{1,10}\z/))
          if number.nil? || number.negative? || number > UnitNormalizer::MAX_BASE_QUANTITY
            raise Conflict.new('Counted quantity must be a whole number of base units.', reason: 'quantity_invalid')
          end

          number
        end

        def expiry!(value)
          return nil if value.blank?

          Date.iso8601(value.to_s)
        rescue Date::Error
          raise Conflict.new('Expiry date is invalid.', reason: 'expiry_invalid')
        end

        # [{ lot_code:, expiry_on:, quantity: }] for receipts and opening balances.
        def lot_rows!(list)
          rows = rows_of(list).map do |row|
            code = row[:lot_code].to_s.strip
            raise Conflict.new('Lot code is required.', reason: 'lot_code_invalid') if code.empty? || code.length > 64

            { lot_code: code, expiry_on: expiry!(row[:expiry_on]), quantity: quantity!(row[:quantity]) }
          end
          raise Conflict.new('Each lot can appear once.', reason: 'duplicate_lot') if rows.map { |row| row[:lot_code] }.uniq.length != rows.length

          rows
        end

        def rows_of(list)
          rows = list.respond_to?(:to_unsafe_h) ? list.to_unsafe_h.values : Array(list)
          raise Conflict.new('Too many rows in one command.', reason: 'too_many_rows') if rows.length > MAX_ROWS

          rows.map { |row| (row.respond_to?(:to_unsafe_h) ? row.to_unsafe_h : row.to_h).with_indifferent_access }
        end

        def lot!(store, lot_id, stock_location, variant)
          lot = InventoryLot.locate(InventoryLot.for_store(store), lot_id)
          raise ActiveRecord::RecordNotFound if lot.nil? || lot.stock_location_id != stock_location.id || lot.variant_id != variant.id

          lot
        end

        def finish!(store, staff, action, subject, metadata)
          AuditEntry.record!(store: store, actor: staff, action: action, subject: subject, metadata: metadata)
          OutboxEntry.record!(store: store, event_type: action, aggregate: subject, payload: metadata.transform_keys(&:to_s))
        end
      end
    end
  end
end
