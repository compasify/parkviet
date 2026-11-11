# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../support/pos_counter_service_helpers'

# Call numbers count 1, 2, 3… per branch and business date, are handed out
# at the first kitchen send or at completion, and stay with their order.
RSpec.describe Spree::Pos::OrderNumbers do
  include PosCounterServiceHelpers

  let(:store) { menu_store }
  let(:branch) { counter_branch(store, trigger: 'manual') }
  let(:item) { menu_item!(store, branch, name: 'Cà phê', price: 20_000) }
  let!(:station) { kitchen_station!(branch, name: 'Bar', default: true) }

  def sale_with_item
    menu_sale(store, branch).tap { |sale| add_menu(sale, size(item)) }
  end

  # A draft whose business date is that of `at` in the branch's zone.
  def sale_at(at)
    allow(Spree::Pos::Workspace).to receive(:business_now).and_return(at)
    sale_with_item
  end

  it 'numbers orders 1, 2, 3 at their first send or completion and keeps the number' do
    first = sale_with_item
    second = sale_with_item
    expect(first.workspace.reload.order_number).to be_nil

    kitchen_send(second)
    pay_and_complete(first)
    expect([first, second].map { |sale| sale.workspace.reload.order_number }).to eq([2, 1])

    add_menu(second, size(item))
    kitchen_send(second)
    pay_and_complete(second)
    expect(second.workspace.reload.order_number).to eq(1)
    expect(Spree::Pos::KitchenTicket.where(workspace_id: second.workspace.id).map { |ticket| ticket.header['order_number'] }).to eq([1, 1])
  end

  it 'starts again from 1 after the business day cutoff, not at midnight' do
    zone = ActiveSupport::TimeZone['Asia/Ho_Chi_Minh']
    late = sale_at(zone.local(2026, 11, 10, 23, 30))
    after_midnight = sale_at(zone.local(2026, 11, 11, 1, 15))
    next_day = sale_at(zone.local(2026, 11, 11, 4, 30))
    [late, after_midnight, next_day].each { |sale| described_class.assign!(sale.workspace.reload) }

    expect([late, after_midnight, next_day].map { |sale| sale.workspace.reload.business_date.iso8601 }).
      to eq(%w[2026-11-10 2026-11-10 2026-11-11])
    expect([late, after_midnight, next_day].map { |sale| sale.workspace.reload.order_number }).to eq([1, 2, 1])
  end

  it 'leaves a canceled order its number and never gives that number to another order' do
    canceled = sale_with_item
    kitchen_send(canceled)
    Spree::Pos::Workspaces::ChangeStatus.call(**editing_args(canceled), status: 'canceled')
    expect(canceled.workspace.reload).to have_attributes(operational_status: 'canceled', order_number: 1)

    following = sale_with_item
    kitchen_send(following)
    expect(following.workspace.reload.order_number).to eq(2)
  end

  it 'refuses to change a number once it is given' do
    sale = sale_with_item
    kitchen_send(sale)
    expect { sale.workspace.reload.update!(order_number: 9) }.to raise_error(ActiveRecord::RecordInvalid)
  end

  it 'gives no number where the branch does not run call numbers' do
    set_pos_module(branch, 'fnb.order_number', false)
    sale = sale_with_item
    kitchen_send(sale)
    pay_and_complete(sale)
    expect(sale.workspace.reload.order_number).to be_nil
    expect(Spree::Pos::OrderNumberCounter.where(branch_id: branch.id)).to be_empty
  end

  it 'counts each branch on its own' do
    other = counter_branch(store, trigger: 'manual')
    date = Date.new(2026, 11, 11)
    expect([described_class.next_value!(branch.id, date), described_class.next_value!(other.id, date),
            described_class.next_value!(branch.id, date)]).to eq([1, 1, 2])
  end
end
