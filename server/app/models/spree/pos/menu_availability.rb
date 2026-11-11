# frozen_string_literal: true

module Spree
  module Pos
    # Sold-out state of a menu item at a branch. It holds for the business
    # date it was set on only, so a new business day starts with the item
    # back on sale.
    class MenuAvailability < Record
      self.table_name = 'spree_pos_menu_availabilities'
      has_prefix_id :posmenuavail

      belongs_to :branch, class_name: 'Spree::Pos::Branch'
      belongs_to :menu_item, class_name: 'Spree::Pos::MenuItem'
      belongs_to :updated_by, polymorphic: true, optional: true

      validates :menu_item_id, uniqueness: { scope: :branch_id }
      validate :same_store

      # Menu item ids sold out at the branch on a business date.
      def self.sold_out_ids(branch, business_date)
        where(branch_id: branch.id, sold_out_on: business_date).pluck(:menu_item_id)
      end

      def self.sold_out?(branch, menu_item, business_date)
        exists?(branch_id: branch.id, menu_item_id: menu_item.id, sold_out_on: business_date)
      end

      private

      def same_store
        errors.add(:menu_item, :invalid) if branch && menu_item && branch.store_id != menu_item.store_id
      end
    end
  end
end
