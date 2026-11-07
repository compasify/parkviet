# frozen_string_literal: true

module Spree
  module Pos
    # A stock count of one tracked variant at a branch. Negative changes and
    # changes above the branch threshold wait for an action-bound approval
    # from someone else; applying it changes typed records and the core shelf
    # together, once.
    class InventoryAdjustment < Record
      self.table_name = 'spree_pos_inventory_adjustments'
      has_prefix_id :posinvadj

      ACTION = 'inventory.adjust'

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :branch, class_name: 'Spree::Pos::Branch'
      belongs_to :variant, class_name: 'Spree::Variant'
      belongs_to :stock_location, class_name: 'Spree::StockLocation'
      belongs_to :requester, class_name: staff_class_name
      belongs_to :applier, class_name: staff_class_name, optional: true
      belongs_to :approval, class_name: 'Spree::Pos::Approval', optional: true

      validates :status, inclusion: { in: %w[pending_approval applied canceled] }

      scope :for_store, ->(store) { where(store_id: store.id) }

      def to_pos
        {
          id: prefixed_id, branch_id: branch.prefixed_id, variant_id: variant.prefixed_id, sku: variant.sku,
          name: variant.product.name, reason: reason, status: status, requires_approval: requires_approval,
          delta: delta, revision: revision, lines: lines, requester_id: requester.prefixed_id,
          requester_name: StaffName.call(requester), approval: approval&.to_ref,
          created_at: created_at.iso8601, applied_at: applied_at&.iso8601
        }
      end
    end
  end
end
