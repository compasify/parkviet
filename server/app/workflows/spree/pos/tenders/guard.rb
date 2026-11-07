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
          raise CanCan::AccessDenied if workspace.branch.disabled? || workspace.register&.disabled? ||
            workspace.shift.owner_id != staff.id ||
            !policy.permission?('write_pos_orders') || !policy.allows?(workspace.branch, Capabilities::OPEN_SHIFT)
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

        def tracked_guard!(workspace)
          return unless SaleLine.where(workspace: workspace).any? { |line| line.tracked_mode != 'none' }

          raise Conflict, 'Tracked goods cannot be tendered until serial/lot reservation is available (phase 8).'
        end
      end
    end
  end
end
