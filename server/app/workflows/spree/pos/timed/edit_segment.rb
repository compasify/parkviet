# frozen_string_literal: true

module Spree
  module Pos
    module Timed
      # Corrects when a stretch of play started or ended, with a reason: a
      # clock started late or left running. It takes `pos.timed.edit`, or a
      # manager's approval bound to the order's revision. The open stretch
      # can only have its start moved. Times never lie ahead of the
      # server's clock, and stretches never overlap. A stopped clock is
      # billed again at the corrected times; its order must still be open.
      module EditSegment
        COMMAND = 'timed.edit_segment'

        module_function

        # @return [Hash] 'workspace' and 'timed_session'
        def call(session:, staff:, key:, segment_id:, reason:, started_at: nil, ended_at: nil, approval_id: nil)
          workspace = session.workspace
          payload = { 'command' => COMMAND, 'timed_session_id' => session.prefixed_id, 'segment_id' => segment_id.to_s,
                      'started_at' => started_at&.to_s, 'ended_at' => ended_at&.to_s, 'reason' => reason.to_s,
                      'approval_id' => approval_id&.to_s }
          CommandExecutor.call(store: workspace.store, actor: staff, key: key, payload: payload, workspace: workspace,
                               authorize: -> { Guard.operate!(workspace, staff) }) do
            session.lock!
            Guard.editable!(workspace)
            segment = TimedSegment.locate(session.timed_segments, segment_id) || raise(ActiveRecord::RecordNotFound)
            raise Conflict.new('A reason is required.', revision: workspace.revision, reason: 'reason_required') if reason.to_s.strip.empty?
            if session.status == 'stopped' && ApplyMinutesCard.charged?(session)
              raise Conflict.new('A minutes card already paid this time.', revision: workspace.revision, reason: 'timed_card_charged')
            end

            new_start = Guard.time!(started_at, 'started_at')
            new_end = Guard.time!(ended_at, 'ended_at')
            if new_start.nil? && new_end.nil?
              raise Conflict.new('Give a new start or end time.', revision: workspace.revision, reason: 'time_required')
            end
            if new_end && segment.open?
              raise Conflict.new('A running stretch ends when the clock stops.', revision: workspace.revision, reason: 'segment_open')
            end

            now = Workspace.database_now
            before = { started_at: segment.started_at.iso8601, ended_at: segment.ended_at&.iso8601 }
            starts = new_start || segment.started_at
            ends = new_end || segment.ended_at
            if starts > now || (ends && ends > now)
              raise Conflict.new('Times cannot be later than now.', revision: workspace.revision, reason: 'time_in_future')
            end
            raise Conflict.new('A stretch must end after it starts.', revision: workspace.revision, reason: 'time_invalid') if ends && ends <= starts

            overlap = session.timed_segments.where.not(id: segment.id).any? do |other|
              other_end = other.ended_at || now
              starts < other_end && (ends.nil? || other.started_at < ends)
            end
            raise Conflict.new('Stretches of a clock cannot overlap.', revision: workspace.revision, reason: 'segment_overlap') if overlap

            approval = Workspaces::ApplyDiscount.approve!(workspace, staff, workspace.revision, approval_id, amount: nil,
                                                                                                         action: Approval::TIMED_EDIT_ACTION,
                                                                                                         capability: Capabilities::TIMED_EDIT,
                                                                                                         message: 'Changing play time needs a manager approval.')
            segment.update!(started_at: starts, ended_at: ends, edited: true)
            session.update!(started_at: session.timed_segments.minimum(:started_at), quote_version: session.quote_version + 1)
            Guard.refresh_planned_end!(session, now)
            if session.status == 'stopped'
              session.update!(stopped_at: session.timed_segments.maximum(:ended_at))
              session.timed_segments.reset
              Stop.bill!(session, Quote.call(session, now: now, card_lots: []))
            end
            workspace.update!(revision: workspace.revision + 1)
            AuditEntry.record!(store: workspace.store, actor: staff, action: COMMAND, subject: workspace,
                               metadata: { timed_session_id: session.prefixed_id, segment_id: segment.prefixed_id, reason: reason.to_s.strip,
                                           before: before, after: { started_at: starts.iso8601, ended_at: ends&.iso8601 },
                                           amount: session.amount&.to_s('F') }.merge(Workspaces::ApplyDiscount.approval_metadata(approval)))
            Realtime.publish(workspace.branch, 'resource.updated', id: session.resource.prefixed_id,
                                                                   refs: { workspace_id: workspace.prefixed_id, timed_session_id: session.prefixed_id })
            { 'workspace' => workspace.to_pos, 'timed_session' => Sessions.to_pos(session.reload, now: now) }
          end
        end
      end
    end
  end
end
