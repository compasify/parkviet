# frozen_string_literal: true

# Spree's `cart_ready_to_complete` factory pays with `Spree::PaymentMethod.first`
# and ships with whichever delivery method already exists. Rows left by other
# specs can make either unusable for the cart ("Payment method is invalid", "Select
# a delivery method"). This one creates a delivery method and pays with a check
# method of its own, for the cart's store.
module PosCheckoutHelpers
  def create_cart_ready_to_complete
    create(:delivery_method)
    cart = create(:cart_ready_for_delivery)
    method = create(:check_payment_method, store: cart.store)
    create(:payment, cart: cart, order: nil, payment_method: method, amount: cart.reload.total)
    cart.reload
  end
end

RSpec.configure { |config| config.include PosCheckoutHelpers }
