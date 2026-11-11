# frozen_string_literal: true

module Spree
  module Pos
    module Einvoices
      # Requests a replacement of an issued invoice, for example when the
      # buyer asks for their company details after it was issued. The rules
      # in force allow no edit or cancellation of an issued invoice, only a
      # replacement (or an adjustment, not offered yet). The replacement has
      # the same lines and the new buyer, and is issued through the queue
      # like any invoice; the original becomes `replaced` once it issues.
      # Needs pos.einvoice.manage at the branch; audited as
      # `einvoice.replacement_requested`.
      module Replace
        module_function

        def call(store:, staff:, key:, einvoice:, buyer:, reason:)
          clean = Buyer.normalize!(buyer)
          note = reason.to_s.strip.first(200)
          payload = { 'command' => 'einvoice.replace', 'einvoice_id' => einvoice.prefixed_id, 'buyer' => clean, 'reason' => note }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload,
                               authorize: -> { Einvoices.manage!(store, staff, einvoice.branch) }) do
            raise Conflict.new('A reason is required.', reason: 'einvoice_reason_required') if note.empty?

            einvoice.lock!
            raise Conflict.new('Only an issued invoice can be replaced.', reason: 'einvoice_not_issued') unless einvoice.status == 'issued'
            if einvoice.replacements.where(status: Einvoice::OUTSTANDING).exists?
              raise Conflict.new('A replacement is already waiting to be issued.', reason: 'einvoice_replacement_pending')
            end

            replacement = Einvoice.create!(
              store: store, branch: einvoice.branch, order: einvoice.order, workspace: einvoice.workspace, created_by: staff,
              relation: 'replacement', original_einvoice: einvoice, invoice_type: einvoice.invoice_type, provider: einvoice.provider,
              status: 'pending', buyer: clean, lines_snapshot: einvoice.lines_snapshot, totals_snapshot: einvoice.totals_snapshot,
              payment_method: einvoice.payment_method, currency: einvoice.currency, cancel_reason: nil
            )
            Einvoices.queue!(replacement)
            AuditEntry.record!(store: store, actor: staff, action: 'einvoice.replacement_requested', subject: einvoice,
                               metadata: { order_id: einvoice.order.prefixed_id, replacement_id: replacement.prefixed_id, reason: note })
            replacement.to_pos
          end
        end
      end
    end
  end
end
