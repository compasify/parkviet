# frozen_string_literal: true

module Spree
  module Pos
    module Displays
      # Disconnects a display: its token stops working at once. `unresponsive`
      # is the cashier's override when the display never confirmed a clear;
      # the screen is then out of use for customers until it is bound again.
      # Revoking cannot unshow a QR code a customer already photographed; a
      # late transfer still arrives as unsolicited funds of its original order.
      class Revoke
        def self.call(store:, staff:, session_id:, reason:)
          raise Conflict.new('Unknown reason.', reason: 'reason_invalid') unless DisplaySession::REVOKE_REASONS.include?(reason.to_s)

          session = Guard.session!(store, staff, session_id)
          DisplaySession.transaction do
            session.lock!
            unless session.revoked_at
              session.update!(revoked_at: Time.current, revoke_reason: reason.to_s, pinned_workspace: nil,
                              pinned_tender_attempt: nil, pinned_at: nil)
              DisplayPairing.where(display_session_id: session.id, used_at: nil).update_all(used_at: Time.current)
              AuditEntry.record!(store: store, actor: staff, action: 'display.revoke', subject: session,
                                 metadata: { reason: reason.to_s, generation: session.generation })
            end
          end
          session.to_pos
        end
      end
    end
  end
end
