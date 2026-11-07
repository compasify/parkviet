# frozen_string_literal: true

require_relative '../../../support/pos_return_helpers'
require_relative '../../../support/pos_race_helpers'

# Returns and refunds racing over two database connections.
RSpec.describe 'POS return and refund races', type: :integration do
  include PosReturnHelpers

  include_context 'with committed POS race rows'

  before do
    @branch = returns_branch(store)
    @cashier = credit_staff(store, @branch, PosReturnHelpers::RETURNS)
    @manager = credit_staff(store, @branch, PosReturnHelpers::APPROVER)
  end

  it 'never lets two counters return the last returnable unit twice' do
    sale = paid_sale(store, @branch, cashier: @cashier, price: 100_000, quantity: 2)
    return_and_receive(store, @cashier, @branch, sale, quantity: 1)
    line = sale_line(sale)
    staff = [@cashier, @manager]

    results = race(line) do |index|
      prepare_return(store, staff[index], @branch, sale, quantity: 1, line: Spree::Pos::SaleLine.find(line.id))
    end

    expect(results.map(&:first)).to contain_exactly(:success, :conflict)
    expect(results.find { |(kind, _)| kind == :conflict }.last).to include('Only 0 units')
    holding = Spree::Pos::ReturnReservation.where(sale_line_id: line.id).holding
    expect(holding.sum(:quantity)).to eq(2)
    expect(holding.sum(:total)).to eq(BigDecimal('200000'))
    expect(Spree::Return.where(order_id: sale.workspace.order_id).where.not(status: 'canceled').count).to eq(2)
  end

  it 'serializes a refund request and a liability payout on one parent receipt without losing either hold' do
    product = stocked_product(store, @branch, price: 100_000)
    sale = open_sale(store, @branch, cashier: @cashier, product: product)
    method = Spree::Pos::PaymentMethodResolver.new(store: store).available.find { |row| row.kind == 'bank_manual' }
    Spree::Pos::Tenders::Prepare.call(**editing_args(sale), payment_method_id: method.prefixed_id || 'posmethod-bank_manual', amount: '100000')
    attempt = Spree::Pos::TenderAttempt.where(workspace: sale.workspace).last
    Spree::Pos::Tenders::Confirm.call(**editing_args(sale), attempt_id: attempt.prefixed_id, evidence_kind: 'bank_manual',
                                                            reference: "FT-RACE-#{SecureRandom.hex(3)}", receiving_account: 'VCB-123',
                                                            received_amount: '150000')
    Spree::Pos::Workspaces::Complete.call(**editing_args(sale))
    hand_over(sale)
    returned = return_and_receive(store, @cashier, @branch, sale, quantity: 1)
    funds = allocation_of(sale).received_funds

    results = race(funds) do |index|
      if index.zero?
        request_refund(store, @cashier, returned, amount: 100_000, method: 'bank_manual')
      else
        Spree::Pos::LiabilityPayouts::Request.call(store: store, staff: @manager, key: SecureRandom.uuid, funds_id: funds.prefixed_id,
                                                   amount: '50000', beneficiary_name: 'Khach', reason: 'Chuyển thừa')
      end
    end

    expect(results.map(&:first)).to eq(%i[success success])
    balance = Spree::Pos::FundsBalance.new(funds.reload).to_h
    expect(balance).to include(available: 0, allocated: 0, payout_reserved: BigDecimal('150000'), paid_out: 0)
    expect(balance[:received_net]).to eq(balance.values_at(:available, :allocated, :payout_reserved, :paid_out).sum)
  end

  it 'lets only one of two refund requests take the last entitlement of a return' do
    sale = paid_sale(store, @branch, cashier: @cashier, price: 100_000)
    returned = return_and_receive(store, @cashier, @branch, sale, quantity: 1)
    op = operation(returned)

    results = race(op) { request_refund(store, @cashier, returned, amount: 60_000) }

    expect(results.map(&:first)).to contain_exactly(:success, :conflict)
    expect(op.reload.refundable_remaining).to eq(BigDecimal('40000'))
    expect(Spree::Pos::FundsBalance.new(allocation_of(sale).received_funds).payout_reserved).to eq(BigDecimal('60000'))
  end
end
