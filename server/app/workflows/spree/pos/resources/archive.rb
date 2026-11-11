# frozen_string_literal: true

module Spree
  module Pos
    module Resources
      # Takes an area or a table off the floor plan. Its history stays; a
      # table with an open order, or an area with active tables, stays until
      # those are gone.
      module Archive
        module_function

        def call(store:, staff:, key:, branch:, record:)
          payload = { 'command' => 'resource.archive', 'branch_id' => branch.prefixed_id, 'id' => record.prefixed_id }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: -> { Guard.manage!(store, staff, branch) }) do
            ModulePolicy.require!(branch, Guard::MODULE)
            record.lock!
            if record.status == 'active'
              in_use!(record)
              record.update!(status: 'archived')
              action = record.is_a?(Area) ? 'area.archive' : 'resource.archive'
              AuditEntry.record!(store: store, actor: staff, action: action, subject: record, metadata: { name: record.name })
              Guard.changed!(branch, record)
            end
            record.to_pos
          end
        end

        def in_use!(record)
          if record.is_a?(Area)
            return unless record.resources.active.exists?

            raise Conflict.new('Archive the tables of this area first.', reason: 'area_in_use')
          end
          return unless Workspace.where(resource_id: record.id, operational_status: Workspace::OPEN_STATUSES).exists?

          raise Conflict.new('This table has an open order.', reason: 'table_in_use')
        end
      end
    end
  end
end
