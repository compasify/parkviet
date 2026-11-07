# frozen_string_literal: true

module Spree
  module Pos
    class CashMovement < Record
      self.table_name = 'spree_pos_cash_movements'
      has_prefix_id :poscashmv

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :branch, class_name: 'Spree::Pos::Branch'
      belongs_to :register, class_name: 'Spree::Pos::Register', optional: true
      belongs_to :shift, class_name: 'Spree::Pos::Shift'
      belongs_to :received_funds, class_name: 'Spree::Pos::ReceivedFunds', optional: true
      belongs_to :liability_payout, class_name: 'Spree::Pos::LiabilityPayout', optional: true
      belongs_to :refund_request, class_name: 'Spree::Pos::RefundRequest', optional: true
      belongs_to :actor, class_name: staff_class_name

      # Drawer cash kinds. Receipts and payouts come from sales, collections,
      # liability payouts and refunds; cash in/out and safe drops are manual
      # drawer movements with a reason (never sales or customer Payments); a
      # reconciliation inflow is late cash newly put into a drawer.
      INFLOWS = %w[receipt cash_in reconciliation_inflow].freeze
      OUTFLOWS = %w[payout cash_out safe_drop].freeze
      MANUAL = %w[cash_in cash_out safe_drop].freeze
      KINDS = (INFLOWS + OUTFLOWS).freeze

      belongs_to :cash_reconciliation, class_name: 'Spree::Pos::CashReconciliation', optional: true

      validates :kind, inclusion: { in: KINDS }
      validates :currency, presence: true
      validates :reason, presence: true, if: -> { MANUAL.include?(kind) }
      validates :reason, length: { maximum: 200 }
      validates :evidence_reference, length: { maximum: 120 }

      scope :for_store, ->(store) { where(store_id: store.id) }

      # Posted movements are the immutable source of a drawer's expected cash;
      # corrections are new entries, never edits.
      def readonly?
        persisted? || super
      end

      # Report category: what kind of fact moved the cash.
      def category
        case source_type
        when 'Spree::Pos::ReceivedFunds'
          if received_funds&.tender_attempt_id then 'sale'
          elsif received_funds&.collection then 'collection'
          else
            'unsolicited'
          end
        when 'Spree::Pos::LiabilityPayout' then 'liability_payout'
        when 'Spree::Pos::RefundRequest' then 'refund'
        else kind
        end
      end

      def to_pos
        { id: prefixed_id, branch_id: branch.prefixed_id, shift_id: shift.prefixed_id, kind: kind, amount: amount.to_s('F'),
          currency: currency, source_type: source_type, received_funds_id: received_funds&.prefixed_id,
          liability_payout_id: liability_payout&.prefixed_id,
          refund_request_id: refund_request&.prefixed_id,
          category: category, reason: reason, evidence_reference: evidence_reference,
          cash_reconciliation_id: cash_reconciliation&.prefixed_id,
          actor_id: actor.prefixed_id, created_at: created_at&.iso8601 }
      end
    end
  end
end
