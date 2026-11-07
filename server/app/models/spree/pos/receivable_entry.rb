# frozen_string_literal: true

module Spree
  module Pos
    # Immutable receivable fact. Amounts are always positive; the kind gives
    # the direction: a debit (credit sale) and a collection reversal raise the
    # balance, a credit note and a collection lower it. Corrections are new
    # entries, never edits of posted ones.
    class ReceivableEntry < Record
      self.table_name = 'spree_pos_receivable_entries'
      has_prefix_id :posrecv

      KINDS = %w[debit credit_note collection collection_reversal].freeze
      RAISING = %w[debit collection_reversal].freeze

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :credit_account, class_name: 'Spree::Pos::CreditAccount'
      belongs_to :branch, class_name: 'Spree::Pos::Branch'
      belongs_to :order, class_name: 'Spree::Order'
      belongs_to :workspace, class_name: 'Spree::Pos::Workspace'
      belongs_to :credit_reservation, class_name: 'Spree::Pos::CreditReservation', optional: true
      belongs_to :funds_allocation, class_name: 'Spree::Pos::FundsAllocation', optional: true
      belongs_to :actor, class_name: staff_class_name

      validates :kind, inclusion: { in: KINDS }
      validates :currency, presence: true
      validates :amount, numericality: { greater_than: 0 }

      scope :for_store, ->(store) { where(store_id: store.id) }

      # SQL expression for the signed balance contribution of each entry.
      SIGNED_SQL = "CASE WHEN spree_pos_receivable_entries.kind IN ('debit', 'collection_reversal') " \
                   'THEN spree_pos_receivable_entries.amount ELSE -spree_pos_receivable_entries.amount END'

      def self.balance_sum(scope)
        BigDecimal(scope.sum(Arel.sql(SIGNED_SQL)).to_s)
      end

      def readonly?
        persisted? || super
      end

      # Return seam: lowers what a customer owes on one credit-sale order for
      # value given back (a return), capped at the open balance so the debt can
      # never go negative. The part of a return above the debt is a refund
      # question for actual money received, never a negative receivable.
      # Callers own the source record (for example a return authorization),
      # which makes the note unique per source and safe to retry.
      def self.post_credit_note!(order:, amount:, source:, actor:, metadata: {})
        debit = find_by(order_id: order.id, kind: 'debit')
        raise Conflict, 'Order has no receivable.' if debit.nil?

        parsed = Record.money(amount.to_s)
        raise Conflict, 'Amount is invalid.' if parsed.nil? || parsed <= 0
        raise Conflict, 'Amount must be a whole amount in the currency.' unless Record.countable_money?(parsed, debit.currency)

        debit.credit_account.with_lock do
          existing = find_by(kind: 'credit_note', source_type: source.class.name, source_id: source.id)
          next existing if existing

          balance = balance_sum(where(order_id: order.id))
          raise Conflict, 'Credit note exceeds the open receivable balance.' if parsed > balance

          entry = create!(
            store: debit.store, credit_account: debit.credit_account, branch: debit.branch, order: order,
            workspace: debit.workspace, actor: actor, kind: 'credit_note', amount: parsed, currency: debit.currency,
            source_type: source.class.name, source_id: source.id, metadata: metadata
          )
          AuditEntry.record!(store: debit.store, actor: actor, action: 'receivable.credit_note', subject: debit.workspace,
                             metadata: { entry_id: entry.prefixed_id, amount: parsed.to_s('F') })
          entry
        end
      end

      def to_pos
        { id: prefixed_id, kind: kind, amount: amount.to_s('F'), currency: currency, order_id: order.prefixed_id,
          funds_allocation_id: funds_allocation&.prefixed_id, due_on: due_on&.iso8601, created_at: created_at&.iso8601 }
      end
    end
  end
end
