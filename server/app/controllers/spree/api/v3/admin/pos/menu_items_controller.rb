# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # Menu items of the store, inactive ones included, each with its
          # sizes at list price for the settings screen.
          class MenuItemsController < MenuResourcesController
            # meta.tax_defaults: the tax categories the store's F&B setup chose
            # for food and for alcoholic drinks (ids or null), for the item form.
            def index
              read_store!
              profile = Spree::Pos::StoreProfile.for_store(current_store).includes(:food_tax_category, :alcohol_tax_category).first
              render json: { data: scope.to_a.map { |record| present(record) },
                             meta: { tax_defaults: profile&.tax_defaults || { food: nil, alcohol: nil } } }
            end

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
                                         modifier_group_ids: [], drink_credit_categories: [], components: %i[variant_id quantity]).to_h
              attributes.delete('product_id') if record
              menu_save.item(store: current_store, staff: current_user, key: key, attributes: attributes, item: record)
            end
          end
        end
      end
    end
  end
end
