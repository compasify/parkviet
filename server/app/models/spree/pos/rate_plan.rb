# frozen_string_literal: true

module Spree
  module Pos
    # The price of play time for one kind of room or table at a branch
    # (`resource_type_code`, else the resource's kind): rules by time of day
    # and kind of day, the block time is rounded to, the grace minutes
    # dropped before rounding up and a minimum. The service variant sold for
    # the time decides the tax. A plan a segment was played on is never
    # changed again; saving it writes the next version (Timed::SaveRatePlan).
    class RatePlan < Record
      self.table_name = 'spree_pos_rate_plans'
      has_prefix_id :posrateplan

      STATUSES = %w[active archived].freeze
      PACKAGE_CODE = /\A[a-z0-9][a-z0-9_-]{0,31}\z/
      MAX_PACKAGES = 10

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :branch, class_name: 'Spree::Pos::Branch'
      belongs_to :variant, class_name: 'Spree::Variant'
      belongs_to :previous, class_name: 'Spree::Pos::RatePlan', optional: true
      has_many :rate_rules, -> { order(:day_type, :position, :start_minute, :id) }, class_name: 'Spree::Pos::RateRule',
                                                                                    inverse_of: :rate_plan, dependent: :delete_all, autosave: true

      validates :name, presence: true, length: { maximum: 120 }
      validates :resource_type_code, presence: true, length: { maximum: 40 }
      validates :status, inclusion: { in: STATUSES }
      validates :block_minutes, numericality: { only_integer: true, in: 1..60 }
      validates :grace_minutes, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
      validates :minimum_minutes, numericality: { only_integer: true, in: 0..1440 }
      validate :grace_within_block
      validate :rules_cover_every_day
      validate :packages_valid

      scope :for_store, ->(store) { where(store_id: store.id) }
      scope :active, -> { where(status: 'active') }

      # The code a resource is priced by.
      def self.type_code_of(resource)
        resource.resource_type_code.presence || resource.kind
      end

      def self.active_for(resource)
        active.find_by(branch_id: resource.branch_id, resource_type_code: type_code_of(resource))
      end

      def active?
        status == 'active'
      end

      # A prepaid package sold on this plan (`{ code, name, minutes, price }`), or nil.
      def package(code)
        Array(packages).find { |row| row['code'] == code.to_s }
      end

      # Whether a play segment was priced on this version.
      def used?
        persisted? && TimedSegment.exists?(rate_plan_id: id)
      end

      def to_pos
        { id: prefixed_id, branch_id: branch.prefixed_id, name: name, resource_type_code: resource_type_code,
          variant_id: variant.prefixed_id, variant_name: variant.product&.name, tax_category_id: variant.tax_category&.prefixed_id,
          tax_category_name: variant.tax_category&.name, block_minutes: block_minutes, grace_minutes: grace_minutes,
          minimum_minutes: minimum_minutes, status: status, version: version, packages: packages,
          rules: rate_rules.map(&:to_pos) }
      end

      private

      # Prepaid packages: a code, a name, the minutes it holds and its price.
      def packages_valid
        list = packages
        return errors.add(:packages, :invalid) unless list.is_a?(Array) && list.size <= MAX_PACKAGES

        valid = list.all? do |row|
          row.is_a?(Hash) && row.keys.sort == %w[code minutes name price] && row['code'].to_s.match?(PACKAGE_CODE) &&
            row['name'].to_s.strip.length.between?(1, 120) && row['minutes'].is_a?(Integer) && row['minutes'].between?(1, 1440) &&
            Record.money(row['price'].to_s)&.then { |price| price >= 0 }
        end
        errors.add(:packages, :invalid) unless valid && list.map { |row| row['code'] }.uniq.size == list.size
      end

      def grace_within_block
        return if grace_minutes.nil? || block_minutes.nil?

        errors.add(:grace_minutes, :less_than_or_equal_to, count: block_minutes) if grace_minutes > block_minutes
      end

      # Weekdays and weekends are always priced; holidays are priced by
      # their own rules or, without any, by the weekend's plus a surcharge.
      # The rules of a kind of day cover the 24 hours exactly once.
      def rules_cover_every_day
        rules = rate_rules.reject(&:marked_for_destruction?)
        by_day = rules.group_by(&:day_type)
        errors.add(:rate_rules, :blank) if by_day['weekday'].blank? || by_day['weekend'].blank?
        by_day.each do |day_type, list|
          minutes = Array.new(RateRule::DAY_MINUTES, 0)
          list.each { |rule| rule.minute_ranges.each { |range| range.each { |minute| minutes[minute] += 1 } } }
          next if minutes.all?(1)

          errors.add(:rate_rules, :invalid, message: "#{day_type} rules must cover the 24 hours once")
        end
      end
    end
  end
end
