# frozen_string_literal: true

module Spree
  module Pos
    class PayoutEvidence < Record
      self.table_name = 'spree_pos_payout_evidences'
      has_prefix_id :pospayev

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :liability_payout, class_name: 'Spree::Pos::LiabilityPayout'
      belongs_to :actor, class_name: staff_class_name

      validates :kind, inclusion: { in: %w[cash_count bank_manual failed_no_effect] }
      validates :attested_at, presence: true

      def to_pos
        { id: prefixed_id, kind: kind, reference: reference, attested_at: attested_at&.iso8601 }
      end
    end
  end
end
