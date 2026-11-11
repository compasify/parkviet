# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../../support/pos_menu_helpers'

# The price of a menu line comes from server data only: list or time-of-day
# price of the size, plus quantity × delta of every picked option.
RSpec.describe Spree::Pos::Menu::Pricing do
  include PosMenuHelpers

  let(:store) { menu_store }
  let(:branch) { menu_branch(store) }
  let(:zone) { ActiveSupport::TimeZone['Asia/Ho_Chi_Minh'] }
  let(:item) { menu_item!(store, branch, name: 'Trà sữa', price: 30_000, sizes: { 'M' => 30_000, 'L' => 38_000 }) }
  let!(:sugar) { modifier_group!(store, item, name: 'Đường', options: { '50%' => 0, '100%' => 0 }, min: 1, max: 1, defaults: ['100%']) }
  let!(:topping) do
    modifier_group!(store, item, name: 'Topping', options: { 'Trân châu' => 5_000, 'Thạch' => 4_000 }, max: 3, allow_quantity: true)
  end

  def resolve(selections, variant: size(item, 1), now: zone.local(2026, 11, 11, 10, 0), note: nil)
    described_class.resolve(branch: branch, variant: variant, selections: selections, now: now, currency: 'VND', note: note)
  end

  def expect_conflict(reason, &block)
    expect(&block).to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq(reason) }
  end

  it 'adds the options to the price of the chosen size' do
    result = resolve(picks([option(sugar, '50%')], [option(topping, 'Trân châu'), 2], [option(topping, 'Thạch')]))
    expect(result.base_price).to eq(38_000)
    expect(result.unit_price).to eq(38_000 + (2 * 5_000) + 4_000)
    expect(result.options.map { |row| [row.option.name, row.quantity] }).to eq([['50%', 1], ['Trân châu', 2], ['Thạch', 1]])
    expect(resolve(picks([option(sugar, '50%')]), variant: size(item, 0)).unit_price).to eq(30_000)
  end

  it 'picks the default options when none are sent, and none for an empty list' do
    expect(resolve(nil).options.map { |row| row.option.name }).to eq(['100%'])
    expect_conflict('modifier_min') { resolve([]) }
  end

  it 'checks every group: at least min, at most max, quantities only where allowed' do
    expect_conflict('modifier_min') { resolve(picks([option(topping, 'Thạch')])) }
    expect_conflict('modifier_max') { resolve(picks([option(sugar, '50%')], [option(sugar, '100%')])) }
    expect_conflict('modifier_max') { resolve(picks([option(sugar, '50%')], [option(topping, 'Trân châu'), 3], [option(topping, 'Thạch')])) }
    expect_conflict('modifier_max') { resolve(picks([option(sugar, '50%'), 2])) }
    expect_conflict('modifier_max') { resolve(picks([option(sugar, '50%')], [option(topping, 'Thạch'), 0])) }
  end

  it 'refuses an option of another item or an inactive one' do
    other = menu_item!(store, branch, name: 'Cà phê', price: 20_000)
    foreign = modifier_group!(store, other, name: 'Đá', options: { 'Ít đá' => 0 })
    expect_conflict('modifier_unknown') { resolve(picks([option(sugar, '50%')], [option(foreign, 'Ít đá')])) }
    option(topping, 'Thạch').update!(active: false)
    expect_conflict('modifier_unknown') { resolve(picks([option(sugar, '50%')], [option(topping, 'Thạch')])) }
    expect_conflict('modifier_unknown') { resolve(['not a row']) }
  end

  it 'gives the same signature to the same set in any order, another to another set or note' do
    first = resolve(picks([option(sugar, '50%')], [option(topping, 'Trân châu')], [option(topping, 'Thạch')]))
    same = resolve(picks([option(topping, 'Thạch')], [option(topping, 'Trân châu')], [option(sugar, '50%')]))
    expect(same.modifier_signature).to eq(first.modifier_signature)
    expect(resolve(picks([option(sugar, '50%')], [option(topping, 'Trân châu')])).modifier_signature).not_to eq(first.modifier_signature)
    noted = resolve(picks([option(sugar, '50%')]), note: '  Ít   ĐÁ ')
    expect(noted.note).to eq('Ít ĐÁ')
    expect(resolve(picks([option(sugar, '50%')]), note: 'ít đá').modifier_signature).to eq(noted.modifier_signature)
    expect(resolve(picks([option(sugar, '50%')])).modifier_signature).not_to eq(noted.modifier_signature)
  end

  describe 'time-of-day menus' do
    def schedule!(starts_at, ends_at, days: [], **item_attributes)
      schedule = Spree::Pos::MenuSchedule.create!(store: store, name: 'Giờ vàng', starts_at: starts_at, ends_at: ends_at, days_of_week: days)
      schedule.menu_schedule_items.create!(menu_item: item, **item_attributes)
      schedule
    end

    it 'applies the price while the window runs, a size row before an all-sizes row' do
      schedule!('14:00', '16:00', price: 25_000)
      schedule!('14:00', '16:00', variant: size(item, 1), price: 33_000)
      expect(resolve(picks([option(sugar, '50%')]), now: zone.local(2026, 11, 11, 14, 30)).base_price).to eq(33_000)
      expect(resolve(picks([option(sugar, '50%')]), variant: size(item, 0), now: zone.local(2026, 11, 11, 15, 59)).base_price).to eq(25_000)
      expect(resolve(picks([option(sugar, '50%')]), now: zone.local(2026, 11, 11, 16, 0)).base_price).to eq(38_000)
      expect(resolve(picks([option(sugar, '50%')]), now: zone.local(2026, 11, 11, 13, 59)).schedule).to be_nil
    end

    it 'runs a window past midnight on the day it starts' do
      # 2026-11-13 is a Friday (5): 22:00 Friday to 02:00 Saturday.
      schedule!('22:00', '02:00', days: [5], price: 20_000)
      expect(resolve(picks([option(sugar, '50%')]), now: zone.local(2026, 11, 13, 23, 0)).base_price).to eq(20_000)
      expect(resolve(picks([option(sugar, '50%')]), now: zone.local(2026, 11, 14, 1, 30)).base_price).to eq(20_000)
      expect(resolve(picks([option(sugar, '50%')]), now: zone.local(2026, 11, 14, 2, 0)).base_price).to eq(38_000)
      expect(resolve(picks([option(sugar, '50%')]), now: zone.local(2026, 11, 14, 23, 0)).base_price).to eq(38_000)
      expect(resolve(picks([option(sugar, '50%')]), now: zone.local(2026, 11, 13, 1, 0)).base_price).to eq(38_000)
    end

    it 'refuses an item hidden while a window runs' do
      schedule!('06:00', '10:00', hidden: true)
      expect_conflict('menu_item_hidden') { resolve(picks([option(sugar, '50%')]), now: zone.local(2026, 11, 11, 9, 0)) }
      expect(resolve(picks([option(sugar, '50%')]), now: zone.local(2026, 11, 11, 10, 0)).base_price).to eq(38_000)
    end

    it 'keeps a given base price, for a line already sold' do
      schedule!('00:00', '23:59', price: 1_000)
      result = described_class.resolve(branch: branch, variant: size(item, 1), selections: picks([option(sugar, '50%')]),
                                       now: zone.local(2026, 11, 11, 10, 0), currency: 'VND', base_price: BigDecimal('38000'))
      expect(result.unit_price).to eq(38_000)
    end
  end
end
