# frozen_string_literal: true

module Spree
  module Pos
    module Workspaces
      # Tags where the sale came from (Tại quầy, Facebook, Zalo, Khác). It
      # moves no money, so it can change while a payment is under way, until
      # the sale is completed. Picking the current source changes nothing.
      class SetOrderSource
        def self.call(workspace:, staff:, revision:, lease_generation:, editor_id:, key:, order_source:)
          payload = {
            'command' => 'order_source.set', 'revision' => revision, 'lease_generation' => lease_generation,
            'editor_digest' => Workspace.editor_digest(editor_id), 'order_source' => order_source.to_s
          }
          CommandExecutor.call(store: workspace.store, actor: staff, key: key, payload: payload, workspace: workspace,
                               authorize: -> { Deliveries::Assign.authorize!(workspace, staff) }) do
            Deliveries::Assign.validate_editing!(workspace, staff, revision, lease_generation, editor_id)
            value = order_source.to_s
            unless Workspace::ORDER_SOURCES.include?(value)
              raise Conflict.new('Order source is invalid.', revision: workspace.revision, reason: 'order_source_invalid')
            end

            if workspace.order_source != value
              before = workspace.order_source
              workspace.update!(order_source: value, revision: workspace.revision + 1)
              AuditEntry.record!(store: workspace.store, actor: staff, action: 'workspace.order_source.set', subject: workspace,
                                 metadata: { before: before, order_source: value })
            end
            workspace.to_pos
          end
        end
      end
    end
  end
end
