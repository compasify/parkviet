# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # Grants an action-bound approval. There is no consume or shared-PIN route.
          class ApprovalsController < BaseController
            scoped_resource :pos_topology

            # Granting is decided per branch by the approve capability, so a
            # branch manager needs no store-level setup permission for it.
            pos_permissions create: %w[write_pos_orders write_pos_topology]

            def index
              return if channel_rejected?

              render_page(Spree::Pos::Approval.for_store(current_store).order(id: :desc))
            end

            def show
              return if channel_rejected?

              render json: { data: approval!(params[:id]).to_pos }
            end

            # The subject is an order (workspace_id) or one of
            # Approvals::Issue::SUBJECT_PARAMS; the checks live in that service.
            def create
              return if channel_rejected? || currency_rejected?

              branch = branch!(params[:branch_id])
              raise CanCan::AccessDenied unless policy.allows?(branch, Spree::Pos::Capabilities::APPROVE)

              requester = staff!(params[:requester_id])
              subject = Spree::Pos::Approvals::Issue.subject!(current_store, branch, params)
              approval = Spree::Pos::Approvals::Issue.call(
                store: current_store, branch: branch, approver: current_user, requester: requester, subject: subject,
                action: params[:action_name], revision: params[:revision], amount: -> { money_or_nil },
                expires_at: params[:expires_at]
              )
              render json: { data: approval.to_pos }, status: :created
            end

            def revoke
              approval = approval!(params[:id])
              raise CanCan::AccessDenied unless policy.allows?(approval.branch, Spree::Pos::Capabilities::APPROVE)

              Spree::Pos::Approvals::Revoke.call(approval: approval, staff: current_user)
              render json: { data: approval.to_pos }
            end

            private

            def money_or_nil
              return if params[:amount].blank?

              amount = Spree::Pos::Record.money(params[:amount])
              raise ActiveRecord::RecordInvalid, invalid_amount if amount.nil?

              amount
            end

            def invalid_amount
              record = Spree::Pos::Approval.new
              record.errors.add(:amount, :invalid)
              record
            end

            def approval!(prefixed)
              approval = Spree::Pos::Approval.locate(Spree::Pos::Approval.for_store(current_store), prefixed)
              raise ActiveRecord::RecordNotFound if approval.nil?

              approval
            end
          end
        end
      end
    end
  end
end
