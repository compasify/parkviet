# frozen_string_literal: true

module Spree
  module Pos
    module Devices
      # Revokes a device. The old token stops working before this returns,
      # and open staff sessions on it end.
      class Revoke
        def self.call(store:, staff:, key:, device_id:)
          device = Guard.device!(store, device_id)
          payload = { 'command' => 'device.revoke', 'device_id' => device.prefixed_id }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload,
                               authorize: -> { Guard.manage!(store, staff, device.branch) }) do
            device.revoke!(actor: staff)
            Kiosks::Provision.revoke!(device: device, actor: staff)
            AuditEntry.record!(store: store, actor: staff, action: 'device.revoked', subject: device,
                               metadata: { generation: device.generation })
            device.to_pos
          end
        end
      end
    end
  end
end
