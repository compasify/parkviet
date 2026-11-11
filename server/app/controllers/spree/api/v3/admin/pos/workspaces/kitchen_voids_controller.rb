# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          module Workspaces
            # Takes back part of a line the kitchen was told about: a reason,
            # an approval unless the person may void, and a void ticket for
            # the station. Answers the workspace, with the void in `meta`.
            class KitchenVoidsController < BaseController
              scoped_resource :pos_orders

              def create
                return if channel_rejected?

                key = idempotency_key
                return if key.nil?

                result = Spree::Pos::Kitchen::VoidSent.call(
                  workspace: workspace!(params[:workspace_id]), staff: current_user, key: key, sale_line_id: params[:sale_line_id],
                  quantity: params[:quantity], reason_code: params[:reason_code], note: params[:note],
                  approval_id: params[:approval_id], device: @pos_device, revision: params[:expected_revision]&.to_i,
                  lease_generation: params[:lease_generation]&.to_i, editor_id: params[:editor_id]
                )
                render json: { data: result['workspace'], meta: { kitchen_void: result['kitchen_void'] } }, status: :created
              end
            end
          end
        end
      end
    end
  end
end
