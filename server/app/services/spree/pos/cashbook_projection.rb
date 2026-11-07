# frozen_string_literal: true

module Spree
  module Pos
    # Expected drawer cash of one shift, read from its immutable CashMovements:
    #   expected = opening float + sum(signed movements)
    # Receipts carry only the cash kept (handed minus change), so change is
    # never subtracted twice; refunds, liability payouts, cash out and safe
    # drops are negative. Bank, card and debt never write a CashMovement, and
    # allocation or reversal moves no physical cash, so none of them appear.
    class CashbookProjection
      def initialize(shift, upto_id: nil)
        @shift = shift
        @upto_id = upto_id
      end

      attr_reader :shift

      def movements
        scope = CashMovement.where(shift_id: shift.id)
        scope = scope.where(id: ..upto_id) if upto_id
        scope.order(:id)
      end

      def inflow_total
        @inflow_total ||= movements.where('amount > 0').sum(:amount)
      end

      def outflow_total
        @outflow_total ||= movements.where('amount < 0').sum(:amount).abs
      end

      def expected
        shift.opening_float + inflow_total - outflow_total
      end

      def last_movement_id
        movements.maximum(:id)
      end

      def movement_count
        movements.count
      end

      # Signed totals per report category (sale, collection, refund, cash_in ...).
      def breakdown
        totals = Hash.new { |hash, key| hash[key] = BigDecimal('0') }
        movements.includes(received_funds: :collection).find_each do |movement|
          totals[movement.category] += movement.amount
        end
        totals.transform_values { |value| value.to_s('F') }
      end

      def summary
        {
          opening_float: shift.opening_float.to_s('F'), inflow_total: inflow_total.to_s('F'),
          outflow_total: outflow_total.to_s('F'), expected: expected.to_s('F'), movement_count: movement_count
        }
      end

      private

      attr_reader :upto_id
    end
  end
end
