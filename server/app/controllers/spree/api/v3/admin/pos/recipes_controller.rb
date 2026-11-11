# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # The recipe of one menu size (`variant_id`) or one modifier option
          # (`modifier_option_id`): the active version with its estimated cost
          # at today's cost prices, and the version history. Saving writes a
          # new version through Recipes::Save.
          class RecipesController < BaseController
            scoped_resource :pos_topology
            pos_permissions show: %w[read_pos_orders write_pos_orders read_pos_topology write_pos_topology],
                            update: %w[write_pos_orders write_pos_topology]

            def show
              Spree::Pos::Recipes.read!(current_store, current_user)
              render json: { data: Spree::Pos::Recipes.present(current_store, owner!) }
            end

            def update
              key = idempotency_key
              return if key.nil?

              rows = params[:ingredients].is_a?(Array) ? params[:ingredients].map { |row| row.permit(:variant_id, :quantity, :unit_code).to_h } : []
              result = Spree::Pos::Recipes::Save.call(
                store: current_store, staff: current_user, key: key, owner: owner!, ingredients: rows,
                confirm_stock_write_off: ActiveModel::Type::Boolean.new.cast(params[:confirm_stock_write_off]) == true
              )
              render json: { data: result }
            end

            private

            def owner!
              Spree::Pos::Recipes.owner!(current_store, variant_id: params[:variant_id], modifier_option_id: params[:modifier_option_id])
            end
          end
        end
      end
    end
  end
end
