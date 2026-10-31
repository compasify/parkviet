# This migration comes from spree (originally 20260922000001)
class AddRefundedOrderToSpreeStoreCredits < ActiveRecord::Migration[8.1]
  def change
    add_reference :spree_store_credits, :refunded_order, index: true
  end
end
