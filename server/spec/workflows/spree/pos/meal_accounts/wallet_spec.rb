# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../../support/pos_meal_helpers'

# The meal wallet holds money received for the eater: a top-up is a receipt
# with no order, a meal is paid by allocating those receipts oldest first,
# and a refund is a payout of them. The balance is always the ledger's sum.
RSpec.describe 'Meal wallets' do
  include PosMealHelpers

  let(:store) { Spree::Store.default }
  let(:branch) { canteen_branch(store) }
  let(:cashier) { credit_staff(store, branch, PosMealHelpers::MEAL_CASHIER) }
  let(:manager) { credit_staff(store, branch, PosCreditHelpers::MANAGER + [PosMealHelpers::CAPS::MEAL_ACCOUNT_MANAGE]) }
  let(:noon) { Time.zone.parse('2026-11-12 05:30:00 UTC') }

  before { allow(Spree::Pos::Workspace).to receive(:business_now).and_return(noon) }

  def wallet_of(account)
    account.reload.stored_value_account
  end

  def ledger_sum(account)
    Spree::Pos::StoredValueEntry.where(stored_value_account: wallet_of(account)).sum(:amount)
  end

  def grant(account, action, amount)
    Spree::Pos::Approval.create!(store: store, branch: branch, approver: manager, requester: cashier, action: action,
                                 amount: amount, currency: store.default_currency, revision: account.reload.revision.to_s,
                                 subject_type: account.class.name, subject_id: account.id, status: 'active',
                                 expires_at: 10.minutes.from_now)
  end

  it 'takes a top-up as money held for the eater, not as a sale' do
    account = meal_account!(store, cashier, branch, low_balance_threshold: '20000')
    open_drawer(store, branch, cashier)

    expect { top_up!(store, cashier, branch, account, 100_000) }.
      to change(Spree::Payment, :count).by(0).
      and change(Spree::Order.complete, :count).by(0).
      and change(Spree::Pos::CashMovement.where(kind: 'receipt'), :count).by(1)

    funds = Spree::Pos::ReceivedFunds.order(:id).last
    expect(funds).to have_attributes(workspace_id: nil, received_net: 100_000, custody: 'drawer')
    expect(wallet_of(account).balance).to eq(100_000)
    expect(Spree::Pos::OutboxEntry.where(event_type: 'meal_wallet.topped_up').count).to eq(1)
  end

  it 'pays a meal from several top-ups oldest first and completes one order' do
    account = meal_account!(store, cashier, branch, low_balance_threshold: '30000')
    sale = meal_sale(store, branch, cashier, price: 35_000)
    top_up!(store, cashier, branch, account, 20_000)
    top_up!(store, cashier, branch, account, 50_000)
    first, second = Spree::Pos::ReceivedFunds.order(:id).last(2)
    swipe(sale, account)

    wallet_pay(sale)

    allocations = Spree::Pos::FundsAllocation.where(workspace: sale.workspace).order(:id)
    expect(allocations.map { |row| [row.received_funds_id, row.amount] }).to eq([[first.id, 20_000], [second.id, 15_000]])
    expect(wallet_of(account).balance).to eq(35_000)
    expect(ledger_sum(account)).to eq(35_000)
    expect(Spree::Pos::OutboxEntry.where(event_type: 'meal_wallet.low_balance').count).to eq(0)

    Spree::Pos::Workspaces::Complete.call(**editing_args(sale))
    expect(sale.workspace.reload.order).to be_complete
    expect(sale.workspace.order.payments.completed.sum(:amount)).to eq(35_000)
  end

  it 'refuses a wallet that cannot pay and leaves a low-balance event when the balance drops under the threshold' do
    account = meal_account!(store, cashier, branch, low_balance_threshold: '30000')
    sale = meal_sale(store, branch, cashier, price: 35_000)
    top_up!(store, cashier, branch, account, 30_000)
    swipe(sale, account)

    expect(refusal { wallet_pay(sale) }.reason).to eq(Spree::Pos::StoredValue::INSUFFICIENT)
    expect(Spree::Pos::FundsAllocation.where(workspace: sale.workspace)).to be_empty

    top_up!(store, cashier, branch, account, 10_000)
    wallet_pay(sale)
    event = Spree::Pos::OutboxEntry.find_by(event_type: 'meal_wallet.low_balance')
    expect(event.payload).to include('meal_account_id' => account.prefixed_id, 'balance' => '5000.0')
  end

  it 'refunds the balance only with an approval and keeps the money held until the payout is confirmed' do
    account = meal_account!(store, cashier, branch)
    open_drawer(store, branch, cashier)
    top_up!(store, cashier, branch, account, 60_000)
    args = { store: store, staff: cashier, branch_id: branch.prefixed_id, meal_account_id: account.prefixed_id }

    expect(refusal { Spree::Pos::MealWallets::Refund.call(**args, key: SecureRandom.uuid) }.reason).to eq('approval_required')
    approval = grant(account, Spree::Pos::Approval::MEAL_REFUND_ACTION, 60_000)
    result = Spree::Pos::MealWallets::Refund.call(**args, key: SecureRandom.uuid, approval_id: approval.prefixed_id)

    payout = Spree::Pos::LiabilityPayout.find_by_prefix_id!(result['payouts'].first['id'])
    expect(payout).to have_attributes(status: 'reserved', amount: 60_000)
    expect(wallet_of(account).balance).to eq(0)
    expect(ledger_sum(account)).to eq(0)
    expect(approval.reload.status).to eq('consumed')
  end

  it 'corrects the balance only with an approval and never beyond the money received' do
    account = meal_account!(store, cashier, branch)
    open_drawer(store, branch, cashier)
    top_up!(store, cashier, branch, account, 50_000)
    args = { store: store, staff: cashier, branch_id: branch.prefixed_id, meal_account_id: account.prefixed_id, note: 'Sai số' }

    expect(refusal { Spree::Pos::MealWallets::Adjust.call(**args, key: SecureRandom.uuid, amount: '-10000') }.reason).
      to eq('approval_required')
    approval = grant(account, Spree::Pos::Approval::MEAL_ADJUST_ACTION, 10_000)
    Spree::Pos::MealWallets::Adjust.call(**args, key: SecureRandom.uuid, amount: '-10000', approval_id: approval.prefixed_id)
    expect(wallet_of(account).balance).to eq(40_000)

    over = refusal do
      Spree::Pos::MealWallets::Adjust.call(store: store, staff: manager, key: SecureRandom.uuid, branch_id: branch.prefixed_id,
                                           meal_account_id: account.prefixed_id, amount: '20000', note: 'Thêm')
    end
    expect(over.reason).to eq('stored_value_adjust_invalid')
    expect(wallet_of(account).balance).to eq(40_000)
    expect(ledger_sum(account)).to eq(40_000)
  end

  it 'puts the money back on the wallet when a paid meal order is canceled' do
    cashier = credit_staff(store, branch, PosMealHelpers::MEAL_CASHIER + [PosMealHelpers::CAPS::RESOLVE])
    account = meal_account!(store, cashier, branch)
    sale = meal_sale(store, branch, cashier, price: 35_000)
    top_up!(store, cashier, branch, account, 50_000)
    swipe(sale, account)
    wallet_pay(sale)
    allocation = Spree::Pos::FundsAllocation.find_by!(workspace: sale.workspace)

    Spree::Pos::Funds::ReverseAllocation.call(**editing_args(sale), allocation_id: allocation.prefixed_id)

    expect(allocation.reload.status).not_to eq('active')
    expect(wallet_of(account).balance).to eq(50_000)
    expect(ledger_sum(account)).to eq(50_000)
  end
end
