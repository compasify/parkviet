# frozen_string_literal: true

require_relative 'pos_credit_helpers'

# E-invoice scenarios through the real POS workflows: a store issuing
# cash-register invoices with the sandbox provider, and cash sales completed
# at its branch.
module PosEinvoiceHelpers
  include PosCreditHelpers

  def einvoice_store(type: 'cash_register', provider: 'sandbox', credentials: nil)
    store = create(:store, default_currency: 'VND', supported_currencies: 'VND')
    Spree::Pos::StoreProfile.create!(store: store, profile_key: 'khac', onboarded_at: 1.day.ago, einvoice_type: type)
    setting = Spree::Pos::EinvoiceSetting.new(store: store, provider: provider, template_code: '1', symbol: 'C26MAA',
                                              seller_name: 'Cửa hàng thử', seller_tax_code: '0101234567',
                                              seller_address: '1 Lê Lợi, Quận 1', lookup_url: 'https://tracuu.example.test')
    setting.credential_values = credentials if credentials
    setting.save!
    store
  end

  def einvoice_manager(store, branch)
    credit_staff(store, branch, [Spree::Pos::Capabilities::EINVOICE_MANAGE])
  end

  # A one-line sale paid in cash and completed.
  def completed_sale(store, branch, price: 20_000, einvoice_buyer: nil)
    sale = credit_sale(store, branch, price: price)
    take_tender(sale, 'cash', price)
    Spree::Pos::Workspaces::Complete.call(**editing_args(sale), einvoice_buyer: einvoice_buyer)
    sale.workspace.reload
    sale
  end

  def einvoice_of(sale)
    Spree::Pos::Einvoice.find_by!(workspace_id: sale.workspace.id, relation: 'original')
  end

  # Runs the outbox the way the recurring job does, as if `at` had come.
  def drain_outbox(at: Time.current)
    travel_to(at, with_usec: true) { Spree::Pos::DispatchOutboxJob.perform_now }
  end

  def issue_entries(einvoice)
    Spree::Pos::OutboxEntry.where(event_type: 'einvoice.issue', aggregate_type: 'Spree::Pos::Einvoice', aggregate_id: einvoice.id)
  end
end
