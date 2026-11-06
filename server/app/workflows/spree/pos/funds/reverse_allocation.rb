# frozen_string_literal: true

module Spree
  module Pos
    module Funds
      # Reverses an unconsumed allocation: voids its core Payment and frees
      # the parent funds. Only valid before the order is placed.
      class ReverseAllocation
        def self.call(workspace:, staff:, revision:, lease_generation:, editor_id:, key:, allocation_id:)
          payload = {
            'command' => 'funds.reverse_allocation', 'revision' => revision, 'lease_generation' => lease_generation,
            'editor_digest' => Workspace.editor_digest(editor_id), 'allocation_id' => allocation_id.to_s
          }
          authorize = lambda do
            Tenders::Guard.authorize_editor!(workspace, staff)
            policy = AccessPolicy.new(store: workspace.store, staff: staff)
            raise CanCan::AccessDenied unless policy.allows?(workspace.branch, Capabilities::RESOLVE)
          end
          CommandExecutor.call(store: workspace.store, actor: staff, key: key, payload: payload, workspace: workspace, authorize: authorize) do
            Tenders::Guard.validate_editor!(workspace, staff, revision, lease_generation, editor_id)
            allocation = FundsAllocation.locate(FundsAllocation.where(workspace_id: workspace.id), allocation_id)
            raise ActiveRecord::RecordNotFound if allocation.nil?
            raise Conflict, 'Allocation is not active.' unless allocation.status == 'active'
            raise Conflict, 'Order is already placed.' if workspace.order.placed? || workspace.order.completed?

            allocation.received_funds.with_lock do
              allocation.lock!
              raise Conflict, 'Allocation is not active.' unless allocation.status == 'active'

              allocation.payment&.void!
              allocation.update!(status: 'reversed', reversed_at: Time.current)
            end
            workspace.update!(revision: workspace.revision + 1)
            AuditEntry.record!(store: workspace.store, actor: staff, action: 'funds.reverse_allocation', subject: workspace,
                               metadata: { allocation_id: allocation.prefixed_id, funds_id: allocation.received_funds.prefixed_id })
            workspace.to_pos
          end
        end
      end
    end
  end
end
