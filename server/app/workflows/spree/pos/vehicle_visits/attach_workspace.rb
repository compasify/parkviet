# frozen_string_literal: true

module Spree
  module Pos
    module VehicleVisits
      # Puts an order on an open coach visit of its branch, moves it to
      # another one, or takes it off (`visit_id` blank), by the person editing
      # the order. Only before the order completes; the visit's revenue is
      # read from its completed orders when it closes. The order's money, lines
      # and e-invoice do not change. Other screens hear `workspace.updated`.
      module AttachWorkspace
        COMMAND = 'workspace.vehicle_visit'

        module_function

        def call(workspace:, staff:, revision:, lease_generation:, editor_id:, key:, visit_id:)
          payload = { 'command' => COMMAND, 'revision' => revision, 'lease_generation' => lease_generation,
                      'editor_digest' => Workspace.editor_digest(editor_id), 'visit_id' => visit_id.to_s.presence }
          authorize = lambda do
            policy = AccessPolicy.new(store: workspace.store, staff: staff)
            raise CanCan::AccessDenied if workspace.branch.disabled? || !policy.permission?('write_pos_orders') ||
                                          !policy.can_edit_workspace?(workspace)

            Guard.operate!(workspace.store, staff, workspace.branch)
          end
          CommandExecutor.call(store: workspace.store, actor: staff, key: key, payload: payload, workspace: workspace,
                               authorize: authorize) do
            ModulePolicy.require!(workspace.branch, Guard::MODULE)
            validate!(workspace, staff, revision, lease_generation, editor_id)
            visit = visit_id.present? ? open_visit!(workspace, visit_id) : nil
            before = workspace.vehicle_visit_id
            if before != visit&.id
              workspace.update!(vehicle_visit: visit, revision: workspace.revision + 1)
              AuditEntry.record!(store: workspace.store, actor: staff, action: COMMAND, subject: workspace,
                                 metadata: { visit_id: visit&.prefixed_id, previous_visit_id: VehicleVisit.prefixed_for(before) })
            end
            workspace.to_pos
          end
        end

        def validate!(workspace, staff, revision, lease_generation, editor_id)
          if workspace.operational_status == 'completed'
            raise Conflict.new('The order is already completed.', reason: 'workspace_completed', revision: workspace.revision)
          end
          raise Conflict.new('Workspace is not editing.', revision: workspace.revision) unless workspace.operational_status == 'editing'
          unless workspace.lease_current?(staff, editor_id) && workspace.lease_generation == lease_generation
            raise Conflict.new('Lease is stale.', revision: workspace.revision, reason: 'lease_stale')
          end
          raise Conflict.new('Revision is stale.', revision: workspace.revision) if workspace.revision != revision
        end

        def open_visit!(workspace, visit_id)
          visit = VehicleVisit.locate(VehicleVisit.for_store(workspace.store).where(branch_id: workspace.branch_id), visit_id)
          raise ActiveRecord::RecordNotFound if visit.nil?

          visit.lock!
          Guard.status!(visit, 'open')
          visit
        end
      end
    end
  end
end
