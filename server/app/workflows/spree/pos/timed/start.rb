# frozen_string_literal: true

module Spree
  module Pos
    module Timed
      # Starts the clock of a room or billiard table on the server's clock:
      # a timed line on the room's order (opened here, as a `timed` order, if
      # the room has none), a running session and its first play segment at
      # the room's rate plan. A room runs one clock at a time; two people
      # pressing Start together get one clock (the room's row lock, and a
      # partial unique index behind it). The client sends no time.
      module Start
        COMMAND = 'timed.start'

        module_function

        # @return [Hash] 'workspace' and 'timed_session'
        def call(store:, staff:, key:, editor_id:, branch_id:, resource_id:, workspace_id: nil, guest_count: nil,
                 planned_end_at: nil, device: nil)
          branch = Guard.branch!(store, branch_id)
          payload = { 'command' => COMMAND, 'branch_id' => branch.prefixed_id, 'resource_id' => resource_id.to_s,
                      'workspace_id' => workspace_id.to_s.presence, 'guest_count' => guest_count&.to_s,
                      'planned_end_at' => planned_end_at.to_s.presence, 'editor_digest' => Workspace.editor_digest(editor_id) }
          session = nil
          result = CommandExecutor.call(store: store, actor: staff, key: key, payload: payload,
                                        authorize: -> { Guard.start!(store, staff, branch) }) do
            ModulePolicy.require!(branch, Guard::MODULE)
            resource = Tables::Guard.table!(branch, resource_id)
            # Starts on one room run one after the other.
            resource.lock!
            Tables::Guard.usable!(resource)
            if TimedSession.active.exists?(resource_id: resource.id)
              raise Conflict.new('A clock already runs in this room.', reason: Guard::RUNNING_REASON, details: { resource_id: resource.prefixed_id })
            end

            plan = RatePlan.active_for(resource)
            raise Conflict.new('This room has no rate plan.', reason: 'rate_plan_missing', details: { resource_id: resource.prefixed_id }) if plan.nil?

            workspace = order_for!(store, staff, key, editor_id, branch, resource, workspace_id, guest_count)
            workspace.lock!
            Guard.operate!(workspace, staff)
            Guard.editable!(workspace)
            now = Workspace.database_now
            ends = Guard.time!(planned_end_at, 'planned_end_at')
            raise Conflict.new('The planned end is in the past.', reason: 'planned_end_invalid') if ends && ends <= now

            sale_line = Lines.create!(workspace: workspace, staff: staff, plan: plan, device: device)
            session = TimedSession.create!(store: store, branch: branch, workspace: workspace, sale_line: sale_line, resource: resource,
                                           status: 'running', started_at: now, planned_end_at: ends, currency: workspace.order.currency,
                                           started_by: staff)
            TimedSegment.create!(timed_session: session, resource: resource, kind: 'play', started_at: now, rate_plan: plan,
                                 rate_plan_version: plan.version)
            Workspaces::ApplyDiscount.recalculate!(workspace)
            workspace.update!(revision: workspace.revision + 1)
            AuditEntry.record!(store: store, actor: staff, action: COMMAND, subject: workspace,
                               metadata: { timed_session_id: session.prefixed_id, resource_id: resource.prefixed_id,
                                           rate_plan_id: plan.prefixed_id, rate_plan_version: plan.version, started_at: now.iso8601,
                                           planned_end_at: ends&.iso8601, device_id: device&.prefixed_id })
            Realtime.publish(branch, 'resource.updated', id: resource.prefixed_id,
                                                         refs: { workspace_id: workspace.prefixed_id, timed_session_id: session.prefixed_id })
            Realtime.announce_workspaces([workspace.id])
            { 'workspace' => workspace.to_pos, 'timed_session' => Sessions.to_pos(session.reload, now: now) }
          end
          result
        rescue ActiveRecord::RecordNotUnique => e
          raise unless e.message.include?('idx_pos_timed_sessions_one_clock')

          raise Conflict.new('A clock already runs in this room.', reason: Guard::RUNNING_REASON)
        end

        # The room's open order, or a new `timed` order for it. A room with
        # several open orders needs the one to bill named.
        def order_for!(store, staff, key, editor_id, branch, resource, workspace_id, guest_count)
          open = Tables::Guard.open_orders(resource).order(:id).to_a
          if workspace_id.present?
            chosen = Workspace.locate(Workspace.where(id: open.map(&:id)), workspace_id)
            raise ActiveRecord::RecordNotFound if chosen.nil?

            return chosen
          end
          return open.first if open.one?
          if open.many?
            raise Conflict.new('Choose the order of this room to bill.', reason: 'workspace_required',
                                                                         details: { workspace_ids: open.map(&:prefixed_id) })
          end

          opened = Tables::Open.call(store: store, staff: staff, key: "#{key}:open", editor_id: editor_id, branch_id: branch.prefixed_id,
                                     resource_id: resource.prefixed_id, guest_count: guest_count, service_mode: 'timed')
          Workspace.find_by_prefix_id!(opened['id'])
        end
      end
    end
  end
end
