# frozen_string_literal: true

module Spree
  module Pos
    # The price of an hour within a time band of one kind of day. Minutes
    # count from midnight; a band whose end comes before its start runs
    # past midnight (22:00 to 02:00 is 1320 to 120) and is priced as the
    # kind of the calendar day each minute falls on.
    class RateRule < Record
      self.table_name = 'spree_pos_rate_rules'
      has_prefix_id :posraterule

      DAY_TYPES = %w[weekday weekend holiday].freeze
      DAY_MINUTES = 1440

      belongs_to :rate_plan, class_name: 'Spree::Pos::RatePlan', inverse_of: :rate_rules

      validates :day_type, inclusion: { in: DAY_TYPES }
      validates :start_minute, numericality: { only_integer: true, in: 0..(DAY_MINUTES - 1) }
      validates :end_minute, numericality: { only_integer: true, in: 1..DAY_MINUTES }
      validates :price_per_hour, numericality: { greater_than_or_equal_to: 0 }
      validates :label, length: { maximum: 40 }
      validate :not_empty

      # The minutes of the day the band covers, as one or two ranges.
      def minute_ranges
        return [] if start_minute.nil? || end_minute.nil? || start_minute == end_minute
        return [start_minute...end_minute] if end_minute > start_minute

        [start_minute...DAY_MINUTES, 0...end_minute].reject { |range| range.size.zero? }
      end

      def covers?(minute)
        minute_ranges.any? { |range| range.cover?(minute) }
      end

      # The next minute of the day after `minute` where the band ends.
      def minutes_until_end(minute)
        stop = end_minute == DAY_MINUTES ? DAY_MINUTES : end_minute
        stop > minute ? stop - minute : DAY_MINUTES - minute
      end

      def to_pos
        { id: prefixed_id, day_type: day_type, start_minute: start_minute, end_minute: end_minute,
          price_per_hour: price_per_hour.to_s('F'), label: label, position: position }
      end

      private

      def not_empty
        errors.add(:end_minute, :invalid) if start_minute.present? && start_minute == end_minute
      end
    end
  end
end
