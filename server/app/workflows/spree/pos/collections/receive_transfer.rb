# frozen_string_literal: true

module Spree
  module Pos
    module Collections
      # A bank transfer the VietQR webhook reports with a pay-later note
      # (PayLater, `TN<order number>`) that matched no counter QR. It is
      # booked through the regular collection path (Receive.book! and
      # Allocate.apply!): one bank receipt, allocated first to the coded
      # order, then to the customer's other open debts, oldest due first.
      # Money above every debt stays available on the receipt, as for any
      # collection. Registered in SpreeVietqr.unmatched_transaction_handlers.
      #
      # The receipt is booked on behalf of the staff member who sold on
      # credit, on their open shift at the branch (else any open shift there,
      # else the branch's last one: bank money moves no drawer). One bank
      # transaction is booked once: the command key is the provider's
      # transaction id, and the event is marked confirmed, which the gem's
      # duplicate check reads. Anything doubtful (no open debt on the coded
      # order, the bank reference already recorded by hand, no shift) is left
      # to staff as an unmatched event.
      class ReceiveTransfer
        def self.call(transaction:, webhook_event:, payment_method:)
          new(transaction, webhook_event, payment_method).call
        end

        def initialize(transaction, event, payment_method)
          @transaction = transaction
          @event = event
          @payment_method = payment_method
        end

        # @return [Boolean] whether the transfer is (or already was) booked
        def call
          number = PayLater.order_number(transaction.raw_content)
          return false if number.nil? || transaction.provider_transaction_id.blank?

          amount = BigDecimal(transaction.amount_cents.to_i.to_s)
          return false unless amount.positive?

          order = Spree::Order.find_by(number: number)
          return false if order.nil? || order.store_id != payment_method&.store_id

          debit = ReceivableEntry.find_by(order_id: order.id, kind: 'debit')
          return false if debit.nil? || debit.currency != PayLater::CURRENCY

          book!(order, debit, amount)
          true
        rescue Conflict => e
          Rails.logger.info("[Spree::Pos::Collections::ReceiveTransfer] #{event.prefixed_id} left unmatched: #{e.message}")
          false
        end

        private

        attr_reader :transaction, :event, :payment_method

        def book!(order, debit, amount)
          store = order.store
          staff = debit.actor
          key = "vietqr-transfer:#{event.provider}:#{transaction.provider_transaction_id}"
          return event.mark_status!('duplicate') if CommandReceipt.exists?(store_id: store.id, actor_id: staff.id, idempotency_key: key)

          reference = transaction.bank_reference.presence || transaction.provider_transaction_id
          account_number = transaction.account_number.presence || event.receiving_account&.account_number
          payload = {
            'command' => 'collection.receive_transfer', 'provider' => event.provider,
            'transaction_id' => transaction.provider_transaction_id.to_s, 'order_number' => order.number,
            'amount' => amount.to_s('F')
          }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: -> {}) do
            branch = debit.branch
            shift = shift_for(branch, staff)
            raise Conflict, 'The branch has no shift to book the transfer on.' if shift.nil?

            ShiftBarrier.hold!(shift) if shift.open?
            if ReceiptReferenceGuard.duplicates(store: store, reference: reference, receiving_account: account_number).exists?
              raise Conflict, 'This bank reference was already recorded.'
            end

            account = debit.credit_account
            account.lock!
            rows = plan(account, order, amount)
            raise Conflict, 'The order has no open debt.' if rows.empty?

            Receive.book!(store: store, staff: staff, branch: branch, shift: shift, account: account, kind: 'bank_manual',
                          kept: amount, money: { handed: amount, change: BigDecimal('0') }, reference: reference,
                          receiving_account: account_number, note: "VietQR #{PayLater.transfer_content(order)}", rows: rows,
                          received_at: received_at,
                          audit: { source: 'vietqr_webhook', webhook_event_id: event.prefixed_id, provider: event.provider,
                                   transaction_id: transaction.provider_transaction_id.to_s, order_number: order.number })
          end
          event.update!(matched_order_number: order.number, status: 'confirmed', error_message: nil, processed_at: Time.current)
        end

        def shift_for(branch, staff)
          shifts = Shift.where(branch_id: branch.id)
          shifts.open_now.find_by(owner_id: staff.id) || shifts.open_now.order(:opened_at, :id).last ||
            shifts.order(:opened_at, :id).last
        end

        # The coded order first, then the account's other open debts oldest
        # due first, each up to what it still owes. Empty when the coded order
        # owes nothing: the transfer is then not obviously for a debt.
        def plan(account, order, amount)
          balances = ReceivableEntry.where(credit_account_id: account.id).group(:order_id).
                     sum(Arel.sql(ReceivableEntry::SIGNED_SQL)).transform_values { |value| BigDecimal(value.to_s) }
          return [] unless balances.fetch(order.id, 0).positive?

          others = balances.except(order.id).select { |_, balance| balance.positive? }
          due = ReceivableEntry.where(order_id: others.keys, kind: 'debit').pluck(:order_id, :due_on).to_h
          ordered = [[order.id, balances.fetch(order.id)]] + others.sort_by { |id, _| [due[id] || Date.new(9999), id] }
          left = amount
          rows = ordered.first(50).filter_map do |(id, balance)|
            next unless left.positive?

            part = [balance, left].min
            left -= part
            [id, part]
          end
          numbers = Spree::Order.where(id: rows.map(&:first)).index_by(&:id)
          rows.map { |(id, part)| { 'order_id' => numbers.fetch(id).prefixed_id, 'amount' => part.to_s('F') } }
        end

        def received_at
          at = transaction.transaction_at
          at.nil? || at > Time.current ? Time.current : at
        end
      end
    end
  end
end
