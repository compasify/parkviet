# frozen_string_literal: true

require_relative '../../../support/pos_return_helpers'

# Returns on a credit sale: returned value lowers the open debt first through
# a credit note; only the part above the debt becomes refund entitlement, and
# no core Refund is ever created for money that was never received.
RSpec.describe 'POS credit-sale returns', type: :request do
  include PosReturnHelpers

  let(:store) { create(:store, default_currency: 'VND', supported_currencies: 'VND') }
  let(:branch) { returns_branch(store) }
  let(:manager) { credit_staff(store, branch, PosReturnHelpers::APPROVER) }
  let(:cashier) { credit_staff(store, branch, PosReturnHelpers::RETURNS) }
  let(:profile) { credit_customer(store, manager) }

  # Sale 1,000,000 as 5 units of 200,000: cash 300,000 + approved debt 700,000.
  def credit_sale_of_five
    configure_credit(store, manager, branch, profile, limit: 5_000_000)
    product = stocked_product(store, branch, price: 200_000)
    sale = open_sale(store, branch, cashier: cashier, product: product, quantity: 5)
    assign(sale, profile)
    take_tender(sale, 'cash', 300_000)
    approval = approve_credit(sale, manager, 700_000)
    complete_on_credit(sale, approval['approval_id'])
    hand_over(sale)
    sale
  end

  it 'turns a 400k return into a credit note that leaves 300k debt and no refund' do
    sale = credit_sale_of_five
    order = sale.workspace.reload.order
    payment_status = order.payment_status
    expect(receivable_balance(order)).to eq(BigDecimal('700000'))

    result = return_and_receive(store, cashier, branch, sale, quantity: 2)

    expect(result).to include('entitlement_total' => '400000.0', 'credit_note_amount' => '400000.0', 'refund_entitlement' => '0.0')
    expect(receivable_balance(order)).to eq(BigDecimal('300000'))
    expect(Spree::Refund.where(payment_id: order.payments.select(:id))).to be_empty
    expect(order.reload.total).to eq(BigDecimal('1000000'))
    expect(order.line_items.first.price).to eq(BigDecimal('200000'))
    expect(order.payment_status).to eq(payment_status)
    expect { request_refund(store, cashier, result, amount: 1) }.to raise_error(Spree::Pos::Conflict, /exceeds the refund entitlement/)
  end

  it 'clears the debt on a full return and leaves exactly the 300k actually paid as refund entitlement' do
    sale = credit_sale_of_five
    order = sale.workspace.reload.order

    result = return_and_receive(store, cashier, branch, sale, quantity: 5)

    expect(result).to include('entitlement_total' => '1000000.0', 'credit_note_amount' => '700000.0',
                              'refund_entitlement' => '300000.0')
    expect(receivable_balance(order)).to eq(0)
    expect(Spree::Refund.where(payment_id: order.payments.select(:id))).to be_empty
    expect { request_refund(store, cashier, result, amount: 300_001) }.to raise_error(Spree::Pos::Conflict)
    refund = request_refund(store, cashier, result, amount: 300_000)
    expect(refund['status']).to eq('reserved')
  end

  it 'grants credit notes then refund across partial returns and never more than the value returned' do
    sale = credit_sale_of_five
    order = sale.workspace.reload.order
    parts = [3, 2].map { |quantity| return_and_receive(store, cashier, branch, sale, quantity: quantity) }

    expect(parts.map { |part| part['credit_note_amount'] }).to eq(%w[600000.0 100000.0])
    expect(parts.map { |part| part['refund_entitlement'] }).to eq(%w[0.0 300000.0])
    notes = Spree::Pos::ReceivableEntry.where(order_id: order.id, kind: 'credit_note').sum(:amount)
    refunds = Spree::Pos::ReturnOperation.where(order_id: order.id).sum(:refund_entitlement)
    expect(notes + refunds).to eq(BigDecimal('1000000'))
    expect(receivable_balance(order)).to eq(0)
  end

  it 'counts a later collection as paid: full return after 200k collected refunds 500k and credits 500k' do
    sale = credit_sale_of_five
    order = sale.workspace.reload.order
    account = Spree::Pos::CreditAccount.find_by!(customer_profile: profile)
    open_drawer(store, branch, manager)
    Spree::Pos::Collections::Receive.call(
      store: store, staff: manager, key: SecureRandom.uuid, branch_id: branch.prefixed_id, credit_account_id: account.prefixed_id,
      kind: 'cash', amount: '200000', handed_amount: '200000',
      allocations: [{ 'order_id' => order.prefixed_id, 'amount' => '200000' }]
    )
    expect(receivable_balance(order)).to eq(BigDecimal('500000'))

    result = return_and_receive(store, cashier, branch, sale, quantity: 5)
    expect(result).to include('credit_note_amount' => '500000.0', 'refund_entitlement' => '500000.0')
  end

  it 'refuses to reverse a collection that a posted refund entitlement depends on' do
    sale = credit_sale_of_five
    order = sale.workspace.reload.order
    account = Spree::Pos::CreditAccount.find_by!(customer_profile: profile)
    open_drawer(store, branch, manager)
    collection = Spree::Pos::Collections::Receive.call(
      store: store, staff: manager, key: SecureRandom.uuid, branch_id: branch.prefixed_id, credit_account_id: account.prefixed_id,
      kind: 'bank_manual', amount: '700000', reference: 'FT-COLLECT-700', receiving_account: 'VCB-123',
      allocations: [{ 'order_id' => order.prefixed_id, 'amount' => '700000' }]
    )
    returned = return_and_receive(store, cashier, branch, sale, quantity: 5)
    expect(returned).to include('credit_note_amount' => '0.0', 'refund_entitlement' => '1000000.0')

    child = Spree::Pos::Collection.find_by_prefix_id!(collection['id']).allocations.first
    expect do
      Spree::Pos::Collections::Reverse.call(store: store, staff: manager, key: SecureRandom.uuid, collection_id: collection['id'],
                                            allocation_id: child.prefixed_id, reason: 'Nhầm khách')
    end.to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('return_entitlement_depends_on_collection') }
    expect(child.reload.status).to eq('active')
  end

  it 'shows an exchange of a credit sale with the split the return will post, before it is received' do
    sale = credit_sale_of_five
    prepared = prepare_return(store, cashier, branch, sale, quantity: 5)
    register = Spree::Pos::Shift.open_now.find_by!(owner: cashier).register
    exchange = Spree::Pos::Exchanges::Execute.call(store: store, staff: cashier, key: SecureRandom.uuid, return_id: prepared['id'],
                                                   editor_id: SecureRandom.uuid, register_id: register.prefixed_id)
    expect(exchange).to include('credit_note_amount' => '700000.0', 'refund_entitlement' => '300000.0', 'refund_owed' => '300000.0')
  end
end
