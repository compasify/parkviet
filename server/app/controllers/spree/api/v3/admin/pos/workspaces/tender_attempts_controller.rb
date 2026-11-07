# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          module Workspaces
            class TenderAttemptsController < BaseController
              scoped_resource :pos_orders

              def index
                return if channel_rejected?

                workspace = workspace!(params[:workspace_id])
                attempts = Spree::Pos::TenderAttempt.where(workspace_id: workspace.id).order(:id)
                render json: { data: attempts.map(&:to_pos) }
              end

              def create
                return if channel_rejected?

                key = idempotency_key
                return if key.nil?

                result = Spree::Pos::Tenders::Prepare.call(
                  workspace: workspace!(params[:workspace_id]), staff: current_user,
                  revision: params[:expected_revision].to_i, lease_generation: params[:lease_generation].to_i,
                  editor_id: params[:editor_id], key: key, payment_method_id: params[:payment_method_id],
                  amount: params[:amount]
                )
                render json: { data: result }
              end

              def confirm
                return if channel_rejected?

                key = idempotency_key
                return if key.nil?

                result = Spree::Pos::Tenders::Confirm.call(
                  workspace: workspace!(params[:workspace_id]), staff: current_user,
                  revision: params[:expected_revision].to_i, lease_generation: params[:lease_generation].to_i,
                  editor_id: params[:editor_id], key: key, attempt_id: params[:id],
                  handed_amount: params[:handed_amount], received_amount: params[:received_amount],
                  evidence_kind: params[:evidence_kind],
                  reference: params[:reference], receiving_account: params[:receiving_account],
                  terminal_ref: params[:terminal_ref], confirm_duplicate: params[:confirm_duplicate]
                )
                render json: { data: result }
              end

              def cancel
                return if channel_rejected?

                key = idempotency_key
                return if key.nil?

                result = Spree::Pos::Tenders::Cancel.call(
                  workspace: workspace!(params[:workspace_id]), staff: current_user,
                  revision: params[:expected_revision].to_i, lease_generation: params[:lease_generation].to_i,
                  editor_id: params[:editor_id], key: key, attempt_id: params[:id]
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
