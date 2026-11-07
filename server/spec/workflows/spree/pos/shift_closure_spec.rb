# frozen_string_literal: true

require_relative '../../../support/pos_shift_helpers'

# Shift close: expected drawer cash from immutable CashMovements, blind count,
# checklist, variance approval, the immutable closing snapshot, and late cash
# reconciled to its custody without rewriting a closed shift or inflating the
# next one.
RSpec.describe 'POS shift close and cash reconciliation', type: :request do
  include PosShiftHelpers
  include ActiveSupport::Testing::TimeHelpers

  let(:store) { create(:store, default_currency: 'VND', supported_currencies: 'VND') }
  let(:branch) { returns_branch(store) }
  let(:lead) { credit_staff(store, branch, PosShiftHelpers::LEAD) }
  let(:manager) { credit_staff(store, branch, PosShiftHelpers::MANAGER) }

  def conflict_reason
    yield
    nil
  rescue Spree::Pos::Conflict => e
    e.reason
  end

  describe 'expected cash' do
    it 'adds cash kept and subtracts cash paid out, without bank, debt, change or allocations' do
      shift = open_shift(store, branch, lead, float: 200_000)
      product = stocked_product(store, branch, price: 250_000)

      # Sale 250k: bank 100k + cash handed 200k with 50k change -> drawer +150k.
      sale = open_sale(store, branch, cashier: lead, product: product)
      take_tender(sale, 'bank_manual', 100_000)
      cash_tender(sale, 150_000, 200_000)
      Spree::Pos::Workspaces::Complete.call(**editing_args(sale))

      # Credit sale of 500k on debt: nothing enters the drawer.
      profile = credit_customer(store, manager)
      account = configure_credit(store, manager, branch, profile, limit: 1_000_000)
      debtor = credit_sale(store, branch, price: 500_000, cashier: lead, product: stocked_product(store, branch, price: 500_000))
      assign(debtor, profile)
      complete_on_credit(debtor, approve_credit(debtor, manager, 500_000)['approval_id'])

      # Debt collection in cash: handed 120k, kept 100k -> +100k.
      Spree::Pos::Collections::Receive.call(
        store: store, staff: lead, key: SecureRandom.uuid, branch_id: branch.prefixed_id, credit_account_id: account.prefixed_id,
        kind: 'cash', amount: '100000', handed_amount: '120000',
        allocations: [{ 'order_id' => debtor.workspace.reload.order.prefixed_id, 'amount' => '100000' }]
      )
      # A late bank transfer: no drawer effect.
      Spree::Pos::RecordUnsolicitedFunds.call(store: store, staff: lead, key: SecureRandom.uuid, branch_id: branch.prefixed_id,
                                              shift_id: shift.prefixed_id, kind: 'bank_manual', handed_amount: '40000',
                                              reference: 'FT-LATE', receiving_account: 'VCB-123')
      # Unsolicited drawer cash 30k paid back as a liability payout: +30k -30k.
      funds = drawer_cash(store, branch, shift, lead, 30_000)
      payout = Spree::Pos::LiabilityPayouts::Request.call(store: store, staff: manager, key: SecureRandom.uuid,
                                                          funds_id: funds.prefixed_id, amount: '30000',
                                                          beneficiary_name: 'Khách lẻ', reason: 'Trả lại tiền thừa')
      Spree::Pos::LiabilityPayouts::Confirm.call(store: store, staff: lead, key: SecureRandom.uuid, payout_id: payout['id'],
                                                 evidence_kind: 'cash_count')
      # A 50k cash sale returned and refunded in cash: +50k -50k.
      returned = paid_sale(store, branch, cashier: lead, price: 50_000)
      refund = request_refund(store, lead, return_and_receive(store, lead, branch, returned, quantity: 1), amount: 50_000)
      approve_refund(store, manager, refund)
      confirm_refund(store, lead, refund)
      # Manual drawer movements.
      move_cash(shift, lead, 'cash_in', 20_000)
      move_cash(shift, lead, 'cash_out', 10_000, reason: 'Mua túi nilon', evidence: 'HD-12', confirmer: manager)
      move_cash(shift, lead, 'safe_drop', 100_000, reason: 'Nộp két', evidence: 'TUI-7', confirmer: manager)

      categories = Spree::Pos::CashMovement.where(shift: shift).order(:id).map { |row| [row.category, row.amount.to_i] }
      expect(categories).to eq([
                                 ['sale', 150_000], ['collection', 100_000], ['unsolicited', 30_000], ['liability_payout', -30_000],
                                 ['sale', 50_000], ['refund', -50_000], ['cash_in', 20_000], ['cash_out', -10_000], ['safe_drop', -100_000]
                               ])
      expect(expected_cash(shift)).to eq(BigDecimal('360000'))

      preview = count_shift(shift, lead, 360_000)
      expect(preview).to include('expected' => '360000.0', 'variance' => '0.0', 'requires_approval' => false)
      closure = close_shift(shift, lead)
      last = Spree::Pos::CashMovement.where(shift: shift).order(:id).last
      expect(closure).to include('expected' => '360000.0', 'counted' => '360000.0', 'variance' => '0.0',
                                 'inflow_total' => '350000.0', 'outflow_total' => '190000.0',
                                 'movement_count' => 9, 'cutoff_movement_id' => last.prefixed_id)
      expect(closure['breakdown']).to include('sale' => '200000.0', 'refund' => '-50000.0', 'safe_drop' => '-100000.0')
      expect(shift.reload.status).to eq('closed')
    end

    it 'refuses an outflow larger than the drawer and manual movements without a reason or capability' do
      shift = open_shift(store, branch, lead, float: 50_000)
      expect(conflict_reason { move_cash(shift, lead, 'safe_drop', 60_000) }).to eq('insufficient_cash')
      expect(conflict_reason { move_cash(shift, lead, 'cash_in', 10_000, reason: ' ') }).to eq('reason_required')
      expect(conflict_reason { move_cash(shift, lead, 'cash_in', '10000.5') }).to eq('amount_invalid')
      expect { move_cash(shift, manager, 'cash_in', 10_000) }.to raise_error(CanCan::AccessDenied)
      expect(Spree::Pos::CashMovement.where(shift: shift)).to be_empty
    end
  end

  describe 'checklist' do
    it 'blocks counting while a tender is prepared or a draft holds money, and lists drafts without money as warnings' do
      shift = open_shift(store, branch, lead)
      product = stocked_product(store, branch, price: 100_000)
      pending = open_sale(store, branch, cashier: lead, product: product)
      method = Spree::Pos::PaymentMethodResolver.new(store: store).available.find { |row| row.kind == 'bank_manual' }
      Spree::Pos::Tenders::Prepare.call(**editing_args(pending), payment_method_id: method.prefixed_id || 'posmethod-bank_manual', amount: '100000')
      funded = open_sale(store, branch, cashier: lead, product: product)
      cash_tender(funded, 40_000, 40_000)
      empty = open_sale(store, branch, cashier: lead, product: product)

      error = nil
      begin
        count_shift(shift, lead, 40_000)
      rescue Spree::Pos::Shifts::CloseBlocked => e
        error = e
      end
      expect(error.reason).to eq('close_blocked')
      blocking = error.checklist.blocking
      expect(blocking.map { |item| item[:type] }).to contain_exactly('tender_attempt', 'workspace_money')
      attempt = blocking.find { |item| item[:type] == 'tender_attempt' }
      expect(attempt).to include(workspace_id: pending.workspace.prefixed_id, status: 'prepared', kind: 'bank_manual')
      expect(blocking.find { |item| item[:type] == 'workspace_money' }).to include(workspace_id: funded.workspace.prefixed_id,
                                                                                   amount: '40000.0')
      expect(error.checklist.warnings.map { |item| item[:workspace_id] }).to include(empty.workspace.prefixed_id)
      expect(shift.reload.closing_counted).to be_nil
    end

    it 'blocks on payouts the owner marked unknown from this drawer, not on ones merely requested' do
      shift = open_shift(store, branch, lead)
      funds = drawer_cash(store, branch, shift, lead, 30_000)
      payout = Spree::Pos::LiabilityPayouts::Request.call(store: store, staff: manager, key: SecureRandom.uuid,
                                                          funds_id: funds.prefixed_id, amount: '30000',
                                                          beneficiary_name: 'Khách', reason: 'Hoàn tiền thừa')
      expect(Spree::Pos::ShiftChecklist.new(shift.reload).blocking).to be_empty

      Spree::Pos::LiabilityPayouts::Resolve.call(store: store, staff: lead, key: SecureRandom.uuid, payout_id: payout['id'],
                                                 outcome: 'unknown')
      sale = paid_sale(store, branch, cashier: lead, price: 50_000)
      refund = request_refund(store, lead, return_and_receive(store, lead, branch, sale, quantity: 1), amount: 50_000)
      Spree::Pos::Refunds::Resolve.call(store: store, staff: lead, key: SecureRandom.uuid, refund_id: refund['id'], outcome: 'unknown')

      blocking = Spree::Pos::ShiftChecklist.new(shift.reload).blocking
      expect(blocking).to contain_exactly(
        { type: 'liability_payout', id: payout['id'], funds_id: funds.prefixed_id, status: 'unknown', amount: '30000.0' },
        a_hash_including(type: 'refund_request', id: refund['id'], return_id: refund['return_id'], status: 'unknown')
      )
      expect(conflict_reason { count_shift(shift, lead, 0) }).to eq('close_blocked')
    end

    it 'blocks while a safe drop waits for its second person' do
      shift = open_shift(store, branch, lead, float: 100_000)
      request = move_cash(shift, lead, 'safe_drop', 40_000, evidence: 'TUI-1')
      expect(Spree::Pos::ShiftChecklist.new(shift.reload).blocking).to eq(
        [{ type: 'cash_movement_request', id: request['id'], kind: 'safe_drop', status: 'requested', amount: '40000.0' }]
      )
    end
  end

  describe 'variance approval' do
    it 'needs a reason and an approval from someone else, bound to the count' do
      shift = open_shift(store, branch, lead, float: 100_000)
      preview = count_shift(shift, lead, 90_000)
      expect(preview).to include('expected' => '100000.0', 'variance' => '-10000.0', 'requires_approval' => true)

      expect(conflict_reason { close_shift(shift, lead) }).to eq('reason_required')
      expect(conflict_reason { approve_close(shift, manager) }).to eq('reason_required')
      count_shift(shift, lead, 90_000, reason: 'Thối nhầm cho khách')
      expect(conflict_reason { close_shift(shift, lead) }).to eq('approval_required')
      expect { approve_close(shift, lead) }.to raise_error(CanCan::AccessDenied)

      approve_close(shift, manager)
      # A new count after the approval makes it unusable.
      count_shift(shift, lead, 95_000, reason: 'Đếm lại')
      expect(conflict_reason { close_shift(shift, lead) }).to eq('approval_required')

      approval = approve_close(shift, manager)['approval']
      closure = close_shift(shift, lead)
      expect(closure).to include('variance' => '-5000.0', 'approver_id' => manager.prefixed_id, 'reason' => 'Đếm lại')
      expect(Spree::Pos::Approval.find_by_prefix_id!(approval['id']).status).to eq('consumed')
    end

    it 'closes within the branch threshold without an approval' do
      branch.update!(variance_threshold: 20_000)
      shift = open_shift(store, branch, lead, float: 100_000)
      expect(count_shift(shift, lead, 110_000)['requires_approval']).to be(false)
      expect(close_shift(shift, lead, reason: 'Tiền lẻ khách không lấy')).to include('variance' => '10000.0', 'approver_id' => nil)
    end

    it 'refuses a close after cash moved since the count' do
      shift = open_shift(store, branch, lead, float: 100_000)
      count_shift(shift, lead, 100_000)
      travel 1.second
      move_cash(shift, lead, 'cash_in', 10_000)
      expect(conflict_reason { close_shift(shift, lead) }).to eq('count_stale')
    end
  end

  describe 'immutability and retry' do
    it 'returns the same snapshot on retry and refuses every later write to the shift' do
      shift = open_shift(store, branch, lead, float: 100_000)
      count_shift(shift, lead, 100_000)
      key = SecureRandom.uuid
      first = close_shift(shift, lead, key: key)
      expect(close_shift(shift, lead, key: key)).to eq(first)
      expect(close_shift(shift, lead)).to eq(first)
      expect(Spree::Pos::ShiftClosure.where(shift: shift).count).to eq(1)

      closure = Spree::Pos::ShiftClosure.find_by!(shift: shift)
      expect { closure.update!(counted: 1) }.to raise_error(ActiveRecord::ReadOnlyRecord)
      expect { shift.reload.update!(opening_float: 1) }.to raise_error(ActiveRecord::ReadOnlyRecord)
      expect(conflict_reason { move_cash(shift, lead, 'cash_in', 10_000) }).to eq('shift_closed')
      expect(conflict_reason { count_shift(shift, lead, 0) }).to eq('shift_closed')
      expect { drawer_cash(store, branch, shift, lead, 10_000) }.to raise_error(Spree::Pos::Conflict)
      expect(Spree::Pos::CashMovement.where(shift: shift)).to be_empty
    end

    it 'keeps the movement ledger immutable' do
      shift = open_shift(store, branch, lead, float: 100_000)
      move_cash(shift, lead, 'cash_in', 10_000)
      movement = Spree::Pos::CashMovement.find_by!(shift: shift)
      expect { movement.update!(amount: 1) }.to raise_error(ActiveRecord::ReadOnlyRecord)
    end
  end

  describe 'late cash' do
    # S1 actually took 100k it never recorded: expected 0, counted 100k.
    def overage_shift
      s1 = open_shift(store, branch, lead, float: 0)
      count_shift(s1, lead, 100_000, reason: 'Thừa tiền chưa rõ nguồn')
      approve_close(s1, manager)
      closure = close_shift(s1, lead)
      expect(closure).to include('expected' => '0.0', 'counted' => '100000.0', 'variance' => '100000.0')
      [s1.reload, Spree::Pos::ShiftClosure.find_by_prefix_id!(closure['id'])]
    end

    let(:auditor) { credit_staff(store, branch, PosShiftHelpers::MANAGER) }

    it 'classifies S1 overage already in the S2 opening float without adding it to S2 (100k stays 100k)' do
      s1, closure = overage_shift
      s2 = open_shift(store, branch, lead, float: 100_000)
      funds = held_cash(store, branch, s1, manager, 100_000)
      expect(Spree::Pos::CashMovement.where(received_funds: funds)).to be_empty

      result = reconcile(store, branch, auditor, outcome: 'in_opening_float', closure_id: closure.prefixed_id,
                                                 funds_id: funds.prefixed_id, target_shift_id: s2.prefixed_id)
      expect(result).to include('outcome' => 'in_opening_float', 'amount' => '100000.0', 'cash_movement_id' => nil)
      expect(expected_cash(s2)).to eq(BigDecimal('100000'))
      expect(closure.reload).to have_attributes(variance: BigDecimal('100000'), counted: BigDecimal('100000'))
      expect(closure.reconciled_amount).to eq(BigDecimal('100000'))
      expect(conflict_reason do
        reconcile(store, branch, auditor, outcome: 'safe', closure_id: closure.prefixed_id, amount: '1000',
                                          custody_reference: 'KET-1')
      end).to eq('overage_explained')
    end

    it 'keeps S2 at 100k when the held cash went to the safe first and S2 opened with it later' do
      s1, closure = overage_shift
      funds = held_cash(store, branch, s1, manager, 100_000)
      # Not naming the closure still counts the held cash against S1's overage.
      result = reconcile(store, branch, auditor, outcome: 'safe', funds_id: funds.prefixed_id, custody_reference: 'KET-9')
      expect(result['shift_closure_id']).to eq(closure.prefixed_id)
      s2 = open_shift(store, branch, lead, float: 100_000)
      expect(conflict_reason do
        reconcile(store, branch, auditor, outcome: 'new_physical_inflow', closure_id: closure.prefixed_id, amount: '100000',
                                          target_shift_id: s2.prefixed_id)
      end).to eq('overage_explained')
      expect(expected_cash(s2)).to eq(BigDecimal('100000'))
    end

    it 'refuses a held receipt for overage a closure-only reconciliation already explained' do
      s1, closure = overage_shift
      s2 = open_shift(store, branch, lead, float: 100_000)
      reconcile(store, branch, auditor, outcome: 'in_opening_float', closure_id: closure.prefixed_id, amount: '100000',
                                        target_shift_id: s2.prefixed_id)
      funds = held_cash(store, branch, s1, manager, 100_000)
      expect(conflict_reason do
        reconcile(store, branch, auditor, outcome: 'new_physical_inflow', funds_id: funds.prefixed_id, target_shift_id: s2.prefixed_id)
      end).to eq('overage_explained')
      expect(expected_cash(s2)).to eq(BigDecimal('100000'))
    end

    it 'never claims more than the opening float it names' do
      _, closure = overage_shift
      s2 = open_shift(store, branch, lead, float: 60_000)
      expect(conflict_reason do
        reconcile(store, branch, auditor, outcome: 'in_opening_float', closure_id: closure.prefixed_id, amount: '100000',
                                          target_shift_id: s2.prefixed_id)
      end).to eq('exceeds_float')
      reconcile(store, branch, auditor, outcome: 'in_opening_float', closure_id: closure.prefixed_id, amount: '60000',
                                        target_shift_id: s2.prefixed_id)
      expect(conflict_reason do
        reconcile(store, branch, auditor, outcome: 'in_opening_float', closure_id: closure.prefixed_id, amount: '10000',
                                          target_shift_id: s2.prefixed_id)
      end).to eq('exceeds_float')
      expect(conflict_reason do
        reconcile(store, branch, auditor, outcome: 'in_opening_float', closure_id: closure.prefixed_id, amount: '10000')
      end).to eq('target_required')
    end

    it 'excludes the closer and the variance approver from reconciling that shift' do
      _s1, closure = overage_shift
      expect(conflict_reason do
        reconcile(store, branch, manager, outcome: 'safe', closure_id: closure.prefixed_id, amount: '1000', custody_reference: 'K')
      end).to eq('self_approval')
    end

    it 'adds held cash newly put into a drawer exactly once' do
      s1, closure = overage_shift
      s2 = open_shift(store, branch, lead, float: 0)
      funds = held_cash(store, branch, s1, manager, 100_000)
      key = SecureRandom.uuid
      args = { outcome: 'new_physical_inflow', closure_id: closure.prefixed_id, funds_id: funds.prefixed_id,
               target_shift_id: s2.prefixed_id, key: key }
      first = reconcile(store, branch, auditor, **args)
      expect(reconcile(store, branch, auditor, **args)).to eq(first)
      expect(conflict_reason { reconcile(store, branch, auditor, **args, key: SecureRandom.uuid) }).to eq('already_reconciled')
      expect(expected_cash(s2)).to eq(BigDecimal('100000'))
      movement = Spree::Pos::CashMovement.find_by!(shift: s2)
      expect(movement).to have_attributes(kind: 'reconciliation_inflow', category: 'reconciliation_inflow')
      expect(first['cash_movement_id']).to eq(movement.prefixed_id)
    end

    it 'records safe custody with a reference, never a drawer movement, and keeps separation of duties' do
      s1, closure = overage_shift
      funds = held_cash(store, branch, s1, manager, 100_000)
      expect(conflict_reason { reconcile(store, branch, auditor, outcome: 'safe', funds_id: funds.prefixed_id) }).
        to eq('evidence_required')
      expect(conflict_reason do
        reconcile(store, branch, manager, outcome: 'safe', funds_id: funds.prefixed_id, custody_reference: 'KET-1')
      end).to eq('self_approval')
      expect { reconcile(store, branch, lead, outcome: 'safe', closure_id: closure.prefixed_id, custody_reference: 'KET-1') }.
        to raise_error(CanCan::AccessDenied)

      reconcile(store, branch, auditor, outcome: 'safe', closure_id: closure.prefixed_id, funds_id: funds.prefixed_id,
                                        custody_reference: 'KET-1')
      expect(Spree::Pos::CashMovement.where(cash_reconciliation_id: Spree::Pos::CashReconciliation.select(:id))).to be_empty
      expect(Spree::Pos::CashReconciliation.last).to have_attributes(outcome: 'safe', custody_reference: 'KET-1')
    end

    it 'keeps the actual received time of late evidence apart from its booking time' do
      s1, = overage_shift
      actual = 2.hours.ago.change(usec: 0)
      result = Spree::Pos::RecordUnsolicitedFunds.call(
        store: store, staff: manager, key: SecureRandom.uuid, branch_id: branch.prefixed_id, shift_id: s1.prefixed_id,
        kind: 'bank_manual', handed_amount: '70000', reference: 'FT-OLD', receiving_account: 'VCB-123',
        received_at: actual.iso8601
      )
      funds = Spree::Pos::ReceivedFunds.find_by_prefix_id!(result['id'])
      expect(funds.received_at).to eq(actual)
      expect(funds.created_at).to be > actual
      expect(conflict_reason do
        Spree::Pos::RecordUnsolicitedFunds.call(
          store: store, staff: manager, key: SecureRandom.uuid, branch_id: branch.prefixed_id, shift_id: s1.prefixed_id,
          kind: 'bank_manual', handed_amount: '1000', reference: 'FT-NEXT', receiving_account: 'VCB-123',
          received_at: 1.hour.from_now.iso8601
        )
      end).to eq('received_at_invalid')
    end
  end

  describe 'held custody payouts' do
    # Cash recorded as held never entered a drawer.
    def held_payout(owner)
      shift = open_shift(store, branch, owner, float: 0)
      funds = held_cash(store, branch, shift, manager, 50_000)
      payout = Spree::Pos::LiabilityPayouts::Request.call(store: store, staff: manager, key: SecureRandom.uuid,
                                                          funds_id: funds.prefixed_id, amount: '50000',
                                                          beneficiary_name: 'Khách', reason: 'Trả lại')
      [shift, payout]
    end

    def confirm(payout, **extra)
      Spree::Pos::LiabilityPayouts::Confirm.call(store: store, staff: lead, key: SecureRandom.uuid, payout_id: payout['id'],
                                                 evidence_kind: 'cash_count', **extra)
    end

    it 'refuses to pay held cash out of a drawer' do
      shift, payout = held_payout(lead)
      expect(conflict_reason { confirm(payout) }).to eq('held_custody')
      expect(Spree::Pos::CashMovement.where(shift: shift)).to be_empty
    end

    it 'records a custody-only outflow with a reference and no drawer movement' do
      shift, payout = held_payout(lead)
      expect(conflict_reason { confirm(payout, paid_from: 'custody') }).to eq('evidence_required')
      expect(confirm(payout, paid_from: 'custody', reference: 'KET-3')['status']).to eq('confirmed')
      expect(Spree::Pos::CashMovement.where(shift: shift)).to be_empty
      evidence = Spree::Pos::PayoutEvidence.where(liability_payout: Spree::Pos::LiabilityPayout.find_by_prefix_id!(payout['id'])).last
      expect(evidence.metadata).to include('paid_from' => 'custody')
      expect(expected_cash(shift)).to eq(0)
    end

    it 'pays drawer cash only from the drawer' do
      shift = open_shift(store, branch, lead, float: 0)
      funds = drawer_cash(store, branch, shift, lead, 30_000)
      payout = Spree::Pos::LiabilityPayouts::Request.call(store: store, staff: manager, key: SecureRandom.uuid,
                                                          funds_id: funds.prefixed_id, amount: '30000',
                                                          beneficiary_name: 'Khách', reason: 'Trả lại')
      expect(conflict_reason { confirm(payout, paid_from: 'custody', reference: 'K') }).to eq('not_held')
      confirm(payout)
      expect(expected_cash(shift)).to eq(0)
    end

    it 'refuses a cash refund paid from a drawer when its receipt is held' do
      shift = open_shift(store, branch, lead, float: 0)
      sale = open_sale(store, branch, cashier: lead, product: stocked_product(store, branch, price: 40_000))
      funds = held_cash(store, branch, shift, manager, 40_000)
      Spree::Pos::Funds::Allocate.call(**editing_args(sale), staff: lead, funds_id: funds.prefixed_id, amount: '40000')
      Spree::Pos::Workspaces::Complete.call(**editing_args(sale))
      hand_over(sale)
      refund = request_refund(store, lead, return_and_receive(store, lead, branch, sale, quantity: 1), amount: 40_000)
      approve_refund(store, manager, refund)
      expect(conflict_reason { confirm_refund(store, lead, refund) }).to eq('held_custody')
      Spree::Pos::Refunds::ConfirmPayout.call(store: store, staff: lead, key: SecureRandom.uuid, refund_id: refund['id'],
                                              evidence_kind: 'cash_count', reference: 'KET-4', paid_from: 'custody')
      expect(Spree::Pos::CashMovement.where(shift: shift, kind: 'payout')).to be_empty
    end
  end

  describe 'two-person drawer outflows' do
    it 'posts a safe drop only once someone else confirms it, and never twice' do
      shift = open_shift(store, branch, lead, float: 100_000)
      expect(conflict_reason { move_cash(shift, lead, 'safe_drop', 40_000, evidence: ' ') }).to eq('evidence_required')
      request = move_cash(shift, lead, 'safe_drop', 40_000, evidence: 'TUI-2')
      expect(request).to include('status' => 'requested', 'branch_id' => branch.prefixed_id)
      expect(expected_cash(shift)).to eq(BigDecimal('100000'))
      expect(conflict_reason { decide_cash(store, lead, request['id'], 'confirm') }).to eq('self_approval')

      key = SecureRandom.uuid
      confirmed = decide_cash(store, manager, request['id'], 'confirm', key: key)
      expect(decide_cash(store, manager, request['id'], 'confirm', key: key)).to eq(confirmed)
      expect(conflict_reason { decide_cash(store, manager, request['id'], 'confirm') }).to eq('not_awaiting')
      expect(confirmed).to include('status' => 'confirmed', 'confirmer_id' => manager.prefixed_id)
      expect(expected_cash(shift)).to eq(BigDecimal('60000'))
      movement = Spree::Pos::CashMovement.find_by!(shift: shift)
      expect(movement).to have_attributes(kind: 'safe_drop', amount: BigDecimal('-40000'), evidence_reference: 'TUI-2')
    end

    it 'cancels a request without touching the drawer, with a note' do
      shift = open_shift(store, branch, lead, float: 100_000)
      request = move_cash(shift, lead, 'cash_out', 10_000, evidence: 'HD-1')
      expect(conflict_reason { decide_cash(store, lead, request['id'], 'cancel') }).to eq('reason_required')
      expect(decide_cash(store, lead, request['id'], 'cancel', note: 'Nhập nhầm')['status']).to eq('canceled')
      expect(Spree::Pos::CashMovement.where(shift: shift)).to be_empty
      expect(Spree::Pos::ShiftChecklist.new(shift.reload).blocking).to be_empty
    end
  end

  describe 'stale count and leftover drafts' do
    it 'marks a count stale by movement id' do
      shift = open_shift(store, branch, lead, float: 100_000)
      count_shift(shift, lead, 100_000)
      expect(shift.reload.closing_cutoff_movement_id).to be_nil
      move_cash(shift, lead, 'cash_in', 10_000)
      expect(Spree::Pos::Shifts::Guard.count_stale?(shift.reload)).to be(true)
      count_shift(shift, lead, 110_000)
      expect(Spree::Pos::Shifts::Guard.count_stale?(shift.reload)).to be(false)
      expect(close_shift(shift, lead)['variance']).to eq('0.0')
    end

    it 'moves a draft without money to the cashier next open shift when resumed, and audits it' do
      first = open_shift(store, branch, lead, float: 0)
      draft = open_sale(store, branch, cashier: lead, product: stocked_product(store, branch, price: 10_000))
      count_shift(first, lead, 0)
      close_shift(first, lead)
      second = open_shift(store, branch, lead, float: 0)
      Spree::Pos::Workspaces::ClaimLease.call(workspace: draft.workspace.reload, staff: lead, key: SecureRandom.uuid,
                                              editor_id: draft.editor_id)
      expect(draft.workspace.reload.shift_id).to eq(second.id)
      expect(Spree::Pos::AuditEntry.where(action: 'workspace.rebind_shift', subject_id: draft.workspace.id)).to exist
      cash_tender(PosCreditHelpers::Sale.new(workspace: draft.workspace.reload, cashier: lead, editor_id: draft.editor_id,
                                             product: draft.product), 10_000, 10_000)
      expect(expected_cash(second)).to eq(BigDecimal('10000'))
    end
  end

  describe 'overnight shift' do
    it 'keeps the opening day and the closing day of a shift that crosses midnight' do
      zone = ActiveSupport::TimeZone[branch.timezone]
      travel_to zone.local(2026, 11, 5, 22, 0)
      shift = open_shift(store, branch, lead, float: 100_000)
      travel_to zone.local(2026, 11, 6, 1, 30)
      paid_sale(store, branch, cashier: lead, price: 40_000)
      travel_to zone.local(2026, 11, 6, 2, 0)
      count_shift(shift, lead, 140_000)
      closure = close_shift(shift, lead)
      expect(Time.zone.parse(closure['opened_at']).in_time_zone(zone).to_date).to eq(Date.new(2026, 11, 5))
      expect(Time.zone.parse(closure['closed_at']).in_time_zone(zone).to_date).to eq(Date.new(2026, 11, 6))
      expect(closure['expected']).to eq('140000.0')
    ensure
      travel_back
    end
  end
end
