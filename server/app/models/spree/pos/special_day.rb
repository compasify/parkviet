# frozen_string_literal: true

module Spree
  module Pos
    # A holiday of a branch (Tết, 30/4). Play time on it is priced by the
    # plan's holiday rules, or by its weekend rules plus this surcharge.
    class SpecialDay < Record
      self.table_name = 'spree_pos_special_days'
      has_prefix_id :posspecialday

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :branch, class_name: 'Spree::Pos::Branch'

      validates :date, presence: true, uniqueness: { scope: :branch_id }
      validates :name, presence: true, length: { maximum: 120 }
      validates :holiday_surcharge_percent, numericality: { in: 0..500 }, allow_nil: true

      scope :for_store, ->(store) { where(store_id: store.id) }

      def to_pos
        { id: prefixed_id, branch_id: branch.prefixed_id, date: date.iso8601, name: name,
          holiday_surcharge_percent: holiday_surcharge_percent&.to_s('F') }
      end
    end
  end
end
