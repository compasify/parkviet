# frozen_string_literal: true

module Spree
  module Pos
    # Reads an in-store EAN-13 scale label against the branch's active formats.
    # Returns nil when no format claims the barcode (it is an ordinary barcode).
    # A claimed barcode either resolves to an exact measured quantity or raises:
    # the encoded weight must convert exactly, and an encoded price is accepted
    # only when the server's own price reproduces it within the format tolerance.
    class MeasurementBarcodeParser
      Result = Struct.new(:format, :variant, :variant_unit, :sale_quantity, :base_quantity, :label_amount, :barcode, :unit_price, keyword_init: true) do
        def to_pos(currency)
          price = unit_price
          line_price = price && UnitNormalizer.unit_price_per_base(price: price, variant_unit: variant_unit)
          {
            kind: 'measured_label', barcode: barcode, capability: 'measured_labels',
            format_id: format.prefixed_id, format_version: format.version, label_kind: format.kind,
            variant_id: variant.prefixed_id, name: variant.product.name, sku: variant.sku,
            sale_quantity: sale_quantity, sale_unit: variant_unit.sale_unit.code, base_quantity: base_quantity,
            base_unit: variant_unit.base_unit.code, unit_price: price&.to_s('F'), currency: currency,
            line_amount: line_price && (line_price * base_quantity).to_s('F'), label_amount: label_amount&.to_s('F')
          }
        end
      end

      def self.call(branch:, barcode:, currency: nil, order: nil)
        new(branch, barcode, currency || branch.store.default_currency, order).call
      end

      def self.ean13_valid?(digits)
        return false unless digits.match?(/\A\d{13}\z/)

        sum = digits[0, 12].chars.each_with_index.sum { |char, index| char.to_i * (index.even? ? 1 : 3) }
        (10 - (sum % 10)) % 10 == digits[12].to_i
      end

      def initialize(branch, barcode, currency, order = nil)
        @order = order
        @branch = branch
        @store = branch.store
        @currency = currency
        @barcode = barcode.to_s.strip
      end

      def call
        return nil unless @barcode.match?(/\A\d{13}\z/)

        format = matching_format
        return nil if format.nil?
        raise Conflict, 'Label check digit is invalid.' unless self.class.ean13_valid?(@barcode)

        item_code = @barcode[format.prefix.length, format.item_code_length]
        raw_value = @barcode[format.prefix.length + format.item_code_length, format.value_length].to_i
        raise Conflict, 'Label value is zero.' if raw_value.zero?

        variant_unit = VariantUnit.find_by(store: @store, label_code: item_code, status: 'active')
        raise Conflict, 'Label item is not configured.' if variant_unit.nil?

        variant = Workspaces::ManageLineItem.sellable_variant!(branch: @branch, variant: variant_unit.variant)
        @unit_price = SalesChannel.price(variant, store: @store, currency: @currency, order: @order)&.amount
        value = Rational(raw_value, 10**format.value_decimals)
        base, label_amount = if format.kind == 'weight'
                               [weight_base(format, variant_unit, value), nil]
                             else
                               [price_base(format, variant, variant_unit, value), value]
                             end
        raise Conflict, 'Label quantity is too large.' if base > UnitNormalizer::MAX_BASE_QUANTITY

        Result.new(format: format, variant: variant, variant_unit: variant_unit, sale_quantity: sale_quantity(variant_unit, base),
                   base_quantity: base, label_amount: label_amount && BigDecimal(label_amount, 19), barcode: @barcode, unit_price: @unit_price)
      end

      private

      def matching_format
        LabelFormat.active.where(branch_id: @branch.id).to_a.
          select { |format| @barcode.start_with?(format.prefix) }.
          max_by { |format| format.prefix.length }
      end

      def weight_base(format, variant_unit, value)
        unit = UnitDefinition.find_by!(store: @store, code: format.value_unit_code)
        raise Conflict, 'Label unit does not match this SKU.' unless unit.base_code == variant_unit.base_unit.code

        base = value * unit.factor_to_base
        raise Conflict, 'Label weight cannot be represented exactly in base units.' unless base.denominator == 1

        base.numerator
      end

      # The label states what the scale charged. The server derives the quantity
      # from its own per-base price and refuses labels it cannot reproduce.
      def price_base(format, variant, variant_unit, amount)
        price = @unit_price
        raise Conflict, 'Variant has no price in the order currency.' if price.nil? || price.zero?

        per_base = UnitNormalizer.unit_price_per_base(price: price, variant_unit: variant_unit)
        base = (amount / per_base.to_r).round
        raise Conflict, 'Label price does not match the current price.' if base <= 0
        raise Conflict, 'Label price does not match the current price.' if ((base * per_base.to_r) - amount).abs > format.price_tolerance.to_r

        base
      end

      def sale_quantity(variant_unit, base)
        per_sale_unit = variant_unit.sale_unit.factor_to_base * Rational(variant_unit.ratio_numerator, variant_unit.ratio_denominator)
        quantity = Rational(base) / per_sale_unit
        scale = 10**variant_unit.sale_unit.sale_precision
        raise Conflict, 'Label quantity has too much precision for this unit.' unless (quantity * scale).denominator == 1

        BigDecimal(quantity, 20).round(variant_unit.sale_unit.sale_precision).to_s('F').sub(/\.0\z/, '')
      end
    end
  end
end
