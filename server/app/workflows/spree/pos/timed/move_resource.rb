# frozen_string_literal: true

module Spree
  module Pos
    module Timed
      # Moves a running clock, and the room's order with it, to another
      # room: the segment on the old room ends now and keeps the old room's
      # price; the next one runs at the new room's plan. Like adding items,
      # it needs no lease. The new room must be free.
      module MoveResource
        COMMAND = 'timed.move'

        module_function

        # @return [Hash] 'workspace' and 'timed_session'
        def call(session:, staff:, key:, resource_id:)
          workspace = session.workspace
          payload = { 'command' => COMMAND, 'timed_session_id' => session.prefixed_id, 'resource_id' => resource_id.to_s }
          CommandExecutor.call(store: workspace.store, actor: staff, key: key, payload: payload, workspace: workspace,
                               authorize: -> { Guard.operate!(workspace, staff) }) do
            ModulePolicy.require!(workspace.branch, Guard::MODULE)
            session.lock!
            Guard.running!(session)
            Guard.editable!(workspace)
            from = session.resource
            to = Tables::Guard.table!(workspace.branch, resource_id)
            raise Conflict.new('The clock is already in this room.', revision: workspace.revision, reason: 'same_table') if to.id == from.id

            to.lock!
            Tables::Guard.usable!(to)
            others = Tables::Guard.open_orders(to).where.not(id: workspace.id)
            if others.exists?
              raise Conflict.new('This room already has an open order.', revision: workspace.revision, reason: 'table_occupied',
                                                                          details: { workspace_ids: others.map(&:prefixed_id) })
            end

            now = Workspace.database_now
            Guard.switch!(session, to, now)
            attributes = { revision: workspace.revision + 1 }
            if workspace.resource_id == from.id
              attributes.merge!(resource: to, table_label: Tables::Guard.next_label(to, except: workspace.id))
            end
            workspace.update!(attributes)
            AuditEntry.record!(store: workspace.store, actor: staff, action: COMMAND, subject: workspace,
                               metadata: { timed_session_id: session.prefixed_id, from_resource_id: from.prefixed_id,
                                           to_resource_id: to.prefixed_id, at: now.iso8601 })
            Realtime.publish(workspace.branch, 'resource.updated', id: to.prefixed_id,
                                                                   refs: { workspace_id: workspace.prefixed_id, timed_session_id: session.prefixed_id })
            { 'workspace' => workspace.to_pos, 'timed_session' => Sessions.to_pos(session.reload, now: now) }
          end
        end
      end
    end
  end
end
