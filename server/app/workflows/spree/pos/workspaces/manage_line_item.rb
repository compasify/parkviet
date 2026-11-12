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
              result = LineBuilder.add!(
                workspace: workspace, staff: staff, variant_id: variant_id, quantity: quantity, sale_quantity: sale_quantity,
                sale_unit_code: sale_unit_code, lot_code: lot_code, expiry_on: expiry_on, serial_codes: serial_codes,
                price_override: price_override, merge: merge, measurement_event_id: measurement_event_id,
                label_barcode: label_barcode, modifiers: modifiers, note: note, attributes: { added_by: staff }
              )
              recalculate!(workspace)
              finish!(workspace, staff, 'workspace.item.add', result.audit)
            end
          rescue Conflict
            raise
          end

          def update_quantity(workspace:, staff:, revision:, lease_generation:, editor_id:, key:, sale_line_id:, quantity: nil, sale_quantity: nil)
            payload = command_payload('update_line_item', revision, lease_generation, editor_id, 'sale_line_id' => sale_line_id.to_s, 'quantity' => quantity, 'sale_quantity' => sale_quantity&.to_s)
            execute(workspace:, staff:, key:, payload:) do
              validate_command!(workspace, staff, revision, lease_generation, editor_id)
              sale_line = sale_line!(workspace, sale_line_id)
              Timed::Guard.not_timed!(sale_line, workspace)
              base_quantity = change_quantity!(workspace, sale_line, quantity, sale_quantity)
              finish!(workspace, staff, 'workspace.item.update', sale_line_id: sale_line.prefixed_id, quantity: base_quantity)
            end
          end

          def remove(workspace:, staff:, revision:, lease_generation:, editor_id:, key:, sale_line_id:)
            payload = command_payload('remove_line_item', revision, lease_generation, editor_id, 'sale_line_id' => sale_line_id.to_s)
            execute(workspace:, staff:, key:, payload:) do
              validate_command!(workspace, staff, revision, lease_generation, editor_id)
              sale_line = sale_line!(workspace, sale_line_id)
              Timed::Guard.not_timed!(sale_line, workspace)
              kitchen_sent!(workspace, sale_line, 0)
              sale_id = sale_line.prefixed_id
              remove_line!(workspace, sale_line)
              finish!(workspace, staff, 'workspace.item.remove', sale_line_id: sale_id)
            end
          end

          # Sets a line to a new count or measured amount and sums the order
          # again; the caller checks who may and bumps the revision.
          # @return [Integer] the new base quantity
          def change_quantity!(workspace, sale_line, quantity, sale_quantity)
            raise Conflict, 'A scale label line keeps the labelled quantity.' if sale_line.label_barcode.present?

            variant_unit = variant_unit_for_sale_line(workspace, sale_line)
            if variant_unit.version != (sale_line.conversion_version || 1)
              raise Conflict, 'Unit configuration changed; remove and re-add this line.'
            end
            sale_qty, base_quantity, _kind = LineBuilder.resolve_quantities(variant_unit, quantity, sale_quantity, sale_line.lot_code, sale_line.serial_codes)
            kitchen_sent!(workspace, sale_line, sale_qty)
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
            base_quantity
          end

          # Takes a line off the order and sums the order again.
          def remove_line!(workspace, sale_line)
            Inventory::AllocateTraceability.release_line!(sale_line)
            sale_line.line_item.destroy!
            recalculate!(workspace)
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

          # What the kitchen was told stays on the order: a line goes no lower
          # than its sent quantity, and a sent line keeps its options. Taking
          # back a sent item is a void (an approval), not an edit.
          def kitchen_sent!(workspace, sale_line, sale_quantity)
            return unless sale_line.kitchen_sent_quantity.positive? && sale_quantity < sale_line.kitchen_sent_quantity

            raise Conflict.new('This item was already sent to the kitchen.', revision: workspace.revision, reason: 'kitchen_sent',
                                                                            details: { kitchen_sent_quantity: sale_line.kitchen_sent_quantity.to_s('F') })
          end

          private

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
                !policy.can_edit_workspace?(workspace) || !policy.permission?('write_pos_orders')
            end
            CommandExecutor.call(store: workspace.store, actor: staff, key: key, payload: payload, workspace: workspace, authorize: authorize, &block)
          end

          def validate_command!(workspace, staff, revision, lease_generation, editor_id)
            raise Conflict.new('Workspace is not editing.', revision: workspace.revision) unless workspace.operational_status == 'editing'
            raise Conflict.new('Lease is stale.', revision: workspace.revision, reason: 'lease_stale') unless workspace.lease_current?(staff, editor_id) && workspace.lease_generation == lease_generation
            raise Conflict.new('Revision is stale.', revision: workspace.revision) if workspace.revision != revision
            workspace.ensure_snapshot_editable!
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
