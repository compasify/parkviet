# frozen_string_literal: true

module Spree
  module Pos
    # Keep the original price intact. Targets are per sale unit, not stock unit.
    class TargetPriceDiscount
      def self.call(sale_line:, base:, value:, currency:)
        raise DiscountCalculator::InvalidDiscount unless currency == 'VND' && value.is_a?(String) && value.length <= 64 && value.match?(/\A\d+(?:\.\d+)?\z/)

        target = BigDecimal(value)
        raise DiscountCalculator::InvalidDiscount unless target.frac.zero? && target <= sale_line.unit_price
        raise DiscountCalculator::InvalidDiscount unless base >= 0 && base.frac.zero?

        target_total = Spree::Money::Rounding.to_currency(target * sale_line.sale_quantity, currency)
        [base - target_total, BigDecimal('0')].max
      end
    end
  end
end
