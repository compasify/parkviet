# frozen_string_literal: true

module Spree
  module Pos
    module Returns
      # Posts the entitlement of a received return: its reservations become
      # immutable, a credit note lowers the order's open debt first (through
      # the receivable ledger, never core amount_due), and only the value above
      # the debt becomes refund entitlement, capped by what the order actually
      # received and not already granted to another return.
      #
      # A reservation whose predecessor on the same SaleLine is still
      # unresolved waits: posting it first would freeze a delta the
      # predecessor's cancellation must still be able to change. Posting or
      # canceling a predecessor posts the waiting dependents. Callers hold the
      # operation and SaleLine locks.
      module ApplyCreditNote
        module_function

        def call(operation:, actor:)
          return operation unless operation.status == 'received' && %w[pending awaiting_predecessor].include?(operation.entitlement_status)

          rows = operation.reservations.where(status: 'reserved').to_a
          if rows.any? { |row| predecessor_open?(row) }
            operation.update!(entitlement_status: 'awaiting_predecessor')
            return operation
          end

          post!(operation, rows, actor)
          post_dependents!(operation, actor)
          operation
        end

        def predecessor_open?(row)
          # Earlier chunks of the same return are posted together with it.
          ReturnReservation.where(sale_line_id: row.sale_line_id, status: 'reserved').where(sequence: ...row.sequence).
            where.not(return_operation_id: row.return_operation_id).exists?
        end

        def post!(operation, rows, actor)
          order = operation.order
          value = rows.sum(BigDecimal('0'), &:total)
          entry = nil
          if value.positive? && ReceivableEntry.exists?(order_id: order.id, kind: 'debit')
            entry = ReceivableEntry.post_credit_note!(order: order, amount: value, source: operation, actor: actor,
                                                      metadata: { return_id: operation.prefixed_id }, up_to_balance: true)
          end
          order.lock!
          split = Guard.split(order, value, except: operation, balance: entry&.amount || BigDecimal('0'))
          rows.each { |row| row.update!(status: 'posted') }
          operation.update!(entitlement_status: 'posted', entitlement_total: value, credit_note_amount: split[:credit_note],
                            refund_entitlement: split[:refund], posted_at: Time.current)
          AuditEntry.record!(store: operation.store, actor: actor, action: 'return.entitlement_posted', subject: operation,
                             metadata: { entitlement: value.to_s('F'), credit_note: split[:credit_note].to_s('F'),
                                         refund_entitlement: split[:refund].to_s('F'), receivable_entry_id: entry&.prefixed_id })
          # Posted after its slip was issued as pending: a supplementary slip.
          ReceiptBuilder.issue_supplement_safely!(operation, actor: actor)
        end

        # Received returns of the same lines that were waiting for this one.
        # They take no other command once received, so the SaleLine locks the
        # caller holds are enough to post them.
        def post_dependents!(operation, actor)
          lines = operation.reservations.select(:sale_line_id)
          waiting = ReturnOperation.where(status: 'received', entitlement_status: 'awaiting_predecessor').
                    where(id: ReturnReservation.where(sale_line_id: lines).select(:return_operation_id)).
                    where.not(id: operation.id).order(:id).to_a
          waiting.each { |dependent| call(operation: dependent, actor: actor) }
        end
      end
    end
  end
end
