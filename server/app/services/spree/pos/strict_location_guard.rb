# frozen_string_literal: true

module Spree
  module Pos
    # True only when every fulfillment belongs to the branch stock location.
    # Used before placement (which allocates stock) and before handover.
    class StrictLocationGuard
      def self.call(order:, branch:)
        location_id = branch.stock_location_id
        fulfillments = order.fulfillments.to_a
        return false if fulfillments.empty?

        fulfillments.all? { |fulfillment| fulfillment.stock_location_id == location_id }
      end
    end
  end
end
