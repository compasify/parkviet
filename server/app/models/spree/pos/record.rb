# frozen_string_literal: true

module Spree
  module Pos
    class Record < Spree.base_class
      self.abstract_class = true

      def self.staff_class_name
        Spree.admin_user_class.to_s
      end

      def self.locate(scope, prefixed)
        return if prefixed.blank?

        found = find_by_prefix_id(prefixed.to_s)
        scope.find_by(id: found.id) if found
      end

      # The prefixed id of a row from its key, without loading it.
      def self.prefixed_for(id)
        id && "#{_prefix_id_prefix}_#{Spree::PrefixedId::SQIDS.encode([id])}"
      end

      def self.money(value)
        return value if value.is_a?(BigDecimal)
        return if value.is_a?(Float)

        string = value.to_s.strip
        return if string.blank? || !string.match?(/\A\d+(\.\d{1,4})?\z/)

        BigDecimal(string)
      end

      # Actual money (tenders, receipts, payouts) must be countable in the
      # currency's smallest unit; VND has no fractional unit.
      def self.countable_money?(amount, currency)
        exponent = ::Money::Currency.find(currency.to_s)&.exponent || 2
        amount == amount.round(exponent)
      end
    end
  end
end
