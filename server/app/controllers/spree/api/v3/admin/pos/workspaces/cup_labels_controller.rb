# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          module Workspaces
            # Prints the cup labels of one line (`sale_line_id`), or of the
            # whole order, again.
            class CupLabelsController < BaseController
              scoped_resource :pos_orders

              def create
                return if channel_rejected?

                key = idempotency_key
                return if key.nil?

                result = Spree::Pos::CupLabels::Reprint.call(workspace: workspace!(params[:workspace_id]), staff: current_user,
                                                             key: key, sale_line_id: params[:sale_line_id])
                render json: { data: result }, status: :created
              end
            end
          end
        end
      end
    end
  end
end
