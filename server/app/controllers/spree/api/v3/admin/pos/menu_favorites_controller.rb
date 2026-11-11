# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # The favourites row of a branch's menu grid, replaced as a whole.
          class MenuFavoritesController < BaseController
            scoped_resource :pos_topology
            pos_permissions update: %w[write_pos_orders write_pos_topology]

            def update
              key = idempotency_key
              return if key.nil?

              branch = Spree::Pos::Menu::Guard.branch!(current_store, params[:branch_id])
              result = Spree::Pos::Menu::Save.favorites(store: current_store, staff: current_user, key: key, branch: branch,
                                                        menu_item_ids: Array(params[:menu_item_ids]).map(&:to_s))
              render json: { data: result }
            end
          end
        end
      end
    end
  end
end
