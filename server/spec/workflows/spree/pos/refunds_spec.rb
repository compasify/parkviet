# frozen_string_literal: true

require_relative '../../../support/pos_return_helpers'

# Goods refunds consume the original receipt through its allocation child.
# A core Refund exists only after a confirmed payout; reserved and unknown
# payouts keep their hold on the receipt, and a retry never pays twice.
RSpec.describe 'POS refunds', type: :request do
  include PosReturnHelpers
  include ActiveSupport::Testing::TimeHelpers

  let(:store) { create(:store, default_currency: 'VND', supported_currencies: 'VND') }
  let(:branch) { returns_branch(store) }
  let(:manager) { credit_staff(store, branch, PosReturnHelpers::APPROVER) }
  let(:cashier) { credit_staff(store, branch, PosReturnHelpers::RETURNS) }

  def returned(quantity: 1, price: 100_000, sold: 2, kind: 'cash')
    sale = paid_sale(store, branch, cashier: cashier, price: price, quantity: sold, kind: kind)
    [sale, return_and_receive(store, cashier, branch, sale, quantity: quantity)]
  end

  def core_refunds(sale)
    Spree::Refund.where(payment_id: sale.workspace.order.payments.select(:id))
  end

  it 'creates the core Refund only when the payout is confirmed, on the confirming shift' do
    sale, result = returned
    refund = request_refund(store, cashier, result, amount: 100_000)
    funds = allocation_of(sale).received_funds
    expect(core_refunds(sale)).to be_empty
    expect(Spree::Pos::FundsBalance.new(funds.reload).to_h).to include(payout_reserved: BigDecimal('100000'), allocated: BigDecimal('100000'))

    expect { confirm_refund(store, cashier, refund) }.to raise_error(Spree::Pos::Conflict, /needs an approval/)
    approve_refund(store, manager, refund)
    confirmed = confirm_refund(store, cashier, refund)

    expect(confirmed['status']).to eq('confirmed')
    expect(core_refunds(sale).sum(:amount)).to eq(BigDecimal('100000'))
    request = Spree::Pos::RefundRequest.find_by_prefix_id!(refund['id'])
    expect(request.refund.originator).to eq(operation(result).core_return)
    movement = Spree::Pos::CashMovement.find_by!(refund_request: request)
    expect(movement.amount).to eq(BigDecimal('-100000'))
    expect(movement.shift.owner).to eq(cashier)
    balance = Spree::Pos::FundsBalance.new(funds.reload).to_h
    expect(balance).to include(paid_out: BigDecimal('100000'), payout_reserved: 0, allocated: BigDecimal('100000'))
    expect(balance[:received_net]).to eq(balance.values_at(:available, :allocated, :payout_reserved, :paid_out).sum)
  end

  it 'lets a distinct approver confirm directly and refuses the requester confirming their own without approval' do
    _sale, result = returned
    refund = request_refund(store, cashier, result, amount: 100_000)
    open_drawer(store, branch, manager)
    expect(confirm_refund(store, manager, refund)['status']).to eq('confirmed')

    self_requested = request_refund(store, manager, return_and_receive(store, cashier, branch, returned.first, quantity: 1), amount: 100_000)
    expect { confirm_refund(store, manager, self_requested) }.to raise_error(Spree::Pos::Conflict, /needs an approval/)
    expect { approve_refund(store, manager, self_requested) }.to raise_error(Spree::Pos::Conflict, /own refund/)
  end

  it 'replays a retried confirmation and refuses a second payout of the same request' do
    sale, result = returned
    refund = request_refund(store, cashier, result, amount: 100_000)
    approve_refund(store, manager, refund)
    key = SecureRandom.uuid
    first = confirm_refund(store, cashier, refund, key: key)
    again = confirm_refund(store, cashier, refund, key: key)
    expect(again).to eq(first)
    expect { confirm_refund(store, cashier, refund) }.to raise_error(Spree::Pos::Conflict, /not awaiting/)
    expect(core_refunds(sale).count).to eq(1)
    expect(Spree::Pos::CashMovement.where(source_type: 'Spree::Pos::RefundRequest').count).to eq(1)
  end

  it 'caps requests by the entitlement and the receipt, counting reserved and unknown requests' do
    sale, result = returned(quantity: 2, sold: 2)
    first = request_refund(store, cashier, result, amount: 150_000)
    Spree::Pos::Refunds::Resolve.call(store: store, staff: cashier, key: SecureRandom.uuid, refund_id: first['id'], outcome: 'unknown')
    expect { request_refund(store, cashier, result, amount: 50_001) }.to raise_error(Spree::Pos::Conflict, /entitlement/)
    request_refund(store, cashier, result, amount: 50_000)
    expect(allocation_of(sale).refundable).to eq(0)
    expect(core_refunds(sale)).to be_empty

    # Unknown keeps the hold until evidence shows it had no effect.
    expect do
      Spree::Pos::Refunds::Resolve.call(store: store, staff: cashier, key: SecureRandom.uuid, refund_id: first['id'], outcome: 'failed_no_effect',
                                        reference: 'Bank: lệnh bị trả về')
    end.to raise_error(CanCan::AccessDenied)
    Spree::Pos::Refunds::Resolve.call(store: store, staff: manager, key: SecureRandom.uuid, refund_id: first['id'], outcome: 'failed_no_effect',
                                      reference: 'Bank: lệnh bị trả về')
    expect(allocation_of(sale).refundable).to eq(BigDecimal('150000'))
    expect(operation(result).refundable_remaining).to eq(BigDecimal('150000'))
  end

  it 'pays a bank refund only with a transfer reference, and keeps an unknown bank payout reserved' do
    sale, result = returned(kind: 'bank_manual')
    refund = request_refund(store, cashier, result, amount: 100_000, method: 'bank_manual')
    Spree::Pos::Refunds::Resolve.call(store: store, staff: cashier, key: SecureRandom.uuid, refund_id: refund['id'], outcome: 'unknown')
    funds = allocation_of(sale).received_funds
    expect(Spree::Pos::FundsBalance.new(funds.reload).payout_reserved).to eq(BigDecimal('100000'))
    expect { approve_refund(store, manager, refund) }.to raise_error(Spree::Pos::Conflict, /reserved refund/)

    expect do
      Spree::Pos::Refunds::ConfirmPayout.call(store: store, staff: manager, key: SecureRandom.uuid, refund_id: refund['id'],
                                              evidence_kind: 'bank_manual')
    end.to raise_error(Spree::Pos::Conflict, /transfer reference/)
    confirmed = confirm_refund(store, manager, refund, reference: 'FT2611070001')
    # Command results never carry a full payment reference; the ledger does.
    expect(confirmed['evidence']).to include('kind' => 'bank_manual', 'reference' => '••••••••0001')
    expect(Spree::Pos::PayoutEvidence.where(refund_request_id: Spree::Pos::RefundRequest.find_by_prefix_id!(refund['id']).id).
             pluck(:reference)).to include('FT2611070001')
    expect(core_refunds(sale).sum(:amount)).to eq(BigDecimal('100000'))
    expect(Spree::Pos::CashMovement.where(source_type: 'Spree::Pos::RefundRequest')).to be_empty
  end

  it 'pays a next-day cash refund from the current shift while the sale keeps its own shift and receipt' do
    sale, result = returned
    sale_shift = sale.workspace.shift
    funds = allocation_of(sale).received_funds
    receipt_before = funds.attributes.slice('shift_id', 'received_net', 'handed_amount', 'received_at')
    Spree::Pos::Shift.where(id: sale_shift.id).update_all(status: 'closed')

    travel 1.day do
      refund = request_refund(store, cashier, result, amount: 100_000)
      approve_refund(store, manager, refund)
      expect { confirm_refund(store, cashier, refund) }.to raise_error(Spree::Pos::Conflict, /open shift/)
      register = open_drawer(store, branch, cashier)
      confirm_refund(store, cashier, refund)
      movement = Spree::Pos::CashMovement.find_by!(source_type: 'Spree::Pos::RefundRequest')
      expect(movement.shift.register).to eq(register)
      expect(movement.shift).not_to eq(sale_shift)
    end
    expect(funds.reload.attributes.slice('shift_id', 'received_net', 'handed_amount', 'received_at')).to eq(receipt_before)
    expect(Spree::Pos::CashMovement.where(shift_id: sale_shift.id).sum(:amount)).to eq(BigDecimal('200000'))
  end

  it 'refuses a receipt of another order and releases the hold when a request that never paid is canceled' do
    sale, result = returned
    other = paid_sale(store, branch, cashier: cashier, price: 50_000)
    expect do
      request_refund(store, cashier, result, amount: 1, allocation: allocation_of(other))
    end.to raise_error(ActiveRecord::RecordNotFound)
    refund = request_refund(store, cashier, result, amount: 100_000)
    expect(allocation_of(sale).consumed).to eq(BigDecimal('100000'))
    Spree::Pos::Refunds::Resolve.call(store: store, staff: cashier, key: SecureRandom.uuid, refund_id: refund['id'], outcome: 'cancel',
                                      reason: 'Khách đổi ý, nhận đổi hàng')
    expect(allocation_of(sale).consumed).to eq(0)
  end

  context 'when canceling a refund request' do
    def cancel(staff, refund, reason: 'Khách không nhận')
      Spree::Pos::Refunds::Resolve.call(store: store, staff: staff, key: SecureRandom.uuid, refund_id: refund['id'],
                                        outcome: 'cancel', reason: reason)
    end

    it 'lets only its requester or an approver cancel it, with a reason that is audited' do
      _sale, result = returned
      refund = request_refund(store, cashier, result, amount: 50_000)
      other = credit_staff(store, branch, PosReturnHelpers::RETURNS)
      expect { cancel(other, refund) }.to raise_error(CanCan::AccessDenied)
      expect { cancel(cashier, refund, reason: ' ') }.to raise_error(Spree::Pos::Conflict, /reason/)
      expect(cancel(cashier, refund)['status']).to eq('canceled')
      audit = Spree::Pos::AuditEntry.where(action: 'refund.resolve').last
      expect(audit.metadata).to include('outcome' => 'cancel', 'reason' => 'Khách không nhận')

      second = request_refund(store, cashier, result, amount: 50_000)
      expect(cancel(manager, second)['status']).to eq('canceled')
    end

    it 'refuses to cancel once an approval was granted; the way out is unknown then failed with evidence' do
      _sale, result = returned
      refund = request_refund(store, cashier, result, amount: 50_000)
      approve_refund(store, manager, refund)
      expect { cancel(cashier, refund) }.to raise_error(Spree::Pos::Conflict, /approval was granted/)
      unknown = Spree::Pos::Refunds::Resolve.call(store: store, staff: cashier, key: SecureRandom.uuid, refund_id: refund['id'],
                                                  outcome: 'unknown')
      expect(unknown['evidence']).to include('kind' => 'unknown')
      failed = Spree::Pos::Refunds::Resolve.call(store: store, staff: manager, key: SecureRandom.uuid, refund_id: refund['id'],
                                                 outcome: 'failed_no_effect', reference: 'Sao kê không có lệnh chi')
      expect(failed['status']).to eq('failed')
    end
  end
end
