# frozen_string_literal: true

module Spree
  module Pos
    # A named set of POS capabilities. A membership with a role grants the
    # role's capabilities (see StaffMembership#effective_capabilities), so a
    # change here reaches every member at once. A role in use is neither
    # disabled nor deleted.
    class StaffRole < Record
      self.table_name = 'spree_pos_staff_roles'
      has_prefix_id :posrole

      MAX_NAME_LENGTH = 80

      belongs_to :store, class_name: 'Spree::Store'
      has_many :memberships, class_name: 'Spree::Pos::StaffMembership', inverse_of: :staff_role,
                             dependent: :restrict_with_error

      before_validation do
        self.name = name.to_s.strip
        self.capabilities = Capabilities.sanitize(capabilities)
      end

      validates :name, presence: true, length: { maximum: MAX_NAME_LENGTH }
      validates :name, uniqueness: { scope: :store_id, case_sensitive: false }
      validates :status, inclusion: { in: %w[active disabled] }
      validate :capabilities_are_assignable

      scope :for_store, ->(store) { where(store_id: store.id) }

      def disabled?
        status == 'disabled'
      end

      def in_use?
        memberships.exists?
      end

      def to_pos
        { id: prefixed_id, name: name, capabilities: capabilities, status: status,
          membership_count: memberships.count, created_at: created_at.iso8601, updated_at: updated_at.iso8601 }
      end

      private

      def capabilities_are_assignable
        errors.add(:capabilities, :invalid) if (Array(capabilities) - Capabilities::ASSIGNABLE).any?
      end
    end
  end
end
