# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          module Workspaces
            class PriceOverridesController < BaseController
              scoped_resource :pos_orders

              def create
                return if channel_rejected?

                key = idempotency_key
                return if key.nil?

                result = Spree::Pos::Workspaces::OverridePrice.call(
                  workspace: workspace!(params[:workspace_id]), staff: current_user,
                  revision: params[:expected_revision].to_i, lease_generation: params[:lease_generation].to_i,
                  editor_id: params[:editor_id], key: key, sale_line_id: params[:sale_line_id] || params[:id],
                  price: params[:price], reason: params[:reason], approval_id: params[:approval_id]
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
