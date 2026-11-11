# frozen_string_literal: true

module Spree
  module Pos
    module Kitchen
      # "Fire" a held course of a table order: its held lines become fired
      # and the part the kitchen has not been told yet goes out on the same
      # path as any send (Kitchen::Send), so the stations only ever get the
      # difference. The key makes one fire: the same key again answers the
      # same tickets. Allowed to whoever serves the order, to the people at
      # the pass (pos.expo.operate) and to a pass screen of the branch.
      module FireCourse
        COMMAND = 'kitchen.fire_course'

        module_function

        # `actor` is the staff member, or the expo Device working as the machine.
        def call(workspace:, actor:, course:, key:, approval_id: nil)
          number = Workspaces::TableLines.small!(course, 1, CourseLabel::MAX, 'course_invalid')
          payload = { 'command' => COMMAND, 'course' => number }
          payload['approval_id'] = approval_id.to_s if approval_id.present?
          return fire_as_device(workspace, actor, number, key, approval_id) if actor.is_a?(Device)

          CommandExecutor.call(store: workspace.store, actor: actor, key: key, payload: payload, workspace: workspace,
                               authorize: -> { authorize!(workspace, actor) }) do
            fire!(workspace, actor, number, key, approval_id)
          end
        end

        def authorize!(workspace, staff)
          policy = AccessPolicy.new(store: workspace.store, staff: staff)
          return if policy.allows?(workspace.branch, Capabilities::EXPO_OPERATE)

          Deliveries::Assign.authorize!(workspace, staff)
        end

        # A pass screen has no person to own a command receipt; the fire is
        # idempotent by its send key instead, under the workspace lock.
        def fire_as_device(workspace, device, number, key, approval_id)
          Guard.device!(device)
          raise ActiveRecord::RecordNotFound unless device.branch_id == workspace.branch_id

          result = Workspace.transaction do
            workspace.lock!
            fire!(workspace, device, number, "device:#{device.prefixed_id}:#{key}", approval_id)
          end
          Realtime.announce_workspaces([workspace.id])
          result
        end

        def fire!(workspace, actor, number, send_key, approval_id)
          ModulePolicy.require!(workspace.branch, Send::MODULE)
          replay = KitchenTicket.where(workspace_id: workspace.id, send_key: send_key).order(:sequence).to_a
          return result(workspace, replay, 0) if replay.any?

          Workspaces::AppendItems.validate_append!(workspace, snapshot: false)
          held = SaleLine.where(workspace_id: workspace.id, course: number, course_status: 'held').lock.to_a
          raise Conflict.new('Nothing of this course is waiting.', revision: workspace.revision, reason: 'course_not_held') if held.empty?

          held.each { |line| line.update!(course_status: 'fired') }
          tickets = Send.call(workspace: workspace, actor: actor, send_key: send_key,
                              device: actor.is_a?(Device) ? actor : nil, approval_id: approval_id,
                              scope: SaleLine.where(id: held.map(&:id)))
          workspace.update!(revision: workspace.revision + 1)
          # A pass screen is named on the send (KitchenSend.device); people in the audit log.
          if actor.is_a?(Spree.admin_user_class)
            AuditEntry.record!(store: workspace.store, actor: actor, action: COMMAND, subject: workspace,
                               metadata: { course: number, lines: held.map(&:prefixed_id), tickets: tickets.map(&:prefixed_id) })
          end
          result(workspace, tickets, held.size)
        end

        def result(workspace, tickets, fired)
          { 'workspace' => workspace.to_pos, 'tickets' => tickets.map(&:to_pos), 'ticket_count' => tickets.size,
            'fired_lines' => fired }
        end
      end
    end
  end
end
