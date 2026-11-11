# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # A branch's buffet tiers: the ticket per guest, how long a table
          # eats and the dishes of each tier. Reading is for the people
          # working at the branch; changing needs the menu or branch manager.
          class BuffetTiersController < BaseController
            scoped_resource :pos_topology
            pos_permissions index: %w[read_pos_orders write_pos_orders read_pos_topology write_pos_topology],
                            create: %w[write_pos_orders write_pos_topology], update: %w[write_pos_orders write_pos_topology]

            def index
              branch = Spree::Pos::Resources::Guard.branch!(current_store, params[:branch_id])
              Spree::Pos::Resources::Guard.read!(current_store, current_user, branch)
              scope = Spree::Pos::BuffetTier.where(branch_id: branch.id).includes(:branch, product: :variants,
                                                                                           items: { product: :variants }).order(:id)
              scope = scope.active unless params[:status] == 'all'
              render json: { data: scope.map(&:to_pos) }
            end

            def create
              key = idempotency_key
              return if key.nil?

              branch = Spree::Pos::Resources::Guard.branch!(current_store, params[:branch_id])
              result = Spree::Pos::Buffet::SaveTier.call(store: current_store, staff: current_user, key: key, branch: branch,
                                                         attributes: attributes)
              render json: { data: result }, status: :created
            end

            def update
              key = idempotency_key
              return if key.nil?

              tier = Spree::Pos::BuffetTier.locate(Spree::Pos::BuffetTier.where(store_id: current_store.id), params[:id])
              raise ActiveRecord::RecordNotFound if tier.nil?

              result = Spree::Pos::Buffet::SaveTier.call(store: current_store, staff: current_user, key: key, branch: tier.branch,
                                                         attributes: attributes, tier_id: tier.prefixed_id)
              render json: { data: result }
            end

            private

            def attributes
              params.permit(:name, :product_id, :duration_minutes, :round_item_limit, :round_interval_minutes, :status,
                            items: %i[product_id max_per_round]).to_h
            end
          end
        end
      end
    end
  end
end
