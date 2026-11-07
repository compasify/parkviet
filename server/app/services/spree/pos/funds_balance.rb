# frozen_string_literal: true

module Spree
  module Pos
    # Disjoint buckets over one parent ReceivedFunds:
    #   received_net = available + allocated_unconsumed + payout_reserved + paid_out
    # `paid_out` holds confirmed liability payouts and every Refund taken from
    # an allocation child's Payment, whether that child is still active or was
    # reversed afterwards, so the refunded part of a child is never counted as
    # allocated or available again.
    # Callers must lock the parent row before relying on these numbers.
    class FundsBalance
      def initialize(funds)
        @funds = funds
      end

      # Face amount of active children minus what their Payments already
      # refunded.
      def allocated
        active = funds.allocations.where(status: 'active')
        active.sum(:amount) - refunded(active)
      end

      def payout_reserved
        funds.liability_payouts.where(status: %w[requested reserved unknown]).sum(:amount)
      end

      def paid_out
        funds.liability_payouts.where(status: 'confirmed').sum(:amount) + refunded(funds.allocations)
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

      def refunded(allocations)
        Spree::Refund.where(payment_id: allocations.where.not(payment_id: nil).select(:payment_id)).sum(:amount)
      end
    end
  end
end
