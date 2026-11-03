# frozen_string_literal: true

RSpec.describe 'POS pickup qualification' do
  it 'characterizes an email-free staff draft with a pickup fulfillment and test payment' do
    store = Spree::Store.default
    variant = create(:product, store: store).default_variant
    location = create(:stock_location, store: store, pickup_enabled: true, backorderable_default: false)
    location.restock(variant, 1)
    order = create(:order, store: store, customer: nil, email: nil, bill_address: nil, ship_address: nil)
    create(:line_item, order: order, variant: variant, quantity: 1)
    Pos::WalkInOrder.create!(order: order)
    fulfillment = create(:fulfillment, order: order, stock_location: location, cost: 0, tracking: nil)
    pickup = create(:pickup_delivery_method, store: store)
    rate = fulfillment.add_delivery_method(pickup)
    fulfillment.selected_shipping_rate_id = rate.id
    order.reload.recalculate_totals!
    expect(order.total).to be > 0
    method = create(:check_payment_method, store: store)
    create(:payment, order: order, payment_method: method, amount: order.total)

    result = Spree.order_complete_workflow.call(order: order.reload, notify_customer: false)

    expect(result).to be_success
    expect(order.reload).to be_placed
    expect(order.email).to be_nil
    expect(order.ship_address).to be_nil
    expect(order.payments.completed.sum(:amount)).to eq(order.total)
    expect(fulfillment.reload.provider).to be_a(Spree::FulfillmentProvider::Pickup)
    expect(location.stock_level(variant).reload.allocated_count).to eq(1)

    replay = Spree.order_complete_workflow.call(order: order.reload, notify_customer: false)
    expect(replay).to be_success
    expect(order.payments.completed.count).to eq(1)
    expect(order.payments.completed.sum(:amount)).to eq(order.total)
    expect(location.stock_level(variant).reload.allocated_count).to eq(1)

    handover = Spree.fulfillment_fulfill_workflow.call(fulfillment: fulfillment, notify_customer: false)
    expect(handover).to be_success
    expect(fulfillment.reload).to be_fulfilled
    expect(location.stock_level(variant).reload.count_on_hand).to eq(0)
    expect(location.stock_level(variant).allocated_count).to eq(0)

    repeat = Spree.fulfillment_fulfill_workflow.call(fulfillment: fulfillment.reload, notify_customer: false)
    expect(repeat).not_to be_success
    expect(location.stock_level(variant).reload.count_on_hand).to eq(0)
  end

  it 'refuses handover of an unpaid draft placed for the test' do
    store = Spree::Store.default
    variant = create(:product, store: store).default_variant
    location = create(:stock_location, store: store, pickup_enabled: true, backorderable_default: false)
    location.restock(variant, 1)
    order = create(:order, store: store)
    create(:line_item, order: order, variant: variant, quantity: 1)
    fulfillment = create(:fulfillment, order: order, stock_location: location, cost: 0, tracking: nil)
    rate = fulfillment.add_delivery_method(create(:pickup_delivery_method, store: store))
    fulfillment.selected_shipping_rate_id = rate.id
    order.reload.recalculate_totals!
    expect(order.total).to be > 0

    # Isolates the handover guard; this is not approval to sell on credit.
    placed = Spree.order_complete_workflow.call(order: order.reload, payment_pending: true, notify_customer: false)
    expect(placed).to be_success
    handover = Spree.fulfillment_fulfill_workflow.call(fulfillment: fulfillment.reload, notify_customer: false)

    expect(handover).not_to be_success
    expect(fulfillment.reload).not_to be_fulfilled
    expect(location.stock_level(variant).reload.count_on_hand).to eq(1)
  end
end
