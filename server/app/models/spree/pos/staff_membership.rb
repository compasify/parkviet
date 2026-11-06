# frozen_string_literal: true

module Spree
  module Pos
    class StaffMembership < Record
      self.table_name = 'spree_pos_staff_memberships'
      has_prefix_id :posmembership

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :branch, class_name: 'Spree::Pos::Branch'
      belongs_to :staff, class_name: staff_class_name

      before_validation { self.capabilities = Capabilities.sanitize(capabilities) }

      validates :status, inclusion: { in: %w[active disabled] }
      validates :staff_id, uniqueness: { scope: [:store_id, :branch_id] }
      validate :capabilities_are_assignable
      validate :branch_and_staff_match_store

      scope :for_store, ->(store) { where(store_id: store.id) }

      def disabled?
        status == 'disabled'
      end

      def allows?(capability)
        return false unless Array(capabilities).include?(capability)
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
          capabilities: capabilities,
          status: status
        }
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
    end
  end
end
