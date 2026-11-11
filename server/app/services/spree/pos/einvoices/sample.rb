# frozen_string_literal: true

module Spree
  module Pos
    module Einvoices
      # "Issue a test invoice" on the settings screen: one made-up line sent
      # to a sandbox provider and nothing saved. A real provider would issue
      # a real invoice, so it is refused for them.
      module Sample
        module_function

        def call(setting:, branch: nil)
          adapter = Einvoices.adapter(setting.provider)
          raise Conflict.new('This provider has no adapter.', reason: 'einvoice_provider_unknown') if adapter.nil?
          raise Conflict.new('Only a sandbox provider can issue a test invoice.', reason: 'einvoice_sample_sandbox_only') unless adapter.sandbox?

          invoice = sample_invoice(setting, branch)
          result = adapter.new(setting).issue(invoice)
          { provider: setting.provider, template_code: result.template_code, symbol: result.symbol, number: result.number,
            cqt_code: result.cqt_code, lookup_code: result.lookup_code, lookup_url: result.lookup_url,
            issued_at: result.issued_at&.iso8601, seller: invoice.seller, buyer: invoice.buyer, lines: invoice.lines_snapshot }
        rescue Provider::Error => e
          raise Conflict.new(e.message, reason: 'einvoice_sample_failed', details: { code: e.code })
        end

        def sample_invoice(setting, branch)
          type = StoreProfile.einvoice_type_for(setting.store)
          type = 'cash_register' if type == 'none'
          seller_branch = branch || Branch.for_store(setting.store).order(:id).first
          line = { 'position' => 1, 'kind' => 'goods', 'name' => 'Hàng thử nghiệm', 'unit' => 'cái', 'quantity' => '1',
                   'unit_price' => '10800.0', 'discount' => '0.0', 'tax_rate' => '8', 'tax_amount' => '800.0',
                   'amount_before_tax' => '10000.0', 'amount' => '10800.0', 'price_includes_tax' => true }
          Einvoice.new(
            store: setting.store, invoice_type: type, relation: 'original', status: 'issuing', currency: 'VND',
            template_code: setting.template_code.presence || '1', symbol: setting.symbol.presence || 'C26MYY',
            seller: { 'name' => setting.seller_name.presence || setting.store.name, 'tax_code' => setting.seller_tax_code,
                      'address' => setting.seller_address, 'outlet_code' => seller_branch&.code, 'outlet_name' => seller_branch&.name },
            buyer: { 'label' => setting.consumer_label_text }, lines_snapshot: [line], payment_method: 'TM',
            totals_snapshot: { 'amount_before_tax' => '10000.0', 'tax_amount' => '800.0', 'discount_total' => '0.0', 'total' => '10800.0',
                               'taxes' => [{ 'tax_rate' => '8', 'amount_before_tax' => '10000.0', 'tax_amount' => '800.0' }] }
          )
        end
      end
    end
  end
end
