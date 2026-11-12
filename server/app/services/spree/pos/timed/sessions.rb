# frozen_string_literal: true

module Spree
  module Pos
    module Timed
      # Reading sessions: a running one carries its quote up to now, a
      # stopped one the quote it was billed at.
      module Sessions
        module_function

        def to_pos(session, now: Workspace.database_now, book: nil)
          quote = session.active? ? Quote.call(session, now: now, book: book) : nil
          session.to_pos(quote: quote)
        end

        # The sessions of an order's timed lines, keyed by sale line id, in a
        # fixed number of queries.
        def for_workspace(workspace, sale_line_ids, now: Workspace.database_now)
          return {} if sale_line_ids.empty?

          sessions = TimedSession.where(workspace_id: workspace.id, sale_line_id: sale_line_ids).
                     includes(:resource, :timed_quote_lines, timed_segments: %i[resource rate_plan]).to_a
          return {} if sessions.empty?

          book = book_for(workspace.branch, sessions, now)
          sessions.to_h { |session| [session.sale_line_id, to_pos(session, now: now, book: book)] }
        end

        def book_for(branch, sessions, now)
          running = sessions.select(&:active?)
          return nil if running.empty?

          RateBook.new(branch, plan_ids: running.flat_map { |row| row.timed_segments.map(&:rate_plan_id) }.compact,
                               from: running.map(&:started_at).min, to: now)
        end
      end
    end
  end
end
