# frozen_string_literal: true

module Spree
  module Pos
    module ApprovalRequests
      # The requester stops waiting: the request leaves every manager's inbox.
      module Cancel
        COMMAND = 'approval_request.cancel'

        module_function

        def call(request:, staff:, key:)
          payload = { 'command' => COMMAND, 'approval_request_id' => request.prefixed_id }
          CommandExecutor.call(store: request.store, actor: staff, key: key, payload: payload,
                               authorize: -> { raise CanCan::AccessDenied unless request.requester_id == staff.id }) do
            request.lock!
            next Decide.result(request) unless request.status == 'pending'

            Decide.result(Decide.finish!(request, 'canceled', staff))
          end
        end
      end
    end
  end
end
