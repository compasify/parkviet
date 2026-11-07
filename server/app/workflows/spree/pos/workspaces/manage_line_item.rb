# frozen_string_literal: true

module Spree
  module Pos
    module Workspaces
      # SaleLine-aware item commands. Ordinary scans merge only on an explicit
      # compatible key; measured/tracked adds always create a distinct SaleLine.
      class ManageLineItem
        MAX_QUANTITY = 10_000

        class << self
          def add(workspace:, staff:, revision:, lease_generation:, editor_id:, key:, variant_id:, quantity: nil, sale_quantity: nil, sale_unit_code: nil, lot_code: nil, expiry_on: nil, serial_codes: nil, price_override: nil, merge: nil, measurement_event_id: nil)
            input = {
              'variant_id' => variant_id.to_s, 'quantity' => quantity, 'sale_quantity' => sale_quantity&.to_s,
              'sale_unit_code' => sale_unit_code&.to_s, 'lot_code' => lot_code&.to_s.presence,
              'expiry_on' => expiry_on&.to_s.presence, 'serial_codes' => Array(serial_codes).map(&:to_s),
              'price_override' => price_override&.to_s.presence, 'merge' => merge == true,
              'measurement_event_id' => measurement_event_id&.to_s.presence
            }
            payload = command_payload('add_line_item', revision, lease_generation, editor_id, input)
            execute(workspace:, staff:, key:, payload:) do
              validate_command!(workspace, staff, revision, lease_generation, editor_id)
              variant = authorized_variant!(workspace, variant_id)
              variant_unit = variant_unit_for(workspace, variant, sale_unit_code)
              sale_qty, base_quantity, kind = resolve_quantities(variant_unit, quantity, sale_quantity, lot_code, serial_codes)
              unit_price = resolve_price!(workspace, staff, variant, variant_unit, price_override)
              line_price = UnitNormalizer.unit_price_per_base(price: unit_price, variant_unit: variant_unit)
              merge_key = SaleLine.build_merge_key(variant_id: variant.id, kind: kind, unit_price: line_price, sale_unit_code: variant_unit.sale_unit.code, lot_code: lot_code, serial_codes: Array(serial_codes), tracked_mode: variant_unit.tracked_mode)

              existing = merge == true ? SaleLine.find_by(workspace: workspace, merge_key: merge_key) : nil
              line = nil
              sale_line = nil
              if existing
                line = existing.line_item
                new_base = existing.base_quantity + base_quantity
                raise Conflict, 'Quantity is too large.' if new_base > UnitNormalizer::MAX_BASE_QUANTITY

                line.update!(quantity: new_base, price: line_price)
                existing.update!(base_quantity: new_base, sale_quantity: existing.sale_quantity + sale_qty)
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
                  tracked_mode: variant_unit.tracked_mode, measurement_event_id: measurement_event_id.presence
                )
              end
              recalculate!(workspace)
              finish!(workspace, staff, 'workspace.item.add', variant_id: variant.prefixed_id, sale_line_id: sale_line.prefixed_id, line_item_id: line.prefixed_id, quantity: base_quantity)
            end
          rescue Conflict
            raise
          end

          def update_quantity(workspace:, staff:, revision:, lease_generation:, editor_id:, key:, sale_line_id:, quantity: nil, sale_quantity: nil)
            payload = command_payload('update_line_item', revision, lease_generation, editor_id, 'sale_line_id' => sale_line_id.to_s, 'quantity' => quantity, 'sale_quantity' => sale_quantity&.to_s)
            execute(workspace:, staff:, key:, payload:) do
              validate_command!(workspace, staff, revision, lease_generation, editor_id)
              sale_line = sale_line!(workspace, sale_line_id)
              variant_unit = variant_unit_for_sale_line(workspace, sale_line)
              sale_qty, base_quantity, _kind = resolve_quantities(variant_unit, quantity, sale_quantity, sale_line.lot_code, sale_line.serial_codes, measured: sale_line.kind != 'ordinary')
              sale_line.line_item.update!(quantity: base_quantity)
              sale_line.update!(sale_quantity: sale_qty, base_quantity: base_quantity)
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

          private

          def resolve_quantities(variant_unit, quantity, sale_quantity, lot_code, serial_codes, measured: nil)
            tracked = variant_unit.tracked_mode != 'none' || lot_code.present? || Array(serial_codes).any?
            if sale_quantity.present? || variant_unit.sale_unit.code != variant_unit.base_unit.code || variant_unit.ratio_numerator != variant_unit.ratio_denominator
              qty_string = sale_quantity.presence || quantity&.to_s
              raise Conflict, 'Measured sale quantity is required.' if qty_string.blank?

              base = UnitNormalizer.call(sale_quantity: qty_string.to_s, variant_unit: variant_unit)
              sale_qty = BigDecimal(qty_string.to_s)
              [sale_qty, base, tracked ? 'tracked' : 'measured']
            else
              count = positive_integer!(quantity.presence || sale_quantity)
              [BigDecimal(count), count * variant_unit.sale_unit.factor_to_base * variant_unit.ratio_numerator / variant_unit.ratio_denominator, tracked ? 'tracked' : 'ordinary']
            end
          end

          def resolve_price!(workspace, staff, variant, variant_unit, price_override)
            list_price = variant.price_in(workspace.order.currency)&.amount
            raise Conflict, 'Variant has no price in the order currency.' if list_price.nil?

            return list_price if price_override.blank?

            policy = AccessPolicy.new(store: workspace.store, staff: staff)
            unless policy.allows?(workspace.branch, Capabilities::PRICE_OVERRIDE)
              approval_hint = 'Price override approval is required.'
              raise Conflict, approval_hint
            end
            amount = Record.money(price_override.to_s)
            raise Conflict, 'Price override is invalid.' if amount.nil? || amount < 0

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
            raise Conflict, 'Order is completed or has a payment.' if workspace.order.completed? || workspace.order.payments.exists?
            if defined?(Spree::Pos::TenderAttempt)
              raise Conflict, 'Order snapshot is locked by a tender commitment.' if TenderAttempt.where(workspace: workspace, status: %w[prepared confirmed]).exists?
            end
          end

          def authorized_variant!(workspace, variant_id)
            variant = Spree::Variant.find_by_prefix_id(variant_id.to_s)
            raise ActiveRecord::RecordNotFound if variant.nil? || variant.product.nil? || variant.product.store_id != workspace.store_id ||
              variant.product.status != 'active' || !BranchProduct.exists?(branch_id: workspace.branch_id, product_id: variant.product_id) ||
              (variant.discontinue_on.present? && variant.discontinue_on <= Time.current)

            variant
          end

          def positive_integer!(quantity)
            value = Integer(quantity)
            raise Conflict, 'Quantity is invalid.' unless value.between?(1, MAX_QUANTITY)

            value
          rescue ArgumentError, TypeError
            raise Conflict, 'Quantity is invalid.'
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
