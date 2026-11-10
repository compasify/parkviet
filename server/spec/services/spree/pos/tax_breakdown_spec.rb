# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../support/pos_credit_helpers'

RSpec.describe Spree::Pos::TaxBreakdown, type: :model do
  include PosCreditHelpers

  it 'groups two rates, ignores a credit line, and matches the order tax totals' do
    store = create(:store, default_currency: 'VND', supported_currencies: 'VND')
    branch = credit_branch(store)
    sale = credit_sale(store, branch, price: 20_000)
    order = sale.workspace.order
    line = order.line_items.first
    Spree::TaxLine.create!(order: order, line_item: line, amount: 800, rate: BigDecimal('0.08'),
                           label: 'VAT thực phẩm', included: true)
    Spree::TaxLine.create!(order: order, line_item: line, amount: 1000, rate: BigDecimal('0.10'),
                           label: 'VAT đặc biệt', included: true)
    Spree::TaxLine.create!(order: order, line_item: line, amount: 50, rate: BigDecimal('0.08'),
                           label: 'VAT thực phẩm', included: true, credit: true)
    order.update_columns(included_tax_total: 1800, additional_tax_total: 0)

    taxes = sale.workspace.reload.to_pos[:totals][:taxes]
    expect(taxes).to eq([
      { rate: '0.08', label: 'VAT thực phẩm', amount: '800.0' },
      { rate: '0.1', label: 'VAT đặc biệt', amount: '1000.0' }
    ])
    summed = taxes.sum { |row| BigDecimal(row[:amount]) }
    expect(summed).to eq(order.included_tax_total + order.additional_tax_total)
  end
end
