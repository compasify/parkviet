# frozen_string_literal: true

module Spree
  module Pos
    # A sale to deliver to the customer's door. Marked on the draft (with a
    # free-text deliverer and an optional fee, an order-level Spree::Fee);
    # the order then completes like any sale and the delivery waits as
    # `pending` until staff mark it `delivered`. Only completed sales are
    # listed; a draft's row is just its delivery intent.
    class Delivery < Record
      self.table_name = 'spree_pos_deliveries'
      has_prefix_id :posdelivery

      STATUSES = %w[pending delivered].freeze
      DELIVERER_MAX = 80
      FEE_KIND = 'handling'
      FEE_LABEL = 'Phí giao hàng'

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :branch, class_name: 'Spree::Pos::Branch'
      belongs_to :workspace, class_name: 'Spree::Pos::Workspace'
      belongs_to :order, class_name: 'Spree::Order'
      belongs_to :fee, class_name: 'Spree::Fee', optional: true
      belongs_to :created_by, class_name: staff_class_name
      belongs_to :delivered_by, class_name: staff_class_name, optional: true

      validates :status, inclusion: { in: STATUSES }
      validates :deliverer, length: { maximum: DELIVERER_MAX }
      validates :fee_amount, numericality: { greater_than_or_equal_to: 0 }

      scope :for_store, ->(store) { where(store_id: store.id) }

      def self.normalize_deliverer(value)
        value.to_s.squish.presence
      end

      def to_pos
        {
          id: prefixed_id, status: status, deliverer: deliverer, fee: money(fee_amount),
          delivered_at: delivered_at&.iso8601, delivered_by: delivered_by && StaffName.call(delivered_by)
        }
      end

      private

      def money(value)
        BigDecimal(value.to_s).to_s('F')
      end
    end
  end
end
