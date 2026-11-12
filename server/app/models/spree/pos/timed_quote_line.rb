# frozen_string_literal: true

module Spree
  module Pos
    # One priced piece of a stopped session: a segment within one time band
    # of one day, its minutes (rounding included on the last piece) and its
    # amount. Printed on the bill and the invoice; never changed.
    class TimedQuoteLine < Record
      self.table_name = 'spree_pos_timed_quote_lines'
      has_prefix_id :postimedquote

      belongs_to :timed_session, class_name: 'Spree::Pos::TimedSession', inverse_of: :timed_quote_lines
      belongs_to :timed_segment, class_name: 'Spree::Pos::TimedSegment'
      belongs_to :timed_promotion, class_name: 'Spree::Pos::TimedPromotion', optional: true

      KINDS = %w[rate package card bonus].freeze

      def to_pos
        { segment_id: timed_segment.prefixed_id, starts_at: starts_at.iso8601, ends_at: ends_at.iso8601, day_type: day_type,
          label: label, price_per_hour: price_per_hour.to_s('F'), surcharge_percent: surcharge_percent.to_s('F'),
          minutes: minutes, amount: amount.to_s('F'), kind: kind, promotion_id: timed_promotion_id && TimedPromotion.prefixed_for(timed_promotion_id) }
      end
    end
  end
end
