# frozen_string_literal: true

require_relative '../../../support/pos_checkout_helpers'

RSpec.describe 'POS core checkout qualification' do
  it 'reports missing customer email and items for an empty cart' do
    cart = create(:cart, email: nil)

    requirements = Spree::Checkout::Requirements.new(cart).call(completion: true)
    codes = requirements.map { |requirement| requirement[:code].to_s }

    expect(codes).to include('email_required', 'line_items_required')
  end

  it 'does not create an order when an empty cart is completed' do
    cart = create(:cart, email: nil)

    result = Spree.carts_complete_workflow.call(cart: cart)

    expect(result).not_to be_success
    expect(cart.reload.order).to be_nil
    expect(cart.completed_at).to be_nil
  end

  it 'refuses a prepared checkout without an email instead of creating an order' do
    cart = create_cart_ready_to_complete
    cart.update!(email: nil)

    requirements = Spree::Checkout::Requirements.new(cart).call(completion: true)
    expect(requirements.map { |requirement| requirement[:code].to_s }).to include('email_required')

    result = Spree.carts_complete_workflow.call(cart: cart)
    expect(result).not_to be_success
    expect(cart.reload.order).to be_nil
  end

  it 'places and replays the same order for a fully prepared test checkout' do
    cart = create_cart_ready_to_complete

    first = Spree.carts_complete_workflow.call(cart: cart)
    expect(first).to be_success
    expect(first.value).to be_placed

    retry_result = Spree.carts_complete_workflow.call(cart: cart.reload)
    expect(retry_result).to be_success
    expect(retry_result.value.id).to eq(first.value.id)
    expect(Spree::Order.where(cart_id: cart.id).count).to eq(1)
  end

  it 'rejects placing a staff draft without email even when payment is pending' do
    order = create(:order_with_totals, customer: nil, email: nil, bill_address: nil)
    order.recalculate_totals!

    expect do
      Spree.order_complete_workflow.call(order: order, payment_pending: true, notify_customer: false)
    end.to raise_error(ActiveRecord::RecordInvalid, /Email can't be blank/)

    expect(order.reload).to be_draft
    expect(order.payments).to be_empty
  end
end
