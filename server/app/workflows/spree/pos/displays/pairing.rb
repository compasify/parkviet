# frozen_string_literal: true

module Spree
  module Pos
    module Displays
      # Pairing a separate display device without ever showing its token on
      # the cashier screen: the cashier issues a short single-use code, the
      # device exchanges it for a fresh display token (rotating the session,
      # so any other screen of it stops working).
      module Pairing
        module_function

        def issue(store:, staff:, session_id:)
          session = Guard.session!(store, staff, session_id)
          Guard.authorize_branch!(store, staff, session.branch)
          code = DisplayPairing.new_code
          pairing = DisplaySession.transaction do
            session.lock!
            Guard.usable!(session)
            DisplayPairing.where(display_session_id: session.id, used_at: nil).update_all(used_at: Time.current)
            row = DisplayPairing.create!(store: store, display_session: session, created_by: staff,
                                         code_digest: DisplayPairing.digest(code), expires_at: Time.current + DisplayPairing::TTL)
            AuditEntry.record!(store: store, actor: staff, action: 'display.pairing_code', subject: session,
                               metadata: { pairing_id: row.prefixed_id, expires_at: row.expires_at.iso8601 })
            row
          end
          { code: code, expires_at: pairing.expires_at.iso8601 }
        end

        # [session, token] for a valid code, nil otherwise (unknown, used,
        # expired, or the display can no longer be used). Callers never learn
        # which.
        def exchange(code)
          normalized = DisplayPairing.normalize(code)
          return if normalized.nil?

          DisplaySession.transaction do
            pairing = DisplayPairing.lock.find_by(code_digest: DisplayPairing.digest(normalized))
            next nil unless pairing&.usable?

            session = pairing.display_session
            session.lock!
            next nil unless session.revoked_at.nil? && session.usable?

            pairing.update!(used_at: Time.current)
            token = session.rotate_token!
            AuditEntry.record!(store: session.store, actor: pairing.created_by, action: 'display.paired', subject: session,
                               metadata: { pairing_id: pairing.prefixed_id, generation: session.generation })
            [session, token]
          end
        end
      end
    end
  end
end
