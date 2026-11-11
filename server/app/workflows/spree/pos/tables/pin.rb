# frozen_string_literal: true

module Spree
  module Pos
    module Tables
      # A waiter's device follows a table (pin) or stops following it (unpin),
      # to hear when its dishes are ready. Pinning twice or unpinning a table
      # that is not pinned changes nothing. Answers the device's tables.
      module Pin
        module_function

        def call(device:, staff:, key:, resource_id:, pinned: true)
          resource = Guard.table!(device.branch, resource_id)
          payload = { 'command' => pinned ? 'table.pin' : 'table.unpin', 'device_id' => device.prefixed_id,
                      'resource_id' => resource.prefixed_id }
          CommandExecutor.call(store: device.store, actor: staff, key: key, payload: payload,
                               authorize: -> { authorize!(device, staff) }) do
            ModulePolicy.require!(device.branch, Guard::MODULE)
            if pinned
              unless DeviceTablePin.exists?(device_id: device.id, resource_id: resource.id)
                DeviceTablePin.create!(store: device.store, device: device, resource: resource, staff: staff)
              end
            else
              DeviceTablePin.where(device_id: device.id, resource_id: resource.id).delete_all
            end
            tables(device, staff)
          end
        end

        # The tables a waiter's device hears about: the ones it follows, and
        # the open table orders its signed-in person added to.
        def tables(device, staff)
          serving = Workspace.where(branch_id: device.branch_id, operational_status: Workspace::OPEN_STATUSES).
                    where(id: SaleLine.where(added_by_id: staff.id).select(:workspace_id)).
                    where.not(resource_id: nil).distinct.pluck(:resource_id)
          pinned = DeviceTablePin.where(device_id: device.id).pluck(:resource_id)
          tables = Resource.where(id: pinned | serving).index_by(&:id)
          { 'pinned' => pinned.filter_map { |id| tables[id]&.prefixed_id }, 'serving' => serving.filter_map { |id| tables[id]&.prefixed_id } }
        end

        # Only a waiter's device, for a person who serves tables there.
        def authorize!(device, staff)
          raise CanCan::AccessDenied unless device.mode == 'waiter' && !device.branch.disabled? &&
            AccessPolicy.new(store: device.store, staff: staff).allows?(device.branch, Capabilities::TABLE_SERVE)
        end
      end
    end
  end
end
