# frozen_string_literal: true

module Spree
  module Pos
    # Free minutes on play time, applied when a session is priced:
    # - `bonus_after`: play at least `threshold_minutes`, and up to
    #   `bonus_minutes` past it are free;
    # - `bonus_with_package`: a session sold with a prepaid package plays up
    #   to `bonus_minutes` past the package free.
    # The free minutes stay on the bill as a bonus line at no price, so the
    # invoice still states every hour played. A promotion may be limited to
    # kinds of room (`resource_kinds`, rate plan type codes) and to windows
    # of the week the session starts in (`active_windows`, see OperatingHours).
    class TimedPromotion < Record
      self.table_name = 'spree_pos_timed_promotions'
      has_prefix_id :postimedpromo

      KINDS = %w[bonus_after bonus_with_package].freeze
      STATUSES = %w[active archived].freeze

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :branch, class_name: 'Spree::Pos::Branch'

      validates :name, presence: true, length: { maximum: 120 }
      validates :kind, inclusion: { in: KINDS }
      validates :status, inclusion: { in: STATUSES }
      validates :threshold_minutes, numericality: { only_integer: true, in: 0..1440 }
      validates :bonus_minutes, numericality: { only_integer: true, in: 1..600 }
      validate :kinds_are_codes

      scope :for_store, ->(store) { where(store_id: store.id) }
      scope :active, -> { where(status: 'active') }

      # Whether it applies to a session on `resource` that started at `started_at`.
      def applies?(resource, started_at, timezone, package:)
        return false if kind == 'bonus_with_package' && !package
        return false if resource_kinds.present? && !resource_kinds.include?(RatePlan.type_code_of(resource))

        OperatingHours.open?(active_windows, started_at, timezone)
      end

      # The free minutes on `billed` minutes, `prepaid` of them in a package.
      def bonus_for(billed, prepaid)
        base = kind == 'bonus_with_package' ? prepaid.to_i : threshold_minutes
        return 0 if billed <= base || (kind == 'bonus_after' && billed < threshold_minutes)

        [bonus_minutes, billed - base].min
      end

      def to_pos
        { id: prefixed_id, branch_id: branch.prefixed_id, name: name, kind: kind, threshold_minutes: threshold_minutes,
          bonus_minutes: bonus_minutes, resource_kinds: resource_kinds, active_windows: active_windows, status: status }
      end

      private

      def kinds_are_codes
        valid = resource_kinds.is_a?(Array) && resource_kinds.size <= 20 &&
          resource_kinds.all? { |code| code.is_a?(String) && code.length.between?(1, 40) }
        errors.add(:resource_kinds, :invalid) unless valid
      end
    end
  end
end
