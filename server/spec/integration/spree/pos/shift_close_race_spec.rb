# frozen_string_literal: true

require_relative '../../../support/pos_race_helpers'
require_relative '../../../support/pos_shift_helpers'

# Closing a shift races drawer cash writers over two real database
# connections. Both sides take the shift barrier, so exactly one order wins:
# either the cash posts first (and the counted drawer is stale, so the close
# is refused) or the close fixes its cutoff first and the cash post fails with
# `shift_closed`. A closed shift never gains a movement after its cutoff.
RSpec.describe 'POS shift close races', type: :integration do
  include_context 'with committed POS race rows'
  include PosShiftHelpers

  let(:branch) do
    credit_branch(store).tap { |row| row.update!(variance_threshold: 1_000_000_000, return_window_days: 30) }
  end
  let(:lead) { credit_staff(store, branch, PosShiftHelpers::LEAD) }
  let(:manager) { credit_staff(store, branch, PosShiftHelpers::MANAGER) }

  def counted_shift(owner, float: 100)
    shift = open_shift(store, branch, owner, float: float)
    count_shift(shift, owner, float)
    sleep 0.01
    shift
  end

  # Contender 0 closes; contender 1 runs the cash writer.
  def close_against(shift, owner, &cash)
    race(shift) do |index|
      if index.zero?
        close_shift(Spree::Pos::Shift.find(shift.id), owner)
        :closed
      else
        cash.call
        :cash
      end
    end
  end

  def expect_serialized(shift, outcomes, before: 0)
    winners = outcomes.select { |(status, _)| status == :success }.map(&:last)
    expect(outcomes.map(&:first) - %i[success conflict]).to be_empty, outcomes.inspect
    expect(winners.length).to eq(1), outcomes.inspect
    shift.reload
    movements = Spree::Pos::CashMovement.where(shift_id: shift.id)
    if winners == [:closed]
      closure = Spree::Pos::ShiftClosure.find_by!(shift_id: shift.id)
      expect(shift.status).to eq('closed')
      expect(movements.where('id > ?', closure.cutoff_movement_id.to_i)).to be_empty
      expect(closure.expected).to eq(shift.opening_float + movements.sum(:amount))
      expect(outcomes.map(&:last)).to include(a_string_matching(/Shift is closed/))
      expect(movements.count).to eq(before)
    else
      expect(shift.status).to eq('open')
      expect(Spree::Pos::ShiftClosure.where(shift_id: shift.id)).to be_empty
      expect(movements.count).to eq(before + 1)
    end
  end

  # Counts the shift as it is now, so the race starts from a fresh count.
  def recount(shift, owner)
    count_shift(shift, owner, Spree::Pos::CashbookProjection.new(shift.reload).expected.to_i)
    sleep 0.01
    Spree::Pos::CashMovement.where(shift_id: shift.id).count
  end

  it 'serializes a close with a cash refund payout' do
    sale = paid_sale(store, branch, cashier: lead, price: 40)
    shift = Spree::Pos::Shift.find_by!(owner_id: lead.id, status: 'open')
    refund = request_refund(store, lead, return_and_receive(store, lead, branch, sale, quantity: 1), amount: 40)
    approve_refund(store, manager, refund)
    before = recount(shift, lead)
    outcomes = close_against(shift, lead) { confirm_refund(store, lead, refund) }
    expect_serialized(shift, outcomes, before: before)
  end

  it 'serializes a close with unsolicited drawer cash' do
    shift = counted_shift(lead)
    outcomes = close_against(shift, lead) { drawer_cash(store, branch, Spree::Pos::Shift.find(shift.id), lead, 25) }
    expect_serialized(shift, outcomes)
  end

  it 'serializes a close with a manual cash in' do
    shift = counted_shift(lead)
    outcomes = close_against(shift, lead) { move_cash(Spree::Pos::Shift.find(shift.id), lead, 'cash_in', 10) }
    expect_serialized(shift, outcomes)
  end

  it 'serializes a close with the confirmation of a safe drop' do
    shift = open_shift(store, branch, lead, float: 100)
    request = move_cash(shift, lead, 'safe_drop', 30, evidence: 'TUI-1')
    # A pending request blocks counting; confirm on the race side.
    expect { count_shift(shift, lead, 100) }.to raise_error(Spree::Pos::Shifts::CloseBlocked)
    outcomes = race(shift) do |index|
      if index.zero?
        count_shift(Spree::Pos::Shift.find(shift.id), lead, 100)
        :counted
      else
        decide_cash(store, manager, request['id'], 'confirm')
        :confirmed
      end
    end
    winners = outcomes.select { |(status, _)| status == :success }.map(&:last)
    expect(winners).to include(:confirmed), outcomes.inspect
    drop = Spree::Pos::CashMovement.find_by!(shift_id: shift.id, kind: 'safe_drop')
    expect(Spree::Pos::CashMovement.where(shift_id: shift.id).sum(:amount)).to eq(BigDecimal('-30'))
    counted = Spree::Pos::Shift.find(shift.id)
    if winners.include?(:counted)
      # The confirmation took the barrier first: the count ran only after it
      # committed, against the drawer after the drop, never before it.
      expect(counted.closing_counted_at).to be >= drop.created_at
    else
      # The count took the barrier first while the request was pending: it was refused and recorded nothing.
      expect(counted.closing_counted).to be_nil
    end
  end

  it 'serializes a close with late cash put into its drawer' do
    s1 = open_shift(store, branch, lead, float: 0)
    count_shift(s1, lead, 60, reason: 'Thừa') # within this branch's wide threshold
    close_shift(s1, lead)
    funds = held_cash(store, branch, s1, manager, 60)
    auditor = credit_staff(store, branch, PosShiftHelpers::MANAGER)
    s2 = counted_shift(credit_staff(store, branch, PosShiftHelpers::LEAD), float: 10)
    outcomes = close_against(s2, s2.owner) do
      reconcile(store, branch, auditor, outcome: 'new_physical_inflow', funds_id: funds.prefixed_id,
                                        target_shift_id: s2.prefixed_id)
    end
    expect_serialized(s2, outcomes)
  end

  it 'serializes a close with a credit completion, which moves no cash' do
    profile = credit_customer(store, manager)
    configure_credit(store, manager, branch, profile, limit: 10_000)
    debtor = credit_sale(store, branch, price: 80, cashier: lead, product: stocked_product(store, branch, price: 80))
    assign(debtor, profile)
    approval = approve_credit(debtor, manager, 80)['approval_id']
    shift = Spree::Pos::Shift.find_by!(owner_id: lead.id, status: 'open')
    count_shift(shift, lead, 0)
    outcomes = close_against(shift, lead) do
      fresh = PosCreditHelpers::Sale.new(workspace: Spree::Pos::Workspace.find(debtor.workspace.id), cashier: lead,
                                         editor_id: debtor.editor_id, product: debtor.product)
      complete_on_credit(fresh, approval)
    end
    expect(outcomes.map(&:first)).to all(eq(:success).or(eq(:conflict))), outcomes.inspect
    closed = Spree::Pos::Shift.find(shift.id).status == 'closed'
    completed = debtor.workspace.reload.operational_status == 'completed'
    expect(closed).to be(true), outcomes.inspect
    # Completion either committed before the close (it holds the barrier) or found the shift closed.
    expect(outcomes).to include([:conflict, a_string_matching(/Shift is closed/)]) unless completed
    expect(Spree::Pos::CashMovement.where(shift_id: shift.id)).to be_empty
  end

  it 'returns the same snapshot to two closes racing with different keys' do
    shift = counted_shift(lead)
    outcomes = race(shift) { close_shift(Spree::Pos::Shift.find(shift.id), lead) }
    expect(outcomes.map(&:first)).to eq(%i[success success]), outcomes.inspect
    expect(outcomes.map { |(_, result)| result['id'] }.uniq.length).to eq(1)
    expect(Spree::Pos::ShiftClosure.where(shift_id: shift.id).count).to eq(1)
  end

  it 'serializes a close with a cash sale tender' do
    shift = counted_shift(lead)
    product = stocked_product(store, branch, price: 50)
    sale = open_sale(store, branch, cashier: lead, product: product)
    outcomes = close_against(shift, lead) do
      fresh = PosCreditHelpers::Sale.new(workspace: Spree::Pos::Workspace.find(sale.workspace.id), cashier: lead,
                                         editor_id: sale.editor_id, product: product)
      cash_tender(fresh, 50, 50)
    end
    expect_serialized(shift, outcomes)
  end

  it 'serializes a close with a cash debt collection' do
    profile = credit_customer(store, manager)
    account = configure_credit(store, manager, branch, profile, limit: 10_000)
    debtor = credit_sale(store, branch, price: 80, cashier: lead, product: stocked_product(store, branch, price: 80))
    assign(debtor, profile)
    complete_on_credit(debtor, approve_credit(debtor, manager, 80)['approval_id'])
    # The credit sale opened the lead's drawer; count it before racing.
    shift = Spree::Pos::Shift.find_by!(owner_id: lead.id, status: 'open')
    count_shift(shift, lead, 0)
    sleep 0.01
    order_id = debtor.workspace.reload.order.prefixed_id
    outcomes = close_against(shift, lead) do
      Spree::Pos::Collections::Receive.call(
        store: store, staff: lead, key: SecureRandom.uuid, branch_id: branch.prefixed_id,
        credit_account_id: account.prefixed_id, kind: 'cash', amount: '30',
        allocations: [{ 'order_id' => order_id, 'amount' => '30' }]
      )
    end
    expect_serialized(shift, outcomes)
  end

  it 'serializes a close with a cash liability payout' do
    shift = open_shift(store, branch, lead, float: 100)
    funds = drawer_cash(store, branch, shift, lead, 40)
    payout = Spree::Pos::LiabilityPayouts::Request.call(store: store, staff: manager, key: SecureRandom.uuid,
                                                        funds_id: funds.prefixed_id, amount: '40',
                                                        beneficiary_name: 'Khách', reason: 'Trả tiền thừa')
    count_shift(shift, lead, 140)
    sleep 0.01
    outcomes = close_against(shift, lead) do
      Spree::Pos::LiabilityPayouts::Confirm.call(store: store, staff: lead, key: SecureRandom.uuid, payout_id: payout['id'],
                                                 evidence_kind: 'cash_count')
    end
    winners = outcomes.select { |(status, _)| status == :success }.map(&:last)
    expect(winners.length).to eq(1), outcomes.inspect
    closure = Spree::Pos::ShiftClosure.find_by(shift_id: shift.id)
    payout_rows = Spree::Pos::CashMovement.where(shift_id: shift.id, kind: 'payout')
    if winners == [:closed]
      expect(payout_rows).to be_empty
      expect(closure.expected).to eq(BigDecimal('140'))
      expect(Spree::Pos::LiabilityPayout.find_by_prefix_id!(payout['id']).status).to eq('reserved')
    else
      expect(closure).to be_nil
      expect(payout_rows.sum(:amount)).to eq(BigDecimal('-40'))
    end
  end
end
