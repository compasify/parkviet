# frozen_string_literal: true

module Spree
  module Pos
    module Einvoices
      # Issues one invoice through its provider. Idempotent: an invoice that
      # is already issued (or cancelled, replaced) is left alone, and an
      # invoice another worker is issuing right now is skipped, so only one
      # worker ever calls the adapter for it. The call itself runs outside
      # any transaction; the claim before it and the outcome after it are
      # each committed on their own.
      #
      # Returns nil when nothing more is due, or the time of the next try:
      # after a failure 1, 5, 15 and 60 minutes, then every 6 hours, until it
      # is issued or someone cancels it. A failure a person must fix
      # (`retryable: false`) is not retried on its own.
      module Issue
        BACKOFF = [1.minute, 5.minutes, 15.minutes, 1.hour].freeze
        BACKOFF_CEILING = 6.hours
        # An `issuing` claim older than this belongs to a worker that died.
        CLAIM_TIMEOUT = 10.minutes
        BUSY_RETRY = 1.minute
        ERROR_LIMIT = 500
        NOT_CONFIGURED = 'einvoice_not_configured'

        module_function

        # The outbox handler of `einvoice.issue` (DispatchOutboxJob).
        def handle(entry)
          einvoice = Einvoice.find_by(id: entry.aggregate_id, store_id: entry.store_id)
          einvoice && call(einvoice)
        end

        def call(einvoice)
          setting = nil
          claim = claim!(einvoice)
          return claim unless claim.is_a?(EinvoiceSetting)

          setting = claim
          result = Einvoices.provider_for(setting).issue(einvoice.reload)
          succeed!(einvoice, result)
          nil
        rescue Provider::Error => e
          fail!(einvoice, e.code, scrub(e.message, setting), retryable: e.retryable?)
        rescue StandardError => e
          Rails.error.report(e, handled: true, context: { einvoice_id: einvoice.id })
          fail!(einvoice, 'provider_unavailable', e.class.name, retryable: true)
        end

        def backoff(attempts)
          BACKOFF.fetch(attempts - 1, BACKOFF_CEILING)
        end

        # The settings to issue with once claimed, nil (nothing to do) or a retry time.
        def claim!(einvoice)
          Einvoice.transaction do
            einvoice.lock!
            next nil if Einvoice::FINAL.include?(einvoice.status)
            next Time.current + BUSY_RETRY if einvoice.status == 'issuing' && einvoice.updated_at > CLAIM_TIMEOUT.ago

            setting = EinvoiceSetting.for_branch(einvoice.branch)
            next unconfigured!(einvoice) if setting.nil? || !Einvoices.registered?(setting.provider)

            prepare!(einvoice, setting)
            setting
          end
        end

        # The seller, symbol and buyer label as the settings stand now, and
        # the lines if the snapshot at completion could not be built.
        def prepare!(einvoice, setting)
          if einvoice.lines_snapshot.blank?
            built = Builder.call(einvoice.workspace)
            einvoice.assign_attributes(lines_snapshot: built[:lines], totals_snapshot: built[:totals],
                                       payment_method: built[:payment_method])
          end
          buyer = einvoice.buyer.except('label')
          buyer['label'] = setting.consumer_label_text if Buyer.consumer?(buyer)
          einvoice.update!(status: 'issuing', attempts: einvoice.attempts + 1, provider: setting.provider, buyer: buyer,
                           seller: seller(einvoice.branch, setting), template_code: setting.template_code.presence || '1',
                           symbol: setting.symbol.presence || default_symbol(einvoice), next_attempt_at: nil)
        end

        def seller(branch, setting)
          { 'name' => setting.seller_name.presence || branch.store.name, 'tax_code' => setting.seller_tax_code,
            'address' => setting.seller_address.presence || ReceiptBuilder.store_profile(branch.store)['address'],
            'outlet_code' => branch.code, 'outlet_name' => branch.name }
        end

        # C<yy>M.. for the cash register, C<yy>T.. otherwise: only a default
        # until the provider's own symbol is set.
        def default_symbol(einvoice)
          "C#{Time.current.strftime('%y')}#{einvoice.invoice_type == 'cash_register' ? 'M' : 'T'}YY"
        end

        def succeed!(einvoice, result)
          Einvoice.transaction do
            einvoice.lock!
            einvoice.update!(
              status: 'issued', provider_ref: result.provider_ref, number: result.number,
              template_code: result.template_code.presence || einvoice.template_code, symbol: result.symbol.presence || einvoice.symbol,
              cqt_code: result.cqt_code, lookup_code: result.lookup_code, lookup_url: result.lookup_url,
              issued_at: result.issued_at || Time.current, signed_at: result.signed_at, sent_to_cqt_at: result.sent_to_cqt_at,
              last_error: nil, next_attempt_at: nil
            )
            einvoice.original_einvoice&.update!(status: 'replaced')
            AuditEntry.record!(store: einvoice.store, actor: einvoice.created_by, action: 'einvoice.issued', subject: einvoice,
                               metadata: { order_id: einvoice.order.prefixed_id, number: einvoice.number, symbol: einvoice.symbol,
                                           relation: einvoice.relation, attempts: einvoice.attempts })
          end
        end

        def fail!(einvoice, code, message, retryable:)
          Einvoice.transaction do
            einvoice.lock!
            next nil if Einvoice::FINAL.include?(einvoice.status)

            first = einvoice.last_error.nil?
            retry_at = retryable ? Time.current + backoff([einvoice.attempts, 1].max) : nil
            einvoice.update!(status: 'failed', last_error: "#{code}: #{message}".first(ERROR_LIMIT), next_attempt_at: retry_at)
            if first
              AuditEntry.record!(store: einvoice.store, actor: einvoice.created_by, action: 'einvoice.failed', subject: einvoice,
                                 metadata: { order_id: einvoice.order.prefixed_id, code: code, attempts: einvoice.attempts })
            end
            retry_at
          end
        end

        def unconfigured!(einvoice)
          attempts = einvoice.attempts + 1
          retry_at = Time.current + backoff(attempts)
          first = einvoice.last_error.nil?
          einvoice.update!(status: 'failed', attempts: attempts, last_error: "#{NOT_CONFIGURED}: no active provider settings",
                           next_attempt_at: retry_at)
          if first
            AuditEntry.record!(store: einvoice.store, actor: einvoice.created_by, action: 'einvoice.failed', subject: einvoice,
                               metadata: { order_id: einvoice.order.prefixed_id, code: NOT_CONFIGURED, attempts: attempts })
          end
          retry_at
        end

        # A provider message may echo what it was sent; credential values
        # never reach the stored error.
        def scrub(message, setting)
          text = message.to_s
          (setting&.credential_values || {}).each_value do |value|
            secret = value.to_s
            text = text.gsub(secret, '[FILTERED]') if secret.length >= 4
          end
          text
        end
      end
    end
  end
end
