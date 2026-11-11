# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          module Workspaces
            class TenderAttemptsController < BaseController
              scoped_resource :pos_orders
              pos_permissions vietqr: %w[read_pos_orders]

              def index
                return if channel_rejected?

                workspace = workspace!(params[:workspace_id])
                attempts = Spree::Pos::TenderAttempt.where(workspace_id: workspace.id).order(:id)
                render json: { data: attempts.map(&:to_pos) }
              end

              # QR and bank details of a waiting VietQR tender, or its confirmed
              # state once the bank webhook matched the transfer. Polled by the
              # cashier screen; the QR was reserved when the tender was prepared.
              def vietqr
                return if channel_rejected?

                workspace = workspace!(params[:workspace_id])
                attempt = Spree::Pos::TenderAttempt.locate(Spree::Pos::TenderAttempt.where(workspace_id: workspace.id), params[:id])
                raise ActiveRecord::RecordNotFound if attempt.nil? || attempt.pos_payment_method.kind != 'vietqr'

                summary = Spree::Pos::VietqrTender.summary(attempt, request_base_url: request.base_url)
                raise Spree::Pos::Conflict.new('This tender has no VietQR payment.', reason: 'vietqr_missing') if summary.nil?

                render json: { data: summary }
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
                  terminal_ref: params[:terminal_ref], confirm_duplicate: params[:confirm_duplicate],
                  tip_amount: params[:tip_amount]
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
