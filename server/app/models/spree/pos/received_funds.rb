# frozen_string_literal: true

module Spree
  module Pos
    # Parent financial fact for one actual receipt. Allocations and liability
    # payouts consume this row; they never clone the receipt.
    class ReceivedFunds < Record
      self.table_name = 'spree_pos_received_funds'
      has_prefix_id :posfunds

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :workspace, class_name: 'Spree::Pos::Workspace', optional: true
      belongs_to :branch, class_name: 'Spree::Pos::Branch'
      belongs_to :register, class_name: 'Spree::Pos::Register', optional: true
      belongs_to :shift, class_name: 'Spree::Pos::Shift'
      belongs_to :tender_attempt, class_name: 'Spree::Pos::TenderAttempt', optional: true
      belongs_to :actor, class_name: staff_class_name
      has_many :allocations, class_name: 'Spree::Pos::FundsAllocation', foreign_key: :received_funds_id, dependent: :restrict_with_error
      has_many :liability_payouts, class_name: 'Spree::Pos::LiabilityPayout', foreign_key: :received_funds_id, dependent: :restrict_with_error
      has_many :cash_movements, class_name: 'Spree::Pos::CashMovement', foreign_key: :received_funds_id, dependent: :restrict_with_error

      validates :kind, inclusion: { in: %w[cash bank_manual] }
      validates :status, inclusion: { in: %w[received attention] }
      validates :custody, inclusion: { in: %w[drawer held] }
      validates :currency, presence: true

      scope :for_store, ->(store) { where(store_id: store.id) }

      def balance
        FundsBalance.new(self)
      end

      def to_pos
        bal = balance
        {
          id: prefixed_id, workspace_id: workspace&.prefixed_id, branch_id: branch.prefixed_id,
          shift_id: shift.prefixed_id, tender_attempt_id: tender_attempt&.prefixed_id,
          kind: kind, status: status, handed_amount: handed_amount.to_s('F'),
          applied_amount: applied_amount.to_s('F'), change_amount: change_amount.to_s('F'),
          received_net: received_net.to_s('F'), currency: currency, reference: reference,
          receiving_account: receiving_account, custody: custody, custody_note: custody_note,
          allocated: bal.allocated.to_s('F'), payout_reserved: bal.payout_reserved.to_s('F'),
          paid_out: bal.paid_out.to_s('F'), available: bal.available.to_s('F'),
          received_at: received_at&.iso8601
        }
      end
    end
  end
end
