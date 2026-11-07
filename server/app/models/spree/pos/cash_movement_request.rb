# frozen_string_literal: true

module Spree
  module Pos
    # A cash out or safe drop waiting for a second person. The drawer only
    # changes when someone else (holding `pos.cash.move` or `pos.approval.grant`
    # at the branch) confirms it; confirming posts exactly one CashMovement
    # under the shift barrier. Canceled requests never touch the drawer.
    class CashMovementRequest < Record
      self.table_name = 'spree_pos_cash_movement_requests'
      has_prefix_id :poscashreq

      KINDS = %w[cash_out safe_drop].freeze
      STATUSES = %w[requested confirmed canceled].freeze

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :branch, class_name: 'Spree::Pos::Branch'
      belongs_to :shift, class_name: 'Spree::Pos::Shift'
      belongs_to :requester, class_name: staff_class_name
      belongs_to :confirmer, class_name: staff_class_name, optional: true
      belongs_to :cash_movement, class_name: 'Spree::Pos::CashMovement', optional: true

      validates :kind, inclusion: { in: KINDS }
      validates :status, inclusion: { in: STATUSES }
      validates :reason, presence: true, length: { maximum: 200 }
      validates :evidence_reference, presence: true, length: { maximum: 120 }
      validates :resolution_note, length: { maximum: 200 }

      scope :for_store, ->(store) { where(store_id: store.id) }
      scope :pending, -> { where(status: 'requested') }

      def to_pos
        {
          id: prefixed_id, branch_id: branch.prefixed_id, shift_id: shift.prefixed_id, kind: kind, status: status,
          amount: amount.to_s('F'), currency: currency, reason: reason, evidence_reference: evidence_reference,
          requester_id: requester.prefixed_id, requester_name: StaffName.call(requester),
          confirmer_id: confirmer&.prefixed_id, confirmer_name: confirmer && StaffName.call(confirmer),
          cash_movement_id: cash_movement&.prefixed_id, resolution_note: resolution_note,
          created_at: created_at&.iso8601, resolved_at: resolved_at&.iso8601
        }
      end
    end
  end
end
