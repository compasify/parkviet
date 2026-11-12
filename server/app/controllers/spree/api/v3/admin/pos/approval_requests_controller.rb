# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # Approvals asked for from another device. The requester sends the
          # action, its subject and revision as the command's
          # `approval_required` answer named them; a manager of the branch
          # grants or declines from their own device. `index` lists the
          # requests the reader may decide (branches where they approve), or
          # with `mine=true` the reader's own.
          class ApprovalRequestsController < BaseController
            scoped_resource :pos_orders
            pos_permissions index: %w[read_pos_orders write_pos_orders read_pos_topology write_pos_topology],
                            show: %w[read_pos_orders write_pos_orders read_pos_topology write_pos_topology],
                            create: %w[write_pos_orders],
                            cancel: %w[write_pos_orders],
                            grant: %w[write_pos_orders write_pos_topology],
                            decline: %w[write_pos_orders write_pos_topology]

            STATUSES = Spree::Pos::ApprovalRequest::STATUSES

            def index
              return if channel_rejected?

              scope = Spree::Pos::ApprovalRequest.for_store(current_store)
              scope = mine? ? scope.where(requester_id: current_user.id) : scope.where(branch_id: deciding_branch_ids)
              scope = scope.where(branch_id: branch!(params[:branch_id]).id) if params[:branch_id].present?
              Spree::Pos::ApprovalRequest.expire_due!(scope)
              status = params[:status].presence || 'pending'
              unless status == 'all' || STATUSES.include?(status)
                return render_error(code: 'parameter_invalid', message: 'Unknown status.', status: :unprocessable_content)
              end

              scope = scope.where(status: status) unless status == 'all'
              render_page(scope.includes(:branch, :requester, :approval, :decided_by).order(created_at: :desc, id: :desc))
            end

            def show
              request_row = approval_request!
              Spree::Pos::ApprovalRequest.expire_due!(Spree::Pos::ApprovalRequest.where(id: request_row.id))
              render json: { data: request_row.reload.to_pos }
            end

            def create
              return if channel_rejected? || currency_rejected?

              key = idempotency_key
              return if key.nil?

              branch = branch!(params[:branch_id])
              subject = Spree::Pos::Approvals::Issue.subject!(current_store, branch, params)
              result = Spree::Pos::ApprovalRequests::Submit.call(
                store: current_store, staff: current_user, key: key, branch: branch, subject: subject,
                action: params[:action_name], revision: params[:revision], amount: amount!, reason: params[:reason]
              )
              render json: { data: result['approval_request'] }, status: :created
            end

            def grant
              decide(Spree::Pos::ApprovalRequests::Grant)
            end

            def decline
              decide(Spree::Pos::ApprovalRequests::Decline, reason: params[:reason])
            end

            def cancel
              decide(Spree::Pos::ApprovalRequests::Cancel)
            end

            private

            def decide(workflow, **options)
              key = idempotency_key
              return if key.nil?

              result = workflow.call(request: approval_request!, staff: current_user, key: key, **options)
              render json: { data: result['approval_request'] }
            end

            def mine?
              params[:mine].to_s == 'true'
            end

            # Readable by its requester and by whoever may decide it.
            def approval_request!
              row = Spree::Pos::ApprovalRequest.locate(Spree::Pos::ApprovalRequest.for_store(current_store), params[:id])
              raise ActiveRecord::RecordNotFound if row.nil?
              raise ActiveRecord::RecordNotFound unless row.requester_id == current_user.id || deciding_branch_ids.include?(row.branch_id)

              row
            end

            def deciding_branch_ids
              @deciding_branch_ids ||= policy.memberships.to_a.select { |membership|
                membership.allows?(Spree::Pos::Capabilities::APPROVE)
              }.map(&:branch_id)
            end

            def amount!
              return if params[:amount].blank?

              amount = Spree::Pos::Record.money(params[:amount])
              return amount unless amount.nil?

              raise Spree::Pos::Conflict.new('Amount is not valid.', reason: 'amount_invalid')
            end
          end
        end
      end
    end
  end
end
