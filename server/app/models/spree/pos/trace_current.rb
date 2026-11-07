# frozen_string_literal: true

module Spree
  module Pos
    # Per-request (per-job) memo of which (variant, location) pairs are
    # enrolled, so the stock guards do not query once per core movement.
    # Reset by Rails at the end of every request and job; cleared whenever
    # an enrollment is created or removed.
    class TraceCurrent < ActiveSupport::CurrentAttributes
      attribute :enrolled_pairs

      def self.enrolled?(variant_id, stock_location_id)
        self.enrolled_pairs ||= {}
        key = [variant_id, stock_location_id]
        return enrolled_pairs[key] if enrolled_pairs.key?(key)

        enrolled_pairs[key] = TraceEnrollment.exists?(variant_id: variant_id, stock_location_id: stock_location_id)
      end

      def self.forget!
        self.enrolled_pairs = nil
      end
    end
  end
end
