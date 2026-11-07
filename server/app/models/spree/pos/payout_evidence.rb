# frozen_string_literal: true

module Spree
  module Pos
    class PayoutEvidence < Record
      self.table_name = 'spree_pos_payout_evidences'
      has_prefix_id :pospayev

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :liability_payout, class_name: 'Spree::Pos::LiabilityPayout', optional: true
      belongs_to :refund_request, class_name: 'Spree::Pos::RefundRequest', optional: true
      belongs_to :actor, class_name: staff_class_name

      validates :kind, inclusion: { in: %w[cash_count bank_manual failed_no_effect] }
      validates :attested_at, presence: true
      validate :one_subject

      def to_pos
        # An "unknown" outcome is recorded with the method's kind plus an
        # outcome note; it must never read as a counted or transferred payout.
        shown = metadata.is_a?(Hash) && metadata['outcome'] == 'unknown' ? 'unknown' : kind
        { id: prefixed_id, kind: shown, reference: reference, attested_at: attested_at&.iso8601 }
      end

      private

      # One evidence ledger for both payout kinds; each row answers exactly one.
      def one_subject
        errors.add(:base, :invalid) unless liability_payout_id.nil? ^ refund_request_id.nil?
      end
    end
  end
end
