# frozen_string_literal: true

module Spree
  module Pos
    # A company or school that pays for its people's meals, in full or in
    # part. It is a customer with a credit account: what it owes is posted
    # on that account's receivable ledger like any credit sale, within the
    # limit approved there, and collected the usual way.
    class MealSponsor < Record
      self.table_name = 'spree_pos_meal_sponsors'
      has_prefix_id :posmealsponsor

      SUBSIDY_MODES = %w[none fixed percent].freeze
      STATUSES = %w[active suspended].freeze

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :customer_profile, class_name: 'Spree::Pos::CustomerProfile'
      belongs_to :credit_account, class_name: 'Spree::Pos::CreditAccount', optional: true
      has_many :meal_accounts, class_name: 'Spree::Pos::MealAccount', dependent: :restrict_with_error

      validates :name, presence: true, length: { maximum: 120 }
      validates :subsidy_mode, inclusion: { in: SUBSIDY_MODES }
      validates :status, inclusion: { in: STATUSES }
      validates :statement_day, numericality: { only_integer: true, in: 1..28 }
      validates :subsidy_value, numericality: { greater_than_or_equal_to: 0 }
      validates :subsidy_value, numericality: { less_than_or_equal_to: 100 }, if: -> { subsidy_mode == 'percent' }
      validates :subsidy_daily_cap, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
      validate :same_store

      scope :for_store, ->(store) { where(store_id: store.id) }

      def active?
        status == 'active'
      end

      def to_pos
        credit = credit_account
        {
          id: prefixed_id, name: name, customer_id: customer_profile.prefixed_id, customer_name: customer_profile.name,
          customer_phone: customer_profile.phone, credit_account_id: credit&.prefixed_id,
          credit_limit: credit&.credit_limit&.to_s('F'), due_days: credit&.due_days,
          open_debt: credit&.exposure&.open_debt&.to_s('F'), credit_available: credit&.exposure&.available&.to_s('F'),
          statement_day: statement_day, subsidy_mode: subsidy_mode, subsidy_value: subsidy_value.to_s('F'),
          subsidy_daily_cap: subsidy_daily_cap&.to_s('F'), status: status, accounts_count: meal_accounts.count,
          updated_at: updated_at&.iso8601
        }
      end

      private

      def same_store
        errors.add(:customer_profile, :invalid) if customer_profile && customer_profile.store_id != store_id
        errors.add(:credit_account, :invalid) if credit_account && credit_account.store_id != store_id
      end
    end
  end
end
