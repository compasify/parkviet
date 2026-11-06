# frozen_string_literal: true

module Spree
  module Pos
    class LiabilityPayout < Record
      self.table_name = 'spree_pos_liability_payouts'
      has_prefix_id :pospayout

      STATUSES = %w[requested reserved unknown confirmed failed canceled].freeze

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :received_funds, class_name: 'Spree::Pos::ReceivedFunds'
      belongs_to :branch, class_name: 'Spree::Pos::Branch'
      belongs_to :requester, class_name: staff_class_name
      has_many :payout_evidences, class_name: 'Spree::Pos::PayoutEvidence', foreign_key: :liability_payout_id, dependent: :restrict_with_error
      has_many :cash_movements, class_name: 'Spree::Pos::CashMovement', foreign_key: :liability_payout_id, dependent: :restrict_with_error

      validates :status, inclusion: { in: STATUSES }
      validates :beneficiary_name, :reason, presence: true
      validates :currency, presence: true

      scope :for_store, ->(store) { where(store_id: store.id) }
      scope :reserving, -> { where(status: %w[requested reserved unknown]) }

      def to_pos
        { id: prefixed_id, received_funds_id: received_funds.prefixed_id, branch_id: branch.prefixed_id,
          status: status, amount: amount.to_s('F'), currency: currency,
          beneficiary_name: beneficiary_name, beneficiary_reference: beneficiary_reference,
          reason: reason, confirmed_at: confirmed_at&.iso8601, resolved_at: resolved_at&.iso8601 }
      end
    end
  end
end
