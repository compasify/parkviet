# frozen_string_literal: true

module Spree
  module Pos
    module Shifts
      # Second person on a cash out or safe drop. `confirm` posts the one
      # CashMovement under the shift barrier (shift -> request lock order) and
      # needs `pos.cash.move` or `pos.approval.grant` at the branch from
      # someone other than the requester; `cancel` withdraws a request that
      # never moved cash, by the requester or such a confirmer, with a note.
      class ConfirmCashMovement
        DECISIONS = %w[confirm cancel].freeze

        def self.call(store:, staff:, key:, request_id:, decision:, note: nil)
          payload = { 'command' => 'shift.cash_movement_decision', 'request_id' => request_id.to_s,
                      'decision' => decision.to_s, 'note' => note.to_s.strip.presence }
          authorize = -> { authorize!(store, staff, request!(store, request_id), decision.to_s) }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: authorize) do
            raise Conflict.new('Decision is invalid.', reason: 'decision_invalid') unless DECISIONS.include?(decision.to_s)

            request = request!(store, request_id)
            text = note.to_s.strip.presence
            raise Conflict.new('Note is too long.', reason: 'reason_invalid') if text && text.length > 200

            decision.to_s == 'confirm' ? confirm!(store, staff, request, text) : cancel!(store, staff, request, text)
            request.reload.to_pos
          end
        end

        def self.confirm!(store, staff, request, note)
          shift = ShiftBarrier.hold!(request.shift)
          request.lock!
          raise Conflict.new('This request is no longer waiting.', reason: 'not_awaiting') unless request.status == 'requested'
          if request.amount > CashbookProjection.new(shift).expected
            raise Conflict.new('The drawer does not hold that much cash.', reason: 'insufficient_cash')
          end

          movement = PostCashMovement.post!(shift, request.requester, request.kind, -request.amount, request.reason,
                                            request.evidence_reference, source: request)
          request.update!(status: 'confirmed', confirmer: staff, cash_movement: movement, resolution_note: note,
                          resolved_at: Time.current)
          AuditEntry.record!(store: store, actor: staff, action: 'cash.move_confirm', subject: shift,
                             metadata: { request_id: request.prefixed_id, movement_id: movement.prefixed_id,
                                         kind: request.kind, amount: movement.amount.to_s('F') })
        end

        def self.cancel!(store, staff, request, note)
          raise Conflict.new('A reason is required.', reason: 'reason_required') if note.nil?

          request.lock!
          raise Conflict.new('This request is no longer waiting.', reason: 'not_awaiting') unless request.status == 'requested'

          request.update!(status: 'canceled', confirmer: staff, resolution_note: note, resolved_at: Time.current)
          AuditEntry.record!(store: store, actor: staff, action: 'cash.move_cancel', subject: request.shift,
                             metadata: { request_id: request.prefixed_id, note: note })
        end

        def self.request!(store, request_id)
          request = CashMovementRequest.locate(CashMovementRequest.for_store(store), request_id)
          raise ActiveRecord::RecordNotFound if request.nil?

          request
        end

        def self.confirmer?(store, staff, branch)
          policy = AccessPolicy.new(store: store, staff: staff)
          policy.allows?(branch, Capabilities::CASH_MOVE) || policy.allows?(branch, Capabilities::APPROVE)
        end

        def self.authorize!(store, staff, request, decision)
          return if decision == 'cancel' && request.requester_id == staff.id
          raise Conflict.new('Someone else must confirm this.', reason: 'self_approval') if decision == 'confirm' && request.requester_id == staff.id
          raise CanCan::AccessDenied unless confirmer?(store, staff, request.branch)
        end
      end
    end
  end
end
