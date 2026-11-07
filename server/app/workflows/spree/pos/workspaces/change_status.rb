# frozen_string_literal: true

module Spree
  module Pos
    module Workspaces
      class ChangeStatus
        def self.call(workspace:, staff:, status:, revision:, lease_generation:, key:, editor_id:)
          editor_digest = Workspace.editor_digest(editor_id)
          payload = { 'command' => 'change_status', 'status' => status, 'revision' => revision, 'lease_generation' => lease_generation, 'editor_digest' => editor_digest }
          authorize = lambda do
            policy = AccessPolicy.new(store: workspace.store, staff: staff)
            if workspace.branch.disabled? || workspace.register&.disabled? || !policy.allows?(workspace.branch, Capabilities::OPEN_SHIFT)
              raise CanCan::AccessDenied
            end
          end
          CommandExecutor.call(store: workspace.store, actor: staff, key:, payload:, workspace:, authorize:) do
            unless workspace.lease_current?(staff, editor_id) && workspace.lease_generation == lease_generation
              raise Conflict.new('Lease is stale.', revision: workspace.revision, reason: 'lease_stale')
            end
            raise Conflict.new('Revision is stale.', revision: workspace.revision) if workspace.revision != revision
            allowed = { 'editing' => %w[parked canceled], 'parked' => %w[editing canceled], 'canceled' => [] }
            raise Conflict.new('Invalid workspace status transition.', revision: workspace.revision) unless allowed.fetch(workspace.operational_status, []).include?(status)
            if status == 'canceled' && money_recorded?(workspace)
              raise Conflict.new('A draft with recorded payments cannot be canceled.', revision: workspace.revision, reason: 'payments_recorded')
            end

            workspace.update!(operational_status: status, revision: workspace.revision + 1)
            AuditEntry.record!(store: workspace.store, actor: staff, action: "workspace.#{status}", subject: workspace)
            workspace.to_pos
          end
        end

        # Canceling would strand money that a tender or allocation still accounts
        # for; those must be resolved or reversed first. Funds that were only
        # linked to this order and are not allocated stay in the branch's
        # unapplied inbox, so they do not block the cancel.
        def self.money_recorded?(workspace)
          workspace.order.payments.where.not(status: %w[void invalid failed]).exists? ||
            TenderAttempt.where(workspace_id: workspace.id).where.not(status: %w[canceled failed]).exists? ||
            FundsAllocation.where(workspace_id: workspace.id, status: 'active').exists?
        end
      end
    end
  end
end
