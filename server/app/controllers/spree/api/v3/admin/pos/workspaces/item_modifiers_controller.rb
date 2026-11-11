# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          module Workspaces
            # Replaces the options and note of a menu line.
            class ItemModifiersController < BaseController
              scoped_resource :pos_orders

              def update
                return if channel_rejected?

                key = idempotency_key
                return if key.nil?

                result = Spree::Pos::Workspaces::UpdateLineModifiers.call(
                  workspace: workspace!(params[:workspace_id]), staff: current_user,
                  revision: params[:expected_revision].to_i, lease_generation: params[:lease_generation].to_i,
                  editor_id: params[:editor_id], key: key, sale_line_id: params[:id],
                  modifiers: ItemsController.modifier_params(params) || [], note: params[:note]
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
