# frozen_string_literal: true

module Spree
  module Pos
    module Einvoices
      # Stops an invoice that never reached the provider (pending or
      # failed), with a reason; the queue then leaves it alone. An issued
      # invoice cannot be cancelled under the rules in force: it is replaced
      # instead. Needs pos.einvoice.manage at the branch; audited as
      # `einvoice.canceled`.
      module Cancel
        module_function

        def call(store:, staff:, key:, einvoice:, reason:)
          note = reason.to_s.strip.first(200)
          payload = { 'command' => 'einvoice.cancel', 'einvoice_id' => einvoice.prefixed_id, 'reason' => note }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload,
                               authorize: -> { Einvoices.manage!(store, staff, einvoice.branch) }) do
            raise Conflict.new('A reason is required.', reason: 'einvoice_reason_required') if note.empty?

            einvoice.lock!
            raise Conflict.new('The invoice is being issued; try again in a minute.', reason: UpdateBuyer::BUSY) if einvoice.status == 'issuing'
            unless einvoice.buyer_editable?
              raise Conflict.new('An issued invoice cannot be cancelled; request a replacement.', reason: UpdateBuyer::ISSUED)
            end

            einvoice.update!(status: 'canceled', canceled_at: Time.current, cancel_reason: note, next_attempt_at: nil)
            AuditEntry.record!(store: store, actor: staff, action: 'einvoice.canceled', subject: einvoice,
                               metadata: { order_id: einvoice.order.prefixed_id, reason: note })
            einvoice.to_pos
          end
        end
      end
    end
  end
end
