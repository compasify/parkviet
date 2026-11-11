# frozen_string_literal: true

module Spree
  module Pos
    module Tables
      # Moves an order to another table. The order keeps its lines, kitchen
      # tickets and shift; it takes the first free letter at the new table.
      module Move
        module_function

        def call(workspace:, staff:, revision:, lease_generation:, editor_id:, key:, resource_id:)
          payload = { 'command' => 'table.move', 'revision' => revision, 'lease_generation' => lease_generation,
                      'editor_digest' => Workspace.editor_digest(editor_id), 'resource_id' => resource_id.to_s }
          CommandExecutor.call(store: workspace.store, actor: staff, key: key, payload: payload, workspace: workspace,
                               authorize: -> { Guard.edit!(workspace, staff) }) do
            ModulePolicy.require!(workspace.branch, Guard::MODULE)
            Guard.source!(workspace, staff, revision, lease_generation, editor_id)
            raise Conflict.new('This order is not at a table.', revision: workspace.revision, reason: 'not_table_order') if workspace.resource.nil?

            from = workspace.resource
            to = Guard.table!(workspace.branch, resource_id)
            raise Conflict.new('The order is already at this table.', revision: workspace.revision, reason: 'same_table') if to.id == from.id

            to.lock!
            Guard.usable!(to)
            workspace.update!(resource: to, table_label: Guard.next_label(to, except: workspace.id), revision: workspace.revision + 1)
            AuditEntry.record!(store: workspace.store, actor: staff, action: 'table.move', subject: workspace,
                               metadata: { from_resource_id: from.prefixed_id, to_resource_id: to.prefixed_id, table_label: workspace.table_label })
            Guard.announce!(workspace.branch, [], [from, to])
            workspace.to_pos
          end
        end
      end
    end
  end
end
