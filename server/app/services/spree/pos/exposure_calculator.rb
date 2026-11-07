# frozen_string_literal: true

module Spree
  module Pos
    # Credit exposure of one account:
    #   open_debt (receivable ledger balance) + reserved (approved, still usable)
    # A new reservation fits only while exposure + amount <= credit_limit.
    # Callers lock the account row before trusting `available` for a write.
    class ExposureCalculator
      def initialize(account)
        @account = account
      end

      def open_debt
        ReceivableEntry.balance_sum(ReceivableEntry.where(credit_account_id: account.id))
      end

      def reserved
        BigDecimal(CreditReservation.holding.where(credit_account_id: account.id).sum(:amount).to_s)
      end

      def exposure
        open_debt + reserved
      end

      def available
        [account.credit_limit - exposure, BigDecimal('0')].max
      end

      def fits?(amount)
        account.active? && exposure + amount <= account.credit_limit
      end

      private

      attr_reader :account
    end
  end
end
