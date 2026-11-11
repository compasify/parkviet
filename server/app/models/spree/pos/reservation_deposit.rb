# frozen_string_literal: true

module Spree
  module Pos
    # Money a guest paid to hold a booking. It is a ReceivedFunds without an
    # order; how it ends is read from the money core: applied (a
    # FundsAllocation to the order that ate it), refunded (a LiabilityPayout)
    # or forfeited (a taxed holding-fee order paid from it).
    class ReservationDeposit < Record
      self.table_name = 'spree_pos_reservation_deposits'
      has_prefix_id :posdeposit

      STATUSES = %w[held applied refunded forfeited].freeze

      belongs_to :reservation, class_name: 'Spree::Pos::Reservation', inverse_of: :deposits
      belongs_to :received_funds, class_name: 'Spree::Pos::ReceivedFunds'
      belongs_to :resolution_order, class_name: 'Spree::Order', optional: true
      belongs_to :liability_payout, class_name: 'Spree::Pos::LiabilityPayout', optional: true
      belongs_to :funds_allocation, class_name: 'Spree::Pos::FundsAllocation', optional: true
      belongs_to :actor, class_name: staff_class_name

      validates :status, inclusion: { in: STATUSES }
      validates :amount, numericality: { greater_than: 0 }
      validates :currency, presence: true

      def held?
        status == 'held'
      end

      def to_pos
        {
          id: prefixed_id, reservation_id: reservation.prefixed_id, received_funds_id: received_funds.prefixed_id,
          kind: received_funds.kind, amount: amount.to_s('F'), currency: currency, status: status,
          available: FundsBalance.new(received_funds).available.to_s('F'),
          resolution_order_id: resolution_order&.prefixed_id, liability_payout_id: liability_payout&.prefixed_id,
          funds_allocation_id: funds_allocation&.prefixed_id, received_at: received_funds.received_at&.iso8601,
          resolved_at: resolved_at&.iso8601
        }
      end
    end
  end
end
