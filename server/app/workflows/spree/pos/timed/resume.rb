# frozen_string_literal: true

module Spree
  module Pos
    module Timed
      # Resumes a paused clock: the pause stretch ends now and play goes on
      # at the room's current plan. A pause longer than the branch's
      # `max_pause_minutes` takes `pos.timed.edit` or a manager's approval
      # of `timed.long_pause`. A clock sold with a package ends that much
      # later.
      module Resume
        COMMAND = 'timed.resume'

        module_function

        # @return [Hash] 'workspace' and 'timed_session'
        def call(session:, staff:, key:, approval_id: nil)
          workspace = session.workspace
          payload = { 'command' => COMMAND, 'timed_session_id' => session.prefixed_id, 'approval_id' => approval_id.to_s.presence }
          CommandExecutor.call(store: workspace.store, actor: staff, key: key, payload: payload, workspace: workspace,
                               authorize: -> { Guard.operate!(workspace, staff) }) do
            ModulePolicy.require!(workspace.branch, Guard::MODULE)
            session.lock!
            Guard.running!(session)
            unless session.status == 'paused'
              raise Conflict.new('This clock is not paused.', revision: workspace.revision,
                                                              reason: 'timed_session_not_paused')
            end

            Guard.editable!(workspace)
            now = Workspace.database_now
            since = session.paused_since
            approval = Guard.approve_long_pause!(session, staff, now, approval_id)
            plan = RatePlan.active_for(session.resource)
            if plan.nil?
              raise Conflict.new('This room has no rate plan.', reason: 'rate_plan_missing',
                                                                details: { resource_id: session.resource.prefixed_id })
            end

            pause = session.timed_segments.where(ended_at: nil).lock.first
            if pause.started_at >= now
              pause.update!(kind: 'play', rate_plan: plan, rate_plan_version: plan.version)
            else
              pause.update!(ended_at: now, ended_reason: 'resume')
              TimedSegment.create!(timed_session: session, resource: session.resource, kind: 'play', started_at: now, rate_plan: plan,
                                   rate_plan_version: plan.version)
            end
            session.update!(status: 'running', quote_version: session.quote_version + 1)
            Guard.refresh_planned_end!(session, now)
            workspace.update!(revision: workspace.revision + 1)
            AuditEntry.record!(store: workspace.store, actor: staff, action: COMMAND, subject: workspace,
                               metadata: { timed_session_id: session.prefixed_id, resource_id: session.resource.prefixed_id,
                                           paused_at: since&.iso8601, at: now.iso8601,
                                           paused_minutes: since ? ((now - since) / 60).floor : nil }.
                                                                                                     merge(Workspaces::ApplyDiscount.approval_metadata(approval)))
            Guard.announce!(session, workspace)
            { 'workspace' => workspace.to_pos, 'timed_session' => Sessions.to_pos(session.reload, now: now) }
          end
        end
      end
    end
  end
end
