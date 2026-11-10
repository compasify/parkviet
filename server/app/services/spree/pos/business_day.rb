# frozen_string_literal: true

module Spree
  module Pos
    # Business date of one instant at a branch. A wall-clock time before the
    # branch cutoff belongs to the previous date; the cutoff itself starts the
    # new day. The clock is the server's (`Workspace.business_now`), never a
    # time the client sends.
    class BusinessDay
      def self.for(branch, at)
        zone = ActiveSupport::TimeZone[branch.timezone] || Time.zone
        local = at.in_time_zone(zone)
        date = local.to_date
        minutes = (local.hour * 60) + local.min
        minutes < cutoff_minutes(branch.business_day_cutoff) ? date - 1 : date
      end

      # Minutes from midnight. Accepts a time column, a Time, or "04:00".
      def self.cutoff_minutes(value)
        if value.respond_to?(:hour) && !value.is_a?(String)
          return (value.hour * 60) + value.min
        end

        clock = value.to_s[/\d{2}:\d{2}(?::\d{2})?\z/] || '04:00'
        hour, minute, = clock.split(':').map(&:to_i)
        (hour * 60) + minute
      end
    end
  end
end
