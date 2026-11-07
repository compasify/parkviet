# frozen_string_literal: true

module Spree
  module Pos
    module Returns
      # Takes the returned units in at the receiving branch through core
      # `Spree::Returns::Approve` + `Spree::Returns::Receive`: resellable units
      # go back to the branch stock location once, damaged units are recorded
      # but never restocked. A return that needs an approval consumes it here,
      # bound to the operation, its revision and entitlement. The entitlement
      # is then posted (credit note first, refund entitlement above the debt);
      # paying any refund is a separate request.
      class Receive
        def self.call(store:, staff:, key:, return_id:, approval_id: nil)
          payload = { 'command' => 'return.receive', 'return_id' => return_id.to_s, 'approval_id' => approval_id.to_s.presence }
          authorize = -> { Guard.authorize_return!(store, staff, Guard.operation!(store, return_id).branch) }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: authorize) do
            operation = Guard.operation!(store, return_id)
            operation.lock!
            raise Conflict.new('Return was already received.', reason: 'already_received') if operation.status == 'received'
            raise Conflict.new('Return was canceled.', reason: 'return_canceled') if operation.status == 'canceled'

            # The branch policy may have changed since the return was prepared.
            raise Conflict.new('Returns are not enabled at this branch.', reason: 'returns_disabled') unless operation.branch.returns_enabled?

            if !operation.requires_approval && Guard.out_of_window?(operation.order, operation.branch)
              # Committed as the result: the return now waits for an approver
              # instead of being received outside the window.
              operation.update!(status: 'pending_approval', requires_approval: true, out_of_window: true,
                                revision: operation.revision + 1)
              AuditEntry.record!(store: store, actor: staff, action: 'return.window_expired', subject: operation)
              next operation.to_pos
            end

            rows = operation.reservations.order(:id).to_a
            Guard.lock_sale_lines!(rows.map(&:sale_line_id))
            approval = consume_approval!(store, staff, operation, approval_id)
            core = operation.core_return
            approved = Spree::Returns::Approve.call(return_record: core, approver: approval&.approver || staff)
            raise Conflict, Guard.core_error(approved, 'Core return could not be approved.') unless approved.success?

            received = Spree::Returns::Receive.call(
              return_record: core.reload, received_by: staff,
              items: rows.map { |row| { return_line_item: row.return_line_item, quantity: row.quantity, resellable: row.condition == 'resellable' } }
            )
            raise Conflict, Guard.core_error(received, 'Core return could not be received.') unless received.success?

            rows.each do |row|
              row.update!(received_quantity: row.quantity, restocked_quantity: row.condition == 'resellable' ? row.quantity : 0)
            end
            operation.update!(status: 'received', receiver: staff, received_at: Time.current)
            ApplyCreditNote.call(operation: operation, actor: staff)
            damaged = rows.sum(&:received_quantity) - rows.sum(&:restocked_quantity)
            AuditEntry.record!(store: store, actor: staff, action: 'return.receive', subject: operation,
                               metadata: { restocked: rows.sum(&:restocked_quantity), damaged: damaged,
                                           location_id: operation.branch.stock_location.prefixed_id, approval_id: approval&.prefixed_id })
            OutboxEntry.record!(store: store, event_type: 'return.received', aggregate: operation,
                                payload: { 'return_id' => operation.prefixed_id })
            operation.reload.to_pos
          end
        end

        def self.consume_approval!(store, staff, operation, approval_id)
          return nil unless operation.requires_approval

          approval = if approval_id.present?
                       Approval.locate(Approval.for_store(store).where(branch_id: operation.branch_id), approval_id)
                     else
                       operation.approval
                     end
          raise Conflict.new('This return needs an approval.', reason: 'approval_required') if approval.nil?

          approval.consume!(action: ReturnOperation::ACTION, amount: operation.entitlement_total, currency: operation.currency,
                            revision: operation.revision, subject: operation, requester: staff)
          approval
        end
      end
    end
  end
end
