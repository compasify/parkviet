# frozen_string_literal: true

module Spree
  module Pos
    module Shifts
      # Manual drawer movement on the caller's own open shift, always with a
      # reason. It is drawer custody only: never a sale, a receipt or a
      # customer Payment.
      #
      # - Cash in posts at once under the shift barrier.
      # - Cash out and safe drops need an evidence reference and a second
      #   person: this only records the request; ConfirmCashMovement posts the
      #   movement. A request is refused when the drawer does not hold the
      #   amount (and is checked again on confirmation).
      class PostCashMovement
        KINDS = %w[cash_in cash_out safe_drop].freeze

        def self.call(store:, staff:, key:, shift_id:, kind:, amount:, reason:, evidence_reference: nil)
          value = Record.money(amount.to_s)
          payload = { 'command' => 'shift.cash_movement', 'shift_id' => shift_id.to_s, 'kind' => kind.to_s,
                      'amount' => value&.to_s('F'), 'reason' => reason.to_s.strip,
                      'evidence_reference' => evidence_reference.to_s.strip.presence }
          authorize = -> { authorize!(store, staff, Guard.shift!(store, shift_id)) }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: authorize) do
            shift = Guard.shift!(store, shift_id)
            # Requests already made can still be confirmed or canceled.
            FeaturePolicy.require!(shift.branch, :cash_moves)
            note, evidence = validate!(kind.to_s, value, shift.currency, reason, evidence_reference)
            ShiftBarrier.hold!(shift)
            if kind.to_s == 'cash_in'
              movement = post!(shift, staff, 'cash_in', value, note, evidence)
              AuditEntry.record!(store: store, actor: staff, action: 'cash.move', subject: shift,
                                 metadata: { movement_id: movement.prefixed_id, kind: 'cash_in',
                                             amount: movement.amount.to_s('F'), reason: note, evidence_reference: evidence })
              next movement.to_pos.merge(status: 'posted')
            end

            ensure_cash!(shift, value)
            request = CashMovementRequest.create!(
              store: store, branch: shift.branch, shift: shift, requester: staff, kind: kind.to_s, status: 'requested',
              amount: value, currency: shift.currency, reason: note, evidence_reference: evidence
            )
            AuditEntry.record!(store: store, actor: staff, action: 'cash.move_request', subject: shift,
                               metadata: { request_id: request.prefixed_id, kind: request.kind, amount: value.to_s('F'),
                                           reason: note, evidence_reference: evidence })
            request.to_pos
          end
        end

        def self.validate!(kind, value, currency, reason, evidence_reference)
          raise Conflict.new('Movement kind is invalid.', reason: 'kind_invalid') unless KINDS.include?(kind)
          if value.nil? || !value.positive? || !Record.countable_money?(value, currency)
            raise Conflict.new('Amount must be a positive whole amount.', reason: 'amount_invalid')
          end

          note = reason.to_s.strip
          raise Conflict.new('A reason is required.', reason: 'reason_required') if note.blank?
          raise Conflict.new('Reason is too long.', reason: 'reason_invalid') if note.length > 200

          evidence = evidence_reference.to_s.strip.presence
          raise Conflict.new('Evidence reference is too long.', reason: 'evidence_invalid') if evidence && evidence.length > 120
          raise Conflict.new('Cash out and safe drops need an evidence reference.', reason: 'evidence_required') if kind != 'cash_in' && evidence.nil?

          [note, evidence]
        end

        def self.ensure_cash!(shift, value)
          return if value <= CashbookProjection.new(shift).expected

          raise Conflict.new('The drawer does not hold that much cash.', reason: 'insufficient_cash')
        end

        def self.authorize!(store, staff, shift)
          policy = AccessPolicy.new(store: store, staff: staff)
          allowed = shift.owner_id == staff.id && !shift.branch.disabled? &&
            policy.allows?(shift.branch, Capabilities::CASH_MOVE)
          raise CanCan::AccessDenied unless allowed
        end

        # A manual movement takes its id first when it is its own source, so
        # the source link (unique per source and kind) points at itself.
        def self.post!(shift, staff, kind, signed, reason, evidence, source: nil)
          id = CashMovement.connection.select_value("SELECT nextval(pg_get_serial_sequence('spree_pos_cash_movements', 'id'))").to_i
          CashMovement.create!(
            id: id, store: shift.store, branch: shift.branch, register: shift.register, shift: shift, actor: staff,
            kind: kind, amount: signed, currency: shift.currency, source_type: source ? source.class.name : CashMovement.name,
            source_id: source ? source.id : id, reason: reason, evidence_reference: evidence
          )
        end
      end
    end
  end
end
