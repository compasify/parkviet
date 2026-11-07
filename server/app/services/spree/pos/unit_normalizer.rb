# frozen_string_literal: true

module Spree
  module Pos
    # Exact integer-canonical conversion. Fractional sale quantities are only
    # accepted when they map exactly to an integer count of canonical base units.
    class UnitNormalizer
      MAX_BASE_QUANTITY = 10_000_000

      def self.call(sale_quantity:, variant_unit:)
        quantity = parse_decimal(sale_quantity)
        raise Conflict, 'Sale quantity is invalid.' if quantity.nil? || quantity <= 0

        # Rational, never BigDecimal: BigDecimal * Rational(1, 3) is rounded.
        factor = Rational(variant_unit.sale_unit.factor_to_base.to_s)
        ratio = Rational(variant_unit.ratio_numerator, variant_unit.ratio_denominator)
        base = quantity * factor * ratio
        raise Conflict, 'Sale quantity cannot be represented exactly in base units.' unless base.denominator == 1

        base_quantity = base.numerator
        raise Conflict, 'Sale quantity is too large.' if base_quantity > MAX_BASE_QUANTITY

        scale = 10**variant_unit.sale_unit.sale_precision
        raise Conflict, 'Sale quantity has too much precision for this unit.' unless (quantity * scale).denominator == 1

        base_quantity
      end

      def self.parse_decimal(value)
        return nil unless value.is_a?(String) && value.match?(/\A\d+(?:\.\d+)?\z/)

        Rational(value)
      rescue ArgumentError
        nil
      end

      def self.unit_price_per_base(price:, variant_unit:)
        amount = price.is_a?(BigDecimal) ? price : BigDecimal(price.to_s)
        # Rational throughout: BigDecimal * Rational(1, 24) rounds to a
        # repeating decimal, which would refuse an exact 240000 per case of 24.
        per_sale_unit = amount.to_r * Rational(variant_unit.ratio_denominator, variant_unit.ratio_numerator)
        per_base = per_sale_unit / variant_unit.price_unit.factor_to_base.to_r
        raise Conflict, 'Price cannot be represented exactly per base unit.' unless (per_base * 10_000).denominator == 1

        BigDecimal((per_base * 10_000).to_i) / 10_000
      end
    end
  end
end
