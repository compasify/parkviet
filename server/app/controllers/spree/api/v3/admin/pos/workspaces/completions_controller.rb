# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          module Workspaces
            class CompletionsController < BaseController
              scoped_resource :pos_orders

              def create
                return if channel_rejected?

                key = idempotency_key
                return if key.nil?

                result = Spree::Pos::Workspaces::Complete.call(
                  workspace: workspace!(params[:workspace_id]), staff: current_user,
                  revision: params[:expected_revision].to_i, lease_generation: params[:lease_generation].to_i,
                  editor_id: params[:editor_id], key: key, credit_approval_id: params[:credit_approval_id],
                  einvoice_buyer: params[:einvoice_buyer], meal_sponsor: params[:meal_sponsor]
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
