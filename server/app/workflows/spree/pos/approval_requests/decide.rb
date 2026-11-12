# frozen_string_literal: true

module Spree
  module Pos
    module ApprovalRequests
      # Shared rules of answering a request: who may decide it, and closing
      # it with an audit entry and an `approval_request.updated` event the
      # requester's device listens for.
      module Decide
        module_function

        # A manager of the request's branch who is not the requester.
        def decider!(request, staff)
          policy = AccessPolicy.new(store: request.store, staff: staff)
          raise CanCan::AccessDenied unless policy.allows?(request.branch, Capabilities::APPROVE)
          return unless request.requester_id == staff.id

          raise Conflict.new('Someone else has to approve your own request.', reason: 'approver_is_requester')
        end

        # Closes a pending request that waited too long or whose subject
        # changed since it was sent. Answers true when it did.
        def lapse!(request, staff)
          return false unless request.status == 'pending'

          subject = request.subject
          stale = subject.nil? || subject.revision.to_s != request.revision
          return false unless stale || request.expires_at <= Workspace.database_now

          finish!(request, 'expired', staff)
          true
        end

        def finish!(request, status, staff, approval: nil, reason: nil)
          request.update!(status: status, approval: approval, decided_by: staff, decided_at: Time.current)
          AuditEntry.record!(store: request.store, actor: staff, action: "approval_request.#{status}", subject: request,
                             metadata: { approval_action: request.action, approval_id: approval&.prefixed_id, reason: reason }.compact)
          refs = { approval_id: approval&.prefixed_id }
          refs[Approvals::Issue::REFS.fetch(request.subject_type)] = request.subject_type.constantize.prefixed_for(request.subject_id)
          Realtime.publish(request.branch, 'approval_request.updated', id: request.prefixed_id, refs: refs.compact)
          request
        end

        def result(request)
          { 'approval_request' => request.to_pos }
        end
      end
    end
  end
end
