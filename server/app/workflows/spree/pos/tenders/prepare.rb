# frozen_string_literal: true

module Spree
  module Pos
    module Tenders
      # Creates a durable tender commitment against a locked order snapshot.
      # A prepared attempt freezes item/customer/discount edits until it is
      # confirmed or canceled; it is never itself proof of money received.
      class Prepare
        def self.call(workspace:, staff:, revision:, lease_generation:, editor_id:, key:, payment_method_id:, amount:)
          parsed = Record.money(amount.to_s)
          payload = {
            'command' => 'tender.prepare', 'revision' => revision, 'lease_generation' => lease_generation,
            'editor_digest' => Workspace.editor_digest(editor_id), 'payment_method_id' => payment_method_id.to_s,
            'amount' => parsed&.to_s('F')
          }
          authorize = lambda do
            Guard.authorize_editor!(workspace, staff)
            Guard.authorize_collect!(workspace, staff)
          end
          CommandExecutor.call(store: workspace.store, actor: staff, key: key, payload: payload, workspace: workspace, authorize: authorize) do
            Guard.validate_editor!(workspace, staff, revision, lease_generation, editor_id)
            Guard.validate_open_shift!(workspace)
            Guard.tracked_guard!(workspace)
            raise Conflict, 'Amount is invalid.' if parsed.nil? || parsed <= 0

            order = workspace.order
            raise Conflict, 'Order has no items.' if order.line_items.empty?
            raise Conflict, 'Payment already exists for this order.' if order.payments.where(status: 'pending').exists?

            resolver = PaymentMethodResolver.new(store: workspace.store)
            row, core_method = resolver.resolve!(payment_method_id)
            raise Conflict, 'Payment method is not available for this store.' if core_method.nil?

            allocated = FundsAllocation.where(workspace: workspace, status: 'active').sum(:amount)
            prepared_sum = TenderAttempt.where(workspace: workspace, status: 'prepared').sum(:amount)
            remaining = order.total - allocated - prepared_sum
            raise Conflict, 'Amount exceeds the remaining balance.' if parsed > remaining

            attempt = TenderAttempt.create!(
              store: workspace.store, workspace: workspace, branch: workspace.branch, register: workspace.register,
              shift: workspace.shift, pos_payment_method: persist_method!(row, core_method), actor: staff,
              status: 'prepared', amount: parsed, order_total_snapshot: order.total, currency: order.currency,
              workspace_revision: workspace.revision,
              snapshot: { 'total' => order.total.to_s('F'), 'currency' => order.currency, 'payment_method_type' => core_method.type }
            )
            workspace.update!(revision: workspace.revision + 1)
            AuditEntry.record!(store: workspace.store, actor: staff, action: 'tender.prepare', subject: workspace,
                               metadata: { attempt_id: attempt.prefixed_id, amount: attempt.amount.to_s('F'), kind: attempt.pos_payment_method.kind })
            OutboxEntry.record!(store: workspace.store, event_type: 'tender.prepared', aggregate: attempt,
                                payload: { 'attempt_id' => attempt.prefixed_id, 'workspace_id' => workspace.prefixed_id })
            workspace.to_pos
          end
        end

        def self.persist_method!(row, core_method)
          return row if row.persisted?

          PosPaymentMethod.create!(store: row.store, code: row.code, name: row.name, kind: row.kind,
                                   payment_method_type: core_method.type, payment_method_id: core_method.id,
                                   status: 'active', position: row.position)
        rescue ActiveRecord::RecordNotUnique
          PosPaymentMethod.find_by!(store: row.store, code: row.code)
        end
      end
    end
  end
end
