# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../../support/pos_einvoice_helpers'

# The sandbox answers like a provider without leaving the database: the same
# invoice always gets the same number and codes, a cash-register invoice an
# M1 code, and any well-formed tax code a made-up company.
RSpec.describe Spree::Pos::Einvoices::SandboxProvider do
  include PosEinvoiceHelpers

  let(:store) { einvoice_store }
  let(:branch) { credit_branch(store) }
  let(:setting) { Spree::Pos::EinvoiceSetting.for_branch(branch) }

  it 'is the only registered provider outside production' do
    expect(Spree::Pos::Einvoices.providers.keys).to eq(['sandbox'])
    expect(Spree::Pos::Einvoices.catalog.sole).to include(key: 'sandbox', sandbox: true, tax_code_lookup: true)
  end

  it 'answers the same for the same invoice' do
    einvoice = einvoice_of(completed_sale(store, branch))
    einvoice.update!(template_code: '1', symbol: 'C26MAA')
    first = described_class.new(setting).issue(einvoice)
    second = described_class.new(setting).issue(einvoice)

    expect(first.to_h.except(:issued_at, :signed_at, :sent_to_cqt_at)).to eq(second.to_h.except(:issued_at, :signed_at, :sent_to_cqt_at))
    expect(first.number).to match(/\A\d{8}\z/)
    expect(first.cqt_code).to match(/\AM1-\d{2}-SBX[0-9A-F]{2}-\d{11}\z/)
    expect(first.lookup_code).to match(/\A[0-9A-F]{10}\z/)
  end

  it 'refuses an invoice without lines for a person to fix' do
    einvoice = einvoice_of(completed_sale(store, branch))
    einvoice.lines_snapshot = []

    expect { described_class.new(setting).issue(einvoice) }.
      to raise_error(Spree::Pos::Einvoices::Provider::Error) { |error| expect(error.retryable?).to be(false) }
  end

  it 'looks up well-formed tax codes only' do
    adapter = described_class.new(setting)
    expect(adapter.lookup_tax_code('0312345678').name).to eq('Công ty thử nghiệm 0312345678')
    expect(adapter.lookup_tax_code('12')).to be_nil
  end
end
