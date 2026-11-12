# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../../support/pos_meal_helpers'

# Recording a meal at the canteen counter: the server checks the account,
# the duplicate window, the meal times and the daily limit under the account
# lock, records every attempt, and puts the eater on the order.
RSpec.describe Spree::Pos::MealAccounts::Swipe do
  include PosMealHelpers

  let(:store) { Spree::Store.default }
  let(:branch) { canteen_branch(store) }
  let(:cashier) { credit_staff(store, branch, PosMealHelpers::MEAL_CASHIER) }
  let(:manager) { credit_staff(store, branch, [PosMealHelpers::CAPS::APPROVE]) }
  let(:noon) { Time.zone.parse('2026-11-12 05:30:00 UTC') } # 12:30 in Ho Chi Minh City

  before { allow(Spree::Pos::Workspace).to receive(:business_now).and_return(noon) }

  it 'puts the eater on the order and counts the meal once' do
    account = meal_account!(store, cashier, branch, code: 'nv001', daily_meal_limit: 2)
    sale = meal_sale(store, branch, cashier, price: 35_000)

    result = swipe(sale, code: ' NV001 ')

    expect(result['result']).to eq('ok')
    expect(result['meal']).to include('employee_code' => 'NV001', 'meals_today' => 1, 'meals_left' => 1)
    expect(sale.workspace.reload.pos_customer_id).to eq(account.customer_profile_id)
    expect(Spree::Pos::MealSwipe.where(meal_account: account).pluck(:result, :input_method)).to eq([%w[ok code]])

    again = swipe(sale, account)
    expect(again['result']).to eq('ok')
    expect(Spree::Pos::MealSwipe.where(meal_account: account).count).to eq(1)
  end

  it 'refuses a locked account and an unknown code, and records both' do
    account = meal_account!(store, cashier, branch, status: 'locked')
    sale = meal_sale(store, branch, cashier, price: 35_000)

    locked = refusal { swipe(sale, account) }
    unknown = refusal { swipe(sale, code: 'KHONGCO') }

    expect(locked.reason).to eq('meal_account_locked')
    expect(locked.details[:result]).to eq('revoked')
    expect(unknown.reason).to eq('meal_account_unknown')
    expect(Spree::Pos::MealSwipe.where(workspace: sale.workspace).pluck(:result)).to contain_exactly('revoked', 'unknown')
    expect(sale.workspace.reload.pos_customer_id).to be_nil
  end

  it 'refuses the same account within 60 seconds as a duplicate' do
    account = meal_account!(store, cashier, branch, daily_meal_limit: 3)
    first = meal_sale(store, branch, cashier, price: 35_000)
    second = meal_sale(store, branch, cashier, price: 35_000)
    swipe(first, account)

    duplicate = refusal { swipe(second, account) }

    expect(duplicate.reason).to eq('meal_duplicate_swipe')
    allow(Spree::Pos::Workspace).to receive(:business_now).and_return(noon + 61.seconds)
    expect(swipe(second, account)['result']).to eq('ok')
  end

  it 'refuses a meal past the daily limit unless an approval overrides it' do
    account = meal_account!(store, cashier, branch, daily_meal_limit: 1)
    first = meal_sale(store, branch, cashier, price: 35_000)
    second = meal_sale(store, branch, cashier, price: 35_000)
    swipe(first, account)
    allow(Spree::Pos::Workspace).to receive(:business_now).and_return(noon + 2.minutes)

    limit = refusal { swipe(second, account) }
    expect(limit.reason).to eq('meal_daily_limit')
    expect(refusal { swipe(second, account, override: true) }.reason).to eq('approval_required')

    approval = Spree::Pos::Approval.create!(store: store, branch: branch, approver: manager, requester: cashier,
                                            action: Spree::Pos::Approval::MEAL_OVERRIDE_ACTION, revision: account.reload.revision.to_s,
                                            subject_type: account.class.name, subject_id: account.id, status: 'active',
                                            expires_at: 10.minutes.from_now)
    expect(swipe(second, account, approval_id: approval.prefixed_id)['result']).to eq('ok')
    expect(approval.reload.status).to eq('consumed')
    expect(Spree::Pos::MealSwipe.counting.where(meal_account: account).count).to eq(2)
  end

  it 'gives the meal back when the order is canceled or loses its eater' do
    account = meal_account!(store, cashier, branch, daily_meal_limit: 1)
    first = meal_sale(store, branch, cashier, price: 35_000)
    swipe(first, account)
    Spree::Pos::Workspaces::AssignCustomer.call(**editing_args(first), profile_id: nil)
    allow(Spree::Pos::Workspace).to receive(:business_now).and_return(noon + 2.minutes)

    second = meal_sale(store, branch, cashier, price: 35_000)
    expect(swipe(second, account)['result']).to eq('ok')
  end

  it 'refuses a meal outside the meal times and checks the limit of a meal time' do
    windows = [{ 'key' => 'lunch', 'from' => '11:00', 'to' => '13:30', 'limit' => 1 }, { 'key' => 'dinner', 'from' => '17:00', 'to' => '19:00' }]
    account = meal_account!(store, cashier, branch, meal_windows: windows)
    sale = meal_sale(store, branch, cashier, price: 35_000)
    allow(Spree::Pos::Workspace).to receive(:business_now).and_return(Time.zone.parse('2026-11-12 08:00:00 UTC')) # 15:00

    outside = refusal { swipe(sale, account) }
    expect(outside.reason).to eq('meal_outside_window')

    allow(Spree::Pos::Workspace).to receive(:business_now).and_return(noon)
    expect(swipe(sale, account)['result']).to eq('ok')
    expect(Spree::Pos::MealSwipe.where(meal_account: account, result: 'ok').pick(:meal_window)).to eq('lunch')

    allow(Spree::Pos::Workspace).to receive(:business_now).and_return(noon + 5.minutes)
    other = meal_sale(store, branch, cashier, price: 35_000)
    expect(refusal { swipe(other, account) }.reason).to eq('meal_daily_limit')
  end

  it 'refuses while the module is off at the branch' do
    account = meal_account!(store, cashier, branch)
    sale = meal_sale(store, branch, cashier, price: 35_000)
    set_pos_module(branch, 'fnb.meal_accounts', false)

    expect(refusal { swipe(sale, account) }.reason).to eq('module_disabled')
  end
end
