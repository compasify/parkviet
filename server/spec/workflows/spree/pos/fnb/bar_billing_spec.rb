# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../../support/pos_table_helpers'

# The money of a bar night: a VIP table's minimum spend, the drink credit of
# door tickets, happy-hour prices and tips kept off the order.
RSpec.describe 'Bar billing' do
  include ActiveSupport::Testing::TimeHelpers
  include PosTableHelpers

  let(:store) { menu_store }
  let(:branch) { table_branch(store) }
  let(:cashier) { credit_staff(store, branch, PosCreditHelpers::CASHIER + [Spree::Pos::Capabilities::DISCOUNT]) }
  let(:manager) { credit_staff(store, branch, PosCreditHelpers::MANAGER + [Spree::Pos::Capabilities::DISCOUNT]) }
  let(:area) { area!(branch) }

  before { table_register!(branch, cashier) }

  def lines_of(order)
    Spree::Pos::SaleLine.where(workspace_id: order.workspace.id).order(:id).to_a
  end

  describe 'minimum spend' do
    let(:vip) { table!(area, name: 'VIP 1', minimum_spend: 1_000_000, minimum_spend_currency: 'VND') }
    let(:bottle) { menu_product!(store, branch, name: 'Chivas 12', price: 400_000) }

    def fee_of(order)
      order.workspace.reload.order.fees.find_by(kind: 'minimum_spend')
    end

    it 'adds a taxed fee for the shortfall that follows the items and goes away at the minimum' do
      order = open_table(cashier, vip)
      add_dish(order, bottle)

      fee = fee_of(order)
      expect(fee).to have_attributes(amount: 600_000, label: 'Phụ thu mức tối thiểu')
      expect(order.workspace.order.total).to eq(1_000_000)
      expect(order.workspace.to_pos[:minimum_spend]).to eq(minimum: '1000000.0', amount: '600000.0', waived: false)
      expect(order.workspace.to_pos[:totals][:fees]).to include(include(kind: 'minimum_spend', amount: '600000.0'))

      add_dish(order, bottle, quantity: 2)
      expect(fee_of(order)).to be_nil
      expect(order.workspace.order.total).to eq(1_200_000)
    end

    it 'charges nothing at an ordinary table or where tables are off' do
      order = open_table(cashier, table!(area, name: 'Bàn 2', x: 6))
      add_dish(order, bottle)
      expect(fee_of(order)).to be_nil
    end

    it 'is waived only with an approval, bound to the fee, and can be put back' do
      order = open_table(cashier, vip)
      add_dish(order, bottle)
      waive = lambda do |staff, waived, approval_id = nil|
        workspace = order.workspace.reload
        Spree::Pos::Fnb::WaiveMinimumSpend.call(workspace: workspace, staff: staff, revision: workspace.revision,
                                                lease_generation: workspace.lease_generation, editor_id: order.editor_id,
                                                key: SecureRandom.uuid, waived: waived, approval_id: approval_id)
      end

      expect { waive.call(cashier, true) }.to raise_error(Spree::Pos::Conflict, /approval/i)
      workspace = order.workspace.reload
      approval = Spree::Pos::Approval.create!(store: store, branch: branch, approver: manager, requester: cashier,
                                              subject_type: workspace.class.name, subject_id: workspace.id,
                                              action: Spree::Pos::Approval::MINIMUM_SPEND_WAIVE_ACTION, amount: 600_000,
                                              currency: 'VND', revision: workspace.revision.to_s, status: 'active',
                                              expires_at: 10.minutes.from_now)
      waive.call(cashier, true, approval.prefixed_id)

      expect(fee_of(order)).to be_nil
      expect(order.workspace.reload).to have_attributes(minimum_spend_waived: true)
      expect(approval.reload.status).to eq('consumed')
      expect(Spree::Pos::AuditEntry.where(action: 'workspace.minimum_spend.waive', subject_id: workspace.id)).to exist

      waive.call(cashier, false)
      expect(fee_of(order).amount).to eq(600_000)
    end
  end

  describe 'door tickets' do
    let(:ticket) do
      menu_item!(store, branch, name: 'Vé vào cửa', price: 200_000).tap do |item|
        item.update!(drink_credit: 100_000, drink_credit_categories: ['bar'])
      end
    end
    let(:beer) { menu_item!(store, branch, name: 'Bia', price: 60_000).tap { |item| item.update!(kitchen_category: 'bar') } }
    let(:snack) { menu_item!(store, branch, name: 'Khô mực', price: 50_000).tap { |item| item.update!(kitchen_category: 'kitchen') } }

    it 'sells a cover line whose credit pays the allowed drinks in order, never the food' do
      order = open_table(cashier, table!(area, name: 'Bàn 3'))
      add_dish(order, size(ticket))
      add_dish(order, size(snack))
      add_dish(order, size(beer))
      add_dish(order, size(beer), quantity: 1)

      cover, food, *beers = lines_of(order)
      expect(cover.kind).to eq('cover')
      intents = Spree::Pos::LineDiscountIntent.where(workspace_id: order.workspace.id)
      expect(intents.pluck(:sale_line_id, :source, :value)).to contain_exactly([beers.first.id, 'cover_credit', '60000'], [beers.last.id, 'cover_credit', '40000'])
      expect(intents.where(sale_line_id: food.id)).to be_empty
      workspace = order.workspace.reload
      expect(workspace.order.total).to eq(270_000) # 200k + 50k + 120k - 100k credit
      expect(workspace.to_pos[:drink_credit]).to eq(total: '100000.0', used: '100000.0', remaining: '0.0')
    end

    it 'gives the credit back to the next drink when a paid one is removed' do
      order = open_table(cashier, table!(area, name: 'Bàn 4'))
      add_dish(order, size(ticket))
      add_dish(order, size(beer))
      first_beer = lines_of(order).last
      Spree::Pos::Workspaces::ManageLineItem.remove_by_line(**editing_args(order), line_item_id: first_beer.line_item.prefixed_id)
      expect(Spree::Pos::LineDiscountIntent.where(workspace_id: order.workspace.id)).to be_empty
      expect(order.workspace.reload.to_pos[:drink_credit]).to include(used: '0.0', remaining: '100000.0')
    end
  end

  it 'names the happy-hour price on the line, by the server clock' do
    zone = ActiveSupport::TimeZone[branch.timezone]
    beer = menu_item!(store, branch, name: 'Bia tươi', price: 50_000)
    schedule = Spree::Pos::MenuSchedule.create!(store: store, name: 'Giờ vàng quầy bar', label: 'Happy hour',
                                                starts_at: '17:00', ends_at: '19:00')
    schedule.menu_schedule_items.create!(menu_item: beer, price: 35_000)
    order = open_table(cashier, table!(area, name: 'Bàn 5'))
    travel_to(zone.local(2026, 11, 11, 18, 0)) { add_dish(order, size(beer)) }
    travel_to(zone.local(2026, 11, 11, 20, 0)) { add_dish(order, size(beer), quantity: 1) }

    expect(lines_of(order).map { |line| [line.unit_price.to_i, line.price_label] }).to eq([[35_000, 'Happy hour'], [50_000, nil]])
    expect(order.workspace.reload.to_pos[:line_items].map { |row| row[:price_label] }).to include('Happy hour')
  end

  describe 'tips' do
    let(:waiter) { credit_staff(store, branch, PosTableHelpers::WAITER) }
    let(:bartender) { credit_staff(store, branch, PosTableHelpers::WAITER) }

    def tipped(amount:, handed:, tip:)
      order = open_table(cashier, table!(area, name: "Bàn #{SecureRandom.hex(2)}", x: rand(0..18)))
      add_dish(order, menu_product!(store, branch, price: amount))
      method = Spree::Pos::PaymentMethodResolver.new(store: store).available.find { |row| row.kind == 'cash' }
      Spree::Pos::Tenders::Prepare.call(**editing_args(order), payment_method_id: method.prefixed_id || 'posmethod-cash', amount: amount.to_s)
      attempt = Spree::Pos::TenderAttempt.where(workspace: order.workspace).order(:id).last
      Spree::Pos::Tenders::Confirm.call(**editing_args(order), attempt_id: attempt.prefixed_id, evidence_kind: 'cash_count',
                                                               handed_amount: handed.to_s, tip_amount: tip.to_s)
      order
    end

    it 'keeps the tip on the receipt but off the order, its revenue and its invoice' do
      order = tipped(amount: 180_000, handed: 250_000, tip: 20_000)
      workspace = order.workspace.reload
      funds = Spree::Pos::ReceivedFunds.where(workspace_id: workspace.id).sole

      expect(workspace.order.total).to eq(180_000)
      expect(funds).to have_attributes(handed_amount: 250_000, applied_amount: 180_000, change_amount: 50_000, received_net: 200_000)
      expect(Spree::Pos::FundsBalance.new(funds).available).to eq(20_000)
      expect(Spree::Pos::TipRecord.sole).to have_attributes(amount: 20_000, status: 'held', business_date: workspace.business_date,
                                                            received_funds_id: funds.id)
      expect(workspace.to_pos[:financial][:tip]).to eq('20000.0')
      expect(Spree::Pos::CashMovement.where(received_funds_id: funds.id).sum(:amount)).to eq(200_000)
    end

    it 'refuses a tip larger than the cash handed over, and a tip in a way it cannot be held' do
      expect { tipped(amount: 100_000, handed: 110_000, tip: 20_000) }.to raise_error(Spree::Pos::Conflict, /less than/)
    end

    it 'pays the held tips of a day to the staff, split equally, as reserved payouts' do
      first = tipped(amount: 100_000, handed: 115_000, tip: 15_000)
      tipped(amount: 100_000, handed: 110_000, tip: 10_000)
      day = first.workspace.reload.business_date

      result = Spree::Pos::Tips::Payout.call(store: store, staff: manager, key: SecureRandom.uuid, branch_id: branch.prefixed_id,
                                             business_date: day.iso8601,
                                             recipients: [{ staff_id: waiter.prefixed_id }, { staff_id: bartender.prefixed_id }])

      expect(result['shares'].map { |row| row['amount'] }).to eq(['12500.0', '12500.0'])
      payouts = Spree::Pos::LiabilityPayout.order(:id)
      expect(payouts.sum(:amount)).to eq(25_000)
      expect(payouts.pluck(:status).uniq).to eq(['reserved'])
      expect(payouts.pluck(:beneficiary_reference).uniq).to contain_exactly(waiter.prefixed_id, bartender.prefixed_id)
      expect(Spree::Pos::TipRecord.pluck(:status).uniq).to eq(['paid_out'])
      expect do
        Spree::Pos::Tips::Payout.call(store: store, staff: manager, key: SecureRandom.uuid, branch_id: branch.prefixed_id,
                                      business_date: day.iso8601, recipients: [{ staff_id: waiter.prefixed_id }])
      end.to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('tips_none') }
    end

    it 'splits by hours and refuses manual amounts that do not add up' do
      order = tipped(amount: 100_000, handed: 130_000, tip: 30_000)
      day = order.workspace.reload.business_date.iso8601
      pay = lambda do |mode, rows|
        Spree::Pos::Tips::Payout.call(store: store, staff: manager, key: SecureRandom.uuid, branch_id: branch.prefixed_id,
                                      business_date: day, mode: mode, recipients: rows)
      end

      expect { pay.call('manual', [{ staff_id: waiter.prefixed_id, amount: '10000' }]) }.
        to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('tip_split_mismatch') }
      result = pay.call('by_hours', [{ staff_id: waiter.prefixed_id, hours: '4' }, { staff_id: bartender.prefixed_id, hours: '8' }])
      expect(result['shares'].map { |row| row['amount'] }).to eq(['10000.0', '20000.0'])
    end
  end
end
