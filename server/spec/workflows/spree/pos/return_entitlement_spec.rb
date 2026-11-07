# frozen_string_literal: true

require_relative '../../../support/pos_return_helpers'

# Cumulative entitlement per immutable SaleLine: returns earn the delta of
# E(after) - E(before), so several partial returns add up to exactly the
# original value, and canceled or concurrent reservations never grant twice.
RSpec.describe 'POS return entitlement', type: :request do
  include PosReturnHelpers

  let(:store) { create(:store, default_currency: 'VND', supported_currencies: 'VND') }
  let(:branch) { returns_branch(store) }
  let(:cashier) { credit_staff(store, branch, PosReturnHelpers::RETURNS) }

  def totals(result)
    operation(result).reservations.map(&:total).sum
  end

  it 'gives back exactly 2 VND for 5 units at 0.4 VND returned as 1 + 1 + 3' do
    sale = paid_sale(store, branch, cashier: cashier, price: '0.4', quantity: 5)
    expect(sale.workspace.order.total).to eq(BigDecimal('2'))

    first = return_and_receive(store, cashier, branch, sale, quantity: 1)
    second = return_and_receive(store, cashier, branch, sale, quantity: 1)
    third = return_and_receive(store, cashier, branch, sale, quantity: 3)

    granted = [first, second, third].map { |result| BigDecimal(result['entitlement_total']) }
    expect(granted).to eq([BigDecimal('0'), BigDecimal('1'), BigDecimal('1')])
    expect(granted.sum).to eq(BigDecimal('2'))
    expect(granted.sum).to eq(sale.workspace.order.total)
    expect(Spree::Pos::ReturnReservation.where(sale_line_id: sale_line(sale).id).sum(:quantity)).to eq(5)
    expect { prepare_return(store, cashier, branch, sale, quantity: 1) }.to raise_error(Spree::Pos::Conflict, /Only 0 units/)
  end

  it 'keeps price, discount and tax components reconciled with the total for every partial return' do
    product = stocked_product(store, branch, price: 33_333)
    sale = open_sale(store, branch, cashier: cashier, product: product, quantity: 3)
    line = sale_line(sale)
    Spree::Pos::Workspaces::ApplyLineDiscount.call(**editing_args(sale), sale_line_id: line.prefixed_id,
                                                                         value_type: 'flat', value: '1000', reason: 'Khách quen')
    complete_paid(sale)
    hand_over(sale)
    order = sale.workspace.reload.order
    original = Spree::Pos::ReturnEntitlement.new(order).original(line.line_item)
    expect(original.total).to eq(order.total)
    expect(original.gross - original.discount).to eq(original.net)
    expect(original.discount).to eq(BigDecimal('1000'))

    results = [1, 1, 1].map { return_and_receive(store, cashier, branch, sale, quantity: 1) }
    rows = results.flat_map { |result| operation(result).reservations.to_a }
    rows.each do |row|
      expect(row.total).to eq(row.net + row.tax)
      expect(row.gross - row.discount).to eq(row.net)
      expect([row.total, row.net, row.tax, row.discount, row.gross]).to all(be >= 0)
    end
    expect(rows.sum(&:total)).to eq(order.total)
    expect(rows.sum(&:discount)).to eq(original.discount)
    expect(rows.sum(&:gross)).to eq(original.gross)
  end

  it 're-prices a later unposted reservation when an earlier one is canceled, so nothing is granted twice' do
    sale = paid_sale(store, branch, cashier: cashier, price: '0.4', quantity: 5)
    first = prepare_return(store, cashier, branch, sale, quantity: 2)
    second = prepare_return(store, cashier, branch, sale, quantity: 3)
    expect([first, second].map { |result| BigDecimal(result['entitlement_total']) }).to eq([BigDecimal('1'), BigDecimal('1')])

    # The second waits for the first: it is received but not posted.
    receive_return(store, cashier, second)
    expect(operation(second).entitlement_status).to eq('awaiting_predecessor')

    Spree::Pos::Returns::Cancel.call(store: store, staff: cashier, key: SecureRandom.uuid, return_id: first['id'], reason: 'Nhầm')
    second_op = operation(second).reload
    expect(second_op.entitlement_status).to eq('posted')
    expect(second_op.entitlement_total).to eq(BigDecimal('1'))
    expect(second_op.reservations.first.cumulative_before).to eq(0)
    expect(second_op.revision).to eq(2)

    rest = return_and_receive(store, cashier, branch, sale, quantity: 2)
    expect(BigDecimal(rest['entitlement_total'])).to eq(BigDecimal('1'))
    posted = Spree::Pos::ReturnReservation.where(sale_line_id: sale_line(sale).id, status: 'posted').sum(:total)
    expect(posted).to eq(BigDecimal('2'))
  end

  it 'refuses to cancel a reservation whose later dependent is already posted' do
    sale = paid_sale(store, branch, cashier: cashier, price: 10_000, quantity: 2)
    first = prepare_return(store, cashier, branch, sale, quantity: 1)
    second = prepare_return(store, cashier, branch, sale, quantity: 1)
    receive_return(store, cashier, first)
    receive_return(store, cashier, second)
    expect(operation(second).entitlement_status).to eq('posted')

    expect do
      Spree::Pos::Returns::Cancel.call(store: store, staff: cashier, key: SecureRandom.uuid, return_id: first['id'], reason: 'x')
    end.to raise_error(Spree::Pos::Conflict, /already received|not received/)

    third_sale = paid_sale(store, branch, cashier: cashier, price: 10_000, quantity: 2)
    pending = prepare_return(store, cashier, branch, third_sale, quantity: 1)
    later = prepare_return(store, cashier, branch, third_sale, quantity: 1)
    # Post the later one by hand-forcing its predecessor out of the way is not
    # possible; instead show that a posted later row blocks the cancel.
    operation(later).reservations.first.update!(status: 'posted')
    expect do
      Spree::Pos::Returns::Cancel.call(store: store, staff: cashier, key: SecureRandom.uuid, return_id: pending['id'], reason: 'x')
    end.to raise_error(Spree::Pos::Conflict, /already posted/)
  end

  it 'previews the same split the return will post, without writing anything' do
    sale = paid_sale(store, branch, cashier: cashier, price: '0.4', quantity: 5)
    return_and_receive(store, cashier, branch, sale, quantity: 1)
    preview = Spree::Pos::Returns::Prepare.preview(
      store: store, staff: cashier, branch_id: branch.prefixed_id, order_id: sale.workspace.order.prefixed_id,
      lines: [{ 'sale_line_id' => sale_line(sale).prefixed_id, 'quantity' => 1 }]
    )
    line = preview[:lines].first
    expect(line).to include(cumulative_before: 1, cumulative_after: 2, used: '0.0', sold_quantity: 5)
    expect(line[:this_time]).to include(total: '1.0')
    expect(preview).to include(entitlement_total: '1.0', credit_note: '0.0', refund: '1.0')
    expect(Spree::Pos::ReturnOperation.count).to eq(1)
  end
end
