# frozen_string_literal: true

module Spree
  module Pos
    module Timed
      # Shared rules of the play-time commands (module `timed_billing`):
      # who may run a clock, finding sessions, the time line of an order,
      # and the clock following its order to another room.
      module Guard
        MODULE = 'timed_billing'
        RUNNING_REASON = 'timed_session_running'

        module_function

        # Starting, stopping and moving a clock: whoever may edit the
        # room's order and runs play time.
        def operate!(workspace, staff)
          Deliveries::Assign.authorize!(workspace, staff)
          raise CanCan::AccessDenied unless AccessPolicy.new(store: workspace.store, staff: staff).allows?(workspace.branch, Capabilities::TIMED_OPERATE)
        end

        # Starting on a room with no order yet: whoever seats guests and runs play time.
        def start!(store, staff, branch)
          Tables::Guard.serve!(store, staff, branch)
          raise CanCan::AccessDenied unless AccessPolicy.new(store: store, staff: staff).allows?(branch, Capabilities::TIMED_OPERATE)
        end

        # Rate plans and holidays of a branch.
        def manage!(store, staff, branch)
          policy = AccessPolicy.new(store: store, staff: staff)
          raise CanCan::AccessDenied if branch.disabled? || !policy.allows?(branch, Capabilities::RATE_PLAN_MANAGE)
        end

        # Reading plans: their managers and whoever runs play time.
        def read!(store, staff, branch)
          policy = AccessPolicy.new(store: store, staff: staff)
          keys = [Capabilities::RATE_PLAN_MANAGE, Capabilities::TIMED_OPERATE, Capabilities::OPEN_SHIFT, Capabilities::REPORT_READ]
          raise CanCan::AccessDenied if keys.none? { |key| policy.allows?(branch, key) }
        end

        def branch!(store, branch_id)
          Branch.locate(Branch.for_store(store), branch_id) || raise(ActiveRecord::RecordNotFound)
        end

        def session!(store, session_id)
          TimedSession.locate(TimedSession.where(store_id: store.id), session_id) || raise(ActiveRecord::RecordNotFound)
        end

        # The order is open and takes changes: no payment has locked it.
        def editable!(workspace)
          unless Workspace::OPEN_STATUSES.include?(workspace.operational_status)
            raise Conflict.new('This order is no longer open.', revision: workspace.revision, reason: 'workspace_closed')
          end

          workspace.ensure_snapshot_editable!
        end

        def running!(session)
          return if session.active?

          raise Conflict.new('This clock has stopped.', reason: 'timed_session_stopped', details: { timed_session_id: session.prefixed_id })
        end

        # A payment is taken only once every clock of the order has stopped.
        # A rule on the data: it holds even where the module is off.
        def stopped_before_payment!(workspace)
          running = TimedSession.active.where(workspace_id: workspace.id).pluck(:id)
          return if running.empty?

          raise Conflict.new('Stop the clock before taking the payment.', revision: workspace.revision, reason: RUNNING_REASON,
                                                                           details: { timed_session_ids: running.map { |id| TimedSession.prefixed_for(id) } })
        end

        # Timed lines change only through the clock's own commands.
        def not_timed!(sale_line, workspace)
          return unless sale_line&.kind == Lines::KIND

          raise Conflict.new('Play time changes through its clock.', revision: workspace.revision, reason: 'timed_line')
        end

        # When an order moves rooms, the clock running in the old room
        # follows: the open segment ends now on the old room and the next
        # one starts on the new room at that room's plan. The old segment
        # keeps its price. Clocks of merged rooms stay in their rooms.
        def follow!(workspace, from, to, now: Workspace.database_now)
          TimedSession.active.where(workspace_id: workspace.id, resource_id: from.id).lock.each do |session|
            switch!(session, to, now)
          end
        end

        def switch!(session, to, now)
          return if session.resource_id == to.id

          plan = RatePlan.active_for(to)
          raise Conflict.new('This room has no rate plan.', reason: 'rate_plan_missing', details: { resource_id: to.prefixed_id }) if plan.nil?
          if TimedSession.active.where(resource_id: to.id).where.not(id: session.id).exists?
            raise Conflict.new('A clock already runs in this room.', reason: RUNNING_REASON, details: { resource_id: to.prefixed_id })
          end

          from = session.resource
          current = session.timed_segments.where(ended_at: nil).lock.first
          if current
            if current.started_at >= now
              # A segment that has not run yet is simply moved.
              current.update!(resource: to, rate_plan: plan, rate_plan_version: plan.version)
            else
              closing_plan = current_plan!(current)
              current.update!(ended_at: now, rate_plan: closing_plan, rate_plan_version: closing_plan&.version)
              TimedSegment.create!(timed_session: session, resource: to, kind: current.kind, started_at: now,
                                   rate_plan: current.play? ? plan : nil, rate_plan_version: current.play? ? plan.version : nil)
            end
          end
          session.update!(resource: to, quote_version: session.quote_version + 1)
          Realtime.publish(session.branch, 'resource.updated', id: from.prefixed_id, refs: { timed_session_id: session.prefixed_id })
          session
        end

        # The plan a closing segment is priced at: the room's plan of now,
        # as the running quote priced it, else the one it started on.
        def current_plan!(segment)
          return segment.rate_plan unless segment.play?

          RatePlan.active_for(segment.resource) || segment.rate_plan
        end

        # Server time as ISO 8601 in, a Time out; nil stays nil.
        def time!(value, field)
          return nil if value.blank?

          Time.iso8601(value.to_s)
        rescue ArgumentError
          raise Conflict.new("#{field} is not a valid time.", reason: 'time_invalid', details: { field: field })
        end
      end
    end
  end
end
