# frozen_string_literal: true

module Spree
  module Pos
    # Spree workflow hook (validate) for website and dashboard carts/orders:
    # a variant tracked by serial or lot at a stock location the cart's
    # channel can ship from is refused when it is added and again before
    # checkout completes, i.e. before any payment is taken. Those units can
    # only be sold through the POS, which allocates the serials and lots.
    # The stock movement guard remains the backstop at placement.
    class TraceCheckoutGuard
      MESSAGE = 'This item is tracked by serial or lot and can only be sold at the counter.'

      def call(workflow)
        record = cart_of(workflow)
        variants = workflow.respond_to?(:variant) && workflow.variant ? [workflow.variant] : record&.line_items&.map(&:variant).to_a
        return if variants.empty?

        refused = variants.compact.find { |variant| enrolled_for?(variant, record) }
        return unless refused

        workflow.errors.add(:base, :trace_checkout_refused, message: "#{refused.sku}: #{MESSAGE}")
        workflow.reject!
      end

      private

      def cart_of(workflow)
        %i[cart order].each do |reader|
          return workflow.public_send(reader) if workflow.respond_to?(reader) && workflow.public_send(reader)
        end
        nil
      end

      def enrolled_for?(variant, record)
        scope = TraceEnrollment.where(variant_id: variant.id)
        return false unless scope.exists?

        # A channel without its own list ships from every store location.
        channel = record.respond_to?(:channel) ? record.channel : nil
        return true if channel.nil? || !channel.respond_to?(:served_stock_locations)

        scope.where(stock_location_id: channel.served_stock_locations.select(:id)).exists?
      end
    end
  end
end
