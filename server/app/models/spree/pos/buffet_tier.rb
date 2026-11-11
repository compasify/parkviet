# frozen_string_literal: true

module Spree
  module Pos
    # A buffet ticket class of a branch: the product sold per guest (its
    # price and tax category make the cover line), how long a table may
    # eat, and how much each round may bring to the table. The dishes of the
    # tier are its items; they are sold at no price on the cover.
    class BuffetTier < Record
      self.table_name = 'spree_pos_buffet_tiers'
      has_prefix_id :posbuffet

      STATUSES = %w[active archived].freeze

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :branch, class_name: 'Spree::Pos::Branch'
      belongs_to :product, class_name: 'Spree::Product'
      has_many :items, -> { order(:id) }, class_name: 'Spree::Pos::BuffetTierItem', dependent: :delete_all, inverse_of: :buffet_tier

      validates :name, presence: true, length: { maximum: 80 }
      validates :status, inclusion: { in: STATUSES }
      validates :duration_minutes, numericality: { only_integer: true, in: 1..1440 }
      validates :round_interval_minutes, numericality: { only_integer: true, in: 0..240 }
      validates :round_item_limit, numericality: { only_integer: true, in: 1..99 }, allow_nil: true
      validate :product_of_store

      scope :active, -> { where(status: 'active') }

      def item_for(product_id)
        items.detect { |item| item.product_id == product_id }
      end

      def to_pos
        {
          id: prefixed_id, branch_id: branch.prefixed_id, name: name, status: status,
          product_id: product.prefixed_id, product_name: product.name, variant_id: product.default_variant.prefixed_id,
          duration_minutes: duration_minutes, round_item_limit: round_item_limit, round_interval_minutes: round_interval_minutes,
          items: items.map(&:to_pos)
        }
      end

      private

      def product_of_store
        errors.add(:product, :invalid) if product && store && product.store_id != store.id
      end
    end
  end
end
