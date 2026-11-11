# frozen_string_literal: true

module Spree
  module Pos
    # A table asking for the bill. It moves no money and locks nothing; the
    # cashier sees it and collects through the usual tender.
    class PaymentRequest < Record
      self.table_name = 'spree_pos_payment_requests'
      has_prefix_id :pospayreq

      STATUSES = %w[open done canceled].freeze
      NOTE_MAX = 200

      belongs_to :workspace, class_name: 'Spree::Pos::Workspace'
      belongs_to :requested_by, class_name: staff_class_name
      belongs_to :resolved_by, class_name: staff_class_name, optional: true
      belongs_to :device, class_name: 'Spree::Pos::Device', optional: true

      validates :status, inclusion: { in: STATUSES }
      validates :note, length: { maximum: NOTE_MAX }

      scope :open, -> { where(status: 'open') }

      def to_pos
        { id: prefixed_id, status: status, note: note, requested_by_id: requested_by.prefixed_id,
          requested_at: created_at.iso8601, resolved_at: resolved_at&.iso8601 }
      end
    end
  end
end
