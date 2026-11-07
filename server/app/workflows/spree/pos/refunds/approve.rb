# frozen_string_literal: true

module Spree
  module Pos
    module Refunds
      # An approver at the paying branch grants one approval for one refund
      # payout, bound to the requester, the request, its revision and amount.
      class Approve
        DEFAULT_TTL = 30.minutes

        def self.call(store:, staff:, key:, refund_id:, expires_at: nil)
          payload = { 'command' => 'refund.approve', 'refund_id' => refund_id.to_s, 'expires_at' => expires_at.to_s.presence }
          authorize = lambda do
            request = Guard.request!(store, refund_id)
            raise CanCan::AccessDenied unless AccessPolicy.new(store: store, staff: staff).allows?(request.branch, Capabilities::APPROVE)
          end
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: authorize) do
            request = Guard.request!(store, refund_id)
            request.lock!
            raise Conflict.new('Only a reserved refund can be approved.', reason: 'not_reserved') unless request.status == 'reserved'
            raise Conflict.new('You cannot approve your own refund.', reason: 'self_approval') if request.requester_id == staff.id

            approval = Approval.create!(
              store: store, branch: request.branch, approver: staff, requester: request.requester,
              subject_type: request.class.name, subject_id: request.id, action: RefundRequest::ACTION,
              amount: request.amount, currency: request.currency, revision: request.revision.to_s,
              expires_at: expires_at.presence || (Time.current + DEFAULT_TTL), status: 'active'
            )
            request.update!(approval: approval)
            AuditEntry.record!(store: store, actor: staff, action: 'refund.approve', subject: request.return_operation,
                               metadata: { refund_id: request.prefixed_id, approval_id: approval.prefixed_id, amount: request.amount.to_s('F') })
            request.to_pos
          end
        end
      end
    end
  end
end
