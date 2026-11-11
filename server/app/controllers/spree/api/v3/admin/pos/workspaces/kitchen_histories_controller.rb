# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          module Workspaces
            # What the kitchen was told about an order and what was taken
            # back, oldest first: each send with its items, each void with
            # its reason.
            class KitchenHistoriesController < BaseController
              scoped_resource :pos_orders

              def show
                render json: { data: Spree::Pos::Kitchen::History.for(workspace!(params[:workspace_id])) }
              end
            end
          end
        end
      end
    end
  end
end
