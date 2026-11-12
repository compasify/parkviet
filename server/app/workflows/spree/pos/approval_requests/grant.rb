# frozen_string_literal: true

module Spree
  module Pos
    module ApprovalRequests
      # A manager grants a request from their own device. The approval is
      # issued through Approvals::Issue with the manager as approver and the
      # requester as requester, bound to the revision the requester saw, so
      # the requester's next command spends it exactly like one granted at
      # the counter. A request that waited too long or whose subject changed
      # closes as expired instead. Granting it again answers the same request.
      module Grant
        COMMAND = 'approval_request.grant'

        module_function

        def call(request:, staff:, key:)
          payload = { 'command' => COMMAND, 'approval_request_id' => request.prefixed_id }
          CommandExecutor.call(store: request.store, actor: staff, key: key, payload: payload,
                               authorize: -> { Decide.decider!(request, staff) }) do
            request.lock!
            next Decide.result(request) if request.status == 'granted' && request.decided_by_id == staff.id
            # Expired requests answer as they are: there is nothing left to decide.
            next Decide.result(request) if request.status == 'expired' || Decide.lapse!(request, staff)
            raise Conflict.new('This request was already answered.', reason: 'approval_request_decided') unless request.status == 'pending'

            approval = Approvals::Issue.call(
              store: request.store, branch: request.branch, approver: staff, requester: request.requester,
              subject: request.subject, action: request.action, revision: request.revision, amount: request.amount,
              expires_at: Time.current + ApprovalRequest::GRANT_TTL
            )
            Decide.result(Decide.finish!(request, 'granted', staff, approval: approval))
          end
        end
      end
    end
  end
end
