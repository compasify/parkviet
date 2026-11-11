# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # The kitchen and bar stations of a branch. Reading is for managers
          # and the people who work the kitchen; changing needs
          # pos.kitchen.manage or store administration.
          class KitchenStationsController < BaseController
            scoped_resource :pos_topology
            pos_permissions index: %w[read_pos_orders write_pos_orders read_pos_topology write_pos_topology],
                            create: %w[write_pos_orders write_pos_topology], update: %w[write_pos_orders write_pos_topology],
                            destroy: %w[write_pos_orders write_pos_topology]

            def index
              branch = guard.branch!(current_store, params[:branch_id])
              guard.read_setup!(current_store, current_user, branch)
              stations = Spree::Pos::KitchenStation.where(branch_id: branch.id).includes(:branch, :printer).ordered
              render json: { data: stations.map(&:to_pos) }
            end

            def create
              key = idempotency_key
              return if key.nil?

              branch = guard.branch!(current_store, params[:branch_id])
              result = setup.create_station(store: current_store, staff: current_user, key: key, branch: branch, attributes: attributes)
              render json: { data: result }, status: :created
            end

            def update
              key = idempotency_key
              return if key.nil?

              result = setup.update_station(store: current_store, staff: current_user, key: key, station: station!, attributes: attributes)
              render json: { data: result }
            end

            def destroy
              key = idempotency_key
              return if key.nil?

              result = setup.destroy_station(store: current_store, staff: current_user, key: key, station: station!)
              render json: { data: result }
            end

            private

            def guard
              Spree::Pos::Kitchen::Guard
            end

            def setup
              Spree::Pos::Kitchen::Setup
            end

            def station!
              Spree::Pos::KitchenStation.locate(Spree::Pos::KitchenStation.for_store(current_store), params[:id]) ||
                raise(ActiveRecord::RecordNotFound)
            end

            def attributes
              params.permit(*Spree::Pos::Kitchen::Setup::STATION_FIELDS, :printer_id, :expo_station_id).to_h
            end
          end
        end
      end
    end
  end
end
