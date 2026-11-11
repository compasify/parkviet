# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          module Workspaces
            # The cashier's "send to kitchen": the part of every menu line the
            # kitchen has not been told yet. Answers the workspace, with the
            # tickets of this send in `meta`.
            class KitchenSendsController < BaseController
              scoped_resource :pos_orders

              def create
                return if channel_rejected?

                key = idempotency_key
                return if key.nil?

                result = Spree::Pos::Kitchen::Send.command(
                  workspace: workspace!(params[:workspace_id]), staff: current_user, key: key,
                  revision: params[:expected_revision].to_i, lease_generation: params[:lease_generation].to_i,
                  editor_id: params[:editor_id]
                )
                render json: { data: result['workspace'], meta: { tickets: result['tickets'] } }, status: :created
              end
            end
          end
        end
      end
    end
  end
end