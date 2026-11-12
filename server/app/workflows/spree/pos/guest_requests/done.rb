# frozen_string_literal: true

module Spree
  module Pos
    module GuestRequests
      # Staff mark a guest's call or bill request as taken care of.
      module Done
        COMMAND = 'guest_request.done'

        module_function

        def call(request:, staff:, key:)
          payload = { 'command' => COMMAND, 'guest_request_id' => request.prefixed_id }
          CommandExecutor.call(store: request.store, actor: staff, key: key, payload: payload,
                               authorize: -> { GuestOrders::Guard.read!(request.store, staff, request.branch) }) do
            request.lock!
            if request.status == 'open'
              request.update!(status: 'done', handled_by: staff, handled_at: Time.current)
              Realtime.publish(request.branch, 'guest_request.updated', id: request.prefixed_id,
                                                                        refs: { resource_id: request.resource.prefixed_id })
            end
            request.to_pos
          end
        end
      end
    end
  end
end
