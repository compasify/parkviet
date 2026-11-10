# frozen_string_literal: true

module Spree
  module Pos
    module Devices
      class StaffSignOut
        def self.call(device:, token:)
          session = DeviceStaffSession.open.find_by(device: device, token_digest: DeviceStaffSession.digest(token.to_s))
          return if session.nil?

          session.end!('sign_out')
          AuditEntry.record!(store: device.store, actor: session.staff, action: 'device.staff_sign_out', subject: device,
                             metadata: { session_id: session.prefixed_id })
        end
      end
    end
  end
end
