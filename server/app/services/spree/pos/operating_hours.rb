# frozen_string_literal: true

module Spree
  module Pos
    # Windows of the week, in the branch's time zone: when a branch opens
    # play time (`Branch#operating_windows`), and when a timed promotion
    # applies. A window is `{ "days" => [0..6], "from" => "HH:MM", "to" =>
    # "HH:MM" }` with 0 = Sunday; "24:00" ends at midnight, and a window
    # whose end comes before its start runs past midnight and belongs to the
    # day it starts. No windows means always open.
    #
    # Starting a clock outside the branch's windows is only warned about
    # (`outside_operating_hours`), never refused: the rule is the branch's
    # own, not a check the law makes.
    module OperatingHours
      WARNING = 'outside_operating_hours'
      CLOCK = /\A(?:([01]\d|2[0-3]):([0-5]\d)|24:00)\z/
      MAX_WINDOWS = 14

      module_function

      # nil when `at` is inside the branch's windows, else the warning.
      def check(branch, at)
        open?(branch.operating_windows, at, branch.timezone) ? nil : WARNING
      end

      def open?(windows, at, timezone)
        list = Array(windows)
        return true if list.empty?

        zone = ActiveSupport::TimeZone[timezone.to_s] || Time.zone
        local = at.in_time_zone(zone)
        minute = (local.hour * 60) + local.min
        wday = local.wday
        list.any? { |window| covers?(window, wday, minute) }
      end

      def covers?(window, wday, minute)
        days = Array(window['days']).map(&:to_i)
        from = minute_of(window['from'])
        to = minute_of(window['to'])
        return days.include?(wday) && minute >= from && minute < to if to > from

        (days.include?(wday) && minute >= from) || (days.include?((wday - 1) % 7) && minute < to)
      end

      def minute_of(clock)
        hour, min = clock.to_s.split(':').map(&:to_i)
        (hour * 60) + min
      end

      # The windows in their stored form, or raises Conflict (`field`
      # names what was sent).
      def normalize!(rows, field: 'operating_windows')
        invalid = -> { raise Conflict.new('The time windows are invalid.', reason: 'operating_windows_invalid', details: { fields: [field] }) }
        invalid.call unless rows.is_a?(Array) && rows.size <= MAX_WINDOWS
        rows.map do |row|
          row = row.to_unsafe_h if row.respond_to?(:to_unsafe_h)
          invalid.call unless row.is_a?(Hash)
          row = row.stringify_keys
          invalid.call unless (row.keys - %w[days from to]).empty?
          days = Array(row['days']).map { |day| Integer(day.to_s, 10) }.uniq.sort
          from = row['from'].to_s
          to = row['to'].to_s
          invalid.call if days.empty? || days.any? { |day| !day.between?(0, 6) }
          invalid.call unless from.match?(CLOCK) && to.match?(CLOCK) && from != '24:00' && from != to
          { 'days' => days, 'from' => from, 'to' => to }
        end
      rescue ArgumentError
        invalid.call
      end

      # Errors of windows written in a profile, in the catalog's words.
      def problem(rows)
        normalize!(rows)
        nil
      rescue Conflict
        'must be a list of { days: [0-6], from: "HH:MM", to: "HH:MM" } windows'
      end
    end
  end
end
