# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          module Workspaces
            # What the kitchen was told about an order, send by send, with the
            # status of every item.
            class KitchenTicketsController < BaseController
              scoped_resource :pos_orders

              def index
                workspace = workspace!(params[:workspace_id])
                tickets = Spree::Pos::KitchenTicket.where(workspace_id: workspace.id).
                          includes(:kitchen_station, :workspace, :branch, items: :sale_line).order(:sequence)
                render json: { data: tickets.map(&:to_pos) }
              end
            end
          end
        end
      end
    end
  end
end