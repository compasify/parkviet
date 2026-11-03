# frozen_string_literal: true

RSpec.describe 'POS sale-line identity on the core add-item workflow' do
  it 'characterizes repeated additions of one variant with different prices and lot metadata' do
    cart = create(:cart)
    variant = create(:on_demand_variant)

    first = Spree::Carts::AddItem.call(cart: cart, variant: variant, quantity: 1,
                                      price: '0.4', metadata: { lot: 'lot-a' })
    second = Spree::Carts::AddItem.call(cart: cart, variant: variant, quantity: 1,
                                       price: '0.7', metadata: { lot: 'lot-b' })

    expect(first).to be_success
    expect(second).to be_success
    expect(cart.line_items.reload.size).to eq(1)
    expect(second.value.id).to eq(first.value.id)
    expect(second.value.reload.quantity).to eq(2)
    expect(second.value.price).to eq(BigDecimal('0.7'))
    expect(second.value.metadata).to include('lot' => 'lot-b')
  end
end
