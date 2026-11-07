# frozen_string_literal: true

module Spree
  module Pos
    module Workspaces
      class AssignCustomer
        def self.call(workspace:, staff:, revision:, lease_generation:, editor_id:, key:, profile_id:)
          editor_digest = Workspace.editor_digest(editor_id)
          payload = {
            'command' => 'assign_customer', 'revision' => revision, 'lease_generation' => lease_generation,
            'editor_digest' => editor_digest, 'profile_id' => profile_id.to_s.presence
          }
          authorize = lambda do
            policy = AccessPolicy.new(store: workspace.store, staff: staff)
            raise CanCan::AccessDenied if workspace.branch.disabled? || workspace.register&.disabled? ||
              workspace.shift.owner_id != staff.id ||
              !policy.permission?('write_pos_orders') || !policy.allows?(workspace.branch, Capabilities::OPEN_SHIFT)
          end
          CommandExecutor.call(store: workspace.store, actor: staff, key: key, payload: payload, workspace: workspace, authorize: authorize) do
            validate!(workspace, staff, revision, lease_generation, editor_id)
            profile = profile_id.present? ? profile!(workspace, profile_id) : nil
            workspace.order.update!(customer: profile&.customer, email: profile&.email)
            workspace.update!(pos_customer: profile, revision: workspace.revision + 1)
            AuditEntry.record!(
              store: workspace.store, actor: staff, action: profile ? 'workspace.customer.assign' : 'workspace.customer.clear',
              subject: workspace, metadata: { profile_id: profile&.prefixed_id, customer_id: profile&.customer&.prefixed_id }
            )
            workspace.to_pos
          end
        end

        def self.validate!(workspace, staff, revision, lease_generation, editor_id)
          raise Conflict.new('Workspace is not editing.', revision: workspace.revision) unless workspace.operational_status == 'editing'
          raise Conflict.new('Lease is stale.', revision: workspace.revision, reason: 'lease_stale') unless workspace.lease_current?(staff, editor_id) && workspace.lease_generation == lease_generation
          raise Conflict.new('Revision is stale.', revision: workspace.revision) if workspace.revision != revision
          raise Conflict, 'Order is completed or has a payment.' if workspace.order.completed? || workspace.order.payments.exists?
        end

        def self.profile!(workspace, profile_id)
          profile = CustomerProfile.locate(CustomerProfile.for_store(workspace.store), profile_id)
          raise ActiveRecord::RecordNotFound if profile.nil?

          profile
        end
      end
    end
  end
end
