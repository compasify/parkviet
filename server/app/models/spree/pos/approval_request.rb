# frozen_string_literal: true

module Spree
  module Pos
    # A cashier's or waiter's request for a manager's approval, answered from
    # another device (the owner's phone, a manager's tablet). Granting it
    # issues an ordinary `Approval` through Approvals::Issue, with the
    # decider as approver, so every check of an approval at the counter
    # applies. A request is pending for TTL; a changed subject makes it stale.
    class ApprovalRequest < Record
      self.table_name = 'spree_pos_approval_requests'
      has_prefix_id :posapprovalreq

      TTL = 10.minutes
      # How long the issued approval waits for the requester's device to use it.
      GRANT_TTL = 10.minutes
      REASON_MAX = 200
      STATUSES = %w[pending granted declined expired canceled].freeze
      # Actions a device may ask for remotely: those its commands answer
      # `approval_required` for. Credit, returns, refunds and stock counts
      # are approved on their own records.
      ACTIONS = [
        Workspaces::ApplyDiscount::ACTION, Workspaces::ApplyDiscount::CLEAR_ACTION,
        Workspaces::ApplyLineDiscount::ACTION, Workspaces::ApplyLineDiscount::CLEAR_ACTION,
        Workspaces::OverridePrice::ACTION, *Approval::PREBILL_ACTIONS, Approval::KITCHEN_VOID_ACTION,
        PlatformOrders::Cancel::ACTION, Approval::BUFFET_OVERRIDE_ACTION, Approval::MINIMUM_SPEND_WAIVE_ACTION,
        Approval::TIMED_EDIT_ACTION, Approval::TIMED_LONG_PAUSE_ACTION, *Approval::RESERVATION_ACTIONS,
        Approval::BOTTLE_KEEP_ADJUST_ACTION, *Approval::MEAL_ACTIONS, Approval::VEHICLE_VISIT_ADJUST_ACTION,
        *Approval::STORED_VALUE_ACTIONS
      ].uniq.freeze

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :branch, class_name: 'Spree::Pos::Branch'
      belongs_to :requester, class_name: staff_class_name
      belongs_to :approval, class_name: 'Spree::Pos::Approval', optional: true
      belongs_to :decided_by, class_name: staff_class_name, optional: true

      validates :status, inclusion: { in: STATUSES }
      validates :action, inclusion: { in: ACTIONS }
      validates :subject_type, inclusion: { in: Approvals::Issue::REFS.keys }
      validates :revision, :expires_at, presence: true
      validates :reason, length: { maximum: REASON_MAX }

      scope :for_store, ->(store) { where(store_id: store.id) }
      scope :pending, -> { where(status: 'pending') }

      # Pending requests past their time become expired. Reads call this
      # first, so nobody decides a request the requester stopped waiting for.
      def self.expire_due!(scope = all)
        now = Workspace.database_now
        scope.pending.where(expires_at: ..now).update_all(status: 'expired', decided_at: now, updated_at: now)
      end

      def subject
        @subject ||= subject_type.constantize.find_by(id: subject_id)
      end

      def pending?
        status == 'pending' && expires_at > Workspace.database_now
      end

      def to_pos
        {
          id: prefixed_id, branch_id: branch.prefixed_id, branch_name: branch.name,
          requester_id: requester.prefixed_id, requester_name: StaffName.call(requester),
          action: action, subject_type: subject_type.demodulize.underscore, subject_id: subject&.prefixed_id,
          subject_label: subject_label, revision: revision, amount: amount&.to_s('F'), currency: currency,
          reason: reason, status: status, approval_id: approval&.prefixed_id,
          decided_by_name: StaffName.call(decided_by), decided_at: decided_at&.iso8601,
          expires_at: expires_at.iso8601, created_at: created_at.iso8601
        }
      end

      private

      # What the decider recognises the request by: the table or order
      # number, the booking time, the card or account code. Never a
      # customer's name.
      def subject_label
        case subject
        when Workspace then subject.resource&.name || subject.order&.number
        when Reservation then subject.starts_at&.in_time_zone(branch.timezone)&.strftime('%H:%M %d/%m')
        when VehicleVisit then subject.plate
        when BottleKeep then subject.code
        when MealAccount then subject.employee_code
        when StoredValueAccount then subject.card_hint
        end
      end
    end
  end
end
