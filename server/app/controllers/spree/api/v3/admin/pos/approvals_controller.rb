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

            def create
              return if channel_rejected? || currency_rejected?

              branch = branch!(params[:branch_id])
              raise CanCan::AccessDenied unless policy.allows?(branch, Spree::Pos::Capabilities::APPROVE)

              requester = staff!(params[:requester_id])
              subject = Spree::Pos::Workspace.locate(
                Spree::Pos::Workspace.for_store(current_store).where(branch_id: branch.id), params[:workspace_id]
              )
              raise ActiveRecord::RecordNotFound if subject.nil?
              requester_policy = Spree::Pos::AccessPolicy.new(store: current_store, staff: requester)
              # The cashier of the order, or for a table order anyone who may edit it.
              cashier = [subject.shift.owner_id, subject.lease_holder_id].include?(requester.id) &&
                        requester_policy.allows?(branch, Spree::Pos::Capabilities::OPEN_SHIFT)
              raise CanCan::AccessDenied unless cashier || (subject.resource_id && requester_policy.can_edit_workspace?(subject))
              raise Spree::Pos::Conflict.new('Revision is stale.', revision: subject.revision) unless params[:revision].to_s == subject.revision.to_s
              # Credit approvals reserve exposure, so they only come from the credit approval endpoint.
              if params[:action_name].to_s == Spree::Pos::Credit::ACTION
                raise Spree::Pos::Conflict, 'Credit approvals are granted per workspace credit.'
              end
              # Returns and refund payouts are approved on their own record.
              if [Spree::Pos::ReturnOperation::ACTION, Spree::Pos::RefundRequest::ACTION,
                  Spree::Pos::InventoryAdjustment::ACTION].include?(params[:action_name].to_s)
                raise Spree::Pos::Conflict, 'Return, refund and stock count approvals are granted on their own record.'
              end

              amount = money_or_nil
              approval = Spree::Pos::Approval.create!(
                store: current_store,
                branch: branch,
                approver: current_user,
                requester: requester,
                subject_type: subject.class.name,
                subject_id: subject.id,
                action: params[:action_name],
                amount: amount,
                currency: amount ? current_store.default_currency : nil,
                revision: params[:revision].to_s,
                expires_at: params[:expires_at],
                status: 'active'
              )
              audit!('approval.grant', approval, action: approval.action, revision: approval.revision)
              Spree::Pos::Realtime.publish(branch, 'approval.requested', id: approval.prefixed_id,
                                                                         refs: { workspace_id: subject.prefixed_id })
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
