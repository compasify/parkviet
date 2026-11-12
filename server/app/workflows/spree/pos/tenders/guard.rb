# frozen_string_literal: true

module Spree
  module Pos
    module Tenders
      # Shared guards for tender commands. Every writer re-checks under the
      # workspace lock via CommandExecutor; this module keeps the rules in one
      # place so prepare/confirm cannot drift apart.
      module Guard
        module_function

        def authorize_editor!(workspace, staff)
          policy = AccessPolicy.new(store: workspace.store, staff: staff)
          owner = workspace.shift.owner_id == staff.id && policy.allows?(workspace.branch, Capabilities::OPEN_SHIFT)
          raise CanCan::AccessDenied if workspace.branch.disabled? || workspace.register&.disabled? ||
            !(owner || policy.can_collect_table?(workspace)) || !policy.permission?('write_pos_orders')
        end

        # A table's bill collected by a cashier other than the shift owner is
        # booked on the collector's shift, while it holds no money yet.
        def collect_on_own_shift!(workspace, staff)
          ShiftRebind.rebind_to_collector!(workspace: workspace, staff: staff) if workspace.shift.owner_id != staff.id
        end

        def authorize_collect!(workspace, staff)
          policy = AccessPolicy.new(store: workspace.store, staff: staff)
          raise CanCan::AccessDenied unless policy.allows?(workspace.branch, Capabilities::PAYMENT)
        end

        def validate_editor!(workspace, staff, revision, lease_generation, editor_id)
          raise Conflict.new('Workspace is not editing.', revision: workspace.revision) unless workspace.operational_status == 'editing'
          raise Conflict.new('Lease is stale.', revision: workspace.revision, reason: 'lease_stale') unless workspace.lease_current?(staff, editor_id) && workspace.lease_generation == lease_generation
          raise Conflict.new('Revision is stale.', revision: workspace.revision) if workspace.revision != revision
          raise Conflict, 'Order is already placed.' if workspace.order.completed? || workspace.order.placed?
        end

        # Takes the shift close barrier (after the workspace lock, before any
        # funds or order lock), so tender, allocation and completion commands
        # serialize with closing the drawer and fail with `shift_closed` after it.
        def validate_open_shift!(workspace)
          ShiftBarrier.hold!(workspace.shift)
        end

        # Payment is only taken while every serial/lot line holds its units:
        # lots are reserved FEFO here and every reservation is held until the
        # draft completes, parks or cancels. Every path that takes or settles
        # a payment passes here, so a running clock is refused here too: play
        # time is billed only once its clock has stopped.
        def tracked_guard!(workspace)
          Timed::Guard.stopped_before_payment!(workspace)
          Inventory::AllocateTraceability.ensure!(workspace, hold: true)
        end
      end
    end
  end
end
