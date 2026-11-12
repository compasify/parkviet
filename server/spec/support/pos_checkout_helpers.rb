# frozen_string_literal: true

# Spree's `cart_ready_to_complete` factory pays with `Spree::PaymentMethod.first`,
# which can belong to another store and is then refused as "invalid". This one
# pays with a method of the cart's own store.
module PosCheckoutHelpers
  def create_cart_ready_to_complete
    cart = create(:cart_ready_for_delivery)
    method = Spree::PaymentMethod.find_by(store_id: cart.store_id) || create(:check_payment_method, store: cart.store)
    create(:payment, cart: cart, order: nil, payment_method: method, amount: cart.reload.total)
    cart.reload
  end
end

RSpec.configure { |config| config.include PosCheckoutHelpers }
