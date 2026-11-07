# frozen_string_literal: true

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
end
