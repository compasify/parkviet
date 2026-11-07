# frozen_string_literal: true

module Spree
  module Pos
    # After-commit check of core stock movements on tracked pairs. The guard
    # that stops unsupported writers runs inside the transaction (see
    # StockIntegration); this subscriber only detects drift that slipped past
    # it and raises attention, so it may run asynchronously.
    class StockTraceabilitySubscriber < Spree::Subscriber
      subscribes_to 'stock_movement.created'

      on 'stock_movement.created', :check

      def check(event)
        movement = find_movement(event.payload)
        level = movement&.stock_level
        return if level.nil?

        enrollment = TraceEnrollment.find_by(variant_id: level.variant_id, stock_location_id: level.stock_location_id)
        StockIntegration.check_drift!(enrollment) if enrollment
      end

      private

      def find_movement(payload)
        id = payload['id'] || payload[:id]
        return nil if id.blank?

        Spree::StockMovement.find_by_prefix_id(id.to_s) || Spree::StockMovement.find_by(id: id)
      end
    end
  end
end
