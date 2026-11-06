# frozen_string_literal: true

module Spree
  module Pos
    # Explicit branch assortment; absence is deliberately not a wildcard.
    class BranchProduct < Record
      self.table_name = 'spree_pos_branch_products'

      belongs_to :branch, class_name: 'Spree::Pos::Branch'
      belongs_to :product, class_name: 'Spree::Product'
      validate :same_store

      private

      def same_store
        errors.add(:product, :invalid) if branch && product && branch.store_id != product.store_id
      end
    end
  end
end
