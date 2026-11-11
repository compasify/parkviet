# frozen_string_literal: true

module Spree
  module Pos
    module Einvoices
      # A provider that issues nothing outside this database: it answers like
      # a real one so the whole flow (queue, retry, buyer details, lookup,
      # receipts) can be tried without a provider account. Numbers come from
      # the invoice id, the tax authority code and lookup code are derived
      # from it, so a retried issue answers the same. Nothing it issues is a
      # legal invoice; production only offers it with POS_EINVOICE_SANDBOX=on.
      class SandboxProvider < Provider
        KEY = 'sandbox'

        class << self
          def label
            'Thử nghiệm (không gửi cơ quan thuế)'
          end

          def sandbox?
            true
          end

          def tax_code_lookup?
            true
          end
        end

        def issue(invoice)
          raise Error.new('The invoice has no lines.', code: 'invoice_empty', retryable: false) if invoice.lines_snapshot.empty?

          digest = Digest::SHA256.hexdigest("sandbox-einvoice:#{invoice.id}").upcase
          number = invoice.id.to_s.rjust(8, '0').last(8)
          at = Time.current
          Result.new(
            provider_ref: "SBX-#{invoice.persisted? ? invoice.prefixed_id : 'sample'}", number: number, template_code: invoice.template_code,
            symbol: invoice.symbol, cqt_code: cqt_code(invoice, digest, at), lookup_code: digest.first(10),
            lookup_url: setting.lookup_url.presence, issued_at: at, signed_at: invoice.invoice_type == 'coded' ? at : nil,
            sent_to_cqt_at: at
          )
        end

        def status(invoice)
          invoice.number.present? ? 'issued' : 'unknown'
        end

        def cancel(_invoice, _reason)
          true
        end

        def lookup_tax_code(tax_code)
          return nil unless tax_code.to_s.match?(EinvoiceSetting::TAX_CODE)

          TaxCodeResult.new(tax_code: tax_code, name: "Công ty thử nghiệm #{tax_code}", address: 'Địa chỉ thử nghiệm')
        end

        private

        # Cash-register invoices carry an `M1-YY-XXXXX-<11 digits>` code; a
        # coded invoice carries a 34-character code.
        def cqt_code(invoice, digest, at)
          return digest.first(34) if invoice.invoice_type == 'coded'

          "M1-#{at.strftime('%y')}-SBX#{digest.first(2)}-#{invoice.id.to_s.rjust(11, '0').last(11)}"
        end
      end
    end
  end
end
