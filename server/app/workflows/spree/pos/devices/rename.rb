# frozen_string_literal: true

module Spree
  module Pos
    module Devices
      class Rename
        def self.call(store:, staff:, key:, device_id:, name:)
          device = Guard.device!(store, device_id)
          label = name.to_s.strip
          raise Conflict.new('Device name is required.', reason: 'device_name_invalid') if label.blank? || label.length > 80

          payload = { 'command' => 'device.rename', 'device_id' => device.prefixed_id, 'name' => label }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload,
                               authorize: -> { Guard.manage!(store, staff, device.branch) }) do
            device.update!(name: label)
            device.to_pos
          end
        end
      end
    end
  end
end
