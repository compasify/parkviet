# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          module Workspaces
            class DiscountsController < BaseController
              scoped_resource :pos_workspaces

              def create
                return if channel_rejected?

                key = idempotency_key
                return if key.nil?

                result = Spree::Pos::Workspaces::ApplyDiscount.call(
                  workspace: workspace!(params[:workspace_id]), staff: current_user,
                  revision: params[:expected_revision].to_i, lease_generation: params[:lease_generation].to_i,
                  editor_id: params[:editor_id], key: key, value_type: params[:value_type],
                  value: params[:value], reason: params[:reason], approval_id: params[:approval_id]
                )
                render json: { data: result }
              end

              def clear
                return if channel_rejected?

                key = idempotency_key
                return if key.nil?

                result = Spree::Pos::Workspaces::ApplyDiscount.clear(
                  workspace: workspace!(params[:workspace_id] || params[:id]), staff: current_user,
                  revision: params[:expected_revision].to_i, lease_generation: params[:lease_generation].to_i,
                  editor_id: params[:editor_id], key: key, approval_id: params[:approval_id]
                )
                render json: { data: result }
              end

              def coupon
                return if channel_rejected?

                key = idempotency_key
                return if key.nil?

                result = Spree::Pos::Workspaces::ApplyCoupon.call(
                  workspace: workspace!(params[:workspace_id] || params[:id]), staff: current_user,
                  revision: params[:expected_revision].to_i, lease_generation: params[:lease_generation].to_i,
                  editor_id: params[:editor_id], key: key, coupon_code: params[:coupon_code]
                )
                render json: { data: result }
              end

              def clear_coupon
                return if channel_rejected?

                key = idempotency_key
                return if key.nil?

                result = Spree::Pos::Workspaces::ApplyCoupon.clear(
                  workspace: workspace!(params[:workspace_id] || params[:id]), staff: current_user,
                  revision: params[:expected_revision].to_i, lease_generation: params[:lease_generation].to_i,
                  editor_id: params[:editor_id], key: key
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
