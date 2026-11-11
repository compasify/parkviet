# frozen_string_literal: true

module Spree
  module Pos
    # Puts one variant on a draft: reads a scale label, picks the unit, the
    # lot or serials, the menu price or the list price (or an allowed
    # override), then merges into an existing line or writes a new SaleLine.
    # Shared by the counter's "add item" (Workspaces::ManageLineItem.add) and
    # a table's batch of items (Workspaces::AppendItems); the caller has
    # already checked who may edit the order and how. Runs under the
    # caller's workspace lock.
    module LineBuilder
      Result = Struct.new(:sale_line, :line_item, :audit, keyword_init: true)

      class << self
        # `server_price` sells the item at a price the server set.
        # `merge_scope` is where a mergeable item may join an existing line;
        # `attributes` are written on a new SaleLine (who added it, from
        # which device, in which batch).
        def add!(workspace:, staff:, variant_id:, quantity: nil, sale_quantity: nil, sale_unit_code: nil, lot_code: nil, expiry_on: nil,
                 serial_codes: nil, price_override: nil, merge: nil, measurement_event_id: nil, label_barcode: nil, modifiers: nil,
                 note: nil, merge_scope: nil, server_price: nil, attributes: {})
          SalesChannel.validate_order!(workspace)
          expiry_on = parse_expiry!(expiry_on)
          label = read_label!(workspace, label_barcode, variant_id) if label_barcode.present?
          if label
            variant_id = label.variant.prefixed_id
            sale_quantity = label.sale_quantity
            sale_unit_code = label.variant_unit.sale_unit.code
            quantity = nil
            merge = false
            raise Conflict, 'A scale label already carries its price.' if price_override.present?
          end
          variant = authorized_variant!(workspace, variant_id)
          # Shares the row lock taken when unit configuration changes, so a
          # first sale and a reconfiguration cannot interleave.
          Spree::Variant.where(id: variant.id).lock('FOR SHARE').load
          variant_unit = variant_unit_for(workspace, variant, sale_unit_code)
          serial_codes = trace_inputs!(workspace, variant, variant_unit, serial_codes)
          lot_code, expiry_on = traced_lot!(workspace, variant, lot_code) if variant_unit.tracked_mode == 'lot'
          sale_qty, base_quantity, kind = resolve_quantities(variant_unit, quantity, sale_quantity, lot_code, serial_codes)
          raise Conflict, 'A scale label line takes no options.' if label && (!modifiers.nil? || note.present?)

          menu = label ? nil : SaleLineKinds::Menu.resolve(workspace: workspace, variant: variant, modifiers: modifiers, note: note)
          if menu
            raise Conflict.new('A menu item is priced by the menu.', reason: 'menu_price_fixed') if price_override.present?
            raise Conflict.new('Menu items are sold by count.', reason: 'menu_count_only') unless kind == 'ordinary'

            # A door ticket is a cover of its own, with the drink credit it carries.
            kind = menu.menu_item.door_ticket? ? Workspaces::TableLines::COVER_KIND : SaleLineKinds::Menu::KIND
            unit_price = menu.unit_price
            # The time-of-day menu the price came from names it ("Happy hour").
            attributes = attributes.merge(price_label: menu.schedule&.label) if menu.schedule&.label.present?
          else
            unit_price = resolve_price!(workspace, staff, variant, variant_unit, price_override)
          end
          # A price the server decides: a buffet dish (free, paid by its
          # ticket) or a forfeited deposit's holding fee.
          if server_price
            raise Conflict, 'This item takes no price from the client.' if price_override.present?

            unit_price = server_price
          end
          line_price = UnitNormalizer.unit_price_per_base(price: unit_price, variant_unit: variant_unit)
          merge_key = if menu
                        SaleLineKinds::Menu.merge_key(variant: variant, sale_unit_code: variant_unit.sale_unit.code, line_price: line_price, pricing: menu)
                      else
                        SaleLine.build_merge_key(variant_id: variant.id, kind: kind, unit_price: line_price, sale_unit_code: variant_unit.sale_unit.code, lot_code: lot_code, serial_codes: Array(serial_codes), tracked_mode: variant_unit.tracked_mode, expiry_on: expiry_on)
                      end
          ensure_new_measurement!(workspace, measurement_event_id)
          ensure_unsold_serials!(workspace, serial_codes)

          mergeable = merge == true && SaleLineKinds.mergeable?(kind) && !measured_unit?(variant_unit, sale_quantity) &&
                      Array(serial_codes).empty? && measurement_event_id.blank?
          # Several packages may share a key (added without merge); an explicit
          # merge always goes into the oldest one.
          existing = mergeable ? (merge_scope || SaleLine.where(workspace: workspace)).where(merge_key: merge_key).order(:id).first : nil
          if existing
            line = existing.line_item
            new_base = existing.base_quantity + base_quantity
            raise Conflict, 'Quantity is too large.' if new_base > UnitNormalizer::MAX_BASE_QUANTITY

            line.update!(quantity: new_base, price: line_price)
            existing.update!(base_quantity: new_base, sale_quantity: existing.sale_quantity + sale_qty)
            # Lots are chosen again for the new quantity when payment is prepared.
            Inventory::AllocateTraceability.release_line!(existing)
            sale_line = existing
          else
            line = workspace.order.line_items.build(variant: variant, quantity: base_quantity, price: line_price, currency: workspace.order.currency)
            # Per-base prices (e.g. 0.1 VND/g) are not list prices: mark the
            # line manual so core quantity changes never re-derive the price.
            line.price_source = Spree::LineItem::MANUAL_PRICE_SOURCE
            line.save!
            sale_line = SaleLine.create!(
              workspace: workspace, order: workspace.order, line_item: line, variant: variant, kind: kind,
              merge_key: merge_key, sale_quantity: sale_qty, base_quantity: base_quantity,
              sale_unit_code: variant_unit.sale_unit.code, base_unit_code: variant_unit.base_unit.code,
              ratio_numerator: variant_unit.ratio_numerator, ratio_denominator: variant_unit.ratio_denominator,
              conversion_version: variant_unit.version, unit_price: unit_price, line_price: line_price,
              lot_code: lot_code.presence, expiry_on: expiry_on.presence, serial_codes: Array(serial_codes).map(&:to_s),
              tracked_mode: variant_unit.tracked_mode, measurement_event_id: measurement_event_id.presence,
              label_barcode: label&.barcode, label_format_id: label&.format&.id, label_format_version: label&.format&.version,
              **attributes
            )
            if variant_unit.tracked_mode == 'serial'
              Inventory::AllocateTraceability.reserve_serials!(workspace: workspace, sale_line: sale_line, serials: sale_line.serial_codes)
            end
            SaleLineKinds::Menu.record!(sale_line, menu) if menu
          end
          audit = { variant_id: variant.prefixed_id, sale_line_id: sale_line.prefixed_id, line_item_id: line.prefixed_id, quantity: base_quantity }
          audit[:menu] = SaleLineKinds::Menu.audit(menu) if menu
          audit.merge!(label_barcode: label.barcode, label_format_version: label.format.version, label_amount: label.label_amount&.to_s('F')) if label
          if price_override.present?
            list_price = SalesChannel.price(variant, store: workspace.store, currency: workspace.order.currency, order: workspace.order).amount
            audit.merge!(price_override: { before: list_price.to_s('F'), after: unit_price.to_s('F') })
          end
          Result.new(sale_line: sale_line, line_item: line, audit: audit)
        end

        # [sale quantity, base quantity, kind] of a count or a measured amount.
        def resolve_quantities(variant_unit, quantity, sale_quantity, lot_code, serial_codes)
          tracked = variant_unit.tracked_mode != 'none' || lot_code.present? || Array(serial_codes).any?
          serials = Array(serial_codes)
          if measured_unit?(variant_unit, sale_quantity)
            qty_string = sale_quantity.presence || quantity&.to_s
            raise Conflict, 'Measured sale quantity is required.' if qty_string.blank?

            base = UnitNormalizer.call(sale_quantity: qty_string.to_s, variant_unit: variant_unit)
            sale_qty = BigDecimal(qty_string.to_s)
            [sale_qty, base, tracked ? 'tracked' : 'measured']
          else
            count = positive_integer!(quantity.presence || sale_quantity)
            validate_serials!(variant_unit, serials, count)
            [BigDecimal(count), count * variant_unit.sale_unit.factor_to_base * variant_unit.ratio_numerator / variant_unit.ratio_denominator, tracked ? 'tracked' : 'ordinary']
          end
        end

        def measured_unit?(variant_unit, sale_quantity)
          sale_quantity.present? || variant_unit.sale_unit.code != variant_unit.base_unit.code ||
            variant_unit.ratio_numerator != variant_unit.ratio_denominator
        end

        private

        # Serial-tracked goods carry exactly one distinct serial per unit sold.
        def validate_serials!(variant_unit, serials, count)
          serial_mode = variant_unit.tracked_mode == 'serial'
          return if serials.empty? && !serial_mode

          raise Conflict.new('Serial numbers must match the quantity.', reason: 'trace_serial_required') unless serials.size == count
          raise Conflict.new('Each serial number can be scanned once.', reason: 'trace_serial_duplicate') unless serials.uniq.size == serials.size
        end

        # Tracked goods are sold only where their typed stock is reconciled;
        # serial numbers belong to serial-tracked goods only.
        def trace_inputs!(workspace, variant, variant_unit, serial_codes)
          mode = variant_unit.tracked_mode
          serials = Array(serial_codes).map { |code| mode == 'serial' ? SerialUnit.normalize(code) : code.to_s }
          StockIntegration.ensure_sellable!(workspace.branch, variant, mode) if %w[serial lot].include?(mode)
          # One serial is one base unit; a pack or measured sale unit would
          # sell several units under one serial.
          if mode == 'serial' && (variant_unit.sale_unit.code != variant_unit.base_unit.code ||
                                  variant_unit.ratio_numerator != variant_unit.ratio_denominator || variant_unit.sale_unit.factor_to_base != 1)
            raise Conflict.new('Serial-tracked items are sold one unit per serial.', reason: 'trace_serial_unit_mismatch')
          end
          if serials.any? && mode != 'serial'
            raise Conflict.new('Serial numbers apply only to serial-tracked items.', reason: 'trace_serial_invalid')
          end

          serials
        end

        # Lot-tracked goods take lots FEFO on the server; a cashier may name a
        # lot only where the branch allows picking, and only a sellable one.
        def traced_lot!(workspace, variant, lot_code)
          return [nil, nil] if lot_code.blank?

          branch = workspace.branch
          unless branch.lot_selection == 'cashier_pick'
            raise Conflict.new('Lots are chosen by expiry (FEFO) at this branch.', reason: 'trace_lot_pick_forbidden')
          end

          today = StockIntegration.today(branch)
          lot = FefoAllocator.candidates(variant, branch.stock_location, today).find { |row| row.lot_code == lot_code.to_s }
          raise Conflict.new('The chosen lot cannot be sold (expired, quarantined or not at this branch).', reason: 'trace_lot_invalid') if lot.nil?

          [lot.lot_code, lot.expiry_on&.iso8601]
        end

        def parse_expiry!(value)
          return nil if value.blank?

          Date.iso8601(value.to_s).iso8601
        rescue Date::Error
          raise Conflict, 'Expiry date is invalid.'
        end

        def ensure_unsold_serials!(workspace, serial_codes)
          codes = Array(serial_codes).map(&:to_s)
          return if codes.empty?
          return unless SaleLine.where(workspace: workspace).where('serial_codes ?| array[:codes]', codes: codes).exists?

          raise Conflict.new('A serial number is already on this order.', reason: 'trace_serial_duplicate')
        end

        def ensure_new_measurement!(workspace, measurement_event_id)
          return if measurement_event_id.blank?
          return unless SaleLine.exists?(workspace: workspace, measurement_event_id: measurement_event_id.to_s)

          raise Conflict, 'This measurement was already added.'
        end

        def resolve_price!(workspace, staff, variant, variant_unit, price_override)
          list_price = SalesChannel.price(variant, store: workspace.store, currency: workspace.order.currency, order: workspace.order)&.amount
          raise Conflict, 'Variant has no price in the order currency.' if list_price.nil?

          return list_price if price_override.blank?

          policy = AccessPolicy.new(store: workspace.store, staff: staff)
          unless policy.allows?(workspace.branch, Capabilities::PRICE_OVERRIDE)
            approval_hint = 'Price override approval is required.'
            raise Conflict, approval_hint
          end
          amount = Record.money(price_override.to_s)
          raise Conflict, 'Price override is invalid.' if amount.nil? || amount < 0
          raise Conflict, 'Price override is invalid.' if workspace.order.currency == 'VND' && !amount.frac.zero?

          amount
        end

        def variant_unit_for(workspace, variant, sale_unit_code)
          UnitDefinition.ensure_defaults!(workspace.store)
          configured = VariantUnit.find_by(store: workspace.store, variant: variant, status: 'active')
          if configured
            raise Conflict, 'Sale unit does not match this SKU configuration.' if sale_unit_code.present? && sale_unit_code.to_s != configured.sale_unit.code

            return configured
          end
          raise Conflict, 'Tracked or measured sale requires unit configuration for this SKU.' if sale_unit_code.present? && !%w[item chai].include?(sale_unit_code.to_s)

          unit = UnitDefinition.find_by!(store: workspace.store, code: sale_unit_code.presence || 'item')
          VariantUnit.new(store: workspace.store, variant: variant, sale_unit: unit, base_unit: unit, price_unit: unit, ratio_numerator: 1, ratio_denominator: 1, tracked_mode: 'none', version: 1)
        end

        def read_label!(workspace, barcode, variant_id)
          label = MeasurementBarcodeParser.call(branch: workspace.branch, barcode: barcode, currency: workspace.order.currency, order: workspace.order)
          raise Conflict, 'Barcode is not a scale label of this branch.' if label.nil?
          raise Conflict, 'Scale label does not match the selected item.' if variant_id.present? && variant_id.to_s != label.variant.prefixed_id

          label
        end

        def authorized_variant!(workspace, variant_id)
          Workspaces::ManageLineItem.sellable_variant!(branch: workspace.branch, variant: Spree::Variant.find_by_prefix_id(variant_id.to_s))
        end

        # Counts are whole numbers: a JSON 1.9 or "1.5" is rejected, never truncated.
        def positive_integer!(quantity)
          value = case quantity
                  when Integer then quantity
                  when /\A\d{1,9}\z/ then Integer(quantity, 10)
                  end
          raise Conflict, 'Quantity is invalid.' unless value&.between?(1, Workspaces::ManageLineItem::MAX_QUANTITY)

          value
        end
      end
    end
  end
end
