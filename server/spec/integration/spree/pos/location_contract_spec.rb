# frozen_string_literal: true

RSpec.describe 'POS stock location qualification' do
  it 'considers active locations in the store, not just a POS branch' do
    cart = create(:cart_with_line_items)
    variant = cart.line_items.first.variant
    branch_a = create(:stock_location, store: cart.store, backorderable_default: false)
    branch_b = create(:stock_location, store: cart.store, backorderable_default: false)
    branch_a.stock_level_or_create(variant)
    branch_b.restock(variant, 5)

    coordinator = Spree::Stock::Coordinator.new(cart)
    expect(coordinator.candidate_stock_locations).to include(branch_a, branch_b)
    expect(branch_a.stock_level(variant).count_on_hand).to eq(0)
    expect(branch_b.stock_level(variant).count_on_hand).to eq(5)
  end

  it 'characterizes whether the coordinator falls back when the preferred branch is empty' do
    cart = create(:cart_with_line_items)
    variant = cart.line_items.first.variant
    branch_a = create(:stock_location, store: cart.store, backorderable_default: false)
    branch_b = create(:stock_location, store: cart.store, backorderable_default: false)
    branch_a.stock_level_or_create(variant)
    branch_b.restock(variant, 5)
    cart.update!(preferred_stock_location: branch_a)

    packages = Spree::Stock::Coordinator.new(cart).allocated_packages([branch_a, branch_b])
    expect(packages.map(&:stock_location)).to include(branch_b)
  end

  it 'does not reserve the same last unit twice in sequential cart checkouts' do
    cart_a = create(:cart)
    cart_b = create(:cart, store: cart_a.store)
    variant = create(:product, store: cart_a.store).default_variant
    location = create(:stock_location, store: cart_a.store, backorderable_default: false)
    location.restock(variant, 1)
    create(:line_item, cart: cart_a, variant: variant, quantity: 1)
    create(:line_item, cart: cart_b, variant: variant, quantity: 1)

    first = Spree::StockReservations::Reserve.call(cart: cart_a)
    second = Spree::StockReservations::Reserve.call(cart: cart_b)

    expect(first).to be_success
    expect(second).not_to be_success
    expect(location.stock_level(variant).reload.reserved_count).to eq(1)
  end

  it 'characterizes two staff drafts allocating the same last unit sequentially' do
    store = Spree::Store.default
    variant = create(:product, store: store).default_variant
    location = create(:stock_location, store: store, backorderable_default: false)
    location.restock(variant, 1)
    orders = 2.times.map do
      order = create(:order, store: store)
      create(:line_item, order: order, variant: variant, quantity: 1)
      create(:fulfillment, order: order, stock_location: location, tracking: nil)
      order.reload
    end

    # This intentionally bypasses payment to isolate allocation behavior.
    # It does not authorize or qualify selling on credit.
    results = orders.map do |order|
      Spree.order_complete_workflow.call(order: order, payment_pending: true, notify_customer: false)
    end

    expect(results.map(&:success?)).to eq([true, true])
    level = location.stock_level(variant).reload
    expect(level.count_on_hand).to eq(1)
    expect(level.allocated_count).to eq(2)
  end

  it 'sees reservations held by the other owner in the core reservation helper' do
    store = Spree::Store.default
    variant = create(:product, store: store).default_variant
    location = create(:stock_location, store: store, backorderable_default: false)
    location.restock(variant, 2)
    level = location.stock_level(variant)
    order = create(:order, store: store)
    cart = create(:cart, store: store)
    order_item = create(:line_item, order: order, variant: variant)
    cart_item = create(:line_item, cart: cart, variant: variant)
    create(:stock_reservation, order: order, stock_level: level, line_item: order_item)
    create(:stock_reservation, cart: cart, stock_level: level, line_item: cart_item)

    expect(Spree::StockReservation.active.where(stock_level: level).sum(:quantity)).to eq(2)
    reserve = Spree::StockReservations::Reserve.new
    expect(reserve.send(:held_by_others, [level.id], cart)).to eq(level.id => 1)
    expect(reserve.send(:held_by_others, [level.id], order)).to eq(level.id => 1)
  end

  it 'refuses a draft reservation once a cart holds the only unit' do
    store = Spree::Store.default
    variant = create(:product, store: store).default_variant
    location = create(:stock_location, store: store, backorderable_default: false)
    location.restock(variant, 1)
    cart = create(:cart, store: store)
    order = create(:order, store: store)
    create(:line_item, cart: cart, variant: variant, quantity: 1)
    create(:line_item, order: order, variant: variant, quantity: 1)

    first = Spree::StockReservations::Reserve.call(cart: cart)
    expect(first).to be_success
    expect(location.stock_level(variant).reload.reserved_count).to eq(1)
    second = Spree::StockReservations::Reserve.call(order: order)

    expect(second).not_to be_success
    expect(location.stock_level(variant).reload.reserved_count).to eq(1)
  end

  it 'refuses a cart reservation once a draft holds the only unit' do
    store = Spree::Store.default
    variant = create(:product, store: store).default_variant
    location = create(:stock_location, store: store, backorderable_default: false)
    location.restock(variant, 1)
    cart = create(:cart, store: store)
    order = create(:order, store: store)
    create(:line_item, cart: cart, variant: variant, quantity: 1)
    create(:line_item, order: order, variant: variant, quantity: 1)

    first = Spree::StockReservations::Reserve.call(order: order)
    expect(first).to be_success
    expect(location.stock_level(variant).reload.reserved_count).to eq(1)
    second = Spree::StockReservations::Reserve.call(cart: cart)

    expect(second).not_to be_success
    expect(location.stock_level(variant).reload.reserved_count).to eq(1)
  end
end
