# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          module Kitchen
            # "Done" for a whole ticket: every open item becomes ready.
            class TicketsController < BaseController
              scoped_resource :pos_orders
              pos_permissions bump: %w[write_pos_orders], bump_all_day: %w[write_pos_orders]

              def bump
                ticket = Spree::Pos::Kitchen::Guard.staff_ticket!(current_store, current_user, params[:id])
                Spree::Pos::Kitchen::ChangeItemStatus.bump(ticket: ticket, actor: current_user)
                render json: { data: ticket.reload.to_pos }
              end

              # One dish on the "by dish" tab: its oldest open items become ready.
              def bump_all_day
                guard = Spree::Pos::Kitchen::Guard
                branch = guard.branch!(current_store, params[:branch_id])
                guard.operate!(current_store, current_user, branch)
                stations = guard.stations!(branch, params[:station_ids])
                stations = Spree::Pos::KitchenStation.where(branch_id: branch.id).active.to_a if stations.empty?
                tickets = Spree::Pos::Kitchen::ChangeItemStatus.bump_all_day(stations: stations, key: params[:key], quantity: params[:quantity] || 1,
                                                                             actor: current_user)
                render json: { data: tickets.map(&:to_pos) }
              end
            end
          end
        end
      end
    end
  end
end
