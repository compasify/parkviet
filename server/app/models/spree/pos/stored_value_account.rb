# frozen_string_literal: true

module Spree
  module Pos
    # Prepaid value one customer keeps with the store: money held for them,
    # never revenue. Its balance is the sum of its append-only entries; every
    # writer (Spree::Pos::StoredValue) locks this row first, so it is the
    # serialization point for balance checks.
    class StoredValueAccount < Record
      self.table_name = 'spree_pos_stored_value_accounts'
      has_prefix_id :posstoredvalue

      KINDS = %w[meal].freeze
      STATUSES = %w[active closed].freeze

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :customer_profile, class_name: 'Spree::Pos::CustomerProfile'
      has_many :entries, class_name: 'Spree::Pos::StoredValueEntry', inverse_of: :stored_value_account,
                         dependent: :restrict_with_error

      validates :kind, inclusion: { in: KINDS }
      validates :status, inclusion: { in: STATUSES }
      validates :currency, presence: true

      def balance
        BigDecimal(entries.sum(:amount).to_s)
      end
    end
  end
end
