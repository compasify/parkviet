# frozen_string_literal: true

require_relative '../../../support/pos_checkout_helpers'

RSpec.describe 'POS sandbox payment qualification' do
  it 'does not place a cart when the test payment covers only half the total' do
    cart = create_cart_ready_to_complete
    expect(cart.total).to be > 0
    cart.payments.first.update!(amount: cart.total / 2)

    result = Spree.carts_complete_workflow.call(cart: cart)
    expect(result).not_to be_success
    expect(cart.reload.order).to be_nil
    expect(cart.completed_at).to be_nil
  end

  it 'invalidates the previous checkout payment when another test payment is created' do
    cart = create_cart_ready_to_complete
    payment = cart.payments.first
    first_amount = (cart.total / 2).round(2)
    payment.update!(amount: first_amount)
    create(:payment, cart: cart, order: nil, payment_method: payment.payment_method,
           amount: cart.total - first_amount)

    expect(payment.reload.status).to eq('invalid')
    expect(cart.reload.payments.valid.sum(:amount)).to eq(cart.total - first_amount)
    result = Spree.carts_complete_workflow.call(cart: cart.reload)
    expect(result).not_to be_success
    expect(cart.reload.order).to be_nil
  end

  it 'characterizes whether a pending payment is enough for a staff draft to be placed' do
    order = create(:order_with_totals)
    order.recalculate_totals!
    expect(order.total).to be > 0
    method = create(:check_payment_method, store: order.store)
    payment = create(:payment, order: order, payment_method: method, amount: order.total, status: 'pending')

    result = Spree.order_complete_workflow.call(order: order.reload, notify_customer: false)

    expect(result).to be_success
    expect(order.reload).to be_placed
    expect(payment.reload.status).to eq('pending')
    expect(order.payments.completed.sum(:amount)).to eq(0)
  end
end
