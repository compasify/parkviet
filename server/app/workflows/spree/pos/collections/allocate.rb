# frozen_string_literal: true

module Spree
  module Pos
    module Collections
      # Settles debtor orders from a collection's parent receipt. Each child is
      # a completed core Payment on that order, a FundsAllocation and a
      # receivable collection entry. The children together never exceed the
      # parent's available money (FundsBalance, the same cap payouts use) and
      # each never exceeds that order's open receivable balance. No sale, stock
      # or price changes. Lock order: account -> parent funds -> orders by id.
      class Allocate
        def self.call(store:, staff:, key:, collection_id:, allocations:)
          rows = normalize(allocations)
          payload = { 'command' => 'collection.allocate', 'collection_id' => collection_id.to_s, 'allocations' => rows }
          authorize = -> { authorize_later!(store, staff, collection!(store, collection_id)) }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: authorize) do
            collection = collection!(store, collection_id)
            collection.credit_account.lock!
            apply!(collection: collection, rows: rows, staff: staff)
            AuditEntry.record!(store: store, actor: staff, action: 'collection.allocate', subject: collection,
                               metadata: { allocations: rows })
            collection.reload.to_pos
          end
        end

        # Caller holds the account lock.
        def self.apply!(collection:, rows:, staff:)
          raise Conflict, 'At least one allocation is required.' if rows.empty?

          funds = collection.received_funds.lock!
          parsed = rows.map { |row| [order!(collection, row['order_id']), Record.money(row['amount'])] }
          parsed.each do |(_, amount)|
            raise Conflict, 'Amount is invalid.' if amount.nil? || amount <= 0
            raise Conflict, 'Amount must be a whole amount in the currency.' unless Record.countable_money?(amount, funds.currency)
          end
          raise Conflict, 'Allocations exceed the money available on this receipt.' if parsed.sum(&:last) > FundsBalance.new(funds).available

          core_method = Funds::Allocate.core_method_for(funds)
          raise Conflict, 'Payment method is not available for this store.' if core_method.nil?

          parsed.sort_by { |(order, _)| order.id }.map do |(order, amount)|
            order.lock!
            debit = ReceivableEntry.find_by!(order_id: order.id, kind: 'debit')
            balance = ReceivableEntry.balance_sum(ReceivableEntry.where(order_id: order.id))
            raise Conflict.new('Amount exceeds the open debt of this order.', reason: 'exceeds_debt') if amount > balance

            payment = order.payments.create!(payment_method: core_method, amount: amount)
            payment.complete!
            allocation = FundsAllocation.create!(
              store: collection.store, received_funds: funds, workspace: debit.workspace, order: order, payment: payment,
              collection: collection, status: 'active', amount: amount, currency: funds.currency
            )
            ReceivableEntry.create!(
              store: collection.store, credit_account: collection.credit_account, branch: debit.branch, order: order,
              workspace: debit.workspace, funds_allocation: allocation, actor: staff, kind: 'collection',
              amount: amount, currency: funds.currency
            )
            allocation
          end
        end

        def self.normalize(allocations)
          list = allocations.respond_to?(:to_unsafe_h) ? allocations.to_unsafe_h.values : Array(allocations)
          list = list.map { |row| row.respond_to?(:to_unsafe_h) ? row.to_unsafe_h : row.to_h }
          rows = list.map do |row|
            amount = Record.money(row.with_indifferent_access[:amount].to_s)
            { 'order_id' => row.with_indifferent_access[:order_id].to_s, 'amount' => amount&.to_s('F') }
          end
          ids = rows.map { |row| row['order_id'] }
          raise Conflict, 'Each order can appear once per allocation.' if ids.uniq.length != ids.length
          raise Conflict, 'Too many allocations in one command.' if rows.length > 50

          rows
        end

        def self.collection!(store, collection_id)
          collection = Collection.locate(Collection.for_store(store), collection_id)
          raise ActiveRecord::RecordNotFound if collection.nil?

          collection
        end

        # Allocating money left on a receipt later is a resolver's decision. The
        # collector who took the money may still place it themselves while the
        # shift that holds it is their own and open.
        def self.authorize_later!(store, staff, collection)
          policy = AccessPolicy.new(store: store, staff: staff)
          return if policy.allows?(collection.branch, Capabilities::RESOLVE)

          shift = collection.received_funds.shift
          own = collection.actor_id == staff.id && shift.owner_id == staff.id && shift.status == 'open'
          raise CanCan::AccessDenied unless own && policy.allows?(collection.branch, Capabilities::PAYMENT)
        end

        # Any credit-sale order of this account in the store: a customer may pay
        # a debt at a branch other than the one that sold on credit.
        def self.order!(collection, order_id)
          order = Spree::Order.find_by_prefix_id(order_id.to_s)
          raise ActiveRecord::RecordNotFound if order.nil? || order.store_id != collection.store_id

          debit = ReceivableEntry.find_by(order_id: order.id, kind: 'debit', credit_account_id: collection.credit_account_id)
          raise ActiveRecord::RecordNotFound if debit.nil?
          raise Conflict, 'Order currency does not match the receipt.' if order.currency != collection.received_funds.currency

          order
        end
      end
    end
  end
end
