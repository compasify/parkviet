# frozen_string_literal: true

module Spree
  module Pos
    module Einvoices
      # What every e-invoice adapter implements. An adapter is built for one
      # settings row (`setting`, with decrypted `credentials`) and talks to
      # one provider. It never writes the database: Einvoices::Issue copies
      # what `issue` returns onto the invoice.
      #
      # `issue(invoice)` gets an Einvoice whose lines, totals, buyer, seller,
      # template code and symbol are already set, and returns a Result. It
      # sends `invoice.prefixed_id` as the provider's idempotency reference
      # whenever the provider supports one, so a retry after a lost answer
      # never makes a second invoice. Failures raise Error; `retryable: false`
      # means a person must fix something before trying again.
      class Provider
        Result = Struct.new(:provider_ref, :number, :template_code, :symbol, :cqt_code, :lookup_code, :lookup_url,
                            :issued_at, :signed_at, :sent_to_cqt_at, keyword_init: true)
        TaxCodeResult = Struct.new(:tax_code, :name, :address, keyword_init: true)

        class Error < StandardError
          attr_reader :code

          def initialize(message, code: 'provider_error', retryable: true)
            super(message)
            @code = code
            @retryable = retryable
          end

          def retryable?
            @retryable
          end
        end

        class << self
          def label
            name.demodulize
          end

          def sandbox?
            false
          end

          # Names of the credential fields the settings screen asks for.
          def credential_fields
            []
          end

          def tax_code_lookup?
            false
          end
        end

        attr_reader :setting

        def initialize(setting)
          @setting = setting
        end

        def credentials
          @credentials ||= setting.credential_values
        end

        def issue(_invoice)
          raise NotImplementedError, "#{self.class.name}#issue"
        end

        # The provider's view of an invoice: `issued`, `pending` or `unknown`.
        def status(_invoice)
          raise NotImplementedError, "#{self.class.name}#status"
        end

        # Kept for providers that still accept withdrawing an invoice that was
        # never sent to the buyer; the POS itself only cancels invoices that
        # never reached the provider (Einvoices::Cancel).
        def cancel(_invoice, _reason)
          raise NotImplementedError, "#{self.class.name}#cancel"
        end

        # A TaxCodeResult for a tax code, nil when unknown or unsupported.
        def lookup_tax_code(_tax_code)
          nil
        end
      end
    end
  end
end
