# frozen_string_literal: true

module Spree
  module Pos
    module Resources
      # Marks a table as being cleaned, out of service, or back in use. A
      # table with open orders cannot be taken out of service.
      module SetManualStatus
        module_function

        def call(store:, staff:, key:, branch:, resource:, manual_status:)
          status = manual_status.to_s
          payload = { 'command' => 'resource.manual_status', 'resource_id' => resource.prefixed_id, 'manual_status' => status }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: -> { Guard.mark!(store, staff, branch) }) do
            ModulePolicy.require!(branch, Guard::MODULE)
            unless Resource::MANUAL_STATUSES.include?(status)
              raise Conflict.new('Status is invalid.', reason: 'manual_status_invalid')
            end

            resource.lock!
            raise Conflict.new('This table is archived.', reason: 'table_archived') unless resource.active?
            if status == 'out_of_service' && Workspace.where(resource_id: resource.id, operational_status: Workspace::OPEN_STATUSES).exists?
              raise Conflict.new('This table has an open order.', reason: 'table_in_use')
            end

            before = resource.manual_status
            if before != status
              resource.update!(manual_status: status)
              AuditEntry.record!(store: store, actor: staff, action: 'resource.manual_status', subject: resource,
                                 metadata: { before: before, after: status })
              Guard.changed!(branch, resource)
            end
            resource.to_pos
          end
        end
      end
    end
  end
end
