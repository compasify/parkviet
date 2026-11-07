# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # The approver's side of credit sales at one branch: pending requests
          # from cashiers and approvals still holding exposure. Every action
          # needs `pos.approval.grant` and `pos.credit.manage` at that branch.
          class CreditRequestsController < BaseController
            scoped_resource :pos_orders

            def index
              return if channel_rejected?

              branch = branch!(params[:branch_id])
              authorize_branch!(branch)
              pending = Spree::Pos::CreditRequest.for_store(current_store).actionable.where(branch_id: branch.id)
              approved = Spree::Pos::CreditRequest.for_store(current_store).where(branch_id: branch.id, status: 'approved').
                         where(credit_reservation_id: Spree::Pos::CreditReservation.holding.select(:id))
              scope = Spree::Pos::CreditRequest.where(id: pending.select(:id)).or(Spree::Pos::CreditRequest.where(id: approved.select(:id))).
                      includes(:workspace, :customer_profile, :requester, credit_reservation: :approval).order(created_at: :desc)
              render_page(scope)
            end

            def approve
              return if channel_rejected?

              key = idempotency_key
              return if key.nil?

              request_row = request!
              Spree::Pos::Credit::Approve.call(
                workspace: request_row.workspace, staff: current_user, key: key, requester_id: request_row.requester.prefixed_id,
                amount: request_row.amount.to_s('F'), revision: request_row.workspace_revision, expires_at: params[:expires_at],
                request: request_row
              )
              render json: { data: request_row.reload.to_pos }
            end

            def reject
              return if channel_rejected?

              key = idempotency_key
              return if key.nil?

              result = Spree::Pos::Credit::Reject.call(request: request!, staff: current_user, key: key, reason: params[:reason])
              render json: { data: result }
            end

            def revoke
              return if channel_rejected?

              request_row = request!
              approval = request_row.credit_reservation&.approval
              raise Spree::Pos::Conflict.new('This request has no active approval.', reason: 'approval_not_active') if approval.nil?

              Spree::Pos::Approvals::Revoke.call(approval: approval, staff: current_user)
              render json: { data: request_row.reload.to_pos }
            end

            private

            def authorize_branch!(branch)
              allowed = policy.allows?(branch, Spree::Pos::Capabilities::APPROVE) &&
                policy.allows?(branch, Spree::Pos::Capabilities::CREDIT_MANAGE)
              raise CanCan::AccessDenied unless allowed
            end

            def request!
              row = Spree::Pos::CreditRequest.locate(Spree::Pos::CreditRequest.for_store(current_store), params[:id])
              raise ActiveRecord::RecordNotFound if row.nil?

              authorize_branch!(row.branch)
              row
            end
          end
        end
      end
    end
  end
end
