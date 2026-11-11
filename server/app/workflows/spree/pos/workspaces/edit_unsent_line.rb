# frozen_string_literal: true

module Spree
  module Pos
    module Workspaces
      # Changes the quantity of a table order's line the kitchen has not been
      # told about, without a lease. The line's own version is checked
      # instead of the order's revision, so people working on other lines
      # never block each other. A sent line is voided (Kitchen::VoidSent),
      # not edited.
      module EditUnsentLine
        module_function

        def call(workspace:, staff:, key:, sale_line_id:, row_version:, quantity:)
          payload = { 'command' => 'edit_unsent_line', 'sale_line_id' => sale_line_id.to_s, 'row_version' => row_version.to_s,
                      'quantity' => quantity }
          AppendItems.run(workspace: workspace, staff: staff, key: key, payload: payload) do
            AppendItems.validate_append!(workspace)
            sale_line = unsent_line!(workspace, sale_line_id, row_version)
            base_quantity = ManageLineItem.change_quantity!(workspace, sale_line, quantity, nil)
            workspace.update!(revision: workspace.revision + 1)
            AuditEntry.record!(store: workspace.store, actor: staff, action: 'workspace.item.update', subject: workspace,
                               metadata: { sale_line_id: sale_line.prefixed_id, quantity: base_quantity, row_version: sale_line.row_version })
            workspace.to_pos
          end
        end

        # The line as the client saw it: still there, at the same version,
        # and not sent to the kitchen.
        def unsent_line!(workspace, sale_line_id, row_version)
          sale_line = SaleLine.locate(SaleLine.where(workspace_id: workspace.id), sale_line_id)
          sale_line&.lock!
          if sale_line.nil? || sale_line.row_version.to_s != row_version.to_s
            raise Conflict.new('Someone else just changed this line.', revision: workspace.revision, reason: 'line_changed',
                                                                         details: { sale_line: sale_line && current(sale_line) })
          end
          if sale_line.kitchen_sent_quantity.positive?
            raise Conflict.new('This line was already sent to the kitchen; void the sent part instead.',
                               revision: workspace.revision, reason: 'line_sent', details: { sale_line: current(sale_line) })
          end

          sale_line
        end

        def current(sale_line)
          { sale_line_id: sale_line.prefixed_id, row_version: sale_line.row_version, sale_quantity: sale_line.sale_quantity.to_s('F'),
            kitchen_sent_quantity: sale_line.kitchen_sent_quantity.to_s('F') }
        end
      end
    end
  end
end
