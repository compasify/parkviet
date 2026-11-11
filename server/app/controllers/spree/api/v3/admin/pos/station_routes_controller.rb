# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # Which station makes what at a branch: by product or by kitchen
          # category, for one service mode or every mode.
          class StationRoutesController < BaseController
            scoped_resource :pos_topology
            pos_permissions index: %w[read_pos_orders write_pos_orders read_pos_topology write_pos_topology],
                            create: %w[write_pos_orders write_pos_topology], update: %w[write_pos_orders write_pos_topology],
                            destroy: %w[write_pos_orders write_pos_topology]

            def index
              branch = guard.branch!(current_store, params[:branch_id])
              guard.read_setup!(current_store, current_user, branch)
              routes = Spree::Pos::StationRoute.where(branch_id: branch.id).includes(:branch, :kitchen_station, :product).order(:id)
              render json: { data: routes.map(&:to_pos) }
            end

            def create
              key = idempotency_key
              return if key.nil?

              branch = guard.branch!(current_store, params[:branch_id])
              result = setup.create_route(store: current_store, staff: current_user, key: key, branch: branch, attributes: attributes)
              render json: { data: result }, status: :created
            end

            def update
              key = idempotency_key
              return if key.nil?

              result = setup.update_route(store: current_store, staff: current_user, key: key, route: route!, attributes: attributes)
              render json: { data: result }
            end

            def destroy
              key = idempotency_key
              return if key.nil?

              result = setup.destroy_route(store: current_store, staff: current_user, key: key, route: route!)
              render json: { data: result }
            end

            private

            def guard
              Spree::Pos::Kitchen::Guard
            end

            def setup
              Spree::Pos::Kitchen::Setup
            end

            def route!
              Spree::Pos::StationRoute.locate(Spree::Pos::StationRoute.for_store(current_store), params[:id]) ||
                raise(ActiveRecord::RecordNotFound)
            end

            def attributes
              params.permit(:kitchen_station_id, :product_id, *Spree::Pos::Kitchen::Setup::ROUTE_FIELDS).to_h
            end
          end
        end
      end
    end
  end
end