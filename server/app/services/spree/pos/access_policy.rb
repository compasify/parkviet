# frozen_string_literal: true

module Spree
  module Pos
    class AccessPolicy
      def initialize(store:, staff:)
        @store = store
        @staff = reload(staff)
      end

      attr_reader :staff, :store

      def active_staff?
        staff.present? && !deactivated?
      end

      def permission?(key)
        return false unless active_staff?

        Spree.ability_class.new(staff, store: store).permission_keys.include?(key)
      end

      def memberships
        return StaffMembership.none unless active_staff?

        StaffMembership.for_store(store).where(staff_id: staff.id).includes(:staff_role)
      end

      def membership_for(branch)
        memberships.find_by(branch_id: branch.id)
      end

      def allows?(branch, capability)
        membership_for(branch)&.allows?(capability) || false
      end

      def visible_branches
        if permission?('read_pos_topology') || permission?('write_pos_topology')
          Branch.for_store(store)
        else
          Branch.for_store(store).where(id: memberships.select(:branch_id))
        end
      end

      # A kiosk register takes only the shifts a manager opens for its kiosk,
      # and a kiosk's service account opens no shift itself.
      def can_open_shift?(register)
        return false if register.disabled? || register.branch.disabled? || register.kiosk?

        membership = membership_for(register.branch)
        membership.present? && !membership.service_account && membership.allows?(Capabilities::OPEN_SHIFT)
      end

      def can_open_branch_shift?(branch)
        branch.present? && branch.store_id == store.id && !branch.disabled? &&
          allows?(branch, Capabilities::OPEN_SHIFT) && !membership_for(branch).service_account &&
          !Register.for_store(store).where(branch_id: branch.id).exists?
      end

      # Who may edit an order: the cashier whose shift it is booked on, or,
      # for an order at a table, anyone serving tables at its branch. A
      # counter order (no table) stays with its cashier.
      def can_edit_workspace?(workspace)
        return false unless active_staff?
        return true if workspace.shift.owner_id == staff.id && allows?(workspace.branch, Capabilities::OPEN_SHIFT)

        workspace.shared_service? && allows?(workspace.branch, Capabilities::TABLE_SERVE)
      end

      # A cashier other than the shift owner collecting a table's bill; the
      # order then moves to their shift (ShiftRebind.rebind_to_collector!).
      def can_collect_table?(workspace)
        workspace.shared_service? && allows?(workspace.branch, Capabilities::PAYMENT) &&
          allows?(workspace.branch, Capabilities::OPEN_SHIFT)
      end

      def can_recover?(branch)
        allows?(branch, Capabilities::RECOVER)
      end

      private

      def reload(candidate)
        return unless candidate.is_a?(Spree.admin_user_class) && candidate.persisted?

        Spree.admin_user_class.find_by(id: candidate.id)
      end

      def deactivated?
        staff.respond_to?(:deactivated?) && staff.deactivated?
      end
    end
  end
end
