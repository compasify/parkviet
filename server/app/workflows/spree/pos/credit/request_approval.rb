# frozen_string_literal: true

module Spree
  module Pos
    module Credit
      # The selling cashier asks for the unpaid remainder of the current
      # workspace revision to be approved on credit. One request per revision:
      # asking again returns the same request (pending, approved or rejected),
      # and it never changes the revision itself.
      class RequestApproval
        def self.call(workspace:, staff:, revision:, lease_generation:, editor_id:, key:)
          payload = {
            'command' => 'credit.request', 'revision' => revision, 'lease_generation' => lease_generation,
            'editor_digest' => Workspace.editor_digest(editor_id)
          }
          authorize = lambda do
            Tenders::Guard.authorize_editor!(workspace, staff)
            Workspaces::Complete.authorize_credit!(workspace, staff)
          end
          CommandExecutor.call(store: workspace.store, actor: staff, key: key, payload: payload, workspace: workspace, authorize: authorize) do
            Tenders::Guard.validate_editor!(workspace, staff, revision, lease_generation, editor_id)
            existing = CreditRequest.find_by(workspace_id: workspace.id, workspace_revision: workspace.revision)
            next existing.to_pos if existing

            profile = workspace.pos_customer
            raise Conflict.new('Credit needs an identified customer.', reason: 'credit_customer_required') if profile.nil?
            if TenderAttempt.where(workspace: workspace, status: TenderAttempt::UNRESOLVED).exists?
              raise Conflict.new('Unresolved tender attempts block credit.', reason: 'tender_unresolved')
            end

            order = workspace.order
            allocated = FundsAllocation.where(workspace: workspace, status: 'active', collection_id: nil).sum(:amount)
            amount = order.total - allocated
            raise Conflict, 'Nothing remains to sell on credit.' unless amount.positive?

            account = CreditAccount.for_store(workspace.store).find_by(customer_profile_id: profile.id, currency: order.currency)
            raise Conflict.new('Customer has no credit account.', reason: 'credit_account_missing') if account.nil?
            raise Conflict.new('Credit account is suspended.', reason: 'credit_account_suspended') unless account.active?

            request = CreditRequest.create!(
              store: workspace.store, branch: workspace.branch, workspace: workspace, customer_profile: profile,
              requester: staff, amount: amount, currency: order.currency, workspace_revision: workspace.revision,
              status: 'pending'
            )
            AuditEntry.record!(store: workspace.store, actor: staff, action: 'credit.request', subject: workspace,
                               metadata: { request_id: request.prefixed_id, amount: amount.to_s('F') })
            request.to_pos
          end
        end
      end
    end
  end
end
