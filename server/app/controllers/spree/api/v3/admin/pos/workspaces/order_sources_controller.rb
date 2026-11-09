# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          module Workspaces
            # Where the sale came from: counter, facebook, zalo or other.
            class OrderSourcesController < BaseController
              scoped_resource :pos_orders

              def assign
                return if channel_rejected?

                key = idempotency_key
                return if key.nil?

                result = Spree::Pos::Workspaces::SetOrderSource.call(
                  workspace: workspace!(params[:workspace_id]), staff: current_user,
                  revision: params[:expected_revision].to_i, lease_generation: params[:lease_generation].to_i,
                  editor_id: params[:editor_id], key: key, order_source: params[:order_source]
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
