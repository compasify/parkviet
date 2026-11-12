# frozen_string_literal: true

module Spree
  module Pos
    module Timed
      # Stops a clock on the server's clock: the open segment ends now (at
      # the room's current plan, as the running quote priced it), the quote
      # is written as quote lines, and the timed line takes the billed
      # minutes at the price that makes them cost the quoted amount. A clock
      # that already stopped is left as it is. A clock paused longer than the
      # branch allows needs the approval resuming it would (Guard). A minutes
      # card on the clock pays its part as it stops (ApplyMinutesCard).
      module Stop
        COMMAND = 'timed.stop'

        module_function

        # @return [Hash] 'workspace' and 'timed_session'
        def call(session:, staff:, key:, approval_id: nil)
          workspace = session.workspace
          payload = { 'command' => COMMAND, 'timed_session_id' => session.prefixed_id, 'approval_id' => approval_id.to_s.presence }
          CommandExecutor.call(store: workspace.store, actor: staff, key: key, payload: payload, workspace: workspace,
                               authorize: -> { Guard.operate!(workspace, staff) }) do
            session.lock!
            unless session.active?
              next { 'workspace' => workspace.to_pos, 'timed_session' => Sessions.to_pos(session) }
            end

            Guard.editable!(workspace)
            now = Workspace.database_now
            approval = Guard.approve_long_pause!(session, staff, now, approval_id)
            stop!(session, staff, now)
            workspace.update!(revision: workspace.revision + 1)
            AuditEntry.record!(store: workspace.store, actor: staff, action: COMMAND, subject: workspace,
                               metadata: { timed_session_id: session.prefixed_id, resource_id: session.resource.prefixed_id,
                                           stopped_at: now.iso8601, played_minutes: session.played_minutes,
                                           billed_minutes: session.billed_minutes, amount: session.amount.to_s('F') }.
                                 merge(Workspaces::ApplyDiscount.approval_metadata(approval)))
            Realtime.publish(workspace.branch, 'resource.updated', id: session.resource.prefixed_id,
                                                                   refs: { workspace_id: workspace.prefixed_id, timed_session_id: session.prefixed_id })
            { 'workspace' => workspace.to_pos, 'timed_session' => Sessions.to_pos(session.reload) }
          end
        end

        # Stops every clock of an order, inside the caller's command.
        def stop_all!(workspace, staff)
          sessions = TimedSession.active.where(workspace_id: workspace.id).lock.to_a
          return if sessions.empty?

          now = Workspace.database_now
          sessions.each do |session|
            # A canceled order is not paid, so no card pays for it.
            stop!(session, staff, now, card: false)
            AuditEntry.record!(store: workspace.store, actor: staff, action: COMMAND, subject: workspace,
                               metadata: { timed_session_id: session.prefixed_id, stopped_at: now.iso8601, reason: 'workspace_canceled' })
            Realtime.publish(workspace.branch, 'resource.updated', id: session.resource.prefixed_id, refs: { timed_session_id: session.prefixed_id })
          end
        end

        # Closes the open segment, prices the session and bills its line,
        # inside the caller's command.
        def stop!(session, staff, now, card: true)
          segment = session.timed_segments.where(ended_at: nil).lock.first
          if segment
            if segment.started_at >= now
              # A segment of no time at all is not kept.
              segment.destroy!
            else
              plan = Guard.current_plan!(segment)
              segment.update!(ended_at: now, ended_reason: 'stop', rate_plan: plan, rate_plan_version: plan&.version)
            end
          end
          session.timed_segments.reset
          quote = card ? Quote.call(session, now: now, card_lots: ApplyMinutesCard.lots!(session) || []) : Quote.call(session, now: now, card_lots: [])
          bill!(session, quote)
          session.update!(status: 'stopped', stopped_at: now, stopped_by: staff)
          AttendantAssignments::Stop.end_for!(session, staff, now)
          ApplyMinutesCard.charge!(session, quote, staff) if card
          quote
        end

        # Writes a quote as the session's lines and its order line; also
        # used when a stopped session's times are corrected.
        def bill!(session, quote)
          session.timed_quote_lines.delete_all
          quote.lines.each_with_index do |line, index|
            TimedQuoteLine.create!(timed_session: session, timed_segment: line.segment, position: index + 1,
                                   starts_at: line.starts_at, ends_at: line.ends_at, day_type: line.day_type, rate_rule_id: line.rule_id,
                                   label: line.label, price_per_hour: line.price_per_hour, surcharge_percent: line.surcharge_percent,
                                   minutes: line.minutes, amount: line.amount, kind: line.kind, timed_promotion: line.promotion)
          end
          session.update!(played_minutes: quote.played_minutes, billed_minutes: quote.billed_minutes, amount: quote.amount,
                          quote_version: session.quote_version + 1)
          Lines.write!(session.workspace, session.sale_line, minutes: quote.billed_minutes, amount: quote.amount)
        end
      end
    end
  end
end
