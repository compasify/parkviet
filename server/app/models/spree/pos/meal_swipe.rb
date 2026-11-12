# frozen_string_literal: true

module Spree
  module Pos
    # One meal recorded at a counter, accepted or refused: the duplicate
    # guard, the daily count and the canteen reports read these rows. An
    # accepted meal counts while its order is the eater's and not canceled,
    # so taking the eater off an order gives the meal back.
    class MealSwipe < Record
      self.table_name = 'spree_pos_meal_swipes'
      has_prefix_id :posmealswipe

      INPUT_METHODS = %w[code search].freeze
      RESULTS = %w[ok duplicate limit window revoked unknown].freeze
      # The refusal reason a client plays its sound for.
      REASONS = {
        'duplicate' => 'meal_duplicate_swipe', 'limit' => 'meal_daily_limit', 'window' => 'meal_outside_window',
        'revoked' => 'meal_account_locked', 'unknown' => 'meal_account_unknown'
      }.freeze

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :meal_account, class_name: 'Spree::Pos::MealAccount', optional: true
      belongs_to :branch, class_name: 'Spree::Pos::Branch'
      belongs_to :workspace, class_name: 'Spree::Pos::Workspace', optional: true
      belongs_to :actor, class_name: staff_class_name

      validates :input_method, inclusion: { in: INPUT_METHODS }
      validates :result, inclusion: { in: RESULTS }

      before_update { raise ActiveRecord::ReadOnlyRecord, 'Meal swipes are append-only.' }

      # Accepted meals that still count: on an order that still belongs to
      # the account's eater and was not canceled.
      def self.counting
        where(result: 'ok').joins(:workspace, :meal_account).
          where.not(spree_pos_workspaces: { operational_status: 'canceled' }).
          where('spree_pos_workspaces.pos_customer_id = spree_pos_meal_accounts.customer_profile_id')
      end
    end
  end
end
