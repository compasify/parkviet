# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          module Collections
            # Allocates a collection's remaining money, or reverses one child.
            class AllocationsController < BaseController
              scoped_resource :pos_orders

              def create
                return if channel_rejected?

                key = idempotency_key
                return if key.nil?

                result = Spree::Pos::Collections::Allocate.call(
                  store: current_store, staff: current_user, key: key, collection_id: params[:collection_id],
                  allocations: params[:allocations] || []
                )
                render json: { data: result }, status: :created
              end

              def reverse
                return if channel_rejected?

                key = idempotency_key
                return if key.nil?

                result = Spree::Pos::Collections::Reverse.call(
                  store: current_store, staff: current_user, key: key, collection_id: params[:collection_id],
                  allocation_id: params[:id], reason: params[:reason]
                )
                render json: { data: result }
              end
            end
          end
        end
      end
    end
  end
end
