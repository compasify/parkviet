# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          module Workspaces
            # How the sale is served: counter, dine in, takeaway, delivery, tab or timed.
            class ServiceModesController < BaseController
              scoped_resource :pos_orders

              def update
                return if channel_rejected?

                key = idempotency_key
                return if key.nil?

                result = Spree::Pos::Workspaces::SetServiceMode.call(
                  workspace: workspace!(params[:workspace_id]), staff: current_user,
                  revision: params[:expected_revision].to_i, lease_generation: params[:lease_generation].to_i,
                  editor_id: params[:editor_id], key: key, service_mode: params[:service_mode]
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
