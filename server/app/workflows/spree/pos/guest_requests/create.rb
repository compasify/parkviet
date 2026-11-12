# frozen_string_literal: true

module Spree
  module Pos
    module GuestRequests
      # A guest calls staff or asks for the bill. One open request of each
      # kind per phone: asking again returns the open one. Asking for the
      # bill needs the table's order open; calling staff works at any table.
      module Create
        module_function

        # @return [GuestRequest]
        def call(session:, kind:)
          kind = kind.to_s
          raise Conflict.new('Unknown request.', reason: 'guest_request_invalid') unless GuestRequest::KINDS.include?(kind)

          GuestOrders::Guard.require!(session.branch)
          if kind == 'request_bill' && !session.ordering?
            raise Conflict.new('The table has no open order.', reason: 'table_closed')
          end

          GuestRequest.transaction do
            session.lock!
            existing = GuestRequest.still_open.find_by(guest_session_id: session.id, kind: kind)
            next existing if existing

            request = GuestRequest.create!(store: session.store, branch: session.branch, guest_session: session,
                                           resource: session.resource, workspace: session.workspace, kind: kind)
            Realtime.publish(session.branch, 'guest_request.created',
                             id: request.prefixed_id, refs: { resource_id: session.resource.prefixed_id,
                                                              workspace_id: session.workspace&.prefixed_id }.compact)
            request
          end
        end
      end
    end
  end
end
