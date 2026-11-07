# frozen_string_literal: true

module Spree
  module Pos
    # Cumulative return entitlement per immutable SaleLine, shared by credit
    # notes and refunds.
    #
    # Each line's original value is fixed once from the placed order, in whole
    # currency units, so the lines of an order add up to what the order asked
    # for (fractional base-unit prices and order-wide discounts are spread with
    # the largest-remainder method, never rounded line by line):
    #   total = net + tax, gross - discount = net, every component >= 0.
    #
    # For a line of Q base units, returning q units in total earns
    #   E(q).net = round_half_up(net * q / Q), E(q).tax = round_half_up(tax * q / Q),
    #   E(q).discount = round_half_up(discount * q / Q),
    #   E(q).total = E(q).net + E(q).tax, E(q).gross = E(q).net + E(q).discount
    # and E(Q) is exactly the original value. One return is granted the delta
    # E(after) - E(before) of its position in the line's sequence, so returns
    # of 1 + 1 + 3 units of a 5 x 0.4 VND line earn 0 + 1 + 1 = 2 VND, and the
    # residual is never lost to per-return rounding. Every E component is
    # non-decreasing in q, so no delta is ever negative.
    class ReturnEntitlement
      KEYS = %i[total net tax discount gross].freeze

      Components = Struct.new(*KEYS, keyword_init: true) do
        def self.zero
          new(**KEYS.index_with { BigDecimal('0') })
        end

        def -(other)
          self.class.new(**KEYS.index_with { |key| self[key] - other[key] })
        end

        def +(other)
          self.class.new(**KEYS.index_with { |key| self[key] + other[key] })
        end

        def to_pos
          KEYS.index_with { |key| self[key].to_s('F') }
        end
      end

      def initialize(order)
        @order = order
        @exponent = ::Money::Currency.find(order.currency.to_s)&.exponent || 2
      end

      attr_reader :order

      # Original whole-currency components of every line, by line item id.
      def originals
        @originals ||= build_originals
      end

      def original(line_item)
        originals.fetch(line_item.id)
      end

      # Entitlement of the first `returned` units of a line of `quantity` units.
      def cumulative(line_item, quantity, returned)
        base = original(line_item)
        return base if returned >= quantity
        return Components.zero if returned <= 0

        net = share(base.net, returned, quantity)
        tax = share(base.tax, returned, quantity)
        discount = share(base.discount, returned, quantity)
        Components.new(total: net + tax, net: net, tax: tax, discount: discount, gross: net + discount)
      end

      def delta(line_item, quantity, before, after)
        cumulative(line_item, quantity, after) - cumulative(line_item, quantity, before)
      end

      private

      attr_reader :exponent

      def share(value, returned, quantity)
        round(value * returned / quantity)
      end

      def round(value)
        BigDecimal(value.to_s).round(exponent, BigDecimal::ROUND_HALF_UP)
      end

      def build_originals
        lines = order.line_items.to_a.sort_by(&:id)
        return {} if lines.empty?

        discounts = order.discounts.to_a
        line_discount = discounts.select(&:line_item_id).group_by(&:line_item_id).transform_values { |rows| -rows.sum(&:amount) }
        # Order-wide discounts that no line carries are spread over the lines
        # by their discounted value.
        unattached = -discounts.select { |row| row.line_item_id.nil? && row.fulfillment_id.nil? }.sum(&:amount)
        nets = lines.map { |line| line.amount - line_discount.fetch(line.id, 0) }
        net_sum = nets.sum
        spread = lines.each_index.map { |index| net_sum.positive? ? unattached * nets[index] / net_sum : BigDecimal('0') }
        taxes = lines.map(&:additional_tax_total)
        weights = lines.each_index.map { |index| [nets[index] - spread[index] + taxes[index], 0].max }
        totals = allocate(round(weights.sum), weights)
        lines.each_with_index.to_h do |line, index|
          total = totals[index]
          tax = [round(taxes[index]), total].min
          net = total - tax
          discount = round(line_discount.fetch(line.id, 0) + spread[index])
          [line.id, Components.new(total: total, net: net, tax: tax, discount: discount, gross: net + discount)]
        end
      end

      # Largest remainder in the currency's smallest unit; ties go to the
      # earlier line so the result is deterministic.
      def allocate(amount, weights)
        unit = BigDecimal('1') / (10**exponent)
        weight_sum = weights.sum
        return weights.map { BigDecimal('0') } unless weight_sum.positive? && amount.positive?

        raw = weights.map { |weight| amount * weight / weight_sum }
        floors = raw.map { |value| (value / unit).floor * unit }
        left = ((amount - floors.sum) / unit).round
        order = raw.each_index.sort_by { |index| [-(raw[index] - floors[index]), index] }
        order.first(left).each { |index| floors[index] += unit }
        floors
      end
    end
  end
end
