# frozen_string_literal: true

module Spree
  module Pos
    # Credit terms for one identified customer in one store currency. No
    # account means no credit; a suspended account keeps its history but
    # takes no new reservations. Every exposure or receivable writer locks this
    # row first, so it is the serialization point for limit and balance checks.
    class CreditAccount < Record
      self.table_name = 'spree_pos_credit_accounts'
      has_prefix_id :poscredit

      STATUSES = %w[active suspended].freeze

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :customer_profile, class_name: 'Spree::Pos::CustomerProfile'
      belongs_to :branch, class_name: 'Spree::Pos::Branch'
      belongs_to :updated_by, class_name: staff_class_name
      has_many :reservations, class_name: 'Spree::Pos::CreditReservation', foreign_key: :credit_account_id,
                              dependent: :restrict_with_error
      has_many :receivable_entries, class_name: 'Spree::Pos::ReceivableEntry', foreign_key: :credit_account_id,
                                    dependent: :restrict_with_error

      validates :status, inclusion: { in: STATUSES }
      validates :currency, presence: true
      validates :credit_limit, numericality: { greater_than_or_equal_to: 0 }
      validates :due_days, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 3650 }
      validate :customer_in_store

      scope :for_store, ->(store) { where(store_id: store.id) }

      def active?
        status == 'active'
      end

      def exposure
        ExposureCalculator.new(self)
      end

      def to_pos
        calc = exposure
        {
          id: prefixed_id, customer_id: customer_profile.prefixed_id, customer_name: customer_profile.name,
          customer_phone: customer_profile.phone, branch_id: branch.prefixed_id,
          status: status, currency: currency, credit_limit: credit_limit.to_s('F'), due_days: due_days,
          open_debt: calc.open_debt.to_s('F'), reserved: calc.reserved.to_s('F'), available: calc.available.to_s('F'),
          updated_at: updated_at&.iso8601
        }
      end

      private

      def customer_in_store
        errors.add(:customer_profile, :invalid) if customer_profile && customer_profile.store_id != store_id
        errors.add(:branch, :invalid) if branch && branch.store_id != store_id
        errors.add(:branch, :invalid) if branch_id_changed? && persisted?
      end
    end
  end
end
