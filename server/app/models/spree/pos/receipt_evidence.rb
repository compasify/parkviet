# frozen_string_literal: true

module Spree
  module Pos
    class ReceiptEvidence < Record
      self.table_name = 'spree_pos_receipt_evidences'
      has_prefix_id :posrcpt

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :tender_attempt, class_name: 'Spree::Pos::TenderAttempt'
      belongs_to :actor, class_name: staff_class_name

      validates :kind, inclusion: { in: %w[cash_count bank_manual external_card] }
      validates :attested_at, presence: true

      def to_pos
        { id: prefixed_id, kind: kind, reference: reference, receiving_account: receiving_account,
          terminal_ref: terminal_ref, attested_at: attested_at&.iso8601 }
      end
    end
  end
end
