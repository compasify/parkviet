# frozen_string_literal: true

RSpec.describe 'POS promotion recalculation qualification' do
  it 'recalculates a coupon discount when a line is removed' do
    cart = create(:cart_with_line_items, line_items_count: 2, line_items_price: 10)
    promotion = create(:promotion_with_order_adjustment, store: cart.store, weighted_order_adjustment_amount: 4)
    cart.update!(coupon_code: promotion.code)
    cart.recalculate_totals!
    expect(cart.reload.discount_total).to eq(-4)

    cart.line_items.last.destroy!
    cart.recalculate_totals!
    expect(cart.reload.line_items.count).to eq(1)
    expect(cart.discount_total).to eq(-4)
    expect(cart.line_items.first.discounts.sum(:amount)).to eq(-4)
  end
end
