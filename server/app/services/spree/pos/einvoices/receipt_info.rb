# frozen_string_literal: true

module Spree
  module Pos
    module Einvoices
      # The e-invoice facts a sale receipt prints, read when the receipt is
      # read rather than frozen into it: at the first print the invoice is
      # usually not issued yet, a reprint shows its lookup code. The buyer
      # link (printed as a QR) is offered only while the invoice can still
      # take buyer details. nil for a sale without an invoice.
      module ReceiptInfo
        module_function

        def for_workspace(workspace_id)
          invoices = Einvoice.where(workspace_id: workspace_id).order(:id).to_a
          return nil if invoices.empty?

          current = invoices.reverse.find { |row| row.status == 'issued' } || invoices.first
          {
            status: current.status, invoice_type: current.invoice_type, number: current.number, symbol: current.symbol,
            template_code: current.template_code, lookup_code: current.lookup_code, lookup_url: current.lookup_url,
            buyer_url: current.buyer_link_open? ? BuyerLink.url(current) : nil
          }
        end
      end
    end
  end
end
