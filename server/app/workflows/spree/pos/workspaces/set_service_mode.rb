# frozen_string_literal: true

module Spree
  module Pos
    module Workspaces
      # How the sale is served. It can change until money locks the snapshot.
      # Picking the current mode changes nothing.
      class SetServiceMode
        def self.call(workspace:, staff:, revision:, lease_generation:, editor_id:, key:, service_mode:)
          mode = service_mode.to_s
          payload = {
            'command' => 'service_mode.set', 'revision' => revision, 'lease_generation' => lease_generation,
            'editor_digest' => Workspace.editor_digest(editor_id), 'service_mode' => mode
          }
          CommandExecutor.call(store: workspace.store, actor: staff, key: key, payload: payload, workspace: workspace,
                               authorize: -> { Deliveries::Assign.authorize!(workspace, staff) }) do
            Deliveries::Assign.validate_editing!(workspace, staff, revision, lease_generation, editor_id)
            workspace.ensure_snapshot_editable!
            unless Workspace::SERVICE_MODES.include?(mode)
              raise Conflict.new('Service mode is invalid.', revision: workspace.revision, reason: 'service_mode_invalid')
            end

            if workspace.service_mode != mode
              before = workspace.service_mode
              workspace.update!(service_mode: mode, revision: workspace.revision + 1)
              AuditEntry.record!(store: workspace.store, actor: staff, action: 'workspace.service_mode', subject: workspace,
                                 metadata: { before: before, service_mode: mode })
            end
            workspace.to_pos
          end
        end
      end
    end
  end
end
