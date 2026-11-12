# frozen_string_literal: true

module Spree
  module Pos
    module Timed
      # Pauses a running clock on the server's clock: the play stretch ends
      # now and a pause stretch starts, which is never billed. Resuming
      # (Timed::Resume) plays on at the room's plan; a pause longer than the
      # branch's `max_pause_minutes` needs an approval to end. Like stopping,
      # it needs no lease. Every pause is audited, so the pauses report can
      # show who paused how often.
      module Pause
        COMMAND = 'timed.pause'

        module_function

        # @return [Hash] 'workspace' and 'timed_session'
        def call(session:, staff:, key:)
          workspace = session.workspace
          payload = { 'command' => COMMAND, 'timed_session_id' => session.prefixed_id }
          CommandExecutor.call(store: workspace.store, actor: staff, key: key, payload: payload, workspace: workspace,
                               authorize: -> { Guard.operate!(workspace, staff) }) do
            ModulePolicy.require!(workspace.branch, Guard::MODULE)
            session.lock!
            Guard.running!(session)
            if session.status == 'paused'
              raise Conflict.new('This clock is already paused.', revision: workspace.revision,
                                                                  reason: 'timed_session_paused')
            end

            Guard.editable!(workspace)
            now = Workspace.database_now
            segment = session.timed_segments.where(ended_at: nil).lock.first
            if segment.started_at >= now
              # A stretch that has not run yet becomes the pause itself.
              segment.update!(kind: 'pause', rate_plan: nil, rate_plan_version: nil)
            else
              plan = Guard.current_plan!(segment)
              segment.update!(ended_at: now, ended_reason: 'pause', rate_plan: plan, rate_plan_version: plan&.version)
              TimedSegment.create!(timed_session: session, resource: segment.resource, kind: 'pause', started_at: now)
            end
            session.update!(status: 'paused', quote_version: session.quote_version + 1)
            workspace.update!(revision: workspace.revision + 1)
            AuditEntry.record!(store: workspace.store, actor: staff, action: COMMAND, subject: workspace,
                               metadata: { timed_session_id: session.prefixed_id, resource_id: session.resource.prefixed_id,
                                           at: now.iso8601 })
            Guard.announce!(session, workspace)
            { 'workspace' => workspace.to_pos, 'timed_session' => Sessions.to_pos(session.reload, now: now) }
          end
        end
      end
    end
  end
end
