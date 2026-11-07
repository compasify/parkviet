# frozen_string_literal: true

module Spree
  module Pos
    module Refunds
      # Confirms that refund money actually left, with evidence, and only then
      # books it in core: `Spree::Refunds::Create` records a Refund on the
      # original Payment (the POS manual method's credit is a no-op, so the
      # core row mirrors a payout that already happened rather than asking a
      # gateway). Cash leaves the confirmer's own open drawer at the paying
      # branch, so a refund paid the next day lands on that day's shift and the
      # sale's own shift and receipt never change. Bank refunds need the
      # transfer reference.
      #
      # Paying out needs someone other than the requester to approve: either
      # the confirmer is a distinct approver, or the confirmer consumes an
      # approval granted for this request. Retrying with the same key replays
      # the result; a second payout of the same request is refused.
      class ConfirmPayout
        AWAITING = %w[reserved unknown].freeze

        def self.call(store:, staff:, key:, refund_id:, evidence_kind:, reference: nil, approval_id: nil)
          payload = { 'command' => 'refund.confirm', 'refund_id' => refund_id.to_s, 'evidence_kind' => evidence_kind.to_s,
                      'reference' => reference.to_s.strip.presence, 'approval_id' => approval_id.to_s.presence }
          authorize = lambda do
            request = Guard.request!(store, refund_id)
            raise CanCan::AccessDenied unless Guard.allows?(store, staff, request.branch, Capabilities::RETURN, Capabilities::RESOLVE)
          end
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: authorize) do
            request = Guard.request!(store, refund_id)
            expected = request.method == 'cash' ? 'cash_count' : 'bank_manual'
            raise Conflict, 'Refund evidence does not match the refund method.' unless evidence_kind.to_s == expected
            raise Conflict, 'A bank refund needs the transfer reference.' if expected == 'bank_manual' && reference.to_s.strip.blank?

            drawer = expected == 'cash_count' ? open_drawer!(store, staff, request.branch) : nil
            funds = request.received_funds
            funds.with_lock do
              request.lock!
              raise Conflict.new('Refund is not awaiting a payout.', reason: 'not_awaiting') unless AWAITING.include?(request.status)

              approval = approve!(store, staff, request, approval_id)
              PayoutEvidence.create!(store: store, refund_request: request, actor: staff, kind: expected,
                                     reference: reference.to_s.strip.presence, attested_at: Time.current,
                                     metadata: { approval_id: approval&.prefixed_id })
              if drawer
                CashMovement.create!(
                  store: store, branch: drawer.branch, register: drawer.register, shift: drawer, received_funds: funds,
                  refund_request: request, actor: staff, kind: 'payout', amount: -request.amount, currency: request.currency,
                  source_type: request.class.name, source_id: request.id
                )
              end
              refund = book_core_refund!(request, staff)
              request.update!(status: 'confirmed', refund: refund, confirmer: staff, shift: drawer,
                              approval: approval || request.approval, confirmed_at: Time.current)
            end
            AuditEntry.record!(store: store, actor: staff, action: 'refund.confirm', subject: request.return_operation,
                               metadata: { refund_id: request.prefixed_id, amount: request.amount.to_s('F'),
                                           shift_id: drawer&.prefixed_id, core_refund_id: request.refund.prefixed_id })
            OutboxEntry.record!(store: store, event_type: 'refund.confirmed', aggregate: request,
                                payload: { 'refund_id' => request.prefixed_id })
            request.to_pos
          end
        end

        def self.open_drawer!(store, staff, branch)
          shift = Shift.for_store(store).find_by(branch_id: branch.id, owner_id: staff.id, status: 'open')
          raise Conflict.new('Cash refunds need your own open shift in this branch.', reason: 'shift_required') if shift.nil?

          shift
        end

        # A distinct approver confirms directly; anyone else spends the
        # approval granted for this request.
        def self.approve!(store, staff, request, approval_id)
          if staff.id != request.requester_id && AccessPolicy.new(store: store, staff: staff).allows?(request.branch, Capabilities::APPROVE)
            return nil
          end

          approval = if approval_id.present?
                       Approval.locate(Approval.for_store(store).where(branch_id: request.branch_id), approval_id)
                     else
                       request.approval
                     end
          raise Conflict.new('This refund needs an approval.', reason: 'approval_required') if approval.nil?

          approval.consume!(action: RefundRequest::ACTION, amount: request.amount, currency: request.currency,
                            revision: request.revision, subject: request, requester: staff)
          approval
        end

        def self.book_core_refund!(request, staff)
          result = Spree::Refunds::Create.call(payment: request.payment, amount: request.amount, refunder: staff,
                                               originator: request.return_operation.core_return, order: request.order)
          raise Conflict, Returns::Guard.core_error(result, 'Core refund could not be recorded.') unless result.success?

          result.value
        end
      end
    end
  end
end
