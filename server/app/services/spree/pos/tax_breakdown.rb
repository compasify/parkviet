# frozen_string_literal: true

module Spree
  module Pos
    # Tax already calculated on the order, grouped by rate. POS does not
    # recompute tax; it reads the tax lines Spree stored and the order totals.
    class TaxBreakdown
      def self.for(order)
        lines = order.tax_lines.reject { |line| line.try(:credit) }
        lines.group_by { |line| [normalize_rate(line.rate), line.label.to_s] }.map do |(rate, label), group|
          { rate: rate, label: label, amount: group.sum { |line| BigDecimal(line.amount.to_s) }.to_s('F') }
        end.sort_by { |row| [row[:rate], row[:label]] }
      end

      def self.normalize_rate(rate)
        BigDecimal(rate.to_s).to_s('F')
      end
    end
  end
end
