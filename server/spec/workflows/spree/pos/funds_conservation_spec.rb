# frozen_string_literal: true

require_relative '../../../support/pos_return_helpers'

# Conservation invariant over the parent ReceivedFunds:
#   received_net = available + allocated_unconsumed + payout_reserved + paid_out
# Buckets are disjoint; no operation may double-consume or go negative.
RSpec.describe 'POS funds conservation (F19/F20)', type: :request do
  it 'keeps buckets disjoint across allocate, payout reserve, unknown, confirm and reversal rules' do
    store = create(:store, default_currency: 'VND', supported_currencies: 'VND')
    user = create(:admin_user)
    location = create(:stock_location, store: store)
    branch = Spree::Pos::Branch.create!(store: store, stock_location: location, name: 'B', code: 'bfund', timezone: 'Asia/Ho_Chi_Minh',
                                        status: 'active')
    register = Spree::Pos::Register.create!(store: store, branch: branch, name: 'R', code: 'rfund', status: 'active')
    shift = Spree::Pos::Shift.create!(store: store, branch: branch, register: register, owner: user, opening_float: 0, currency: 'VND',
                                      status: 'open', opened_at: Time.current)
    order = create(:order, store: store, currency: 'VND')
    workspace = Spree::Pos::Workspace.create!(store: store, branch: branch, register: register, shift: shift, order: order,
                                              revision: 0, lease_generation: 1, operational_status: 'editing')
    funds = Spree::Pos::ReceivedFunds.create!(
      store: store, workspace: workspace, branch: branch, register: register, shift: shift, actor: user,
      kind: 'bank_manual', status: 'received', handed_amount: 100, applied_amount: 100, change_amount: 0,
      received_net: 100, currency: 'VND', received_at: Time.current
    )
    balance = -> { Spree::Pos::FundsBalance.new(funds.reload) }

    expect(balance.call.available).to eq(BigDecimal('100'))
    Spree::Pos::FundsAllocation.create!(store: store, received_funds: funds, workspace: workspace, order: order,
                                        status: 'active', amount: 30, currency: 'VND')
    payout = Spree::Pos::LiabilityPayout.create!(store: store, received_funds: funds, branch: branch, requester: user,
                                                 status: 'reserved', amount: 40, currency: 'VND',
                                                 beneficiary_name: 'A', reason: 'excess')
    expect(balance.call.to_h).to eq(received_net: BigDecimal('100'), allocated: BigDecimal('30'),
                                    payout_reserved: BigDecimal('40'), paid_out: BigDecimal('0'), available: BigDecimal('30'))

    payout.update!(status: 'unknown')
    expect(balance.call.payout_reserved).to eq(BigDecimal('40'))
    expect(balance.call.available).to eq(BigDecimal('30'))

    payout.update!(status: 'confirmed')
    expect(balance.call.paid_out).to eq(BigDecimal('40'))
    expect(balance.call.available).to eq(BigDecimal('30'))

    # Paid-out money never becomes available again; failed payouts release.
    released = Spree::Pos::LiabilityPayout.create!(store: store, received_funds: funds, branch: branch, requester: user,
                                                   status: 'reserved', amount: 30, currency: 'VND',
                                                   beneficiary_name: 'B', reason: 'second')
    expect(balance.call.available).to eq(BigDecimal('0'))
    released.update!(status: 'failed')
    expect(balance.call.available).to eq(BigDecimal('30'))
    b = balance.call.to_h
    expect(b[:received_net]).to eq(b[:available] + b[:allocated] + b[:payout_reserved] + b[:paid_out])

    # A refund taken from a child's Payment is paid out for good: it leaves the
    # allocated bucket and does not come back even if the child is reversed.
    order.update_columns(total: 100)
    payment = order.payments.create!(payment_method: create(:check_payment_method, store: store), amount: 30)
    payment.complete!
    child = Spree::Pos::FundsAllocation.create!(store: store, received_funds: funds, workspace: workspace, order: order,
                                                payment: payment, status: 'active', amount: 30, currency: 'VND')
    create(:refund, payment: payment, amount: 10, reason: create(:refund_reason, store: store))
    expect(balance.call.to_h).to include(allocated: BigDecimal('50'), paid_out: BigDecimal('50'), available: BigDecimal('0'))
    child.update!(status: 'reversed')
    expect(balance.call.to_h).to include(allocated: BigDecimal('30'), paid_out: BigDecimal('50'), available: BigDecimal('20'))
    b = balance.call.to_h
    expect(b[:received_net]).to eq(b[:available] + b[:allocated] + b[:payout_reserved] + b[:paid_out])
  end

  context 'with goods refunds through the real workflows' do
    include PosReturnHelpers

    let(:store) { create(:store, default_currency: 'VND', supported_currencies: 'VND') }
    let(:branch) { returns_branch(store) }
    let(:manager) { credit_staff(store, branch, PosReturnHelpers::APPROVER) }
    let(:cashier) { credit_staff(store, branch, PosReturnHelpers::RETURNS) }

    def conserved!(funds)
      b = Spree::Pos::FundsBalance.new(funds.reload).to_h
      expect(b.values_at(:available, :allocated, :payout_reserved, :paid_out)).to all(be >= 0)
      expect(b[:received_net]).to eq(b[:available] + b[:allocated] + b[:payout_reserved] + b[:paid_out])
      b
    end

    it 'collection 100k -> allocate A -> refund 40k: reversal is refused and the refunded 40k never comes back' do
      profile = credit_customer(store, manager)
      account = configure_credit(store, manager, branch, profile, limit: 1_000_000)
      product = stocked_product(store, branch, price: 100_000)
      sale = open_sale(store, branch, cashier: cashier, product: product)
      assign(sale, profile)
      complete_on_credit(sale, approve_credit(sale, manager, 100_000)['approval_id'])
      hand_over(sale)
      open_drawer(store, branch, manager)
      collection = Spree::Pos::Collections::Receive.call(
        store: store, staff: manager, key: SecureRandom.uuid, branch_id: branch.prefixed_id, credit_account_id: account.prefixed_id,
        kind: 'bank_manual', amount: '100000', reference: 'FT-COLLECT-1', receiving_account: 'VCB-123',
        allocations: [{ 'order_id' => sale.workspace.order.prefixed_id, 'amount' => '100000' }]
      )
      funds = Spree::Pos::Collection.find_by_prefix_id!(collection['id']).received_funds
      child = funds.allocations.first

      returned = return_and_receive(store, cashier, branch, sale, quantity: 1)
      expect(returned).to include('credit_note_amount' => '0.0', 'refund_entitlement' => '100000.0')
      refund = request_refund(store, cashier, returned, amount: 40_000, allocation: child)
      reverse = lambda do
        Spree::Pos::Collections::Reverse.call(store: store, staff: manager, key: SecureRandom.uuid,
                                              collection_id: collection['id'], allocation_id: child.prefixed_id, reason: 'Nhầm đơn')
      end
      # Reserved (not yet paid) already blocks the reversal.
      expect(&reverse).to raise_error(Spree::Pos::Conflict, /cannot be reversed/)
      expect(conserved!(funds)).to include(allocated: BigDecimal('60000'), payout_reserved: BigDecimal('40000'), available: 0)

      approve_refund(store, manager, refund)
      confirm_refund(store, cashier, refund, reference: 'FT-REFUND-1')
      expect(&reverse).to raise_error(Spree::Pos::Conflict, /cannot be reversed/)
      expect(conserved!(funds)).to include(allocated: BigDecimal('60000'), paid_out: BigDecimal('40000'), available: 0)

      # Retrying the same confirmation consumes nothing more.
      expect(child.reload.consumed).to eq(BigDecimal('40000'))
      expect(Spree::Refund.where(payment_id: child.payment_id).sum(:amount)).to eq(BigDecimal('40000'))
    end

    it 'makes liability payouts, goods refunds and allocations share one parent cap' do
      product = stocked_product(store, branch, price: 100_000)
      sale = open_sale(store, branch, cashier: cashier, product: product)
      method = Spree::Pos::PaymentMethodResolver.new(store: store).available.find { |row| row.kind == 'bank_manual' }
      Spree::Pos::Tenders::Prepare.call(**editing_args(sale), payment_method_id: method.prefixed_id || 'posmethod-bank_manual', amount: '100000')
      attempt = Spree::Pos::TenderAttempt.where(workspace: sale.workspace).last
      # The customer transferred 150k for a 100k sale: 50k stays unapplied.
      Spree::Pos::Tenders::Confirm.call(**editing_args(sale), attempt_id: attempt.prefixed_id, evidence_kind: 'bank_manual',
                                                              reference: 'FT-OVER-1', receiving_account: 'VCB-123', received_amount: '150000')
      Spree::Pos::Workspaces::Complete.call(**editing_args(sale))
      hand_over(sale)
      funds = allocation_of(sale).received_funds
      expect(conserved!(funds)).to include(available: BigDecimal('50000'), allocated: BigDecimal('100000'))

      returned = return_and_receive(store, cashier, branch, sale, quantity: 1)
      refund = request_refund(store, cashier, returned, amount: 100_000, method: 'bank_manual')
      Spree::Pos::LiabilityPayouts::Request.call(store: store, staff: manager, key: SecureRandom.uuid, funds_id: funds.prefixed_id,
                                                 amount: '50000', beneficiary_name: 'Khach', reason: 'Chuyển thừa')
      expect(conserved!(funds)).to include(available: 0, allocated: 0, payout_reserved: BigDecimal('150000'))
      expect do
        Spree::Pos::LiabilityPayouts::Request.call(store: store, staff: manager, key: SecureRandom.uuid, funds_id: funds.prefixed_id,
                                                   amount: '1', beneficiary_name: 'Khach', reason: 'x')
      end.to raise_error(Spree::Pos::Conflict, /available/)
      expect { request_refund(store, cashier, returned, amount: 1) }.to raise_error(Spree::Pos::Conflict)

      Spree::Pos::Refunds::Resolve.call(store: store, staff: cashier, key: SecureRandom.uuid, refund_id: refund['id'], outcome: 'unknown')
      expect(conserved!(funds)).to include(payout_reserved: BigDecimal('150000'))
      confirm_refund(store, manager, refund, reference: 'FT-REFUND-2')
      expect(conserved!(funds)).to include(paid_out: BigDecimal('100000'), payout_reserved: BigDecimal('50000'), available: 0)
    end
  end
end
