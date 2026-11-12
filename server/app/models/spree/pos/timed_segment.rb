# frozen_string_literal: true

module Spree
  module Pos
    # A stretch of a session on one room at one rate plan. A segment that
    # is still open has no end; closed segments keep the plan version they
    # were played on, so later price changes never reprice them.
    class TimedSegment < Record
      self.table_name = 'spree_pos_timed_segments'
      has_prefix_id :postimedseg

      KINDS = %w[play pause].freeze
      ENDED_REASONS = %w[pause resume move stop split_window].freeze

      belongs_to :timed_session, class_name: 'Spree::Pos::TimedSession', inverse_of: :timed_segments
      belongs_to :resource, class_name: 'Spree::Pos::Resource'
      belongs_to :rate_plan, class_name: 'Spree::Pos::RatePlan', optional: true

      validates :kind, inclusion: { in: KINDS }
      validates :started_at, presence: true
      validates :ended_reason, inclusion: { in: ENDED_REASONS }, allow_nil: true
      validate :ends_after_start

      def open?
        ended_at.nil?
      end

      def play?
        kind == 'play'
      end

      def to_pos
        { id: prefixed_id, kind: kind, resource_id: resource.prefixed_id, resource_name: resource.name,
          started_at: started_at.iso8601, ended_at: ended_at&.iso8601,
          rate_plan_id: rate_plan&.prefixed_id, rate_plan_name: rate_plan&.name, rate_plan_version: rate_plan_version,
          edited: edited, ended_reason: ended_reason }
      end

      private

      def ends_after_start
        errors.add(:ended_at, :invalid) if ended_at && started_at && ended_at <= started_at
      end
    end
  end
end
