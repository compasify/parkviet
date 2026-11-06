# frozen_string_literal: true

module Spree
  module Pos
    class TenderAttempt < Record
      self.table_name = 'spree_pos_tender_attempts'
      has_prefix_id :postender

      STATUSES = %w[prepared confirmed canceled unknown failed].freeze

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :workspace, class_name: 'Spree::Pos::Workspace'
      belongs_to :branch, class_name: 'Spree::Pos::Branch'
      belongs_to :register, class_name: 'Spree::Pos::Register'
      belongs_to :shift, class_name: 'Spree::Pos::Shift'
      belongs_to :pos_payment_method, class_name: 'Spree::Pos::PosPaymentMethod'
      belongs_to :actor, class_name: staff_class_name
      has_one :received_funds, class_name: 'Spree::Pos::ReceivedFunds', foreign_key: :tender_attempt_id, dependent: :restrict_with_error
      has_many :receipt_evidences, class_name: 'Spree::Pos::ReceiptEvidence', foreign_key: :tender_attempt_id, dependent: :restrict_with_error

      validates :status, inclusion: { in: STATUSES }
      validates :currency, presence: true

      scope :for_store, ->(store) { where(store_id: store.id) }
      scope :unresolved, -> { where(status: %w[prepared unknown]) }

      def to_pos
        {
          id: prefixed_id, workspace_id: workspace.prefixed_id,
          payment_method_id: pos_payment_method.prefixed_id, kind: pos_payment_method.kind,
          status: status, amount: amount.to_s('F'), order_total_snapshot: order_total_snapshot.to_s('F'),
          currency: currency, workspace_revision: workspace_revision,
          received_funds_id: received_funds&.prefixed_id,
          confirmed_at: confirmed_at&.iso8601, canceled_at: canceled_at&.iso8601
        }
      end
    end
  end
end
