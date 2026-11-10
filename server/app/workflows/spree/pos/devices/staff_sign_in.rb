# frozen_string_literal: true

module Spree
  module Pos
    module Devices
      # Checks a PIN and opens a staff session on the device. Five wrong
      # PINs in 15 minutes lock that membership on that device.
      class StaffSignIn
        def self.call(device:, membership_id:, pin:)
          membership = StaffMembership.for_store(device.store).find_by_prefix_id!(membership_id)
          raise ActiveRecord::RecordNotFound if membership.branch_id != device.branch_id || membership.status != 'active'
          raise Conflict.new('Set a PIN on the dashboard before signing in here.', reason: 'pin_not_set') if membership.pin_digest.blank?

          if DevicePinFailure.locked?(device, membership)
            raise Conflict.new('PIN is locked for 15 minutes.', reason: 'pin_locked')
          end

          unless membership.pin_matches?(pin)
            DevicePinFailure.create!(device: device, staff_membership: membership, failed_at: Time.current)
            if DevicePinFailure.locked?(device, membership)
              AuditEntry.record!(store: device.store, actor: membership.staff, action: 'device.pin_lockout', subject: device,
                                 metadata: { membership_id: membership.prefixed_id })
              raise Conflict.new('PIN is locked for 15 minutes.', reason: 'pin_locked')
            end
            raise Conflict.new('PIN is incorrect.', reason: 'pin_incorrect')
          end

          token = nil
          session = DeviceStaffSession.transaction do
            DevicePinFailure.recent(device, membership).delete_all
            DeviceStaffSession.open.where(device: device, staff_id: membership.staff_id).find_each do |row|
              row.end!('replaced')
            end
            token = DeviceStaffSession.new_token
            now = Time.current
            DeviceStaffSession.create!(
              device: device, staff: membership.staff, token_digest: DeviceStaffSession.digest(token),
              expires_at: now + DeviceStaffSession::ABSOLUTE_TTL, last_active_at: now
            )
          end
          AuditEntry.record!(store: device.store, actor: membership.staff, action: 'device.staff_sign_in', subject: device,
                             metadata: { session_id: session.prefixed_id })
          { token: token, expires_at: session.expires_at.iso8601, staff_id: membership.staff.prefixed_id, name: membership.staff.full_name }
        end
      end
    end
  end
end
