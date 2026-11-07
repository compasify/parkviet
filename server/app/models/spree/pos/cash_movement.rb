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
      belongs_to :actor, class_name: staff_class_name

      validates :kind, inclusion: { in: %w[receipt payout] }
      validates :currency, presence: true

      scope :for_store, ->(store) { where(store_id: store.id) }

      def to_pos
        { id: prefixed_id, shift_id: shift.prefixed_id, kind: kind, amount: amount.to_s('F'),
          currency: currency, source_type: source_type, received_funds_id: received_funds&.prefixed_id,
          liability_payout_id: liability_payout&.prefixed_id }
      end
    end
  end
end
