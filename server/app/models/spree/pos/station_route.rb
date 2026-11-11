# frozen_string_literal: true

module Spree
  module Pos
    # Sends a product, or every menu item of a kitchen category, to a station
    # of the branch. Without a service mode the route holds for every mode.
    class StationRoute < Record
      self.table_name = 'spree_pos_station_routes'
      has_prefix_id :posroute

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :branch, class_name: 'Spree::Pos::Branch'
      belongs_to :kitchen_station, class_name: 'Spree::Pos::KitchenStation'
      belongs_to :product, class_name: 'Spree::Product', optional: true

      validates :kitchen_category, format: { with: MenuItem::KITCHEN_CATEGORY }, allow_nil: true
      validates :service_mode, inclusion: { in: Workspace::SERVICE_MODES }, allow_nil: true
      validate :one_target
      validate :same_branch

      scope :for_store, ->(store) { where(store_id: store.id) }

      def to_pos
        {
          id: prefixed_id, branch_id: branch.prefixed_id, kitchen_station_id: kitchen_station.prefixed_id,
          product_id: product&.prefixed_id, product_name: product&.name, kitchen_category: kitchen_category,
          service_mode: service_mode
        }
      end

      private

      def one_target
        errors.add(:base, :invalid) if product_id.nil? == kitchen_category.nil?
      end

      def same_branch
        errors.add(:kitchen_station, :invalid) if kitchen_station && kitchen_station.branch_id != branch_id
        errors.add(:product, :invalid) if product && product.store_id != store_id
      end
    end
  end
end
