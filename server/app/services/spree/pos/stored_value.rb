# frozen_string_literal: true

module Spree
  module Pos
    # The prepaid value ledger. Money only enters as an actual receipt (a
    # ReceivedFunds with no order, like a deposit) and only leaves as an
    # allocation of those receipts to an order or a liability payout, so the
    # wallet never creates money: what it holds is backed by receipts,
    # oldest first.
    #
    #   0 <= balance <= what its top-up receipts still have available
    #
    # Every writer locks the account row first, then the receipts in id
    # order (callers that already hold a receipt lock take the account lock
    # before it, see `lock_for`). Callers run inside a command transaction.
    module StoredValue
      INSUFFICIENT = 'stored_value_insufficient'

      module_function

      def balance(account)
        account.balance
      end

      # The receipts behind the balance, oldest first.
      def backing(account)
        ids = StoredValueEntry.where(stored_value_account_id: account.id, kind: 'top_up').select(:received_funds_id)
        ReceivedFunds.where(id: ids).order(:id).to_a
      end

      def backing_available(account)
        backing(account).sum(BigDecimal('0')) { |funds| FundsBalance.new(funds).available }
      end

      # Money received for the account: the receipt is created by the caller
      # (on its shift, into its drawer) and is only recorded here.
      def top_up!(account:, funds:, actor:, note: nil)
        lock_active!(account)
        raise Conflict, 'Funds currency does not match the account.' if funds.currency != account.currency

        StoredValueEntry.create!(stored_value_account: account, kind: 'top_up', amount: funds.received_net,
                                 received_funds: funds, actor: actor, note: note)
      end

      # Pays `amount` of the workspace's order from the wallet: each receipt,
      # oldest first, gets a completed core Payment and a FundsAllocation for
      # its share, and the ledger a matching spend line. Caller holds the
      # workspace lock.
      def spend!(account:, workspace:, amount:, actor:)
        lock_active!(account)
        if balance(account) < amount
          raise Conflict.new('The wallet balance is too low.', reason: INSUFFICIENT,
                                                               details: { balance: balance(account).to_s('F') })
        end

        order = workspace.order
        remaining = amount
        entries = []
        backing(account).each do |funds|
          break unless remaining.positive?

          funds.lock!
          raise Conflict, 'Funds currency does not match the order.' if funds.currency != order.currency

          share = [FundsBalance.new(funds).available, remaining].min
          next unless share.positive?

          core_method = Funds::Allocate.core_method_for(funds)
          raise Conflict, 'Payment method is not available for this store.' if core_method.nil?

          payment = order.payments.create!(payment_method: core_method, amount: share)
          payment.complete!
          allocation = FundsAllocation.create!(store: workspace.store, received_funds: funds, workspace: workspace, order: order,
                                               payment: payment, status: 'active', amount: share, currency: order.currency)
          entries << StoredValueEntry.create!(stored_value_account: account, kind: 'spend', amount: -share, received_funds: funds,
                                              funds_allocation: allocation, workspace: workspace, actor: actor)
          remaining -= share
        end
        raise Conflict.new('The wallet money is not available.', reason: INSUFFICIENT) if remaining.positive?

        entries
      end

      # Gives `amount` back to the customer: a reserved LiabilityPayout on
      # each receipt, oldest first, that a second person confirms like any
      # payout of unapplied money.
      def refund!(account:, amount:, actor:, beneficiary_name:, beneficiary_reference: nil, reason: nil)
        account.lock!
        raise Conflict.new('The wallet balance is too low.', reason: INSUFFICIENT) if balance(account) < amount

        remaining = amount
        entries = []
        backing(account).each do |funds|
          break unless remaining.positive?

          funds.lock!
          share = [FundsBalance.new(funds).available, remaining].min
          next unless share.positive?

          payout = LiabilityPayout.create!(
            store: account.store, received_funds: funds, branch: funds.branch, requester: actor, status: 'reserved',
            amount: share, currency: funds.currency, beneficiary_name: beneficiary_name,
            beneficiary_reference: beneficiary_reference, reason: reason.presence || 'Hoàn số dư ví suất ăn'
          )
          entries << StoredValueEntry.create!(stored_value_account: account, kind: 'refund', amount: -share, received_funds: funds,
                                              liability_payout: payout, actor: actor, note: reason)
          remaining -= share
        end
        raise Conflict.new('The wallet money is not available.', reason: INSUFFICIENT) if remaining.positive?

        entries
      end

      # A correction of the balance by `amount` (signed). It moves no money,
      # so the balance stays between zero and what the receipts still hold.
      def adjust!(account:, amount:, actor:, note:)
        account.lock!
        after = balance(account) + amount
        if after.negative? || after > backing_available(account)
          raise Conflict.new('The correction would leave the wallet outside its money.', reason: 'stored_value_adjust_invalid',
                                                                                         details: { balance: balance(account).to_s('F') })
        end

        StoredValueEntry.create!(stored_value_account: account, kind: 'adjust', amount: amount, actor: actor, note: note)
      end

      # The wallet a funds allocation or a payout of a wallet came from, or
      # nil. Commands that reverse one call this before locking its receipt.
      def lock_for(allocation: nil, payout: nil)
        entry = StoredValueEntry.find_by(funds_allocation_id: allocation.id) if allocation
        entry = StoredValueEntry.find_by(liability_payout_id: payout.id) if payout
        entry&.stored_value_account&.tap(&:lock!)
      end

      # Puts back what a reversed allocation or a payout that never happened
      # took out of the wallet. Caller holds the account lock (lock_for).
      def restore!(account:, amount:, actor:, note:, workspace: nil)
        StoredValueEntry.create!(stored_value_account: account, kind: 'adjust', amount: amount, actor: actor, note: note,
                                 workspace: workspace)
      end

      def lock_active!(account)
        account.lock!
        raise Conflict.new('This wallet is closed.', reason: 'stored_value_closed') unless account.status == 'active'
      end
    end
  end
end
