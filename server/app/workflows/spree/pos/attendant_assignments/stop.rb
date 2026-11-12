# frozen_string_literal: true

module Spree
  module Pos
    module AttendantAssignments
      # Ends a turn in the attendants book now. A turn already ended is
      # left as it is. Turns on a clock also end when the clock stops
      # (`end_for!`).
      module Stop
        COMMAND = 'attendant.stop'

        module_function

        def call(store:, staff:, key:, assignment_id:)
          assignment = AttendantAssignment.locate(AttendantAssignment.for_store(store), assignment_id) || raise(ActiveRecord::RecordNotFound)
          payload = { 'command' => COMMAND, 'assignment_id' => assignment.prefixed_id }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload,
                               authorize: -> { authorize!(store, staff, assignment.branch) }) do
            assignment.lock!
            if assignment.open?
              now = Workspace.database_now
              assignment.update!(ended_at: now, ended_by: staff)
              AuditEntry.record!(store: store, actor: staff, action: COMMAND, subject: assignment,
                                 metadata: { ended_at: now.iso8601, minutes: assignment.minutes(now) })
              Realtime.publish(assignment.branch, 'resource.updated', id: assignment.resource.prefixed_id,
                                                                      refs: { attendant_assignment_id: assignment.prefixed_id })
            end
            assignment.to_pos
          end
        end

        # Whoever runs play time at the branch.
        def authorize!(store, staff, branch)
          policy = AccessPolicy.new(store: store, staff: staff)
          raise CanCan::AccessDenied if branch.disabled? || !policy.allows?(branch, Capabilities::TIMED_OPERATE)
        end

        # Ends the open turns on a clock that stopped, inside its command.
        def end_for!(session, staff, now)
          AttendantAssignment.open.where(timed_session_id: session.id).update_all(ended_at: now, ended_by_id: staff.id, updated_at: Time.current)
        end
      end
    end
  end
end
