# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          class MenuCategoriesController < MenuResourcesController
            private

            def model
              Spree::Pos::MenuCategory
            end

            def scope
              super.order(:name)
            end

            def save(key, record)
              attributes = params.permit(*Spree::Pos::Menu::Save::CATEGORY_FIELDS).to_h
              menu_save.category(store: current_store, staff: current_user, key: key, attributes: attributes, category: record)
            end
          end
        end
      end
    end
  end
end
