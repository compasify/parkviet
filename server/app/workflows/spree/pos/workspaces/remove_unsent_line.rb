# frozen_string_literal: true

module Spree
  module Pos
    module Workspaces
      # Takes a line the kitchen has not been told about off a table order,
      # without a lease, checked against the line's own version
      # (EditUnsentLine). A sent line is voided instead.
      module RemoveUnsentLine
        module_function

        def call(workspace:, staff:, key:, sale_line_id:, row_version:)
          payload = { 'command' => 'remove_unsent_line', 'sale_line_id' => sale_line_id.to_s, 'row_version' => row_version.to_s }
          AppendItems.run(workspace: workspace, staff: staff, key: key, payload: payload) do
            AppendItems.validate_append!(workspace)
            sale_line = EditUnsentLine.unsent_line!(workspace, sale_line_id, row_version)
            sale_id = sale_line.prefixed_id
            ManageLineItem.remove_line!(workspace, sale_line)
            workspace.update!(revision: workspace.revision + 1)
            AuditEntry.record!(store: workspace.store, actor: staff, action: 'workspace.item.remove', subject: workspace,
                               metadata: { sale_line_id: sale_id })
            workspace.to_pos
          end
        end
      end
    end
  end
end
