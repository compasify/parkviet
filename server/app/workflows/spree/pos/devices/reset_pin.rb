# frozen_string_literal: true

module Spree
  module Pos
    module Devices
      # A manager clears a PIN. The old value is not returned. Open device
      # sessions for that person at the branch end.
      class ResetPin
        def self.call(store:, staff:, key:, membership_id:)
          membership = StaffMembership.for_store(store).find_by_prefix_id!(membership_id)
          payload = { 'command' => 'staff.pin_reset', 'membership_id' => membership.prefixed_id }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload,
                               authorize: -> { Guard.manage!(store, staff, membership.branch) }) do
            membership.clear_pin!
            DeviceStaffSession.open.joins(:device).where(staff_id: membership.staff_id, spree_pos_devices: { branch_id: membership.branch_id }).find_each do |session|
              session.end!('pin_reset')
            end
            AuditEntry.record!(store: store, actor: staff, action: 'staff.pin_reset', subject: membership, metadata: {})
            { id: membership.prefixed_id, pin_set: false }
          end
        end
      end
    end
  end
end
