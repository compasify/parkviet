# frozen_string_literal: true

module Spree
  module Pos
    module Tables
      # Closes a table's open payment request: `done` once the cashier has
      # it in hand, `canceled` when the guests changed their mind. Closing
      # one already closed changes nothing.
      module ResolvePaymentRequest
        STATUSES = %w[done canceled].freeze

        module_function

        def call(workspace:, staff:, key:, status:)
          status = status.to_s
          payload = { 'command' => 'table.resolve_payment_request', 'status' => status }
          CommandExecutor.call(store: workspace.store, actor: staff, key: key, payload: payload, workspace: workspace,
                               authorize: -> { RequestPayment.authorize!(workspace, staff) }) do
            raise Conflict.new('Status is invalid.', reason: 'payment_request_status_invalid') unless STATUSES.include?(status)

            request = PaymentRequest.open.lock.find_by(workspace_id: workspace.id)
            if request
              request.update!(status: status, resolved_by: staff, resolved_at: Time.current)
              AuditEntry.record!(store: workspace.store, actor: staff, action: "table.payment_request.#{status}", subject: workspace,
                                 metadata: { payment_request_id: request.prefixed_id })
              Realtime.publish(workspace.branch, 'resource.updated', id: workspace.resource.prefixed_id) if workspace.resource
            end
            workspace.to_pos
          end
        end
      end
    end
  end
end
