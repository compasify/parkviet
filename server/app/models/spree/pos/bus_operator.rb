# frozen_string_literal: true

module Spree
  module Pos
    # A coach company (nhà xe) whose drivers stop at the store's rest stops.
    # Commission rules may be set for one operator; archived operators keep
    # their past visits but take no new ones.
    class BusOperator < Record
      self.table_name = 'spree_pos_bus_operators'
      has_prefix_id :posbusop

      STATUSES = %w[active archived].freeze

      belongs_to :store, class_name: 'Spree::Store'

      validates :name, presence: true, length: { maximum: 120 }, uniqueness: { scope: :store_id }
      validates :phone, length: { maximum: 32 }
      validates :note, length: { maximum: 500 }
      validates :status, inclusion: { in: STATUSES }

      scope :for_store, ->(store) { where(store_id: store.id) }

      def active?
        status == 'active'
      end

      def to_ref
        { id: prefixed_id, name: name }
      end

      def to_pos
        { id: prefixed_id, name: name, phone: phone, note: note, status: status, updated_at: updated_at&.iso8601 }
      end
    end
  end
end
