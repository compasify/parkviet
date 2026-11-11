# frozen_string_literal: true

module Spree
  module Pos
    class Approval < Record
      self.table_name = 'spree_pos_approvals'
      has_prefix_id :posapproval

      # Technical ceiling, not a management policy: an approval answers one
      # pending action at the counter, so it must not outlive a short wait.
      MAX_TTL = 1.hour

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :branch, class_name: 'Spree::Pos::Branch'
      belongs_to :approver, class_name: staff_class_name
      belongs_to :requester, class_name: staff_class_name

      # Set only by Credit::QuickApprove: the cashier's own credit approval.
      attr_accessor :self_credit

      validates :action, :revision, :expires_at, :subject_type, :subject_id, presence: true
      validates :status, inclusion: { in: %w[active revoked consumed] }
      validate :approver_is_distinct
      validate :expires_within_window, on: :create

      scope :for_store, ->(store) { where(store_id: store.id) }

      def usable?
        status == 'active' && revoked_at.nil? && consumed_at.nil? && expires_at > Workspace.database_now
      end

      # Records an approval may be bound to. Each carries its own revision, so
      # a changed subject invalidates the approval.
      SUBJECTS = %w[Spree::Pos::Workspace Spree::Pos::ReturnOperation Spree::Pos::RefundRequest Spree::Pos::Shift
                    Spree::Pos::InventoryAdjustment].freeze
      # Who may ask for an approval at the branch: sellers, and return staff
      # for returns and refunds.
      REQUESTER_CAPABILITIES = {
        'Spree::Pos::ReturnOperation' => [Capabilities::RETURN],
        'Spree::Pos::RefundRequest' => [Capabilities::RETURN],
        # A shift close variance: the cashier, or a manager closing for them.
        'Spree::Pos::Shift' => [Capabilities::OPEN_SHIFT, Capabilities::RECOVER],
        'Spree::Pos::InventoryAdjustment' => [Capabilities::INVENTORY_MANAGE],
        # Sellers, and the people serving a table (only table orders are theirs to edit).
        'Spree::Pos::Workspace' => [Capabilities::OPEN_SHIFT, Capabilities::TABLE_SERVE]
      }.freeze
      # Pre-bills of a table: printing one again, or taking one back.
      PREBILL_ACTIONS = %w[workspace.reprint_prebill workspace.cancel_prebill].freeze
      # Taking back an item the kitchen was told about (Kitchen::VoidSent).
      KITCHEN_VOID_ACTION = 'kitchen.void_sent'

      def consume!(action:, amount:, currency:, revision:, subject:, requester:)
        raise Conflict, 'Approval subject is required.' unless SUBJECTS.include?(subject.class.name) && subject.persisted?

        subject.with_lock do
          with_lock do
            raise Conflict, 'Approval cannot be reused.' unless usable?
            unless matches?(action: action, amount: amount, currency: currency, revision: revision, subject: subject, requester: requester)
              raise Conflict, 'Approval does not match this action.'
            end

            update!(status: 'consumed', consumed_at: Time.current)
          end
        end
      end

      def revoke!
        with_lock do
          raise Conflict.new('Only an active approval can be revoked.', reason: 'approval_not_active') unless status == 'active'

          update!(status: 'revoked', revoked_at: Time.current)
        end
      end

      def matches?(action:, amount:, currency:, revision:, subject:, requester:)
        incoming = amount.nil? ? nil : Record.money(amount)
        amount_matches = self.amount.nil? ? incoming.nil? : incoming && self.amount == incoming && self.currency == currency
        subject_matches = subject_type.present? && subject_type == subject&.class&.name && subject_id == subject&.id
        current_revision = subject.respond_to?(:revision) && subject.reload.revision.to_s == revision.to_s
        approver_allowed = approver_allowed?
        requester_capabilities = REQUESTER_CAPABILITIES.fetch(subject_type, [Capabilities::OPEN_SHIFT])
        requester_policy = AccessPolicy.new(store: store, staff: requester)
        requester_capable = requester_capabilities.any? { |capability| requester_policy.allows?(branch, capability) }
        requester_allowed = requester_id == requester&.id && requester_capable
        self.action == action && self.revision.to_s == revision.to_s && amount_matches && subject_matches && current_revision && approver_allowed && requester_allowed && !branch.reload.disabled?
      end

      # Compact reference for return and refund read models. Uses the app
      # clock: it is a display hint, consuming re-checks against the database.
      def to_ref
        shown = status
        shown = expires_at > Time.current && revoked_at.nil? && consumed_at.nil? ? 'active' : 'expired' if status == 'active'
        { id: prefixed_id, status: shown, expires_at: expires_at.iso8601 }
      end

      def to_pos
        {
          id: prefixed_id,
          branch_id: branch.prefixed_id,
          approver_id: approver.prefixed_id,
          requester_id: requester.prefixed_id,
          action: action,
          amount: amount&.to_s('F'),
          currency: currency,
          revision: revision,
          status: status,
          expires_at: expires_at.iso8601
        }
      end

      private

      def expires_within_window
        return if expires_at.nil?

        now = Time.current
        errors.add(:expires_at, :invalid) unless expires_at > now && expires_at <= now + MAX_TTL
      end

      # A quick credit self-approval stays valid only while the switch is on
      # and its cashier may still sell on credit.
      def approver_allowed?
        policy = AccessPolicy.new(store: store, staff: approver)
        return FeaturePolicy.quick_credit?(branch) && policy.allows?(branch, Capabilities::CREDIT_SELL) if self_approved_credit?

        policy.allows?(branch, Capabilities::APPROVE)
      end

      # Only a quick credit sale may be approved by its own cashier.
      def self_approved_credit?
        approver_id.present? && approver_id == requester_id && action == Credit::ACTION
      end

      # A self-approval is created only with `self_credit`; once stored it may
      # be consumed or revoked like any other approval.
      def approver_is_distinct
        return unless approver_id.present? && approver_id == requester_id
        return if action == Credit::ACTION && (self_credit || (persisted? && !approver_id_changed? && !requester_id_changed?))

        errors.add(:approver, :invalid)
      end
    end
  end
end
