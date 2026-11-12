# frozen_string_literal: true

module Spree
  module Pos
    module Devices
      # The signed-in person sets the PIN on their own membership. A manager
      # cannot read it and cannot set someone else's.
      class SetPin
        def self.call(store:, staff:, key:, membership_id:, pin:)
          membership = StaffMembership.for_store(store).people.find_by_prefix_id!(membership_id)
          raise CanCan::AccessDenied unless membership.staff_id == staff.id

          payload = { 'command' => 'staff.pin_set', 'membership_id' => membership.prefixed_id, 'pin_digest' => pin_digest(pin) }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: -> { true }) do
            membership.set_pin!(pin)
            AuditEntry.record!(store: store, actor: staff, action: 'staff.pin_set', subject: membership, metadata: {})
            { id: membership.prefixed_id, pin_set: true }
          end
        end

        # Receipts keep a digest of the payload. A PIN has at most a million
        # values, so it is keyed; a plain hash could be reversed from the row.
        def self.pin_digest(pin)
          secret = Rails.application.key_generator.generate_key('spree.pos.staff_pin.command_digest', 32)
          OpenSSL::HMAC.hexdigest('SHA256', secret, pin.to_s)
        end
      end
    end
  end
end
