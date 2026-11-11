# frozen_string_literal: true

module Spree
  module Pos
    module Tables
      # Merges this order into another table order: every line moves to the
      # target and this order is canceled. Both orders are locked in id
      # order, so two merges crossing each other (A into B, B into A) run one
      # after the other and the second finds its order canceled.
      module Merge
        module_function

        def call(workspace:, staff:, revision:, lease_generation:, editor_id:, key:, target_workspace_id:)
          payload = { 'command' => 'table.merge', 'workspace_id' => workspace.prefixed_id, 'revision' => revision,
                      'lease_generation' => lease_generation, 'editor_digest' => Workspace.editor_digest(editor_id),
                      'target_workspace_id' => target_workspace_id.to_s }
          target = Workspace.locate(Workspace.where(branch_id: workspace.branch_id), target_workspace_id)
          raise ActiveRecord::RecordNotFound if target.nil?

          authorize = lambda do
            Guard.edit!(workspace, staff)
            Guard.edit!(target, staff)
          end
          CommandExecutor.call(store: workspace.store, actor: staff, key: key, payload: payload, authorize: authorize) do
            source, into = Guard.lock_all!([workspace, target])
            ModulePolicy.require!(source.branch, Guard::MODULE)
            raise Conflict.new('An order cannot be merged into itself.', revision: source.revision, reason: 'same_order') if source.id == into.id

            Guard.source!(source, staff, revision, lease_generation, editor_id)
            Guard.editable!(into)
            if source.resource_id.nil? || into.resource_id.nil?
              raise Conflict.new('Only table orders are merged.', revision: source.revision, reason: 'not_table_order')
            end

            lines = SaleLine.where(workspace_id: source.id).to_a
            Guard.movable_lines!(source, lines)
            Guard.movable_lines!(into, [])
            Guard.move_lines!(lines, into)
            Guard.recalculate!(into)
            Guard.recalculate!(source)
            Inventory::AllocateTraceability.release!(source)
            guests = [source.guest_count, into.guest_count].compact.sum if source.guest_count || into.guest_count
            Guard.bump!(source)
            source.update!(operational_status: 'canceled')
            into.update!(guest_count: guests, revision: into.revision + 1)
            metadata = { source_workspace_id: source.prefixed_id, target_workspace_id: into.prefixed_id,
                         sale_line_ids: lines.map(&:prefixed_id), from_resource_id: source.resource.prefixed_id,
                         to_resource_id: into.resource.prefixed_id }
            AuditEntry.record!(store: source.store, actor: staff, action: 'table.merge', subject: into, metadata: metadata)
            AuditEntry.record!(store: source.store, actor: staff, action: 'workspace.canceled', subject: source, metadata: metadata)
            Guard.announce!(source.branch, [source, into], [source.resource, into.resource])
            into.to_pos
          end
        end
      end
    end
  end
end
