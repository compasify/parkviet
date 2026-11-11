# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # Menu items of the store, inactive ones included, each with its
          # sizes at list price for the settings screen.
          class MenuItemsController < MenuResourcesController
            private

            def model
              Spree::Pos::MenuItem
            end

            def scope
              super.includes({ product: [:tax_category, { variants: [:prices, :option_values] }] },
                             :menu_category, { menu_item_modifier_groups: :modifier_group }, { combo_components: { variant: :product } })
            end

            def present(record)
              record.to_pos.merge(
                variants: record.sizes.map do |variant|
                  price = Spree::Pos::SalesChannel.price(variant, store: current_store, currency: current_store.default_currency)
                  { id: variant.prefixed_id, name: variant.is_master? ? nil : variant.options_text.presence, sku: variant.sku.presence,
                    price: price&.amount&.to_s('F') }
                end
              )
            end

            def save(key, record)
              attributes = params.permit(:product_id, :menu_category_id, :tax_category_id, *Spree::Pos::Menu::Save::ITEM_FIELDS,
                                         modifier_group_ids: [], components: %i[variant_id quantity]).to_h
              attributes.delete('product_id') if record
              menu_save.item(store: current_store, staff: current_user, key: key, attributes: attributes, item: record)
            end
          end
        end
      end
    end
  end
end
