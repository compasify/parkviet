# frozen_string_literal: true

module Spree
  module Pos
    module Workspaces
      class ClaimLease
        def self.call(workspace:, staff:, key:, editor_id:, takeover: false)
          editor_digest = Workspace.editor_digest(editor_id)
          payload = { 'command' => 'claim_lease', 'editor_digest' => editor_digest, 'takeover' => takeover }
          authorize = lambda do
            owner = workspace.shift.owner_id == staff.id
            policy = AccessPolicy.new(store: workspace.store, staff: staff)
            takeover_allowed = policy.allows?(workspace.branch, Capabilities::TAKEOVER)
            owner_allowed = owner && policy.allows?(workspace.branch, Capabilities::OPEN_SHIFT)
            raise CanCan::AccessDenied if workspace.branch.disabled? || workspace.register&.disabled? || !(owner_allowed || takeover_allowed)
            raise CanCan::AccessDenied if workspace.operational_status == 'canceled'
          end
          CommandExecutor.call(store: workspace.store, actor: staff, key:, payload:, workspace:, authorize:) do
            active = workspace.lease_expires_at.present? && workspace.lease_expires_at > Workspace.database_now
            same_editor = workspace.lease_holder_id == staff.id && workspace.lease_editor_digest == editor_digest
            if active && !same_editor
              allowed = takeover && AccessPolicy.new(store: workspace.store, staff: staff).allows?(workspace.branch, Capabilities::TAKEOVER)
              unless allowed
                seconds = [(workspace.lease_expires_at - Workspace.database_now).ceil, 1].max
                raise Conflict.new('Workspace is being edited elsewhere.', revision: workspace.revision,
                  reason: 'lease_busy', retry_after_seconds: seconds)
              end
            end

            workspace.update!(
              lease_holder: staff,
              lease_editor_digest: editor_digest,
              lease_generation: workspace.lease_generation + 1,
              lease_expires_at: Workspace.database_now + Workspace::LEASE_TTL
            )
            AuditEntry.record!(
              store: workspace.store,
              actor: staff,
              action: active && !same_editor ? 'workspace.takeover' : 'workspace.lease',
              subject: workspace
            )
            workspace.to_pos
          end
        end
      end
    end
  end
end
