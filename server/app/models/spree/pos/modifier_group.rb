# frozen_string_literal: true

module Spree
  module Pos
    # A set of options picked together on a menu item ("Đường", "Đá",
    # "Topping"). At least `min_select` and at most `max_select` picks; with
    # `allow_quantity` one option may be picked several times and each counts.
    class ModifierGroup < Record
      self.table_name = 'spree_pos_modifier_groups'
      has_prefix_id :posmodgroup

      MAX_OPTION_QUANTITY = 10

      belongs_to :store, class_name: 'Spree::Store'
      has_many :modifier_options, -> { order(:position, :id) }, class_name: 'Spree::Pos::ModifierOption',
                                                                dependent: :destroy, inverse_of: :modifier_group
      has_many :menu_item_modifier_groups, class_name: 'Spree::Pos::MenuItemModifierGroup', dependent: :delete_all

      validates :name, presence: true, length: { maximum: 80 }
      validates :min_select, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
      validates :max_select, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
      validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
      validate :min_within_max

      scope :for_store, ->(store) { where(store_id: store.id) }

      def required?
        min_select.positive?
      end

      def to_pos
        {
          id: prefixed_id, name: name, min_select: min_select, max_select: max_select, allow_quantity: allow_quantity,
          position: position, required: required?, options: modifier_options.map(&:to_pos)
        }
      end

      private

      def min_within_max
        return if min_select.nil? || max_select.nil? || min_select <= max_select

        errors.add(:min_select, :less_than_or_equal_to, count: max_select)
      end
    end
  end
end
