# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          module Kitchen
            # A station's open tickets and the ones finished in the last 30
            # minutes, for a person working the kitchen. Without `station_id`,
            # every station of the branch.
            class BoardController < BaseController
              scoped_resource :pos_orders
              pos_permissions show: %w[read_pos_orders write_pos_orders read_pos_topology]

              def show
                return if channel_rejected?

                guard = Spree::Pos::Kitchen::Guard
                branch = guard.branch!(current_store, params[:branch_id])
                guard.operate!(current_store, current_user, branch)
                station = params[:station_id].present? ? guard.station!(branch, params[:station_id]) : nil
                stations = guard.stations!(branch, params[:station_ids])
                render json: { data: Spree::Pos::Kitchen::Board.call(branch: branch, station: station, stations: stations,
                                                                     service_mode: guard.service_mode!(params[:service_mode])) }
              end
            end
          end
        end
      end
    end
  end
end
