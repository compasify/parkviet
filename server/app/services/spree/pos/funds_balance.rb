# frozen_string_literal: true

module Spree
  module Pos
    # Disjoint buckets over one parent ReceivedFunds:
    #   received_net = available + allocated_unconsumed + payout_reserved + paid_out
    # Callers must lock the parent row before relying on these numbers.
    class FundsBalance
      def initialize(funds)
        @funds = funds
      end

      def allocated
        funds.allocations.where(status: 'active').sum(:amount)
      end

      def payout_reserved
        funds.liability_payouts.where(status: %w[requested reserved unknown]).sum(:amount)
      end

      def paid_out
        funds.liability_payouts.where(status: 'confirmed').sum(:amount)
      end

      def available
        funds.received_net - allocated - payout_reserved - paid_out
      end

      def to_h
        { received_net: funds.received_net, allocated: allocated, payout_reserved: payout_reserved,
          paid_out: paid_out, available: available }
      end

      private

      attr_reader :funds
    end
  end
end
