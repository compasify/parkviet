# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../support/pos_menu_helpers'

# The menu records: one menu item per product and store, a kitchen key the
# kitchen can route by, groups whose min never passes their max, and line
# copies that stay as sold when the option changes or goes away.
RSpec.describe Spree::Pos::MenuItem do
  include PosMenuHelpers

  let(:store) { menu_store }
  let(:branch) { menu_branch(store) }
  let(:item) { menu_item!(store, branch, name: 'Cà phê sữa', price: 25_000) }

  it 'is one item per product of the store, with a prefixed id' do
    expect(item.prefixed_id).to start_with('posmenuitem_')
    duplicate = described_class.new(store: store, product: item.product)
    expect(duplicate).not_to be_valid
    expect(duplicate.errors.attribute_names).to include(:product_id)
    expect { duplicate.save!(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)

    foreign = create(:product, store: create(:store))
    expect(described_class.new(store: store, product: foreign)).not_to be_valid
  end

  it 'accepts a kitchen key of lower-case letters and underscores only' do
    item.kitchen_category = 'quay_bar'
    expect(item).to be_valid
    ['Bar', 'b', 'quầy', 'bar-1', 'x' * 41].each do |value|
      item.kitchen_category = value
      expect(item).not_to be_valid, value
    end
    item.kind = 'buffet'
    expect(item).not_to be_valid
  end

  it 'refuses a modifier group whose min passes its max, in the model and in the table' do
    group = Spree::Pos::ModifierGroup.new(store: store, name: 'Đá', min_select: 2, max_select: 1)
    expect(group).not_to be_valid
    expect(group.errors.attribute_names).to include(:min_select)
    expect { group.save!(validate: false) }.to raise_error(ActiveRecord::StatementInvalid, /chk_pos_modifier_groups_select/)
    expect(Spree::Pos::ModifierGroup.new(store: store, name: 'Đá', min_select: 0, max_select: 0)).not_to be_valid
  end

  it 'offers a group once per item' do
    group = modifier_group!(store, item, name: 'Đá', options: { 'Ít đá' => 0 })
    expect(Spree::Pos::MenuItemModifierGroup.new(menu_item: item, modifier_group: group)).not_to be_valid
  end

  it 'reads a time window past midnight on the day it starts' do
    schedule = Spree::Pos::MenuSchedule.new(store: store, name: 'Đêm', starts_at: '22:00', ends_at: '02:00', days_of_week: [5])
    zone = ActiveSupport::TimeZone['Asia/Ho_Chi_Minh']
    expect(schedule).to be_valid
    expect(schedule.running_at?(zone.local(2026, 11, 13, 22, 0), 'Asia/Ho_Chi_Minh')).to be(true)
    expect(schedule.running_at?(zone.local(2026, 11, 14, 1, 59), 'Asia/Ho_Chi_Minh')).to be(true)
    expect(schedule.running_at?(zone.local(2026, 11, 14, 22, 0), 'Asia/Ho_Chi_Minh')).to be(false)
    expect(Spree::Pos::MenuSchedule.new(store: store, name: 'x', starts_at: '10:00', ends_at: '10:00')).not_to be_valid
    expect(Spree::Pos::MenuSchedule.new(store: store, name: 'x', starts_at: '10:00', ends_at: '11:00', days_of_week: [7])).not_to be_valid
  end

  it 'keeps the line copy of an option when the option is changed or deleted' do
    group = modifier_group!(store, item, name: 'Topping', options: { 'Trân châu' => 5_000 }, max: 2)
    sale = menu_sale(store, branch)
    add_menu(sale, size(item), modifiers: picks([option(group, 'Trân châu')]))
    copy = Spree::Pos::LineModifier.sole
    expect(copy).to have_attributes(name: 'Trân châu', group_name: 'Topping', price_delta: 5_000, quantity: 1)

    option(group, 'Trân châu').update!(name: 'Trân châu đen', price_delta: 7_000)
    group.update!(name: 'Thêm')
    expect(copy.reload).to have_attributes(name: 'Trân châu', group_name: 'Topping', price_delta: 5_000)

    group.destroy!
    expect(copy.reload).to have_attributes(modifier_option_id: nil, name: 'Trân châu', price_delta: 5_000)
    expect(menu_lines(sale).sole.unit_price).to eq(30_000)
  end
end
