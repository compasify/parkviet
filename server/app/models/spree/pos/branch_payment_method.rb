# frozen_string_literal: true

module Spree
  module Pos
    # One payment method a branch offers. A branch without rows offers every
    # active method of the store (see PaymentMethodResolver).
    class BranchPaymentMethod < Record
      self.table_name = 'spree_pos_branch_payment_methods'

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :branch, class_name: 'Spree::Pos::Branch'
      belongs_to :pos_payment_method, class_name: 'Spree::Pos::PosPaymentMethod'

      validates :pos_payment_method_id, uniqueness: { scope: :branch_id }
      validate :same_store

      private

      def same_store
        errors.add(:branch, :invalid) if branch && branch.store_id != store_id
        errors.add(:pos_payment_method, :invalid) if pos_payment_method && pos_payment_method.store_id != store_id
      end
    end
  end
end
