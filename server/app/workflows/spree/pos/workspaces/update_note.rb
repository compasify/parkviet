# frozen_string_literal: true

module Spree
  module Pos
    module Workspaces
      # A POS-only draft note. It is deliberately not copied to the core order
      # until checkout/printing semantics are enabled under the later gates.
      class UpdateNote
        MAX_LENGTH = 1000

        def self.call(workspace:, staff:, revision:, lease_generation:, editor_id:, key:, note:)
          editor_digest = Workspace.editor_digest(editor_id)
          payload = {
            'command' => 'update_note', 'revision' => revision, 'lease_generation' => lease_generation,
            'editor_digest' => editor_digest, 'note' => note.to_s
          }
          authorize = lambda do
            policy = AccessPolicy.new(store: workspace.store, staff: staff)
            raise CanCan::AccessDenied if workspace.branch.disabled? || workspace.register&.disabled? ||
              workspace.shift.owner_id != staff.id ||
              !policy.permission?('write_pos_orders') || !policy.allows?(workspace.branch, Capabilities::OPEN_SHIFT)
          end
          CommandExecutor.call(store: workspace.store, actor: staff, key: key, payload: payload, workspace: workspace, authorize: authorize) do
            raise Conflict.new('Workspace is not editing.', revision: workspace.revision) unless workspace.operational_status == 'editing'
            raise Conflict.new('Lease is stale.', revision: workspace.revision, reason: 'lease_stale') unless workspace.lease_current?(staff, editor_id) && workspace.lease_generation == lease_generation
            raise Conflict.new('Revision is stale.', revision: workspace.revision) if workspace.revision != revision
            raise Conflict, 'Order is completed or has a payment.' if workspace.order.completed? || workspace.order.payments.exists?

            normalized = note.to_s.strip.presence
            raise Conflict, 'Note is too long.' if normalized && normalized.length > MAX_LENGTH

            workspace.update!(note: normalized, revision: workspace.revision + 1)
            AuditEntry.record!(store: workspace.store, actor: staff, action: 'workspace.note.update', subject: workspace,
                               metadata: { note_present: normalized.present?, note_length: normalized&.length || 0 })
            workspace.to_pos
          end
        end
      end
    end
  end
end
