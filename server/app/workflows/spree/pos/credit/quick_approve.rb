# frozen_string_literal: true

module Spree
  module Pos
    module Credit
      # Quick credit for a one-person shop: with `quick_credit` (and `credit`)
      # on at the branch, the selling cashier with `pos.credit.sell` approves
      # the unpaid remainder of their own workspace, without a second person.
      # A customer without a credit account gets one with the default terms.
      # The limit is still enforced exactly as in Approve, and the cashier then
      # completes with the returned approval through Workspaces::Complete.
      # Lock order: workspace (CommandExecutor) -> request -> account.
      class QuickApprove
        # Terms of an account opened by a quick credit sale; a credit manager
        # can change them later like any other account.
        DEFAULT_LIMIT = BigDecimal('2000000')
        DEFAULT_DUE_DAYS = 30

        def self.call(workspace:, staff:, revision:, lease_generation:, editor_id:, key:)
          payload = {
            'command' => 'credit.quick_approve', 'revision' => revision, 'lease_generation' => lease_generation,
            'editor_digest' => Workspace.editor_digest(editor_id)
          }
          authorize = lambda do
            Tenders::Guard.authorize_editor!(workspace, staff)
            Workspaces::Complete.authorize_credit!(workspace, staff)
          end
          CommandExecutor.call(store: workspace.store, actor: staff, key: key, payload: payload, workspace: workspace, authorize: authorize) do
            FeaturePolicy.require!(workspace.branch, :credit)
            FeaturePolicy.require!(workspace.branch, :quick_credit)
            Tenders::Guard.validate_editor!(workspace, staff, revision, lease_generation, editor_id)

            profile = workspace.pos_customer
            raise Conflict.new('Credit needs an identified customer.', reason: 'credit_customer_required') if profile.nil?
            if TenderAttempt.where(workspace: workspace, status: TenderAttempt::UNRESOLVED).exists?
              raise Conflict.new('Unresolved tender attempts block credit.', reason: 'tender_unresolved')
            end

            order = workspace.order
            allocated = FundsAllocation.where(workspace: workspace, status: 'active').sum(:amount)
            amount = order.total - allocated
            raise Conflict, 'Nothing remains to sell on credit.' unless amount.positive?

            # A pending request for this revision is answered by this approval.
            request = CreditRequest.find_by(workspace_id: workspace.id, workspace_revision: workspace.revision, status: 'pending')
            request&.lock!
            account = account!(workspace, staff, profile, order.currency)
            approval, reservation = Approve.reserve!(workspace: workspace, approver: staff, requester: staff, account: account,
                                                     amount: amount, expires_at: Time.current + Approve::DEFAULT_TTL)
            request&.update!(status: 'approved', decided_by: staff, decided_at: Time.current, credit_reservation: reservation)
            AuditEntry.record!(store: workspace.store, actor: staff, action: 'credit.quick_approve', subject: workspace,
                               metadata: { reservation_id: reservation.prefixed_id, approval_id: approval.prefixed_id,
                                           account_id: account.prefixed_id, amount: amount.to_s('F'),
                                           request_id: request&.prefixed_id })
            reservation.to_pos
          end
        end

        # The customer's account, or a new one homed at this branch with the
        # default terms (audited like Configure). Another counter opening the
        # same account first is not an error: its account is used.
        def self.account!(workspace, staff, profile, currency)
          scope = CreditAccount.for_store(workspace.store)
          existing = scope.find_by(customer_profile_id: profile.id, currency: currency)
          return existing if existing

          store = workspace.store
          raise Conflict.new('Customer has no credit account.', reason: 'credit_account_missing') if currency != store.default_currency

          account = Configure.build(store, staff, profile.prefixed_id, workspace.branch)
          account.assign_attributes(credit_limit: DEFAULT_LIMIT, due_days: DEFAULT_DUE_DAYS)
          begin
            CreditAccount.transaction(requires_new: true) { account.save! }
          rescue ActiveRecord::RecordNotUnique
            return scope.find_by!(customer_profile_id: profile.id, currency: currency)
          end
          AuditEntry.record!(store: store, actor: staff, action: 'credit.configure', subject: account,
                             metadata: { branch_id: workspace.branch.prefixed_id, before: {}, quick_credit: true,
                                         after: account.slice(:credit_limit, :due_days, :status).transform_values(&:to_s) })
          account
        end
      end
    end
  end
end
