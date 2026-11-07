# frozen_string_literal: true

module Spree
  module Pos
    module Credit
      # A manager approves selling the unpaid remainder of one workspace on
      # credit. The approval is bound to the requester, amount, revision and
      # customer, and it reserves exposure under the account lock:
      #   open debt + usable reservations + amount <= credit limit.
      # Approvers need both `pos.approval.grant` and `pos.credit.manage` at the
      # workspace branch. With `request` the approval answers that cashier's
      # pending credit request, which is marked approved in the same commit.
      # Lock order: workspace (CommandExecutor) -> request -> account.
      class Approve
        DEFAULT_TTL = 15.minutes

        def self.call(workspace:, staff:, key:, requester_id:, amount:, revision:, expires_at: nil, request: nil)
          parsed = Record.money(amount.to_s)
          payload = {
            'command' => 'credit.approve', 'requester_id' => requester_id.to_s, 'amount' => parsed&.to_s('F'),
            'revision' => revision.to_s, 'expires_at' => expires_at.to_s.presence
          }
          payload['request_id'] = request.prefixed_id if request
          authorize = -> { authorize_approver!(workspace, staff) }
          CommandExecutor.call(store: workspace.store, actor: staff, key: key, payload: payload, workspace: workspace, authorize: authorize) do
            FeaturePolicy.require!(workspace.branch, :credit)
            if request
              request.lock!
              raise Conflict.new('Credit request is no longer pending.', reason: 'credit_request_closed') unless request.current_status == 'pending'
            end
            requester = requester!(workspace, staff, requester_id)
            raise Conflict.new('Workspace is not editing.', revision: workspace.revision) unless workspace.operational_status == 'editing'
            raise Conflict.new('Revision is stale.', revision: workspace.revision) unless workspace.revision.to_s == revision.to_s
            raise Conflict, 'Amount is invalid.' if parsed.nil? || parsed <= 0

            order = workspace.order
            raise Conflict, 'Amount must be a whole amount in the order currency.' unless Record.countable_money?(parsed, order.currency)

            profile = workspace.pos_customer
            raise Conflict.new('Credit needs an identified customer.', reason: 'credit_customer_required') if profile.nil?
            if TenderAttempt.where(workspace: workspace, status: TenderAttempt::UNRESOLVED).exists?
              raise Conflict, 'Unresolved tender attempts block a credit approval.'
            end

            allocated = FundsAllocation.where(workspace: workspace, status: 'active').sum(:amount)
            raise Conflict, 'Credit amount must equal the unpaid remainder.' unless parsed == order.total - allocated

            account = CreditAccount.for_store(workspace.store).find_by(customer_profile_id: profile.id, currency: order.currency)
            raise Conflict.new('Customer has no credit account.', reason: 'credit_account_missing') if account.nil?

            Release.call(workspace: workspace, actor: staff, reason: 'superseded')
            account.lock!
            raise Conflict.new('Credit account is suspended.', reason: 'credit_account_suspended') unless account.active?
            raise Conflict.new('Credit limit would be exceeded.', reason: 'credit_limit_exceeded') unless account.exposure.fits?(parsed)

            approval = Approval.create!(
              store: workspace.store, branch: workspace.branch, approver: staff, requester: requester,
              subject_type: workspace.class.name, subject_id: workspace.id, action: ACTION, amount: parsed,
              currency: order.currency, revision: workspace.revision.to_s, status: 'active',
              expires_at: expiry(expires_at)
            )
            reservation = CreditReservation.create!(
              store: workspace.store, credit_account: account, workspace: workspace, approval: approval,
              customer_profile: profile, amount: parsed, currency: order.currency,
              workspace_revision: workspace.revision, status: 'active'
            )
            request&.update!(status: 'approved', decided_by: staff, decided_at: Time.current, credit_reservation: reservation)
            AuditEntry.record!(store: workspace.store, actor: staff, action: 'credit.approve', subject: workspace,
                               metadata: { reservation_id: reservation.prefixed_id, approval_id: approval.prefixed_id,
                                           account_id: account.prefixed_id, amount: parsed.to_s('F'),
                                           requester_id: requester.prefixed_id, request_id: request&.prefixed_id })
            reservation.to_pos
          end
        end

        def self.authorize_approver!(workspace, staff)
          policy = AccessPolicy.new(store: workspace.store, staff: staff)
          allowed = !workspace.branch.disabled? && policy.allows?(workspace.branch, Capabilities::APPROVE) &&
            policy.allows?(workspace.branch, Capabilities::CREDIT_MANAGE)
          raise CanCan::AccessDenied unless allowed
        end

        def self.requester!(workspace, staff, requester_id)
          requester = Spree.admin_user_class.find_by_prefix_id(requester_id.to_s)
          raise ActiveRecord::RecordNotFound if requester.nil?
          raise Conflict, 'An approver cannot approve their own credit sale.' if requester.id == staff.id
          raise CanCan::AccessDenied unless [workspace.shift.owner_id, workspace.lease_holder_id].include?(requester.id)

          policy = AccessPolicy.new(store: workspace.store, staff: requester)
          unless policy.allows?(workspace.branch, Capabilities::OPEN_SHIFT) && policy.allows?(workspace.branch, Capabilities::CREDIT_SELL)
            raise CanCan::AccessDenied
          end

          requester
        end

        def self.expiry(value)
          return Time.current + DEFAULT_TTL if value.blank?

          Time.zone.parse(value.to_s) || raise(Conflict, 'Expiry is invalid.')
        rescue ArgumentError
          raise Conflict, 'Expiry is invalid.'
        end
      end
    end
  end
end
