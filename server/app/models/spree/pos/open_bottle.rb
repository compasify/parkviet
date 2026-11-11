# frozen_string_literal: true

module Spree
  module Pos
    # The bottle open behind the bar that measured pours come from. Its
    # remaining ml falls with every completed sale (Fnb::PourTracker); when
    # it runs dry it is finished and one bottle leaves the shelf.
    class OpenBottle < Record
      self.table_name = 'spree_pos_open_bottles'
      has_prefix_id :posopenbottle

      STATUSES = %w[open finished].freeze
      MAX_ML = 20_000

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :branch, class_name: 'Spree::Pos::Branch'
      belongs_to :variant, -> { with_deleted }, class_name: 'Spree::Variant'
      belongs_to :opened_by, class_name: staff_class_name
      has_many :pour_events, class_name: 'Spree::Pos::PourEvent', dependent: :restrict_with_error, inverse_of: :open_bottle

      validates :status, inclusion: { in: STATUSES }
      validates :capacity_ml, numericality: { only_integer: true, in: 1..MAX_ML }
      validates :remaining_ml, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
      validate :remaining_within_capacity

      scope :unfinished, -> { where(status: 'open') }

      def to_pos
        {
          id: prefixed_id, branch_id: branch.prefixed_id, variant_id: variant.prefixed_id, product_name: variant.product&.name,
          options_text: variant.options_text.presence, capacity_ml: capacity_ml, remaining_ml: remaining_ml, status: status,
          opened_at: opened_at.iso8601, opened_by: { id: opened_by.prefixed_id, name: KitchenSend.staff_name(opened_by) },
          finished_at: finished_at&.iso8601
        }
      end

      private

      def remaining_within_capacity
        errors.add(:remaining_ml, :invalid) if remaining_ml && capacity_ml && remaining_ml > capacity_ml
      end
    end
  end
end
