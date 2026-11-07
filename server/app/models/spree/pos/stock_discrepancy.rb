# frozen_string_literal: true

module Spree
  module Pos
    # A counter handover the system shelf could not cover. The goods left
    # with the customer; the fulfillment stays allocated and is dispatched
    # once whoever reconciles stock has corrected the shelf with a document,
    # so the stock effect still happens exactly once and never goes negative.
    class StockDiscrepancy < Record
      self.table_name = 'spree_pos_stock_discrepancies'
      has_prefix_id :posstockgap

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :branch, class_name: 'Spree::Pos::Branch'
      belongs_to :workspace, class_name: 'Spree::Pos::Workspace'
      belongs_to :order, class_name: 'Spree::Order'
      belongs_to :fulfillment, class_name: 'Spree::Fulfillment'
      belongs_to :variant, class_name: 'Spree::Variant'
      belongs_to :stock_location, class_name: 'Spree::StockLocation'
      belongs_to :actor, class_name: staff_class_name

      validates :status, inclusion: { in: %w[open resolved] }

      scope :open_now, -> { where(status: 'open') }

      def to_pos
        { id: prefixed_id, variant_id: variant.prefixed_id, sku: variant.sku, name: variant.product.name,
          needed: needed, on_hand: on_hand, status: status, checked_at: checked_at.iso8601,
          resolved_at: resolved_at&.iso8601 }
      end
    end
  end
end
