# frozen_string_literal: true

module Spree
  module Pos
    module Tables
      # Seats guests at a table: a dine-in draft pointing at the table,
      # booked on the open shift of the branch's table register (whoever
      # opens it), with its lease held by the person opening it. A table has
      # one open order by default; `add_order` opens another one beside it,
      # lettered A, B and so on.
      module Open
        module_function

        def call(store:, staff:, key:, editor_id:, branch_id:, resource_id:, guest_count: nil, add_order: false)
          editor_digest = Workspace.editor_digest(editor_id)
          add_order = add_order == true || add_order.to_s == 'true'
          payload = { 'command' => 'table.open', 'branch_id' => branch_id.to_s, 'resource_id' => resource_id.to_s,
                      'editor_digest' => editor_digest, 'guest_count' => guest_count&.to_s, 'add_order' => add_order }
          branch = Branch.locate(Branch.for_store(store), branch_id) || raise(ActiveRecord::RecordNotFound)
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: -> { Guard.serve!(store, staff, branch) }) do
            ModulePolicy.require!(branch, Guard::MODULE)
            count = Guard.guest_count!(guest_count)
            resource = Guard.table!(branch, resource_id)
            # One table, one opening at a time: letters and "already open" are decided here.
            resource.lock!
            Guard.usable!(resource)
            open = Guard.open_orders(resource).order(:id).to_a
            if open.any? && !add_order
              raise Conflict.new('This table already has an open order.', reason: 'table_occupied',
                                                                           details: { workspace_ids: open.map(&:prefixed_id) })
            end

            shift = Guard.booking_shift!(branch)
            workspace = Workspaces::Create.draft!(store: store, staff: staff, shift: shift, editor_digest: editor_digest,
                                                  service_mode: 'dine_in', resource: resource, guest_count: count,
                                                  table_label: Guard.next_label(resource))
            AuditEntry.record!(store: store, actor: staff, action: 'table.open', subject: workspace,
                               metadata: { resource_id: resource.prefixed_id, guest_count: count, table_label: workspace.table_label,
                                           shift_id: shift.prefixed_id })
            Realtime.publish(branch, 'resource.updated', id: resource.prefixed_id, refs: { workspace_id: workspace.prefixed_id })
            workspace.to_pos
          end
        end
      end
    end
  end
end
