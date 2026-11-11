# frozen_string_literal: true

module Spree
  module Pos
    # A modifier group offered on a menu item, in display order.
    class MenuItemModifierGroup < Record
      self.table_name = 'spree_pos_menu_item_modifier_groups'
      has_prefix_id :posmenuitemgroup

      belongs_to :menu_item, class_name: 'Spree::Pos::MenuItem', inverse_of: :menu_item_modifier_groups
      belongs_to :modifier_group, class_name: 'Spree::Pos::ModifierGroup'

      validates :modifier_group_id, uniqueness: { scope: :menu_item_id }
      validate :same_store

      private

      def same_store
        return if menu_item.nil? || modifier_group.nil?

        errors.add(:modifier_group, :invalid) if menu_item.store_id != modifier_group.store_id
      end
    end
  end
end
