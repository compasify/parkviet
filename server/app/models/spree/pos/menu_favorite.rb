# frozen_string_literal: true

module Spree
  module Pos
    # The quick-pick row of a branch's menu grid, in order.
    class MenuFavorite < Record
      self.table_name = 'spree_pos_menu_favorites'
      has_prefix_id :posmenufav

      MAX_PER_BRANCH = 20

      belongs_to :branch, class_name: 'Spree::Pos::Branch'
      belongs_to :menu_item, class_name: 'Spree::Pos::MenuItem'

      validates :menu_item_id, uniqueness: { scope: :branch_id }
      validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
      validate :same_store

      private

      def same_store
        errors.add(:menu_item, :invalid) if branch && menu_item && branch.store_id != menu_item.store_id
      end
    end
  end
end
