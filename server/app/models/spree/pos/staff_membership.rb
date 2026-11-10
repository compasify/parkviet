# frozen_string_literal: true

module Spree
  module Pos
    class StaffMembership < Record
      self.table_name = 'spree_pos_staff_memberships'
      has_prefix_id :posmembership

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :branch, class_name: 'Spree::Pos::Branch'
      belongs_to :staff, class_name: staff_class_name
      belongs_to :staff_role, class_name: 'Spree::Pos::StaffRole', optional: true, inverse_of: :memberships

      before_validation { self.capabilities = Capabilities.sanitize(capabilities) }

      validates :status, inclusion: { in: %w[active disabled] }
      validates :staff_id, uniqueness: { scope: [:store_id, :branch_id] }
      validate :capabilities_are_assignable
      validate :branch_and_staff_match_store
      validate :staff_role_is_assignable

      scope :for_store, ->(store) { where(store_id: store.id) }

      def disabled?
        status == 'disabled'
      end

      # The single rule for what a membership grants: its role's capabilities
      # when it has a role, otherwise its own list.
      def effective_capabilities
        staff_role ? Array(staff_role.capabilities) : Array(capabilities)
      end

      def allows?(capability)
        return false unless effective_capabilities.include?(capability)
        return true if capability == Capabilities::RECOVER

        status == 'active'
      end

      def to_pos
        {
          id: prefixed_id,
          branch_id: branch.prefixed_id,
          staff_id: staff.prefixed_id,
          staff: { id: staff.prefixed_id, email: staff.email, full_name: staff.full_name },
          branch_name: branch.name,
          capabilities: effective_capabilities,
          # The membership's own list, used again once the role is removed.
          custom_capabilities: capabilities,
          staff_role: staff_role && { id: staff_role.prefixed_id, name: staff_role.name },
          status: status,
          pin_set: pin_digest.present?
        }
      end

      # A shared-device PIN. The digest never leaves the server.
      def set_pin!(pin)
        raise Conflict.new('PIN must be 4 to 6 digits.', reason: 'pin_invalid') unless pin.to_s.match?(/\A\d{4,6}\z/)

        update!(pin_digest: BCrypt::Password.create(pin.to_s), pin_set_at: Time.current)
      end

      def pin_matches?(pin)
        return false if pin_digest.blank?

        BCrypt::Password.new(pin_digest).is_password?(pin.to_s)
      rescue BCrypt::Errors::InvalidHash
        false
      end

      def clear_pin!
        update!(pin_digest: nil, pin_set_at: nil)
      end

      private

      def capabilities_are_assignable
        unknown = Capabilities.sanitize(capabilities) - Capabilities::ASSIGNABLE
        errors.add(:capabilities, :invalid) if unknown.any?
      end

      def branch_and_staff_match_store
        errors.add(:branch, :invalid) if branch && branch.store_id != store_id
        errors.add(:staff, :invalid) if staff && staff.respond_to?(:deactivated?) && staff.deactivated?
      end

      # A disabled role keeps the members it already has but takes no new ones.
      def staff_role_is_assignable
        return if staff_role.nil?

        errors.add(:staff_role, :invalid) if staff_role.store_id != store_id
        errors.add(:staff_role, :invalid) if staff_role_id_changed? && staff_role.disabled?
      end
    end
  end
end
