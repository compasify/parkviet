# frozen_string_literal: true

module Spree
  module Pos
    module Workspaces
      # Replaces the options and note of a menu line. The line keeps the base
      # price it was sold at; only the options are priced again. When the new
      # set matches another line of the order, the two become one line.
      # Same revision, lease and snapshot checks as every item command.
      class UpdateLineModifiers
        MODULE = SaleLineKinds::Menu::MODULE

        def self.call(workspace:, staff:, revision:, lease_generation:, editor_id:, key:, sale_line_id:, modifiers:, note: nil)
          items = ManageLineItem
          modifiers = items.normalize_modifiers(modifiers) || []
          items.check_note!(note)
          payload = items.send(:command_payload, 'update_line_modifiers', revision, lease_generation, editor_id,
                               'sale_line_id' => sale_line_id.to_s, 'modifiers' => modifiers, 'note' => note.to_s)
          items.send(:execute, workspace: workspace, staff: staff, key: key, payload: payload) do
            items.send(:validate_command!, workspace, staff, revision, lease_generation, editor_id)
            ModulePolicy.require!(workspace.branch, MODULE)
            sale_line = items.send(:sale_line!, workspace, sale_line_id)
            raise Conflict.new('Only a menu line has options.', reason: 'modifier_unknown') unless sale_line.kind == SaleLineKinds::Menu::KIND

            item = MenuItem.for_variant(workspace.store, sale_line.variant)
            raise Conflict.new('This item is not on the menu.', reason: 'modifier_unknown') if item.nil?

            before = sale_line.line_modifiers.map { |row| { name: row.name, quantity: row.quantity } }
            base_price = sale_line.unit_price - sale_line.line_modifiers.sum(BigDecimal('0')) { |row| row.price_delta * row.quantity }
            pricing = Menu::Pricing.resolve(branch: workspace.branch, variant: sale_line.variant, selections: modifiers,
                                            now: Workspace.business_now, note: note, currency: workspace.order.currency,
                                            order: workspace.order, menu_item: item, base_price: base_price)
            variant_unit = items.send(:variant_unit_for_sale_line, workspace, sale_line)
            line_price = UnitNormalizer.unit_price_per_base(price: pricing.unit_price, variant_unit: variant_unit)
            sale_line.assign_attributes(unit_price: pricing.unit_price, line_price: line_price,
                                        modifier_signature: pricing.modifier_signature, note: pricing.note)
            merge_key = sale_line.merge_key_now
            result = merge_into_twin(workspace, sale_line, merge_key) ||
                     replace_options(sale_line, merge_key, line_price, pricing)
            items.send(:recalculate!, workspace)
            items.send(:finish!, workspace, staff, 'workspace.item.modifiers',
                       sale_line_id: result.prefixed_id, merged_from: result.id == sale_line.id ? nil : sale_line.prefixed_id,
                       before: before, after: SaleLineKinds::Menu.audit(pricing))
          end
        end

        # The oldest other line with the same key takes this line's quantity.
        # A line with its own discount keeps its row.
        def self.merge_into_twin(workspace, sale_line, merge_key)
          twin = SaleLine.where(workspace_id: workspace.id, merge_key: merge_key).where.not(id: sale_line.id).order(:id).first
          return if twin.nil? || twin.line_discount_intent || sale_line.line_discount_intent

          new_base = twin.base_quantity + sale_line.base_quantity
          raise Conflict, 'Quantity is too large.' if new_base > UnitNormalizer::MAX_BASE_QUANTITY

          added = sale_line.sale_quantity
          Inventory::AllocateTraceability.release_line!(sale_line)
          sale_line.line_item.destroy!
          twin.line_item.update!(quantity: new_base)
          twin.update!(base_quantity: new_base, sale_quantity: twin.sale_quantity + added)
          Inventory::AllocateTraceability.release_line!(twin)
          twin
        end

        def self.replace_options(sale_line, merge_key, line_price, pricing)
          sale_line.line_item.update!(price: line_price, price_source: Spree::LineItem::MANUAL_PRICE_SOURCE)
          sale_line.update!(merge_key: merge_key)
          SaleLineKinds::Menu.record!(sale_line, pricing)
          sale_line
        end
      end
    end
  end
end
