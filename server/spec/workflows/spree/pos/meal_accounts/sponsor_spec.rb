# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../../support/pos_meal_helpers'

# A sponsor (the employer or school) pays its people's meals on its credit
# account: each meal order's sponsor part is a receivable debit made as the
# order completes, within the credit limit and without a manager per meal.
# With a subsidy the eater pays the rest on the same order.
RSpec.describe 'Meal sponsors' do
  include PosMealHelpers

  let(:store) { Spree::Store.default }
  let(:branch) { canteen_branch(store) }
  let(:cashier) { credit_staff(store, branch, PosMealHelpers::MEAL_CASHIER) }
  let(:manager) do
    credit_staff(store, branch, PosCreditHelpers::MANAGER + [PosMealHelpers::CAPS::MEAL_ACCOUNT_MANAGE, PosMealHelpers::CAPS::REPORT_READ])
  end
  let(:noon) { Time.zone.parse('2026-11-12 05:30:00 UTC') }

  before { allow(Spree::Pos::Workspace).to receive(:business_now).and_return(noon) }

  def later(minutes)
    allow(Spree::Pos::Workspace).to receive(:business_now).and_return(noon + minutes.minutes)
  end

  def statement(sponsor)
    scope = Spree::Pos::Reports::Scope.new(store: store, staff: manager, branch: branch)
    Spree::Pos::Reports.build('meal_statement', scope: scope,
                                                values: { 'from' => '2026-11-12', 'to' => '2026-11-12', 'meal_sponsor_id' => sponsor.prefixed_id })
  end

  it 'charges a meal to the sponsor within its limit and refuses one past it' do
    sponsor = meal_sponsor!(store, manager, branch, credit_limit: 50_000)
    account = meal_account!(store, manager, branch, meal_sponsor_id: sponsor.prefixed_id, pay_mode: 'sponsor')
    first = meal_sale(store, branch, cashier, price: 35_000)
    swipe(first, account)

    complete_with_sponsor(first)

    debit = Spree::Pos::ReceivableEntry.find_by!(workspace: first.workspace, kind: 'debit')
    expect(debit).to have_attributes(credit_account_id: sponsor.credit_account_id, amount: 35_000, source_id: account.id)
    expect(first.workspace.reload.order).to be_complete
    expect(debit.credit_reservation).to have_attributes(status: 'committed')
    expect(debit.credit_reservation.approval).to have_attributes(status: 'consumed', approver_id: cashier.id,
                                                                 action: Spree::Pos::Approval::MEAL_SPONSOR_ACTION)

    later(2)
    second = meal_sale(store, branch, cashier, price: 35_000)
    swipe(second, account)
    expect(refusal { complete_with_sponsor(second) }.reason).to eq('sponsor_limit')
    expect(second.workspace.reload.order).not_to be_complete
    expect(Spree::Pos::ReceivableEntry.where(workspace: second.workspace)).to be_empty

    report = statement(sponsor)
    rows, = report.page(1, 25)
    expect(rows).to contain_exactly(include(employee_code: account.employee_code, sponsor_amount: '35000.0', employee_amount: '0.0'))
    sponsored = Spree::Pos::ReceivableEntry.where(credit_account_id: sponsor.credit_account_id, kind: 'debit').sum(:amount)
    expect(BigDecimal(report.summary[:sponsor_amount])).to eq(sponsored)
  end

  it 'splits a 35,000 meal into a 25,000 subsidy and the rest, and the second meal of the day is the eater’s alone' do
    sponsor = meal_sponsor!(store, manager, branch, subsidy_mode: 'fixed', subsidy_value: '25000', subsidy_daily_cap: '25000')
    account = meal_account!(store, manager, branch, meal_sponsor_id: sponsor.prefixed_id, pay_mode: 'sponsor_subsidy')
    first = meal_sale(store, branch, cashier, price: 35_000)
    swipe(first, account)

    plan = Spree::Pos::MealAccounts::SplitPlan.call(first.workspace.reload)
    expect(plan).to include(sponsor_amount: '25000.0', employee_amount: '10000.0')
    expect(refusal { complete_with_sponsor(first) }.reason).to eq('meal_split_unpaid')

    take_tender(first, 'cash', 10_000)
    complete_with_sponsor(first)
    order = first.workspace.reload.order
    expect(order).to be_complete
    expect(order.payments.completed.sum(:amount)).to eq(10_000)
    expect(Spree::Pos::ReceivableEntry.where(order: order, kind: 'debit').sum(:amount)).to eq(25_000)
    expect(Spree::Order.where(id: Spree::Pos::Workspace.where(id: first.workspace.id).select(:order_id)).count).to eq(1)

    later(2)
    second = meal_sale(store, branch, cashier, price: 35_000)
    swipe(second, account)
    expect(Spree::Pos::MealAccounts::SplitPlan.call(second.workspace.reload)).to include(sponsor_amount: '0.0', employee_amount: '35000.0')
    expect(refusal { complete_with_sponsor(second) }.reason).to eq('sponsor_nothing_due')
    take_tender(second, 'cash', 35_000)
    Spree::Pos::Workspaces::Complete.call(**editing_args(second))
    expect(second.workspace.reload.order).to be_complete

    rows, = statement(sponsor).page(1, 25)
    expect(rows.map { |row| [row[:sponsor_amount], row[:employee_amount]] }).to contain_exactly(%w[25000.0 10000.0], %w[0.0 35000.0])
  end

  it 'refuses a sponsor part while the sponsor has no credit account or is suspended' do
    sponsor = meal_sponsor!(store, manager, branch, credit_limit: 500_000)
    account = meal_account!(store, manager, branch, meal_sponsor_id: sponsor.prefixed_id, pay_mode: 'sponsor')
    sponsor.update!(status: 'suspended')
    sale = meal_sale(store, branch, cashier, price: 35_000)
    swipe(sale, account)

    expect(Spree::Pos::MealAccounts::SplitPlan.call(sale.workspace.reload)).to include(sponsor_unavailable: true)
    expect(refusal { complete_with_sponsor(sale) }.reason).to eq('sponsor_unavailable')
  end
end
