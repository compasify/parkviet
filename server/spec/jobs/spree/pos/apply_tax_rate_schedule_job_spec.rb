# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Pos::ApplyTaxRateScheduleJob, type: :job do
  it 'applies a due schedule once and leaves an earlier rate untouched' do
    store = create(:store, default_currency: 'VND', supported_currencies: 'VND')
    Spree::Pos::TaxCategories.seed!(store)
    Spree::Pos::TaxCategories.seed!(store)
    food = Spree::TaxCategory.find_by!(store: store, tax_code: 'vat_food')
    rate = Spree::TaxRate.find_by!(store: store, tax_category: food)
    expect(rate.amount).to eq(BigDecimal('0.08'))

    described_class.new.apply(Date.new(2026, 12, 31))
    expect(rate.reload.amount).to eq(BigDecimal('0.08'))

    described_class.new.apply(Date.new(2027, 1, 1))
    expect(rate.reload.amount).to eq(BigDecimal('0.10'))
    applied = Spree::Pos::TaxRateSchedule.find_by!(tax_rate: rate, effective_on: Date.new(2027, 1, 1))
    stamped = applied.applied_at
    expect(stamped).to be_present

    described_class.new.apply(Date.new(2027, 1, 2))
    expect(rate.reload.amount).to eq(BigDecimal('0.10'))
    expect(applied.reload.applied_at).to eq(stamped)

    Spree::Pos::TaxCategories.seed!(store)
    expect(rate.reload.amount).to eq(BigDecimal('0.10'))
  end
end
