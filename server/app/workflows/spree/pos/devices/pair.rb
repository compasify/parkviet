# frozen_string_literal: true

module Spree
  module Pos
    module Devices
      # Exchanges a pairing code for a device token. The pairing row is
      # locked, so two devices racing the same code produce one token.
      class Pair
        def self.call(code:, platform:, name:, app_version: nil)
          normalized = DevicePairing.normalize(code)
          raise Conflict.new('The pairing code is invalid or expired.', reason: 'pairing_invalid') if normalized.nil?
          raise Conflict.new('Platform is invalid.', reason: 'device_platform_invalid') unless Device::PLATFORMS.include?(platform.to_s)

          label = name.to_s.strip
          raise Conflict.new('Device name is required.', reason: 'device_name_invalid') if label.blank? || label.length > 80

          DevicePairing.transaction do
            pairing = DevicePairing.lock.find_by(code_digest: DevicePairing.digest(normalized))
            raise Conflict.new('The pairing code is invalid or expired.', reason: 'pairing_invalid') unless pairing&.usable?

            pairing.update!(consumed_at: Time.current)
            device = pairing.device || Device.new(store: pairing.store, branch: pairing.branch, generation: 0,
                                                     token_digest: Device.digest(Device.new_token))
            register_id = pairing.attrs['register_id']
            device.assign_attributes(
              name: label, mode: pairing.mode, platform: platform.to_s, app_version: app_version.presence,
              register: register_id.present? ? Register.find_by_prefix_id!(register_id) : nil,
              status: 'active'
            )
            token = device.rotate_token!(actor: pairing.created_by)
            pairing.update!(device: device)
            AuditEntry.record!(store: device.store, actor: pairing.created_by, action: 'device.paired', subject: device,
                               metadata: { pairing_id: pairing.prefixed_id, mode: device.mode, generation: device.generation })
            { device: device.to_pos, token: token }
          end
        end
      end
    end
  end
end
