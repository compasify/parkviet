# frozen_string_literal: true

module Spree
  module Pos
    # The tip part of one receipt. It was never applied to the order, so it
    # is not revenue and not on the VAT invoice; it waits on its receipt
    # (`held`) until Tips::Payout pays it to the staff (`paid_out`).
    class TipRecord < Record
      self.table_name = 'spree_pos_tip_records'
      has_prefix_id :postip

      STATUSES = %w[held paid_out].freeze

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :branch, class_name: 'Spree::Pos::Branch'
      belongs_to :workspace, class_name: 'Spree::Pos::Workspace'
      belongs_to :received_funds, class_name: 'Spree::Pos::ReceivedFunds'
      belongs_to :shift, class_name: 'Spree::Pos::Shift'
      belongs_to :liability_payout, class_name: 'Spree::Pos::LiabilityPayout', optional: true

      validates :status, inclusion: { in: STATUSES }
      validates :amount, numericality: { greater_than: 0 }
      validates :currency, :business_date, presence: true

      scope :held, -> { where(status: 'held') }

      def to_pos
        {
          id: prefixed_id, branch_id: branch.prefixed_id, workspace_id: workspace.prefixed_id,
          received_funds_id: received_funds.prefixed_id, shift_id: shift.prefixed_id, kind: received_funds.kind,
          amount: amount.to_s('F'), currency: currency, business_date: business_date.iso8601, status: status,
          liability_payout_id: liability_payout&.prefixed_id, created_at: created_at.iso8601, paid_out_at: paid_out_at&.iso8601
        }
      end
    end
  end
end
