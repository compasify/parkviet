# frozen_string_literal: true

module Spree
  module Pos
    module TimedSessions
      # Every minute: tells the branch's devices about clocks that need
      # someone, as a `resource.updated` with an alert and nothing else:
      # - `ending_soon`: a running clock's planned end (its package's end
      #   when it has one) is within ResourceState::ENDING_SOON;
      # - `ended_package`: a running clock has played its whole package;
      # - `pause_too_long`: a clock is paused longer than its branch allows.
      # Each alert goes once per deadline (the end it was sent for is kept
      # in the session's `alerts`); a pause or a change that moves the end
      # makes a new deadline. It never changes money or the clock, and
      # screens count down from the server's end on their own, so a late
      # run only delays the notice.
      class AlertJob < ApplicationJob
        queue_as :default

        def perform(limit: 1000)
          now = Workspace.database_now
          ids = TimedSession.active.where("planned_end_at <= ? OR status = 'paused'", now + ResourceState::ENDING_SOON).
                order(:id).limit(limit).pluck(:id)
          ids.each { |id| alert!(id, now) }
        end

        private

        def alert!(id, now)
          TimedSession.transaction do
            session = TimedSession.lock.includes(:branch, :resource, :timed_segments).find(id)
            due(session, now).each do |alert, deadline|
              next if session.alerts[alert] == deadline

              session.update_columns(alerts: session.alerts.merge(alert => deadline))
              Realtime.publish(session.branch, 'resource.updated', id: session.resource.prefixed_id, alert: alert,
                                                                   refs: { workspace_id: Workspace.prefixed_for(session.workspace_id),
                                                                           timed_session_id: session.prefixed_id })
            end
          end
        rescue StandardError => e
          Rails.error.report(e, handled: true, context: { pos_timed_session_id: id })
        end

        # { alert => the deadline it is for }
        def due(session, now)
          if session.status == 'paused'
            return Timed::Guard.long_pause?(session, now) ? { 'pause_too_long' => session.paused_since.iso8601 } : {}
          end

          ends = session.planned_end_at
          return {} if ends.nil?
          return { 'ended_package' => ends.iso8601 } if session.package? && ends <= now

          ends <= now + ResourceState::ENDING_SOON && ends > now ? { 'ending_soon' => ends.iso8601 } : {}
        end
      end
    end
  end
end
