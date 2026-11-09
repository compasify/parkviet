# frozen_string_literal: true

# Where a neighbourhood order is delivered, written the way the seller says
# it ("1205 S1.02, treo tay nắm cửa"): one free-text line.
class AddAddressToSpreePosCustomers < ActiveRecord::Migration[8.1]
  def change
    add_column :spree_pos_customers, :address, :string, limit: 255
  end
end
