# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          module Workspaces
            # Puts the order on a coach visit of its branch, or takes it off
            # (`visit_id` blank). Only before the order completes.
            class VehicleVisitsController < BaseController
              scoped_resource :pos_orders

              def update
                return if channel_rejected?

                key = idempotency_key
                return if key.nil?

                workspace = workspace!(params[:workspace_id])
                result = Spree::Pos::VehicleVisits::AttachWorkspace.call(
                  workspace: workspace, staff: current_user, revision: params[:expected_revision].to_i,
                  lease_generation: params[:lease_generation].to_i, editor_id: params[:editor_id], key: key,
                  visit_id: params[:visit_id]
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
