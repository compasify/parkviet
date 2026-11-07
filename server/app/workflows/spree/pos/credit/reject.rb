# frozen_string_literal: true

module Spree
  module Pos
    module Credit
      # An approver declines a pending credit request, with an audited reason.
      class Reject
        def self.call(request:, staff:, key:, reason:)
          workspace = request.workspace
          payload = { 'command' => 'credit.reject', 'request_id' => request.prefixed_id, 'reason' => reason.to_s.strip }
          authorize = -> { Approve.authorize_approver!(workspace, staff) }
          CommandExecutor.call(store: workspace.store, actor: staff, key: key, payload: payload, workspace: workspace, authorize: authorize) do
            raise Conflict, 'A reason is required.' if reason.to_s.strip.blank?

            request.lock!
            raise Conflict.new('Credit request is no longer pending.', reason: 'credit_request_closed') unless request.current_status == 'pending'

            request.update!(status: 'rejected', decided_by: staff, decided_at: Time.current, reason: reason.to_s.strip.first(200))
            AuditEntry.record!(store: workspace.store, actor: staff, action: 'credit.reject', subject: workspace,
                               metadata: { request_id: request.prefixed_id, reason: request.reason })
            request.to_pos
          end
        end
      end
    end
  end
end
