# frozen_string_literal: true

module Spree
  module Pos
    # One eater's meal account in a canteen: found by the employee or
    # student code, with a prepaid wallet (a meal StoredValueAccount), the
    # daily meal rules and who pays (`pay_mode`): the wallet, the sponsor,
    # or the sponsor up to its subsidy and the eater for the rest. Recording
    # a meal locks this row, so two counters cannot both take the last meal.
    class MealAccount < Record
      self.table_name = 'spree_pos_meal_accounts'
      has_prefix_id :posmealaccount

      PAY_MODES = %w[wallet sponsor sponsor_subsidy].freeze
      STATUSES = %w[active locked].freeze
      CODE_FORMAT = /\A[A-Z0-9][A-Z0-9._-]{0,31}\z/
      CLOCK = /\A([01]\d|2[0-3]):[0-5]\d\z/
      WINDOW_KEY = /\A[a-z0-9_]{1,32}\z/
      MAX_WINDOWS = 6

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :customer_profile, class_name: 'Spree::Pos::CustomerProfile'
      belongs_to :meal_sponsor, class_name: 'Spree::Pos::MealSponsor', optional: true
      belongs_to :stored_value_account, class_name: 'Spree::Pos::StoredValueAccount'
      has_many :swipes, class_name: 'Spree::Pos::MealSwipe', dependent: :restrict_with_error

      before_validation { self.employee_code = self.class.normalize_code(employee_code) }

      validates :employee_code, format: { with: CODE_FORMAT }, uniqueness: { scope: :store_id }
      validates :group_label, length: { maximum: 120 }
      validates :pay_mode, inclusion: { in: PAY_MODES }
      validates :status, inclusion: { in: STATUSES }
      validates :daily_meal_limit, numericality: { only_integer: true, in: 0..20 }, allow_nil: true
      validates :low_balance_threshold, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
      validates :meal_sponsor, presence: true, unless: -> { pay_mode == 'wallet' }
      validate :windows_valid
      validate :same_store

      scope :for_store, ->(store) { where(store_id: store.id) }

      def self.normalize_code(value)
        value.to_s.strip.upcase.presence
      end

      def active?
        status == 'active'
      end

      def bump!
        update!(revision: revision + 1)
      end

      # The meal window open at a local "HH:MM", or nil. No windows means
      # any time of day.
      def window_at(clock)
        meal_windows.find do |window|
          from = window['from']
          to = window['to']
          from <= to ? clock >= from && clock < to : clock >= from || clock < to
        end
      end

      def to_pos(balance: stored_value_account.balance)
        {
          id: prefixed_id, employee_code: employee_code, name: customer_profile.name, phone: customer_profile.phone,
          customer_id: customer_profile.prefixed_id, group_label: group_label,
          sponsor: meal_sponsor && { id: meal_sponsor.prefixed_id, name: meal_sponsor.name },
          pay_mode: pay_mode, daily_meal_limit: daily_meal_limit, meal_windows: meal_windows,
          low_balance_threshold: low_balance_threshold&.to_s('F'), balance: balance.to_s('F'),
          currency: stored_value_account.currency, status: status, revision: revision, updated_at: updated_at&.iso8601
        }
      end

      private

      def windows_valid
        unless meal_windows.is_a?(Array) && meal_windows.size <= MAX_WINDOWS
          return errors.add(:meal_windows, :invalid)
        end

        keys = meal_windows.map { |window| window.is_a?(Hash) ? window['key'] : nil }
        valid = meal_windows.all? do |window|
          window.is_a?(Hash) && (window.keys - %w[key from to limit]).empty? && window['key'].to_s.match?(WINDOW_KEY) &&
            window['from'].to_s.match?(CLOCK) && window['to'].to_s.match?(CLOCK) && window['from'] != window['to'] &&
            (window['limit'].nil? || (window['limit'].is_a?(Integer) && window['limit'].between?(0, 20)))
        end
        errors.add(:meal_windows, :invalid) unless valid && keys.uniq.size == keys.size
      end

      def same_store
        errors.add(:customer_profile, :invalid) if customer_profile && customer_profile.store_id != store_id
        errors.add(:meal_sponsor, :invalid) if meal_sponsor && meal_sponsor.store_id != store_id
        if stored_value_account && (stored_value_account.store_id != store_id ||
                                    stored_value_account.customer_profile_id != customer_profile&.id)
          errors.add(:stored_value_account, :invalid)
        end
      end
    end
  end
end
