# frozen_string_literal: true

module Spree
  module Pos
    module Devices
      # The signed-in person sets the PIN on their own membership. A manager
      # cannot read it and cannot set someone else's.
      class SetPin
        def self.call(store:, staff:, key:, membership_id:, pin:)
          membership = StaffMembership.for_store(store).find_by_prefix_id!(membership_id)
          raise CanCan::AccessDenied unless membership.staff_id == staff.id

          payload = { 'command' => 'staff.pin_set', 'membership_id' => membership.prefixed_id, 'pin_digest' => Digest::SHA256.hexdigest(pin.to_s) }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: -> { true }) do
            membership.set_pin!(pin)
            AuditEntry.record!(store: store, actor: staff, action: 'staff.pin_set', subject: membership, metadata: {})
            { id: membership.prefixed_id, pin_set: true }
          end
        end
      end
    end
  end
end
