# frozen_string_literal: true

module Spree
  module Pos
    # One item of a time-of-day menu: its price while the window runs (for
    # one size, or every size without a variant), or hidden.
    class MenuScheduleItem < Record
      self.table_name = 'spree_pos_menu_schedule_items'
      has_prefix_id :posmenuschitem

      belongs_to :menu_schedule, class_name: 'Spree::Pos::MenuSchedule', inverse_of: :menu_schedule_items
      belongs_to :menu_item, class_name: 'Spree::Pos::MenuItem'
      belongs_to :variant, class_name: 'Spree::Variant', optional: true

      validates :price, numericality: { greater_than_or_equal_to: 0, less_than: 1_000_000_000 }, allow_nil: true
      validate :price_or_hidden
      validate :same_store

      def to_pos
        {
          id: prefixed_id, menu_item_id: menu_item.prefixed_id, variant_id: variant&.prefixed_id,
          price: price&.to_s('F'), hidden: hidden
        }
      end

      private

      def price_or_hidden
        errors.add(:price, :blank) if price.nil? && !hidden
      end

      def same_store
        return if menu_schedule.nil? || menu_item.nil?

        errors.add(:menu_item, :invalid) if menu_item.store_id != menu_schedule.store_id
        errors.add(:variant, :invalid) if variant && variant.product_id != menu_item.product_id
      end
    end
  end
end
