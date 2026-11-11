# frozen_string_literal: true

module Spree
  module Pos
    module Tables
      # Splits an order by item: the chosen lines move, whole, to a new order
      # at the same table or at another one, on the same shift. At least one
      # line stays; moving everything is a table move.
      module Split
        module_function

        def call(workspace:, staff:, revision:, lease_generation:, editor_id:, key:, sale_line_ids:, resource_id: nil, guest_count: nil)
          ids = Array(sale_line_ids).map(&:to_s).uniq.sort
          payload = { 'command' => 'table.split', 'workspace_id' => workspace.prefixed_id, 'revision' => revision,
                      'lease_generation' => lease_generation, 'editor_digest' => Workspace.editor_digest(editor_id),
                      'sale_line_ids' => ids, 'resource_id' => resource_id.to_s.presence, 'guest_count' => guest_count&.to_s }
          CommandExecutor.call(store: workspace.store, actor: staff, key: key, payload: payload,
                               authorize: -> { Guard.edit!(workspace, staff) }) do
            source, = Guard.lock_all!([workspace])
            ModulePolicy.require!(source.branch, Guard::MODULE)
            Guard.source!(source, staff, revision, lease_generation, editor_id)
            raise Conflict.new('This order is not at a table.', revision: source.revision, reason: 'not_table_order') if source.resource.nil?

            count = Guard.guest_count!(guest_count)
            all = SaleLine.where(workspace_id: source.id).to_a
            chosen = ids.map { |id| SaleLine.locate(SaleLine.where(workspace_id: source.id), id) }
            raise Conflict.new('Choose the items to split off.', revision: source.revision, reason: 'split_lines_invalid') if chosen.empty? || chosen.any?(&:nil?)
            raise Conflict.new('Leave at least one item on this order.', revision: source.revision, reason: 'split_all_lines') if chosen.size >= all.size

            table = resource_id.present? ? Guard.table!(source.branch, resource_id) : source.resource
            table.lock!
            Guard.usable!(table) if table.id != source.resource_id
            Guard.movable_lines!(source, chosen)
            created = Workspaces::Create.draft!(store: source.store, staff: staff, shift: source.shift,
                                                editor_digest: Workspace.editor_digest(editor_id), service_mode: source.service_mode,
                                                resource: table, guest_count: count, table_label: Guard.next_label(table))
            Guard.move_lines!(chosen, created)
            Guard.recalculate!(created)
            Guard.recalculate!(source)
            # The lines' lots are chosen again when each order is paid.
            chosen.each { |line| Inventory::AllocateTraceability.release_line!(line) }
            created.update!(revision: created.revision + 1)
            Guard.bump!(source)
            AuditEntry.record!(store: source.store, actor: staff, action: 'table.split', subject: source,
                               metadata: { new_workspace_id: created.prefixed_id, sale_line_ids: chosen.map(&:prefixed_id),
                                           from_resource_id: source.resource.prefixed_id, to_resource_id: table.prefixed_id })
            AuditEntry.record!(store: source.store, actor: staff, action: 'workspace.create', subject: created,
                               metadata: { split_from_workspace_id: source.prefixed_id })
            Guard.announce!(source.branch, [source, created], [source.resource, table])
            { 'workspace' => source.to_pos, 'new_workspace' => created.to_pos }
          end
        end
      end
    end
  end
end
