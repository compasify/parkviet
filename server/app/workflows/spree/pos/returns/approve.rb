# frozen_string_literal: true

module Spree
  module Pos
    module Returns
      # An approver at the receiving branch grants one action-bound approval
      # for a return that needs it (cross-branch, outside the window, damaged
      # goods). It binds the requester, the operation, its revision and its
      # entitlement; the requester's receive consumes it once.
      class Approve
        DEFAULT_TTL = 30.minutes

        def self.call(store:, staff:, key:, return_id:, expires_at: nil)
          payload = { 'command' => 'return.approve', 'return_id' => return_id.to_s, 'expires_at' => expires_at.to_s.presence }
          authorize = lambda do
            operation = Guard.operation!(store, return_id)
            raise CanCan::AccessDenied unless AccessPolicy.new(store: store, staff: staff).allows?(operation.branch, Capabilities::APPROVE)
          end
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: authorize) do
            operation = Guard.operation!(store, return_id)
            operation.lock!
            unless operation.status == 'pending_approval'
              raise Conflict.new('Only a return waiting for approval can be approved.',
                                 reason: 'not_pending')
            end
            raise Conflict.new('You cannot approve your own return.', reason: 'self_approval') if operation.requester_id == staff.id

            approval = Approval.create!(
              store: store, branch: operation.branch, approver: staff, requester: operation.requester,
              subject_type: operation.class.name, subject_id: operation.id, action: ReturnOperation::ACTION,
              amount: operation.entitlement_total, currency: operation.currency, revision: operation.revision.to_s,
              expires_at: expires_at.presence || (Time.current + DEFAULT_TTL), status: 'active'
            )
            operation.update!(approval: approval)
            AuditEntry.record!(store: store, actor: staff, action: 'return.approve', subject: operation,
                               metadata: { approval_id: approval.prefixed_id, amount: operation.entitlement_total.to_s('F') })
            operation.to_pos
          end
        end
      end
    end
  end
end
