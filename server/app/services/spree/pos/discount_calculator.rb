# frozen_string_literal: true

module Spree
  module Pos
    # Pure calculation seam. Callers must derive bases and authority on the
    # server; this class does not persist discounts or approve any operation.
    class DiscountCalculator
      class InvalidDiscount < StandardError; end

      def self.call(bases:, value:, value_type:, currency:)
        new(bases: bases, value: value, value_type: value_type, currency: currency).call
      end

      def initialize(bases:, value:, value_type:, currency:)
        @bases = bases
        @value = value
        @value_type = value_type
        @currency = currency
      end

      def call
        raise InvalidDiscount unless @bases.is_a?(Array) && @currency == 'VND'
        raise InvalidDiscount unless @value.is_a?(String) && @value.length <= 64 && @value.match?(/\A\d+(?:\.\d+)?\z/)
        raise InvalidDiscount unless %w[flat percent].include?(@value_type)

        bases = @bases.map { |base| parse_base(base) }
        value = BigDecimal(@value)
        total_base = bases.sum
        raise InvalidDiscount unless value.positive?
        raise InvalidDiscount if @value_type == 'percent' && value > 100
        raise InvalidDiscount if @value_type == 'flat' && value.frac != 0
        # A percentage intent remains meaningful while the basket is empty.
        # Fixed discounts must still be rejected when there is no eligible base.
        return bases.map { BigDecimal('0') } if total_base.zero? && @value_type == 'percent'
        raise InvalidDiscount unless total_base.positive?

        amount = @value_type == 'percent' ? Spree::Money::Rounding.to_currency(total_base * value / 100, @currency) : value
        raise InvalidDiscount if amount > total_base

        shares = Spree::Adjusters::LargestRemainder.apportion(amount, bases, @currency)
        raise InvalidDiscount if shares.zip(bases).any? { |share, base| share.negative? || share > base }

        shares
      end

      private

      def parse_base(base)
        raise InvalidDiscount unless base.is_a?(BigDecimal) || base.is_a?(Integer) || (base.is_a?(String) && base.length <= 64 && base.match?(/\A\d+(?:\.\d+)?\z/))

        number = BigDecimal(base.to_s)
        raise InvalidDiscount unless number.finite? && number >= 0 && number.frac.zero?

        number
      rescue ArgumentError
        raise InvalidDiscount
      end
    end
  end
end
