# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          module Workspaces
            # The name the counter calls out with the call number.
            class GuestNamesController < BaseController
              scoped_resource :pos_orders

              def update
                return if channel_rejected?

                key = idempotency_key
                return if key.nil?

                result = Spree::Pos::Workspaces::SetGuestName.call(
                  workspace: workspace!(params[:workspace_id]), staff: current_user,
                  revision: params[:expected_revision].to_i, lease_generation: params[:lease_generation].to_i,
                  editor_id: params[:editor_id], key: key, guest_name: params[:guest_name]
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
