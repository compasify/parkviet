# frozen_string_literal: true

module Spree
  module Pos
    # A tab of the store's menu ("Cà phê", "Trà sữa"). Deleting one leaves its
    # items uncategorized.
    class MenuCategory < Record
      self.table_name = 'spree_pos_menu_categories'
      has_prefix_id :posmenucat

      COLOR = /\A#[0-9a-fA-F]{6}\z/

      belongs_to :store, class_name: 'Spree::Store'
      has_many :menu_items, class_name: 'Spree::Pos::MenuItem', dependent: :nullify

      validates :name, presence: true, length: { maximum: 80 }, uniqueness: { scope: :store_id }
      validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
      validates :color, format: { with: COLOR }, allow_nil: true

      scope :for_store, ->(store) { where(store_id: store.id) }

      def to_pos
        { id: prefixed_id, name: name, position: position, color: color, active: active }
      end
    end
  end
end
