# frozen_string_literal: true

module Spree
  module Pos
    module Devices
      # Checks a PIN and opens a staff session on the device. Five wrong
      # PINs in 15 minutes lock that membership on that device, and the device
      # as a whole has a cap. The device row is locked for the check, so
      # concurrent guesses are counted one at a time. A refusal is returned
      # from the transaction and raised after it, so the failure row commits.
      class StaffSignIn
        def self.call(device:, membership_id:, pin:)
          membership = StaffMembership.for_store(device.store).people.find_by_prefix_id!(membership_id)
          raise ActiveRecord::RecordNotFound if membership.branch_id != device.branch_id || membership.status != 'active'
          raise Conflict.new('Set a PIN on the dashboard before signing in here.', reason: 'pin_not_set') if membership.pin_digest.blank?

          outcome = device.with_lock { attempt(device, membership, pin) }
          raise outcome if outcome.is_a?(Conflict)

          outcome
        end

        def self.attempt(device, membership, pin)
          return locked if DevicePinFailure.locked?(device, membership)
          return Conflict.new('Too many wrong PINs on this device.', reason: 'pin_rate_limited') if DevicePinFailure.device_limited?(device)
          return wrong_pin(device, membership) unless membership.pin_matches?(pin)

          open_session(device, membership)
        end

        def self.wrong_pin(device, membership)
          DevicePinFailure.create!(device: device, staff_membership: membership, failed_at: Time.current)
          return Conflict.new('PIN is incorrect.', reason: 'pin_incorrect') unless DevicePinFailure.locked?(device, membership)

          AuditEntry.record!(store: device.store, actor: membership.staff, action: 'device.pin_lockout', subject: device,
                             metadata: { membership_id: membership.prefixed_id })
          locked
        end

        def self.locked
          Conflict.new('PIN is locked for 15 minutes.', reason: 'pin_locked')
        end

        def self.open_session(device, membership)
          DevicePinFailure.recent(device, membership).delete_all
          DeviceStaffSession.open.where(device: device, staff_id: membership.staff_id).find_each { |row| row.end!('replaced') }
          token = DeviceStaffSession.new_token
          now = Time.current
          session = DeviceStaffSession.create!(
            device: device, staff: membership.staff, token_digest: DeviceStaffSession.digest(token),
            expires_at: now + DeviceStaffSession::ABSOLUTE_TTL, last_active_at: now
          )
          AuditEntry.record!(store: device.store, actor: membership.staff, action: 'device.staff_sign_in', subject: device,
                             metadata: { session_id: session.prefixed_id })
          { token: token, expires_at: session.expires_at.iso8601, staff_id: membership.staff.prefixed_id, name: membership.staff.full_name }
        end
        private_class_method :attempt, :wrong_pin, :locked, :open_session
      end
    end
  end
end
