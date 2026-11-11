# frozen_string_literal: true

require 'rails_helper'
require 'fugit'

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

  it 'seeds a label that stays true after the amount changes' do
    store = create(:store, default_currency: 'VND', supported_currencies: 'VND')
    Spree::Pos::TaxCategories.seed!(store)
    rate = Spree::TaxRate.find_by!(store: store, tax_category: Spree::TaxCategory.find_by!(store: store, tax_code: 'vat_food'))
    expect(rate.adjustment_label(included: true)).not_to match(/\d/)
  end

  it 'is scheduled on the Vietnam clock' do
    config = YAML.safe_load_file(Rails.root.join('config/recurring.yml'), aliases: true)
    schedule = Fugit.parse(config.dig('production', 'pos_apply_tax_rate_schedules', 'schedule'))
    expect(schedule.next_time(Time.utc(2026, 12, 31, 16, 0)).to_i).to eq(Time.utc(2026, 12, 31, 17, 5).to_i)
  end
end
