# frozen_string_literal: true

module Spree
  module Pos
    module Einvoices
      # Sets the buyer an invoice will carry, while it has not gone to the
      # provider yet. A staff change goes through CommandExecutor and needs
      # pos.einvoice.manage at the branch; the buyer's own page uses
      # `from_buyer!` with its signed link instead. An invoice that already
      # issued keeps its buyer: a manager requests a replacement
      # (Einvoices::Replace). A failed invoice is queued again at once.
      # Audited as `einvoice.buyer_updated`.
      module UpdateBuyer
        ISSUED = 'einvoice_already_issued'
        BUSY = 'einvoice_issuing'

        module_function

        def call(store:, staff:, key:, einvoice:, buyer:)
          clean = Buyer.normalize!(buyer)
          payload = { 'command' => 'einvoice.update_buyer', 'einvoice_id' => einvoice.prefixed_id, 'buyer' => clean }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload,
                               authorize: -> { Einvoices.manage!(store, staff, einvoice.branch) }) do
            apply!(einvoice, clean, actor: staff, source: 'staff')
            einvoice.to_pos
          end
        end

        def from_buyer!(einvoice, buyer)
          clean = Buyer.normalize!(buyer)
          Einvoice.transaction do
            einvoice.lock!
            if einvoice.buyer_token_expires_at.nil? || einvoice.buyer_token_expires_at <= Time.current
              raise Conflict.new('The buyer link has expired.', reason: 'einvoice_link_expired')
            end

            apply!(einvoice, clean, actor: einvoice.created_by, source: 'buyer')
          end
        end

        def apply!(einvoice, clean, actor:, source:)
          einvoice.lock!
          raise Conflict.new('The invoice is being issued; try again in a minute.', reason: BUSY) if einvoice.status == 'issuing'
          raise Conflict.new('The invoice has already been issued; request a replacement instead.', reason: ISSUED) unless einvoice.buyer_editable?

          was_failed = einvoice.status == 'failed'
          einvoice.update!(buyer: clean, buyer_submitted_at: source == 'buyer' ? Time.current : einvoice.buyer_submitted_at)
          AuditEntry.record!(store: einvoice.store, actor: actor, action: 'einvoice.buyer_updated', subject: einvoice,
                             metadata: { order_id: einvoice.order.prefixed_id, source: source, business: clean['tax_code'].present? })
          Einvoices.queue!(einvoice) if was_failed || source == 'buyer'
          einvoice
        end
      end
    end
  end
end
