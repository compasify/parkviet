# frozen_string_literal: true

module Spree
  module Pos
    # The clock of one timed sale line: played on one room or table at a
    # time, made of segments. While it runs, its price is a quote read on
    # the server's clock and nothing is written to the line; stopping it
    # writes the quote lines and the line's minutes and price
    # (Timed::Stop). A room runs one clock at a time (partial unique index).
    class TimedSession < Record
      self.table_name = 'spree_pos_timed_sessions'
      has_prefix_id :postimed

      STATUSES = %w[running paused stopped].freeze
      ACTIVE_STATUSES = %w[running paused].freeze

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :branch, class_name: 'Spree::Pos::Branch'
      belongs_to :workspace, class_name: 'Spree::Pos::Workspace'
      belongs_to :sale_line, class_name: 'Spree::Pos::SaleLine'
      belongs_to :resource, class_name: 'Spree::Pos::Resource'
      belongs_to :started_by, class_name: staff_class_name
      belongs_to :stopped_by, class_name: staff_class_name, optional: true
      has_many :timed_segments, -> { order(:started_at, :id) }, class_name: 'Spree::Pos::TimedSegment',
                                                                 inverse_of: :timed_session, dependent: :delete_all
      has_many :timed_quote_lines, -> { order(:position) }, class_name: 'Spree::Pos::TimedQuoteLine',
                                                            inverse_of: :timed_session, dependent: :delete_all

      validates :status, inclusion: { in: STATUSES }

      scope :active, -> { where(status: ACTIVE_STATUSES) }

      def active?
        ACTIVE_STATUSES.include?(status)
      end

      def open_segment
        timed_segments.detect { |segment| segment.ended_at.nil? }
      end

      # The session as an order line shows it: its segments and, while it
      # runs, the quote up to now; once stopped, the quote it was billed at.
      def to_pos(quote: nil)
        {
          id: prefixed_id, status: status, resource_id: resource.prefixed_id, resource_name: resource.name,
          started_at: started_at.iso8601, stopped_at: stopped_at&.iso8601, planned_end_at: planned_end_at&.iso8601,
          played_minutes: played_minutes, billed_minutes: billed_minutes, amount: amount.to_s('F'), currency: currency,
          quote_version: quote_version,
          segments: timed_segments.map(&:to_pos),
          quote: quote&.to_pos || (status == 'stopped' ? stopped_quote_pos : nil)
        }
      end

      def stopped_quote_pos
        { as_of: stopped_at&.iso8601, final: true, played_minutes: played_minutes, billed_minutes: billed_minutes,
          amount: amount.to_s('F'), lines: timed_quote_lines.map(&:to_pos) }
      end
    end
  end
end
