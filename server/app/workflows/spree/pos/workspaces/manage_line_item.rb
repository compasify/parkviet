# frozen_string_literal: true

module Spree
  module Pos
    module Workspaces
      # SaleLine-aware item commands. Counted lines (including one lot and expiry)
      # merge only on an explicit compatible key; measured packages and serial
      # units always keep their own SaleLine.
      class ManageLineItem
        MAX_QUANTITY = 10_000

        class << self
          # `modifiers` ([{ option_id:, quantity: }]) and `note` attach menu
          # options; nil modifiers means none were sent (the menu defaults apply).
          def add(workspace:, staff:, revision:, lease_generation:, editor_id:, key:, variant_id: nil, quantity: nil, sale_quantity: nil, sale_unit_code: nil, lot_code: nil, expiry_on: nil, serial_codes: nil, price_override: nil, merge: nil, measurement_event_id: nil, label_barcode: nil, modifiers: nil, note: nil)
            input = {
              'variant_id' => variant_id.to_s, 'quantity' => quantity, 'sale_quantity' => sale_quantity&.to_s,
              'sale_unit_code' => sale_unit_code&.to_s, 'lot_code' => lot_code&.to_s.presence,
              'expiry_on' => expiry_on&.to_s.presence, 'serial_codes' => Array(serial_codes).map(&:to_s),
              'price_override' => price_override&.to_s.presence, 'merge' => merge == true,
              'measurement_event_id' => measurement_event_id&.to_s.presence, 'label_barcode' => label_barcode&.to_s.presence
            }
            # Present only when sent, so the payload digest of a retail add is unchanged.
            modifiers = normalize_modifiers(modifiers)
            check_note!(note)
            input['modifiers'] = modifiers unless modifiers.nil?
            input['note'] = note.to_s if note.present?
            payload = command_payload('add_line_item', revision, lease_generation, editor_id, input)
            execute(workspace:, staff:, key:, payload:) do
              validate_command!(workspace, staff, revision, lease_generation, editor_id)
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

                kind = SaleLineKinds::Menu::KIND
                unit_price = menu.unit_price
              else
                unit_price = resolve_price!(workspace, staff, variant, variant_unit, price_override)
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
              existing = mergeable ? SaleLine.where(workspace: workspace, merge_key: merge_key).order(:id).first : nil
              line = nil
              sale_line = nil
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
                  label_barcode: label&.barcode, label_format_id: label&.format&.id, label_format_version: label&.format&.version
                )
                if variant_unit.tracked_mode == 'serial'
                  Inventory::AllocateTraceability.reserve_serials!(workspace: workspace, sale_line: sale_line, serials: sale_line.serial_codes)
                end
                SaleLineKinds::Menu.record!(sale_line, menu) if menu
              end
              recalculate!(workspace)
              audit = { variant_id: variant.prefixed_id, sale_line_id: sale_line.prefixed_id, line_item_id: line.prefixed_id, quantity: base_quantity }
              audit[:menu] = SaleLineKinds::Menu.audit(menu) if menu
              audit.merge!(label_barcode: label.barcode, label_format_version: label.format.version, label_amount: label.label_amount&.to_s('F')) if label
              if price_override.present?
                list_price = SalesChannel.price(variant, store: workspace.store, currency: workspace.order.currency, order: workspace.order).amount
                audit.merge!(price_override: { before: list_price.to_s('F'), after: unit_price.to_s('F') })
              end
              finish!(workspace, staff, 'workspace.item.add', audit)
            end
          rescue Conflict
            raise
          end

          def update_quantity(workspace:, staff:, revision:, lease_generation:, editor_id:, key:, sale_line_id:, quantity: nil, sale_quantity: nil)
            payload = command_payload('update_line_item', revision, lease_generation, editor_id, 'sale_line_id' => sale_line_id.to_s, 'quantity' => quantity, 'sale_quantity' => sale_quantity&.to_s)
            execute(workspace:, staff:, key:, payload:) do
              validate_command!(workspace, staff, revision, lease_generation, editor_id)
              sale_line = sale_line!(workspace, sale_line_id)
              raise Conflict, 'A scale label line keeps the labelled quantity.' if sale_line.label_barcode.present?

              variant_unit = variant_unit_for_sale_line(workspace, sale_line)
              if variant_unit.version != (sale_line.conversion_version || 1)
                raise Conflict, 'Unit configuration changed; remove and re-add this line.'
              end
              sale_qty, base_quantity, _kind = resolve_quantities(variant_unit, quantity, sale_quantity, sale_line.lot_code, sale_line.serial_codes)
              if base_quantity > sale_line.base_quantity
                SalesChannel.validate_order!(workspace)
                sellable_variant!(branch: workspace.branch, variant: sale_line.variant)
                SaleLineKinds::Menu.ensure_line_available!(workspace, sale_line) if sale_line.kind == SaleLineKinds::Menu::KIND
              end
              sale_line.line_item.update!(quantity: base_quantity)
              changed = sale_line.base_quantity != base_quantity
              sale_line.update!(sale_quantity: sale_qty, base_quantity: base_quantity)
              # Reservations only follow a real quantity change.
              Inventory::AllocateTraceability.release_line!(sale_line) if changed
              recalculate!(workspace)
              finish!(workspace, staff, 'workspace.item.update', sale_line_id: sale_line.prefixed_id, quantity: base_quantity)
            end
          end

          def remove(workspace:, staff:, revision:, lease_generation:, editor_id:, key:, sale_line_id:)
            payload = command_payload('remove_line_item', revision, lease_generation, editor_id, 'sale_line_id' => sale_line_id.to_s)
            execute(workspace:, staff:, key:, payload:) do
              validate_command!(workspace, staff, revision, lease_generation, editor_id)
              sale_line = sale_line!(workspace, sale_line_id)
              sale_id = sale_line.prefixed_id
              Inventory::AllocateTraceability.release_line!(sale_line)
              sale_line.line_item.destroy!
              recalculate!(workspace)
              finish!(workspace, staff, 'workspace.item.remove', sale_line_id: sale_id)
            end
          end

          # Backward-compatible wrappers used by older callers/tests.
          def update_quantity_by_line(workspace:, staff:, revision:, lease_generation:, editor_id:, key:, line_item_id:, quantity:)
            sale_line = SaleLine.find_by!(workspace: workspace, line_item_id: Spree::LineItem.find_by_prefix_id!(line_item_id.to_s).id)
            update_quantity(workspace:, staff:, revision:, lease_generation:, editor_id:, key:, sale_line_id: sale_line.prefixed_id, quantity: quantity)
          end

          def remove_by_line(workspace:, staff:, revision:, lease_generation:, editor_id:, key:, line_item_id:)
            sale_line = SaleLine.find_by!(workspace: workspace, line_item_id: Spree::LineItem.find_by_prefix_id!(line_item_id.to_s).id)
            remove(workspace:, staff:, revision:, lease_generation:, editor_id:, key:, sale_line_id: sale_line.prefixed_id)
          end

          # Menu options as plain hashes, or nil when none were sent. Shared
          # with UpdateLineModifiers. Quantities are checked by Menu::Pricing.
          def normalize_modifiers(modifiers)
            return nil if modifiers.nil?
            raise Conflict.new('Options are invalid.', reason: 'modifier_unknown') unless modifiers.is_a?(Array)

            modifiers.map do |row|
              raise Conflict.new('Options are invalid.', reason: 'modifier_unknown') unless row.is_a?(Hash)

              row = row.stringify_keys
              { 'option_id' => row['option_id'].to_s, 'quantity' => row['quantity'].nil? ? 1 : row['quantity'] }
            end
          end

          def check_note!(note)
            raise Conflict.new('The note is too long.', reason: 'note_too_long') if note.to_s.length > 200
          end

          private

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

          def variant_unit_for_sale_line(workspace, sale_line)
            UnitDefinition.ensure_defaults!(workspace.store)
            configured = VariantUnit.find_by(store: workspace.store, variant: sale_line.variant, status: 'active')
            return configured if configured

            unit = UnitDefinition.find_by!(store: workspace.store, code: sale_line.sale_unit_code)
            base = UnitDefinition.find_by!(store: workspace.store, code: sale_line.base_unit_code)
            VariantUnit.new(store: workspace.store, variant: sale_line.variant, sale_unit: unit, base_unit: base, price_unit: unit, ratio_numerator: sale_line.ratio_numerator, ratio_denominator: sale_line.ratio_denominator, tracked_mode: sale_line.tracked_mode, version: sale_line.conversion_version || 1)
          end

          def sale_line!(workspace, sale_line_id)
            sale = SaleLine.locate(SaleLine.where(workspace_id: workspace.id), sale_line_id)
            return sale if sale

            # Compatibility: callers may still send a core line-item prefixed ID.
            line = Spree::LineItem.find_by_prefix_id(sale_line_id.to_s)
            sale = line && SaleLine.find_by(workspace: workspace, line_item_id: line.id)
            raise ActiveRecord::RecordNotFound if sale.nil?

            sale
          end

          def command_payload(command, revision, lease_generation, editor_id, extra)
            { 'command' => command, 'revision' => revision, 'lease_generation' => lease_generation, 'editor_digest' => Workspace.editor_digest(editor_id) }.merge(extra)
          end

          def execute(workspace:, staff:, key:, payload:, &block)
            authorize = lambda do
              policy = AccessPolicy.new(store: workspace.store, staff: staff)
              raise CanCan::AccessDenied if workspace.branch.disabled? || workspace.register&.disabled? ||
                workspace.shift.owner_id != staff.id ||
                !policy.permission?('write_pos_orders') || !policy.allows?(workspace.branch, Capabilities::OPEN_SHIFT)
            end
            CommandExecutor.call(store: workspace.store, actor: staff, key: key, payload: payload, workspace: workspace, authorize: authorize, &block)
          end

          def validate_command!(workspace, staff, revision, lease_generation, editor_id)
            raise Conflict.new('Workspace is not editing.', revision: workspace.revision) unless workspace.operational_status == 'editing'
            raise Conflict.new('Lease is stale.', revision: workspace.revision, reason: 'lease_stale') unless workspace.lease_current?(staff, editor_id) && workspace.lease_generation == lease_generation
            raise Conflict.new('Revision is stale.', revision: workspace.revision) if workspace.revision != revision
            workspace.ensure_snapshot_editable!
          end

          def read_label!(workspace, barcode, variant_id)
            label = MeasurementBarcodeParser.call(branch: workspace.branch, barcode: barcode, currency: workspace.order.currency, order: workspace.order)
            raise Conflict, 'Barcode is not a scale label of this branch.' if label.nil?
            raise Conflict, 'Scale label does not match the selected item.' if variant_id.present? && variant_id.to_s != label.variant.prefixed_id

            label
          end

          def authorized_variant!(workspace, variant_id)
            sellable_variant!(branch: workspace.branch, variant: Spree::Variant.find_by_prefix_id(variant_id.to_s))
          end

          public

          # One rule for every path that puts a variant on a branch's sale.
          def sellable_variant!(branch:, variant:)
            product = variant&.product
            now = Time.current
            raise ActiveRecord::RecordNotFound if variant.nil? || product.nil? || product.store_id != branch.store_id ||
              product.status != 'active' || !BranchProduct.exists?(branch_id: branch.id, product_id: variant.product_id) ||
              !SalesChannel.sellable_products(branch.store).exists?(id: product.id) ||
              (variant.is_master? && Spree::Variant.where(product_id: product.id, is_master: false).exists?) ||
              (product.available_on.present? && product.available_on > now) ||
              (product.discontinue_on.present? && product.discontinue_on <= now) ||
              (variant.discontinue_on.present? && variant.discontinue_on <= now)

            variant
          end

          private

          # Counts are whole numbers: a JSON 1.9 or "1.5" is rejected, never truncated.
          def positive_integer!(quantity)
            value = case quantity
                    when Integer then quantity
                    when /\A\d{1,9}\z/ then Integer(quantity, 10)
                    end
            raise Conflict, 'Quantity is invalid.' unless value&.between?(1, MAX_QUANTITY)

            value
          end

          def recalculate!(workspace)
            ApplyDiscount.recalculate!(workspace)
          end

          def finish!(workspace, staff, action, metadata)
            workspace.update!(revision: workspace.revision + 1)
            AuditEntry.record!(store: workspace.store, actor: staff, action: action, subject: workspace, metadata: metadata)
            workspace.to_pos
          end
        end
      end
    end
  end
end
