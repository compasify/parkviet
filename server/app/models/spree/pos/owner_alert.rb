# frozen_string_literal: true

module Spree
  module Pos
    # Something an owner should look at, raised once per `dedupe_key`
    # (OwnerAlerts). `details` holds counts, minutes and amounts the owner
    # app shows; never a customer's name.
    class OwnerAlert < Record
      self.table_name = 'spree_pos_owner_alerts'
      has_prefix_id :posowneralert

      KINDS = %w[kitchen_late shift_variance void_burst revenue_milestone print_failed einvoice_failed].freeze

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :branch, class_name: 'Spree::Pos::Branch'

      validates :kind, inclusion: { in: KINDS }
      validates :dedupe_key, :occurred_at, presence: true

      def to_pos
        { id: prefixed_id, branch_id: branch.prefixed_id, kind: kind, subject_id: subject_ref, details: details,
          occurred_at: occurred_at.iso8601 }
      end
    end
  end
end
