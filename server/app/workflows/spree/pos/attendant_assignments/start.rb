# frozen_string_literal: true

module Spree
  module Pos
    module AttendantAssignments
      # Writes in the attendants book: who serves a room from when, until
      # they stop or the room's clock stops. It moves no money and is never
      # on the bill. Whoever runs play time at the branch may write it, at
      # the cashier's counter or from the waiter app.
      module Start
        COMMAND = 'attendant.start'

        module_function

        def call(store:, staff:, key:, branch_id:, resource_id:, attendant:, note: nil)
          branch = Timed::Guard.branch!(store, branch_id)
          text = note.to_s.strip
          payload = { 'command' => COMMAND, 'branch_id' => branch.prefixed_id, 'resource_id' => resource_id.to_s,
                      'staff_id' => attendant.prefixed_id, 'note' => text.presence }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload,
                               authorize: -> { Stop.authorize!(store, staff, branch) }) do
            ModulePolicy.require!(branch, Timed::Guard::MODULE)
            raise Conflict.new('The note is too long.', reason: 'attendant_invalid', details: { fields: ['note'] }) if text.length > 255
            unless AccessPolicy.new(store: store, staff: attendant).membership_for(branch)&.status == 'active'
              raise Conflict.new('This person does not work at the branch.', reason: 'attendant_not_member')
            end

            resource = Tables::Guard.table!(branch, resource_id)
            resource.lock!
            open = AttendantAssignment.open.find_by(staff_id: attendant.id)
            if open
              details = { assignment_id: open.prefixed_id, resource_id: open.resource.prefixed_id }
              raise Conflict.new('This person already serves a room.', reason: 'attendant_busy', details: details)
            end

            now = Workspace.database_now
            session = TimedSession.active.find_by(resource_id: resource.id)
            assignment = AttendantAssignment.create!(store: store, branch: branch, resource: resource, timed_session: session,
                                                     staff: attendant, started_at: now, started_by: staff, note: text.presence,
                                                     business_date: BusinessDay.for(branch, Workspace.business_now))
            AuditEntry.record!(store: store, actor: staff, action: COMMAND, subject: assignment,
                               metadata: { resource_id: resource.prefixed_id, staff_id: attendant.prefixed_id,
                                           timed_session_id: session&.prefixed_id, started_at: now.iso8601 })
            Realtime.publish(branch, 'resource.updated', id: resource.prefixed_id, refs: { attendant_assignment_id: assignment.prefixed_id })
            assignment.to_pos(now: now)
          end
        rescue ActiveRecord::RecordNotUnique => e
          raise unless e.message.include?('idx_pos_attendant_assignments_open')

          raise Conflict.new('This person already serves a room.', reason: 'attendant_busy')
        end
      end
    end
  end
end
