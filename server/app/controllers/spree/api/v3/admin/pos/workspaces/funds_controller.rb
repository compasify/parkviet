# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          module Workspaces
            class FundsController < BaseController
              scoped_resource :pos_orders

              def allocate
                return if channel_rejected?

                key = idempotency_key
                return if key.nil?

                result = Spree::Pos::Funds::Allocate.call(
                  workspace: workspace!(params[:workspace_id]), staff: current_user,
                  revision: params[:expected_revision].to_i, lease_generation: params[:lease_generation].to_i,
                  editor_id: params[:editor_id], key: key, funds_id: params[:funds_id], amount: params[:amount]
                )
                render json: { data: result }
              end

              def reverse
                return if channel_rejected?

                key = idempotency_key
                return if key.nil?

                result = Spree::Pos::Funds::ReverseAllocation.call(
                  workspace: workspace!(params[:workspace_id]), staff: current_user,
                  revision: params[:expected_revision].to_i, lease_generation: params[:lease_generation].to_i,
                  editor_id: params[:editor_id], key: key, allocation_id: params[:allocation_id]
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
