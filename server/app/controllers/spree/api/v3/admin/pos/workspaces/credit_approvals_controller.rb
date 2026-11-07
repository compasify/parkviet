# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          module Workspaces
            # `index` shows the selling counter what credit the workspace's
            # customer has and which approval currently holds exposure.
            # `create` is the approver's grant: it reserves exposure for the
            # unpaid remainder, bound to requester, amount and revision.
            class CreditApprovalsController < BaseController
              scoped_resource :pos_orders

              def index
                return if channel_rejected?

                workspace = workspace!(params[:workspace_id])
                profile = workspace.pos_customer
                account = profile && Spree::Pos::CreditAccount.for_store(current_store).
                          find_by(customer_profile_id: profile.id, currency: workspace.order.currency)
                reservation = Spree::Pos::CreditReservation.holding.find_by(workspace_id: workspace.id)
                request_row = Spree::Pos::CreditRequest.find_by(workspace_id: workspace.id, workspace_revision: workspace.revision)
                render json: {
                  data: {
                    workspace_id: workspace.prefixed_id, revision: workspace.revision,
                    customer: profile && { id: profile.prefixed_id, name: profile.name },
                    can_sell: policy.allows?(workspace.branch, Spree::Pos::Capabilities::CREDIT_SELL),
                    account: account&.to_pos&.merge(due_on: Spree::Pos::Credit::Commit.due_on(workspace.branch, account).iso8601),
                    reservation: reservation&.to_pos,
                    request: request_row&.to_pos
                  }
                }
              end

              # The cashier asks a manager to approve the unpaid remainder.
              def request_approval
                return if channel_rejected?

                key = idempotency_key
                return if key.nil?

                result = Spree::Pos::Credit::RequestApproval.call(
                  workspace: workspace!(params[:workspace_id]), staff: current_user,
                  revision: params[:expected_revision].to_i, lease_generation: params[:lease_generation].to_i,
                  editor_id: params[:editor_id], key: key
                )
                render json: { data: result }, status: :created
              end

              def create
                return if channel_rejected? || currency_rejected?

                key = idempotency_key
                return if key.nil?

                result = Spree::Pos::Credit::Approve.call(
                  workspace: approvable_workspace!(params[:workspace_id]), staff: current_user, key: key,
                  requester_id: params[:requester_id], amount: params[:amount], revision: params[:revision],
                  expires_at: params[:expires_at]
                )
                render json: { data: result }, status: :created
              end

              private

              # Approvers reach drafts at branches where they may approve credit,
              # without needing a selling shift or a takeover there.
              def approvable_workspace!(prefixed)
                branch_ids = policy.memberships.to_a.select do |membership|
                  membership.allows?(Spree::Pos::Capabilities::APPROVE) &&
                    membership.allows?(Spree::Pos::Capabilities::CREDIT_MANAGE)
                end.map(&:branch_id)
                scope = Spree::Pos::Workspace.for_store(current_store).where(branch_id: branch_ids.presence || [0])
                workspace = Spree::Pos::Workspace.locate(scope, prefixed)
                raise ActiveRecord::RecordNotFound if workspace.nil?

                workspace
              end
            end
          end
        end
      end
    end
  end
end
