# frozen_string_literal: true

module Spree
  module Pos
    module ApprovalRequests
      # A manager turns a request down, optionally saying why. The
      # requester's device stops waiting and shows the answer.
      module Decline
        COMMAND = 'approval_request.decline'

        module_function

        def call(request:, staff:, key:, reason: nil)
          note = reason.to_s.squish.presence
          raise Conflict.new('Reason is too long.', reason: 'reason_invalid') if note && note.length > ApprovalRequest::REASON_MAX

          payload = { 'command' => COMMAND, 'approval_request_id' => request.prefixed_id, 'reason' => note }
          CommandExecutor.call(store: request.store, actor: staff, key: key, payload: payload,
                               authorize: -> { Decide.decider!(request, staff) }) do
            request.lock!
            next Decide.result(request) if request.status == 'declined' && request.decided_by_id == staff.id
            # Expired requests answer as they are: there is nothing left to decide.
            next Decide.result(request) if request.status == 'expired' || Decide.lapse!(request, staff)
            raise Conflict.new('This request was already answered.', reason: 'approval_request_decided') unless request.status == 'pending'

            Decide.result(Decide.finish!(request, 'declined', staff, reason: note))
          end
        end
      end
    end
  end
end
