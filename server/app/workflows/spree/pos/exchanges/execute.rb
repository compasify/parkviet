# frozen_string_literal: true

module Spree
  module Pos
    module Exchanges
      # Starts the replacement leg of an exchange: an ordinary sale workspace
      # on the staff member's own open shift, linked to the return. The new
      # goods are scanned, priced and paid through the normal sale flow; the
      # return keeps its own receipt, credit note and refund. Nothing is
      # netted between the two, so neither leg can lose stock or money.
      class Execute
        def self.call(store:, staff:, key:, return_id:, editor_id:, register_id: nil, branch_id: nil)
          payload = { 'command' => 'exchange.execute', 'return_id' => return_id.to_s, 'register_id' => register_id.to_s.presence,
                      'branch_id' => branch_id.to_s.presence, 'editor_digest' => Workspace.editor_digest(editor_id) }
          authorize = lambda do
            operation = Returns::Guard.operation!(store, return_id)
            Returns::Guard.authorize_return!(store, staff, operation.branch)
          end
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: authorize) do
            operation = Returns::Guard.operation!(store, return_id)
            operation.lock!
            raise Conflict.new('A canceled return cannot be exchanged.', reason: 'return_canceled') if operation.status == 'canceled'
            raise Conflict.new('This return already has an exchange.', reason: 'exchange_exists') if operation.exchange_operation

            created = Workspaces::Create.call(store: store, staff: staff, key: "#{key}:replacement", editor_id: editor_id,
                                              register_id: register_id, branch_id: branch_id)
            replacement = Workspace.find_by_prefix_id!(created['id'])
            raise CanCan::AccessDenied unless replacement.branch_id == operation.branch_id

            exchange = ExchangeOperation.create!(store: store, branch: operation.branch, return_operation: operation,
                                                 replacement_workspace: replacement, actor: staff)
            AuditEntry.record!(store: store, actor: staff, action: 'exchange.execute', subject: operation,
                               metadata: { exchange_id: exchange.prefixed_id, replacement_workspace_id: replacement.prefixed_id })
            exchange.to_pos.merge(workspace: created)
          end
        end
      end
    end
  end
end
