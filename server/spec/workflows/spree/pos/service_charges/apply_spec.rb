# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../../support/pos_table_helpers'

# The service charge follows the items after discounts, is taxed under the
# branch's own tax category, and can be waived by a cashier who may discount.
RSpec.describe Spree::Pos::ServiceCharges::Apply do
  include PosTableHelpers

  let(:store) { menu_store }
  let(:branch) { table_branch(store) }
  let(:cashier) { credit_staff(store, branch, PosCreditHelpers::CASHIER + [Spree::Pos::Capabilities::DISCOUNT]) }
  let(:table) { table!(area!(branch), name: 'Bàn 1') }
  let(:dish) { menu_product!(store, branch, price: 33_333) }

  before do
    table_register!(branch, cashier)
    branch.update!(service_charge_rate: BigDecimal('5'))
  end

  def fee_of(order)
    order.workspace.reload.order.fees.find_by(kind: 'service_charge')
  end

  it 'charges the rate on the items, half up, as they are added and removed' do
    order = open_table(cashier, table)
    add_dish(order, dish, quantity: 1)
    expect(fee_of(order).amount).to eq(1_667) # 1666.65
    add_dish(order, dish, quantity: 2)
    expect(fee_of(order).amount).to eq(5_000) # 99_999 × 5 % = 4999.95

    first, second = order.workspace.order.line_items.order(:id).to_a
    Spree::Pos::Workspaces::ManageLineItem.remove_by_line(**editing_args(order), line_item_id: first.prefixed_id)
    expect(fee_of(order).amount).to eq(3_333) # 66_666 × 5 % = 3333.3
    Spree::Pos::Workspaces::ManageLineItem.remove_by_line(**editing_args(order), line_item_id: second.prefixed_id)
    expect(fee_of(order)).to be_nil
    expect(order.workspace.order.reload.fee_total).to eq(0)
  end

  it 'charges after the order discount and adds to the total' do
    order = open_table(cashier, table)
    add_dish(order, menu_product!(store, branch, price: 100_000))
    Spree::Pos::Workspaces::ApplyDiscount.call(**editing_args(order), value_type: 'flat', value: '20000', reason: 'Khách quen')

    workspace = order.workspace.reload
    expect(fee_of(order).amount).to eq(4_000)
    expect(workspace.order.total).to eq(84_000)
    expect(workspace.to_pos[:service_charge]).to include(rate: '5.0', waived: false, applies: true)
  end

  it 'leaves takeaway orders and branches without the module uncharged' do
    branch.update!(service_charge_applies_to: %w[dine_in])
    counter = credit_sale(store, branch, price: 50_000, cashier: cashier)
    expect(counter.workspace.reload.order.fees.where(kind: 'service_charge')).to be_empty

    order = open_table(cashier, table)
    set_pos_module(branch, 'fnb.service_charge', false)
    add_dish(order, dish)
    expect(fee_of(order)).to be_nil
  end

  it 'is taxed under the branch’s service charge tax category' do
    # Vietnamese VAT, matched on the market's country.
    Spree::Market.where(store_id: store.id).find_each { |market| market.update!(country_codes: ['VN']) }
    Spree::Pos::TaxCategories.seed!(store)
    special = Spree::TaxCategory.find_by!(store: store, tax_code: Spree::Pos::TaxCategories::SPECIAL)
    branch.update!(service_charge_tax_category: special)
    order = open_table(cashier, table)
    add_dish(order, menu_product!(store, branch, price: 100_000))

    fee = fee_of(order)
    expect(fee.metadata['tax_category_id']).to eq(special.id)
    tax = Spree::TaxLine.where(fee_id: fee.id).sole
    expect(tax.tax_rate.tax_category).to eq(special)
    expect(tax.rate).to eq(BigDecimal('0.10'))
  end

  describe Spree::Pos::ServiceCharges::Waive do
    it 'takes the charge off one order and puts it back, audited' do
      order = open_table(cashier, table)
      add_dish(order, menu_product!(store, branch, price: 100_000))

      described_class.call(**editing_args(order), waived: true)
      expect(fee_of(order)).to be_nil
      expect(Spree::Pos::AuditEntry.where(action: 'workspace.service_charge.waive', subject_id: order.workspace.id).count).to eq(1)

      described_class.call(**editing_args(order), waived: false)
      expect(fee_of(order).amount).to eq(5_000)
      expect(Spree::Pos::AuditEntry.where(action: 'workspace.service_charge.restore', subject_id: order.workspace.id).count).to eq(1)
    end

    it 'needs the discount capability' do
      waiter = credit_staff(store, branch, PosTableHelpers::WAITER)
      order = open_table(waiter, table)
      add_dish(order, dish)
      expect { described_class.call(**editing_args(order), waived: true) }.to raise_error(CanCan::AccessDenied)
    end
  end
end
