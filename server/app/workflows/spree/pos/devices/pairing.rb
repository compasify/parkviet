# frozen_string_literal: true

module Spree
  module Pos
    module Devices
      # Issues a single-use pairing code and the QR payload. The plain code
      # is returned to the manager and stored only as a digest. A repeated
      # idempotency key returns the same code.
      class Pairing
        def self.call(store:, staff:, key:, branch_id:, mode:, base_url:, register_id: nil, device_id: nil)
          branch = Guard.branch!(store, branch_id)
          chosen = mode.to_s
          raise Conflict.new('Device mode is invalid.', reason: 'device_mode_invalid') unless Device::MODES.include?(chosen)

          register = chosen == 'kiosk' ? Guard.register!(branch, register_id) : nil
          existing = device_id.present? ? Guard.device!(store, device_id) : nil
          raise Conflict.new('That device is at another branch.', reason: 'device_branch_mismatch') if existing && existing.branch_id != branch.id

          payload = {
            'command' => 'device.pairing', 'branch_id' => branch.prefixed_id, 'mode' => chosen,
            'register_id' => register&.prefixed_id, 'device_id' => existing&.prefixed_id, 'base_url' => base_url
          }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload,
                               authorize: -> { Guard.manage!(store, staff, branch) }) do
            code = DevicePairing.new_code
            row = DevicePairing.create!(
              store: store, branch: branch, device: existing, mode: chosen, created_by: staff,
              code_digest: DevicePairing.digest(code), expires_at: Time.current + DevicePairing::TTL,
              attrs: { 'register_id' => register&.prefixed_id }.compact
            )
            AuditEntry.record!(store: store, actor: staff, action: 'device.pairing_code', subject: row,
                               metadata: { branch_id: branch.prefixed_id, mode: chosen, expires_at: row.expires_at.iso8601 })
            present(row, code, base_url)
          end
        end

        def self.present(row, code, base_url)
          {
            id: row.prefixed_id, code: code, expires_at: row.expires_at.iso8601, mode: row.mode,
            branch_id: row.branch.prefixed_id, register_id: row.attrs['register_id'],
            qr: DeviceAuthenticator.qr_payload(base_url, code)
          }
        end
      end
    end
  end
end
