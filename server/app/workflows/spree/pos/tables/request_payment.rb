# frozen_string_literal: true

module Spree
  module Pos
    module Tables
      # A table asks for the bill. Tells the cashiers and the customer
      # display (`payment.requested`); moves no money, locks nothing and
      # needs no lease. Asking again while a request is open returns it.
      module RequestPayment
        MODULE = 'fnb.postpay'

        module_function

        def call(workspace:, staff:, key:, note: nil, device: nil)
          note = note.to_s.strip.presence
          payload = { 'command' => 'table.request_payment', 'note' => note }
          CommandExecutor.call(store: workspace.store, actor: staff, key: key, payload: payload, workspace: workspace,
                               authorize: -> { authorize!(workspace, staff) }) do
            ModulePolicy.require!(workspace.branch, MODULE)
            Guard.editable!(workspace)
            raise Conflict.new('This order is not at a table.', revision: workspace.revision, reason: 'not_table_order') if workspace.resource_id.nil?
            raise Conflict.new('The note is too long.', reason: 'note_too_long') if note && note.length > PaymentRequest::NOTE_MAX

            request = PaymentRequest.open.find_by(workspace_id: workspace.id) ||
                      PaymentRequest.create!(workspace: workspace, requested_by: staff, device: device, note: note)
            if request.previously_new_record?
              AuditEntry.record!(store: workspace.store, actor: staff, action: 'table.request_payment', subject: workspace,
                                 metadata: { payment_request_id: request.prefixed_id })
              Realtime.publish(workspace.branch, 'payment.requested', id: request.prefixed_id,
                                                                      refs: { workspace_id: workspace.prefixed_id, resource_id: workspace.resource.prefixed_id })
              Realtime.publish(workspace.branch, 'resource.updated', id: workspace.resource.prefixed_id)
            end
            workspace.to_pos
          end
        end

        # Whoever may edit the table order, and the cashiers who collect it.
        def authorize!(workspace, staff)
          policy = AccessPolicy.new(store: workspace.store, staff: staff)
          raise CanCan::AccessDenied if workspace.branch.disabled? ||
            !(policy.can_edit_workspace?(workspace) || policy.can_collect_table?(workspace))
        end
      end
    end
  end
end
