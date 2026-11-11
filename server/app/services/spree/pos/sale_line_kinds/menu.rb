# frozen_string_literal: true

module Spree
  module Pos
    class SaleLineKinds
      # The `menu` kind: a line of a menu item, priced by Menu::Pricing and
      # sold with a snapshot of its options and combo contents. It never goes
      # through a price override, since the client cannot send a price.
      #
      # A branch without `fnb.menu` sells the same variant as an ordinary
      # line at its list price; only attaching options or a note is refused.
      module Menu
        KIND = 'menu'
        MODULE = 'fnb.menu'

        module_function

        # A Menu::Pricing::Result when the line sells as `menu`, nil when it
        # sells as before. `modifiers` nil means none were sent.
        def resolve(workspace:, variant:, modifiers:, note:)
          attached = !modifiers.nil? || note.present?
          branch = workspace.branch
          unless ModulePolicy.enabled?(branch, MODULE)
            ModulePolicy.refuse!(MODULE) if attached
            return nil
          end

          item = MenuItem.for_variant(workspace.store, variant)
          if item.nil?
            raise Conflict.new('This item is not on the menu.', reason: 'modifier_unknown') if attached

            return nil
          end

          # The business-date clock: the database clock, which specs can move.
          now = Workspace.business_now
          ensure_available!(branch, item, now)
          Pos::Menu::Pricing.resolve(branch: branch, variant: variant, selections: modifiers, now: now, note: note,
                                     currency: workspace.order.currency, order: workspace.order, menu_item: item)
        end

        def ensure_available!(branch, item, now)
          return unless MenuAvailability.sold_out?(branch, item, BusinessDay.for(branch, now))

          raise Conflict.new('This item is sold out.', reason: 'menu_item_sold_out', details: { menu_item_id: item.prefixed_id })
        end

        # More of a menu line already in the order is refused while its item
        # is sold out at a branch that runs the menu.
        def ensure_line_available!(workspace, sale_line)
          return unless ModulePolicy.enabled?(workspace.branch, MODULE)

          item = MenuItem.for_variant(workspace.store, sale_line.variant)
          ensure_available!(workspace.branch, item, Workspace.business_now) if item
        end

        def merge_key(variant:, sale_unit_code:, line_price:, pricing:)
          SaleLine.build_merge_key(variant_id: variant.id, kind: KIND, unit_price: line_price, sale_unit_code: sale_unit_code,
                                   modifier_signature: pricing.modifier_signature)
        end

        # Writes the option and combo snapshots of a new line, or replaces
        # the options of a line whose options change.
        def record!(sale_line, pricing)
          sale_line.line_modifiers.delete_all
          pricing.options.each do |row|
            sale_line.line_modifiers.create!(modifier_option: row.option, name: row.option.name, group_name: row.group.name,
                                             price_delta: row.option.price_delta, quantity: row.quantity)
          end
          if sale_line.line_components.empty?
            pricing.components.each do |component|
              sale_line.line_components.create!(variant: component.variant, name: ComboComponent.label(component.variant),
                                                quantity: component.quantity)
            end
          end
          sale_line.update!(note: pricing.note, modifier_signature: pricing.modifier_signature)
          sale_line.line_modifiers.reset
          sale_line.line_components.reset
        end

        def audit(pricing)
          {
            menu_item_id: pricing.menu_item.prefixed_id, schedule_id: pricing.schedule&.prefixed_id,
            base_price: pricing.base_price.to_s('F'), unit_price: pricing.unit_price.to_s('F'),
            modifiers: pricing.options.map { |row| { option_id: row.option.prefixed_id, quantity: row.quantity } }
          }
        end
      end
    end
  end
end
