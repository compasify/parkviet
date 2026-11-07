# frozen_string_literal: true

module Spree
  module Pos
    module Displays
      # Binds a customer display to the caller's own open shift, or rebinds
      # it: the token is rotated (the previous one stops working at once),
      # the generation increments and any pin and acknowledgement are
      # dropped. The plain token is returned only here, for the cashier page
      # to hand to a display window it opens; it is never stored or shown,
      # so a retry is a new rotation rather than a replay.
      class Bind
        def self.call(store:, staff:, shift_id:)
          shift = Guard.own_shift!(store, staff, shift_id)
          FeaturePolicy.require!(shift.branch, :customer_display)
          attempts = 0
          begin
            token = nil
            session = DisplaySession.transaction do
              shift.lock!
              current = DisplaySession.live.lock.find_by(shift_id: shift.id)
              row = current
              if row
                token = row.rotate_token!(staff: staff)
              else
                token = DisplaySession.new_token
                row = DisplaySession.create!(store: store, branch: shift.branch, register: shift.register, shift: shift, staff: staff,
                                             token_digest: DisplaySession.digest(token),
                                             token_expires_at: Time.current + DisplaySession::TOKEN_TTL)
              end
              DisplayPairing.where(display_session_id: row.id, used_at: nil).update_all(used_at: Time.current)
              AuditEntry.record!(store: store, actor: staff, action: current ? 'display.rotate' : 'display.bind', subject: row,
                                 metadata: { shift_id: shift.prefixed_id, generation: row.generation })
              row
            end
          rescue ActiveRecord::RecordNotUnique
            attempts += 1
            retry if attempts < 2
            raise Conflict.new('Another display bind is in progress.', reason: 'display_busy')
          end
          { session: session.to_pos, token: token }
        end
      end
    end
  end
end
