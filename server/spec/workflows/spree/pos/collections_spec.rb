# frozen_string_literal: true

require_relative '../../../support/pos_credit_helpers'

# Debt collection: one actual receipt, bounded child allocations to debtor
# orders, no new sale or stock effect, and a receivable projection that comes
# from the ledger rather than core payment status.
RSpec.describe 'POS debt collections', type: :request do
  include PosCreditHelpers

  let(:store) { create(:store, default_currency: 'VND', supported_currencies: 'VND') }
  let(:branch) { credit_branch(store) }
  let(:manager) { credit_staff(store, branch, PosCreditHelpers::MANAGER) }
  let(:profile) { credit_customer(store, manager) }
  let!(:account) { configure_credit(store, manager, branch, profile, limit: 5_000_000, due_days: 7) }

  def sold_on_credit(price, paid: 0)
    sale = credit_sale(store, branch, price: price)
    assign(sale, profile)
    take_tender(sale, 'cash', paid) if paid.positive?
    approval = approve_credit(sale, manager, price - paid)
    complete_on_credit(sale, approval['approval_id'])
    sale.workspace.reload
  end

  def collect(amount, allocations, kind: 'cash', handed: nil, staff: manager)
    evidence = kind == 'cash' ? { handed_amount: (handed || amount).to_s } : { reference: "FT#{SecureRandom.hex(3)}", receiving_account: 'VCB-123' }
    Spree::Pos::Collections::Receive.call(
      store: store, staff: staff, key: SecureRandom.uuid, branch_id: branch.prefixed_id,
      credit_account_id: account.prefixed_id, kind: kind, amount: amount.to_s,
      allocations: allocations.map { |(order, value)| { 'order_id' => order.prefixed_id, 'amount' => value.to_s } },
      **evidence
    )
  end

  def projection
    Spree::Pos::ReceivableProjection.new(Spree::Pos::ReceivableEntry.where(branch_id: branch.id),
                                         today: Time.now.in_time_zone(branch.timezone).to_date)
  end

  before { open_drawer(store, branch, manager) }

  it 'collects 300k then 200k on a 1m credit sale leaving 500k, with no new sale or stock movement' do
    workspace = sold_on_credit(1_000_000)
    order = workspace.order
    level = branch.stock_location.stock_level(workspace.order.line_items.first.variant)
    stock_before = [level.reload.count_on_hand, level.allocated_count]
    item_total = order.item_total

    collect(300_000, [[order, 300_000]], handed: 500_000)
    collect(200_000, [[order, 200_000]], kind: 'bank_manual')

    expect(receivable_balance(order)).to eq(BigDecimal('500000'))
    expect(order.reload.payments.where(status: 'completed').sum(:amount)).to eq(BigDecimal('500000'))
    expect(order.payment_status).to eq('partially_paid')
    expect(order.item_total).to eq(item_total)
    expect([level.reload.count_on_hand, level.allocated_count]).to eq(stock_before)
    expect(Spree::Order.where(store_id: store.id).complete.count).to eq(1)

    shift = Spree::Pos::Shift.find_by!(owner: manager, status: 'open')
    cash = Spree::Pos::ReceivedFunds.find_by!(shift: shift, kind: 'cash')
    expect(cash).to have_attributes(handed_amount: BigDecimal('500000'), change_amount: BigDecimal('200000'), received_net: BigDecimal('300000'))
    expect(Spree::Pos::CashMovement.where(shift: shift).sum(:amount)).to eq(BigDecimal('300000'))

    row = projection.order_rows(status: 'open').to_a.sole
    expect([row.debt, row.collected, row.balance].map do |value|
      BigDecimal(value.to_s)
    end).to eq([BigDecimal('1000000'), BigDecimal('500000'), BigDecimal('500000')])
    expect(account.reload.exposure.open_debt).to eq(BigDecimal('500000'))
  end

  it 'allocates one receipt across several orders, never beyond the receipt or a debt, and keeps the rest available' do
    first = sold_on_credit(400_000).order
    second = sold_on_credit(300_000).order

    expect { collect(500_000, [[first, 400_000], [second, 200_000]]) }.to raise_error(Spree::Pos::Conflict, /available/)
    expect { collect(600_000, [[first, 500_000]]) }.to raise_error(Spree::Pos::Conflict, /open debt/)
    expect(Spree::Pos::ReceivedFunds.count).to eq(0)

    result = collect(600_000, [[first, 400_000], [second, 100_000]])
    funds = Spree::Pos::ReceivedFunds.find_by_prefix_id!(result['funds']['id'])
    expect(funds.allocations.sum(:amount)).to eq(BigDecimal('500000'))
    expect(funds.balance.available).to eq(BigDecimal('100000'))
    expect(receivable_balance(first)).to eq(0)
    expect(receivable_balance(second)).to eq(BigDecimal('200000'))
    expect(first.reload.payment_status).to eq('paid')

    # The remainder is allocated later from the same parent, bounded again.
    collection_id = result['id']
    expect do
      Spree::Pos::Collections::Allocate.call(store: store, staff: manager, key: SecureRandom.uuid, collection_id: collection_id,
                                             allocations: [{ 'order_id' => second.prefixed_id, 'amount' => '150000' }])
    end.to raise_error(Spree::Pos::Conflict, /available/)
    Spree::Pos::Collections::Allocate.call(store: store, staff: manager, key: SecureRandom.uuid, collection_id: collection_id,
                                           allocations: [{ 'order_id' => second.prefixed_id, 'amount' => '100000' }])
    expect(funds.reload.balance.available).to eq(0)
    expect(receivable_balance(second)).to eq(BigDecimal('100000'))
  end

  it 'reverses an unconsumed child back to available, and refuses to revive refunded money' do
    first = sold_on_credit(100_000).order
    second = sold_on_credit(100_000).order
    result = collect(100_000, [[first, 100_000]], kind: 'bank_manual')
    funds = Spree::Pos::ReceivedFunds.find_by_prefix_id!(result['funds']['id'])
    allocation = funds.allocations.sole

    create(:refund, payment: allocation.payment, amount: 40_000, reason: create(:refund_reason, store: store))
    expect(funds.reload.balance.to_h).to include(allocated: BigDecimal('60000'), paid_out: BigDecimal('40000'), available: 0)
    expect do
      Spree::Pos::Collections::Reverse.call(store: store, staff: manager, key: SecureRandom.uuid, collection_id: result['id'],
                                            allocation_id: allocation.prefixed_id, reason: 'Nham don')
    end.to raise_error(Spree::Pos::Conflict, /refunded/)
    expect(allocation.reload.status).to eq('active')

    other = collect(100_000, [[second, 100_000]], kind: 'bank_manual')
    child = Spree::Pos::FundsAllocation.find_by_prefix_id!(other['allocations'].first['id'])
    key = SecureRandom.uuid
    2.times do
      Spree::Pos::Collections::Reverse.call(store: store, staff: manager, key: key, collection_id: other['id'],
                                            allocation_id: child.prefixed_id, reason: 'Nham don')
    end
    expect(child.reload.status).to eq('reversed')
    expect(child.payment.reload.status).to eq('void')
    expect(receivable_balance(second)).to eq(BigDecimal('100000'))
    expect(child.received_funds.balance.available).to eq(BigDecimal('100000'))
    expect(Spree::Pos::ReceivableEntry.where(kind: 'collection_reversal').count).to eq(1)
  end

  it 'never lets a refunded part come back: whole reversal is refused and nothing is left to reallocate' do
    first = sold_on_credit(100_000).order
    second = sold_on_credit(100_000).order
    result = collect(100_000, [[first, 100_000]], kind: 'bank_manual')
    funds = Spree::Pos::ReceivedFunds.find_by_prefix_id!(result['funds']['id'])
    allocation = funds.allocations.sole
    create(:refund, payment: allocation.payment, amount: 40_000, reason: create(:refund_reason, store: store))

    expect do
      Spree::Pos::Collections::Reverse.call(store: store, staff: manager, key: SecureRandom.uuid, collection_id: result['id'],
                                            allocation_id: allocation.prefixed_id, reason: 'Nhầm đơn')
    end.to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('allocation_consumed') }
    # Core has no way to shrink a completed Payment, so the unrefunded 60k
    # stays applied to the first order rather than being moved by a fake
    # adjustment; the receipt has nothing available for the second order.
    expect(funds.reload.balance.to_h).to include(allocated: BigDecimal('60000'), paid_out: BigDecimal('40000'), available: 0)
    expect do
      Spree::Pos::Collections::Allocate.call(store: store, staff: manager, key: SecureRandom.uuid, collection_id: result['id'],
                                             allocations: [{ 'order_id' => second.prefixed_id, 'amount' => '60000' }])
    end.to raise_error(Spree::Pos::Conflict, /available/)
    expect(receivable_balance(second)).to eq(BigDecimal('100000'))
  end

  it 'keeps a shared collection receipt out of each order sale summary' do
    first = sold_on_credit(300_000)
    second = sold_on_credit(200_000)
    collect(500_000, [[first.order, 300_000], [second.order, 200_000]])

    [first, second].each do |workspace|
      financial = workspace.reload.financial_pos
      expect(financial).to include(received: '0.0', allocated: '0.0', unapplied: '0.0')
      expect(financial[:credit]).to include(balance: '0.0')
    end
    expect(Spree::Pos::ReceivedFunds.sole.workspace_id).to be_nil
  end

  it 'lets the collector place leftover money during their own open shift, otherwise only a resolver' do
    order = sold_on_credit(300_000).order
    collector = credit_staff(store, branch, PosCreditHelpers::CASHIER)
    open_drawer(store, branch, collector)
    result = collect(300_000, [[order, 100_000]], staff: collector)
    allocate = lambda do |staff|
      Spree::Pos::Collections::Allocate.call(store: store, staff: staff, key: SecureRandom.uuid, collection_id: result['id'],
                                             allocations: [{ 'order_id' => order.prefixed_id, 'amount' => '50000' }])
    end

    other = credit_staff(store, branch, PosCreditHelpers::CASHIER)
    expect { allocate.call(other) }.to raise_error(CanCan::AccessDenied)
    allocate.call(collector)
    Spree::Pos::Shift.find_by!(owner: collector, status: 'open').update_columns(status: 'closed')
    expect { allocate.call(collector) }.to raise_error(CanCan::AccessDenied)
    allocate.call(manager)
    expect(receivable_balance(order)).to eq(BigDecimal('100000'))
  end

  it 'collects at another branch for a debt sold elsewhere, posting cash to the collector shift' do
    order = sold_on_credit(200_000).order
    elsewhere = credit_branch(store)
    collector = credit_staff(store, elsewhere, PosCreditHelpers::CASHIER)
    shift_register = open_drawer(store, elsewhere, collector)
    Spree::Pos::Collections::Receive.call(
      store: store, staff: collector, key: SecureRandom.uuid, branch_id: elsewhere.prefixed_id,
      credit_account_id: account.prefixed_id, kind: 'cash', amount: '200000', handed_amount: '200000',
      allocations: [{ 'order_id' => order.prefixed_id, 'amount' => '200000' }]
    )
    expect(receivable_balance(order)).to eq(0)
    expect(Spree::Pos::CashMovement.where(register: shift_register).sum(:amount)).to eq(BigDecimal('200000'))
  end

  it 'refuses a bank reference already recorded unless a resolver confirms it on purpose' do
    order = sold_on_credit(300_000).order
    evidence = { reference: 'FT-DUP', receiving_account: 'VCB-123' }
    receive = lambda do |staff, **extra|
      Spree::Pos::Collections::Receive.call(store: store, staff: staff, key: SecureRandom.uuid, branch_id: branch.prefixed_id,
                                            credit_account_id: account.prefixed_id, kind: 'bank_manual', amount: '100000',
                                            allocations: [{ 'order_id' => order.prefixed_id, 'amount' => '100000' }],
                                            **evidence.merge(extra))
    end
    receive.call(manager)
    collector = credit_staff(store, branch, PosCreditHelpers::CASHIER)
    open_drawer(store, branch, collector)

    expect { receive.call(collector, confirm_duplicate: true) }.to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('duplicate_reference') }
    expect { receive.call(manager) }.to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('duplicate_reference') }
    receive.call(manager, confirm_duplicate: true, reference: ' ft-dup ')
    expect(Spree::Pos::ReceivedFunds.count).to eq(2)
    expect(Spree::Pos::AuditEntry.where(action: 'funds.duplicate_reference_confirmed').count).to eq(1)
  end

  it 'projects credit notes from the ledger while core amount_due is unaware of them' do
    order = sold_on_credit(1_000_000, paid: 300_000).order
    source = Spree::Pos::AuditEntry.create!(store: store, actor: manager, action: 'return.authorized', subject_type: 'Spree::Order',
                                            subject_id: order.id)

    Spree::Pos::ReceivableEntry.post_credit_note!(order: order, amount: '400000', source: source, actor: manager)
    Spree::Pos::ReceivableEntry.post_credit_note!(order: order, amount: '400000', source: source, actor: manager)
    expect(receivable_balance(order)).to eq(BigDecimal('300000'))
    expect(order.reload.outstanding_balance).not_to eq(receivable_balance(order))

    other = Spree::Pos::AuditEntry.create!(store: store, actor: manager, action: 'return.authorized', subject_type: 'Spree::Order',
                                           subject_id: order.id)
    expect do
      Spree::Pos::ReceivableEntry.post_credit_note!(order: order, amount: '300001', source: other, actor: manager)
    end.to raise_error(Spree::Pos::Conflict, /exceeds/)

    rows = projection.order_rows(status: 'all').to_a
    expect(rows.size).to eq(1)
    expect(BigDecimal(rows.first.credit_notes.to_s)).to eq(BigDecimal('400000'))
    expect(projection.summary(rows)).to include('balance' => '300000.0', 'overdue' => '0.0', 'current' => '300000.0')

    later = Spree::Pos::ReceivableProjection.new(Spree::Pos::ReceivableEntry.where(branch_id: branch.id), today: Date.current + 40)
    later_rows = later.order_rows(status: 'overdue').to_a
    expect(later_rows.size).to eq(1)
    expect(later.summary(later_rows)).to include('overdue' => '300000.0', 'days_31_60' => '300000.0')
  end
end
