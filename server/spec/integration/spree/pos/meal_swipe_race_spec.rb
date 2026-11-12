# frozen_string_literal: true

require_relative '../../../support/pos_meal_helpers'
require_relative '../../../support/pos_race_helpers'

# Two counters record the same eater at the same moment, on two connections:
# the meal account lock lets one meal through and the other is refused as a
# duplicate, so the eater gets one meal.
RSpec.describe 'POS meal swipe race', type: :integration do
  include PosMealHelpers

  include_context 'with committed POS race rows'

  it 'records one meal for two simultaneous swipes of one account' do
    allow(Spree::Pos::Workspace).to receive(:business_now).and_return(Time.zone.parse('2026-11-12 05:30:00 UTC'))
    branch = canteen_branch(store)
    cashier = credit_staff(store, branch, PosMealHelpers::MEAL_CASHIER)
    account = meal_account!(store, cashier, branch, daily_meal_limit: 1)
    sales = [meal_sale(store, branch, cashier, price: 35_000), meal_sale(store, branch, cashier, price: 35_000)]
    args = sales.map { |sale| editing_args(sale) }

    outcomes = race(account) do |index|
      Spree::Pos::MealAccounts::Swipe.call(**args[index], code: account.employee_code)['result']
    end

    expect(outcomes.map(&:first)).to contain_exactly(:success, :conflict)
    expect(Spree::Pos::MealSwipe.where(meal_account_id: account.id).pluck(:result)).to contain_exactly('ok', 'duplicate')
    expect(Spree::Pos::Workspace.where(id: sales.map { |sale| sale.workspace.id }).where(pos_customer_id: account.customer_profile_id).count).
      to eq(1)
  end
end
