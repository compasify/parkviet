# frozen_string_literal: true

module Spree
  module Pos
    # A time-of-day menu ("Giờ vàng 14:00–16:00"): its items get another
    # price or are hidden while it runs. `days_of_week` uses 0 = Sunday and is
    # empty for every day. A window that ends before it starts runs past
    # midnight and belongs to the day it starts on. No branch means every
    # branch of the store.
    class MenuSchedule < Record
      self.table_name = 'spree_pos_menu_schedules'
      has_prefix_id :posmenusched

      DAYS = (0..6).to_a.freeze
      CLOCK = /\A([01]\d|2[0-3]):[0-5]\d(:[0-5]\d)?\z/

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :branch, class_name: 'Spree::Pos::Branch', optional: true
      has_many :menu_schedule_items, -> { order(:id) }, class_name: 'Spree::Pos::MenuScheduleItem', dependent: :delete_all,
                                                        inverse_of: :menu_schedule

      validates :name, presence: true, length: { maximum: 80 }
      validates :starts_at, :ends_at, presence: true
      validate :days_known
      validate :window_not_empty
      validate :branch_belongs_to_store

      scope :for_store, ->(store) { where(store_id: store.id) }
      scope :active, -> { where(active: true) }

      # Schedules of the store that apply at a branch, store-wide or its own.
      def self.for_branch(branch)
        active.where(store_id: branch.store_id).where(branch_id: [nil, branch.id])
      end

      # Minutes from midnight of a time column, a Time or "07:30".
      def self.clock_minutes(value)
        return (value.hour * 60) + value.min if value.respond_to?(:hour) && !value.is_a?(String)

        hour, minute, = value.to_s.split(':').map(&:to_i)
        (hour.to_i * 60) + minute.to_i
      end

      # Whether the window runs at `at`, read in the branch timezone.
      def running_at?(at, timezone)
        zone = ActiveSupport::TimeZone[timezone.to_s] || Time.zone
        local = at.in_time_zone(zone)
        minutes = (local.hour * 60) + local.min
        from = self.class.clock_minutes(starts_at)
        to = self.class.clock_minutes(ends_at)
        if from < to
          day?(local.wday) && minutes >= from && minutes < to
        else
          (day?(local.wday) && minutes >= from) || (day?((local.wday - 1) % 7) && minutes < to)
        end
      end

      def day?(wday)
        days_of_week.blank? || days_of_week.include?(wday)
      end

      def to_pos
        {
          id: prefixed_id, branch_id: branch&.prefixed_id, name: name, days_of_week: Array(days_of_week),
          starts_at: clock_label(starts_at), ends_at: clock_label(ends_at), active: active,
          items: menu_schedule_items.map(&:to_pos)
        }
      end

      private

      def clock_label(value)
        return if value.blank?
        return value.strftime('%H:%M') if value.respond_to?(:strftime)

        value.to_s[/\d{2}:\d{2}/]
      end

      def days_known
        values = Array(days_of_week)
        errors.add(:days_of_week, :inclusion) unless values.all? { |day| DAYS.include?(day) } && values.uniq.size == values.size
      end

      def window_not_empty
        return if starts_at.blank? || ends_at.blank?

        errors.add(:ends_at, :invalid) if self.class.clock_minutes(starts_at) == self.class.clock_minutes(ends_at)
      end

      def branch_belongs_to_store
        errors.add(:branch, :invalid) if branch && branch.store_id != store_id
      end
    end
  end
end
