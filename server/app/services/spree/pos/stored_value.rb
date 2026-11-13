# frozen_string_literal: true

module Spree
  module Pos
    # The prepaid value ledger. Money only enters as an actual receipt (a
    # ReceivedFunds with no order, like a deposit) and only leaves as an
    # allocation of those receipts to an order or a liability payout, so the
    # wallet never creates money: what it holds is backing by receipts,
    # oldest first.
    #
    #   0 <= balance <= what its top-up receipts still have available
    #
    # A minutes card also counts minutes on the same lines. Each top-up
    # receipt is a lot with its own minutes and money: minutes are taken
    # oldest lot first, and the money a lot gives for them is its money left
    # times the minutes taken over its minutes left (all of it for its last
    # minutes), so the price per minute fixed when the card was sold holds
    # and a lot never gives more than it has.
    #
    # Every writer locks the account row first, then the receipts in id
    # order (callers that already hold a receipt lock take the account lock
    # before it, see `lock_for`). Callers run inside a command transaction.
    module StoredValue
      INSUFFICIENT = 'stored_value_insufficient'
      # One top-up receipt of a minutes card and what is left on it.
      Lot = Data.define(:funds, :minutes, :money)
      # What a lot gives for minutes taken from it.
      Take = Data.define(:funds, :minutes, :amount)

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

      # Takes an actual receipt for a wallet or a card on the collector's own
      # open shift, the way a deposit or a debt payment is taken: cash into
      # the drawer, a transfer with its reference and receiving account. The
      # block runs after the shift is held and before the receipt is
      # written, for the caller's own locks and checks.
      # @return [Array(ReceivedFunds, Hash)] the receipt and { handed:, change: }
      def receive!(store:, staff:, branch:, kind:, amount:, handed:, currency:, reference: nil, receiving_account: nil,
                   confirm_duplicate: nil)
        money = Collections::Receive.validate!(kind.to_s, amount, handed, currency, reference, receiving_account)
        shift = Shift.for_store(store).open_now.find_by(branch_id: branch.id, owner_id: staff.id)
        raise Conflict.new('Open your own shift before topping up a wallet.', reason: 'shift_required') if shift.nil?

        ShiftBarrier.hold!(shift)
        yield if block_given?
        duplicate_ids = if kind.to_s == 'bank_manual'
                          ReceiptReferenceGuard.check!(store: store, staff: staff, branch: branch, reference: reference,
                                                       receiving_account: receiving_account, confirm_duplicate: confirm_duplicate)
                        else
                          []
                        end
        funds = ReceivedFunds.create!(
          store: store, branch: branch, register: shift.register, shift: shift, actor: staff, kind: kind.to_s,
          status: 'received', handed_amount: money[:handed], applied_amount: amount, change_amount: money[:change],
          received_net: amount, currency: currency, reference: reference.presence,
          receiving_account: receiving_account.presence, custody: 'drawer', received_at: Time.current
        )
        if kind.to_s == 'cash'
          CashMovement.create!(store: store, branch: branch, register: shift.register, shift: shift, received_funds: funds,
                               actor: staff, kind: 'receipt', amount: amount, currency: currency,
                               source_type: funds.class.name, source_id: funds.id)
        end
        ReceiptReferenceGuard.audit!(store: store, staff: staff, funds: funds, duplicate_ids: duplicate_ids)
        [funds, money]
      end

      # Money received for the account: the receipt is created by the caller
      # (on its shift, into its drawer) and is only recorded here. A minutes
      # card records the minutes the money buys.
      def top_up!(account:, funds:, actor:, note: nil, minutes: nil)
        lock_active!(account)
        raise Conflict, 'Funds currency does not match the account.' if funds.currency != account.currency
        if account.minutes? != minutes.present?
          raise Conflict.new('Minutes go on minutes cards only.', reason: 'stored_value_minutes_invalid')
        end

        StoredValueEntry.create!(stored_value_account: account, kind: 'top_up', amount: funds.received_net, minutes: minutes,
                                 received_funds: funds, actor: actor, note: note)
      end

      # Pays `amount` of the workspace's order from the wallet: each receipt,
      # oldest first, gets a completed core Payment and a FundsAllocation for
      # its share, and the ledger a matching spend line. Caller holds the
      # workspace lock.
      def spend!(account:, workspace:, amount:, actor:)
        lock_active!(account)
        raise Conflict.new('A minutes card pays play time only.', reason: 'stored_value_kind_invalid') if account.minutes?
        if balance(account) < amount
          raise Conflict.new('The wallet balance is too low.', reason: INSUFFICIENT,
                                                               details: { balance: balance(account).to_s('F') })
        end

        remaining = amount
        entries = []
        backing(account).each do |funds|
          break unless remaining.positive?

          funds.lock!
          share = [FundsBalance.new(funds).available, remaining].min
          next unless share.positive?

          entries << allocate!(account, workspace, funds, share, actor)
          remaining -= share
        end
        raise Conflict.new('The wallet money is not available.', reason: INSUFFICIENT) if remaining.positive?

        entries
      end

      # The lots of a minutes card with minutes left, oldest first. Locks
      # their receipts when `lock` (writers).
      def lots(account, lock: false)
        left = StoredValueEntry.where(stored_value_account_id: account.id).where.not(received_funds_id: nil).
               group(:received_funds_id).sum(:minutes)
        backing(account).filter_map do |funds|
          funds.lock! if lock
          minutes = left[funds.id].to_i
          next unless minutes.positive?

          Lot.new(funds: funds, minutes: minutes, money: FundsBalance.new(funds).available)
        end
      end

      # What `minutes` cost on the lots, oldest first, and how many of them
      # the lots cover. Pure: nothing is read or written.
      # @return [Array(Array<Take>, Integer)]
      def minutes_cost(lots, minutes, currency)
        remaining = minutes
        takes = []
        lots.each do |lot|
          break if remaining <= 0

          take = [lot.minutes, remaining].min
          remaining -= take
          amount = if take == lot.minutes
                     lot.money
                   else
                     BigDecimal(Spree::Money::Rounding.to_currency(lot.money * take / lot.minutes, currency).to_s)
                   end
          takes << Take.new(funds: lot.funds, minutes: take, amount: [amount, lot.money].min)
        end
        [takes, minutes - [remaining, 0].max]
      end

      # Takes up to `minutes` from a minutes card for the play time of the
      # workspace's order: each lot pays its money for its minutes with a
      # completed core Payment and a FundsAllocation, and the ledger gets a
      # spend line with the money and the minutes. Minutes the card does not
      # have are left to the bill. Caller holds the workspace lock.
      # @return [Array<StoredValueEntry>]
      def spend_minutes!(account:, workspace:, minutes:, actor:)
        lock_active!(account)
        raise Conflict.new('This card holds money, not minutes.', reason: 'stored_value_kind_invalid') unless account.minutes?

        takes, = minutes_cost(lots(account, lock: true), minutes, account.currency)
        takes.filter_map do |take|
          next if take.minutes.zero?

          if take.amount.positive?
            allocate!(account, workspace, take.funds, take.amount, actor, minutes: -take.minutes)
          else
            # Minutes given free on the card (a correction) cost nothing.
            StoredValueEntry.create!(stored_value_account: account, kind: 'adjust', amount: 0, minutes: -take.minutes,
                                     received_funds: take.funds, workspace: workspace, actor: actor, note: 'Phút tặng đã dùng')
          end
        end
      end

      # Gives `amount` back to the customer: a reserved LiabilityPayout on
      # each receipt, oldest first, that a second person confirms like any
      # payout of unapplied money. A minutes card gives back all it has, and
      # its minutes go with the money.
      def refund!(account:, amount:, actor:, beneficiary_name:, beneficiary_reference: nil, reason: nil)
        account.lock!
        raise Conflict.new('The wallet balance is too low.', reason: INSUFFICIENT) if balance(account) < amount

        left = account.minutes? ? lots(account).to_h { |lot| [lot.funds.id, lot.minutes] } : {}
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
            beneficiary_reference: beneficiary_reference, reason: reason.presence || refund_reason(account)
          )
          minutes = account.minutes? ? -left[funds.id].to_i : nil
          entries << StoredValueEntry.create!(stored_value_account: account, kind: 'refund', amount: -share, minutes: minutes,
                                              received_funds: funds, liability_payout: payout, actor: actor, note: reason)
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

      # A correction of a minutes card by `minutes` (signed). It moves no
      # money: minutes added go on the newest lot that still has money (its
      # price per minute falls), minutes taken off come from the newest lots
      # first, and no lot goes below zero minutes.
      def adjust_minutes!(account:, minutes:, actor:, note:)
        account.lock!
        raise Conflict.new('This card holds money, not minutes.', reason: 'stored_value_kind_invalid') unless account.minutes?

        if minutes.positive?
          funds = backing(account).reverse.find { |row| FundsBalance.new(row).available.positive? }
          raise Conflict.new('The card has no money left to give minutes on.', reason: 'stored_value_adjust_invalid') if funds.nil?

          return [StoredValueEntry.create!(stored_value_account: account, kind: 'adjust', amount: 0, minutes: minutes,
                                           received_funds: funds, actor: actor, note: note)]
        end

        remaining = -minutes
        entries = lots(account).reverse.filter_map do |lot|
          next if remaining.zero?

          take = [lot.minutes, remaining].min
          remaining -= take
          StoredValueEntry.create!(stored_value_account: account, kind: 'adjust', amount: 0, minutes: -take,
                                   received_funds: lot.funds, actor: actor, note: note)
        end
        if remaining.positive?
          raise Conflict.new('The card does not have these minutes.', reason: 'stored_value_adjust_invalid',
                                                                      details: { minutes_balance: account.minutes_balance })
        end

        entries
      end

      # The wallet a funds allocation or a payout of a wallet came from, or
      # nil. Commands that reverse one call this before locking its receipt.
      def lock_for(allocation: nil, payout: nil)
        entry_for(allocation: allocation, payout: payout)&.stored_value_account&.tap(&:lock!)
      end

      def entry_for(allocation: nil, payout: nil)
        return StoredValueEntry.find_by(funds_allocation_id: allocation.id) if allocation

        StoredValueEntry.find_by(liability_payout_id: payout.id) if payout
      end

      # Puts back what a reversed allocation or a payout that never happened
      # took out of the wallet, minutes included. Caller holds the account
      # lock (lock_for).
      def restore!(account:, amount:, actor:, note:, workspace: nil, allocation: nil, payout: nil)
        source = entry_for(allocation: allocation, payout: payout)
        minutes = source&.minutes&.nonzero? ? -source.minutes : nil
        StoredValueEntry.create!(stored_value_account: account, kind: 'adjust', amount: amount, minutes: minutes, actor: actor,
                                 note: note, workspace: workspace, received_funds: minutes ? source.received_funds : nil)
      end

      def lock_active!(account)
        account.lock!
        raise Conflict.new('This wallet is closed.', reason: 'stored_value_closed') unless account.status == 'active'
      end

      # One receipt's share paid to the order, and the ledger line for it.
      def allocate!(account, workspace, funds, share, actor, minutes: nil)
        order = workspace.order
        raise Conflict, 'Funds currency does not match the order.' if funds.currency != order.currency

        core_method = Funds::Allocate.core_method_for(funds)
        raise Conflict.new('Payment method is not available for this store.', reason: 'payment_method_unavailable') if core_method.nil?

        payment = order.payments.create!(payment_method: core_method, amount: share)
        payment.complete!
        allocation = FundsAllocation.create!(store: workspace.store, received_funds: funds, workspace: workspace, order: order,
                                             payment: payment, status: 'active', amount: share, currency: order.currency)
        StoredValueEntry.create!(stored_value_account: account, kind: 'spend', amount: -share, minutes: minutes, received_funds: funds,
                                 funds_allocation: allocation, workspace: workspace, actor: actor)
      end

      def refund_reason(account)
        account.kind == 'meal' ? 'Hoàn số dư ví suất ăn' : 'Hoàn số dư thẻ nạp'
      end
    end
  end
end
