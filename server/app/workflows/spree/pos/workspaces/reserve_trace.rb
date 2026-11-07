# frozen_string_literal: true

module Spree
  module Pos
    module Workspaces
      # Reserves the draft's tracked stock now (lots FEFO, lost serial
      # reservations again) so the cashier sees exactly which lots and units
      # the sale will take before taking money. The reservations keep their
      # TTL; payment commands hold them.
      class ReserveTrace
        def self.call(workspace:, staff:, revision:, lease_generation:, editor_id:, key:)
          payload = { 'command' => 'workspace.reserve_trace', 'revision' => revision, 'lease_generation' => lease_generation,
                      'editor_digest' => Workspace.editor_digest(editor_id) }
          authorize = -> { Tenders::Guard.authorize_editor!(workspace, staff) }
          CommandExecutor.call(store: workspace.store, actor: staff, key: key, payload: payload, workspace: workspace, authorize: authorize) do
            Tenders::Guard.validate_editor!(workspace, staff, revision, lease_generation, editor_id)
            Inventory::AllocateTraceability.ensure!(workspace, hold: workspace.snapshot_locked?)
            workspace.update!(revision: workspace.revision + 1)
            AuditEntry.record!(store: workspace.store, actor: staff, action: 'workspace.trace_reserve', subject: workspace)
            workspace.to_pos
          end
        end
      end
    end
  end
end
