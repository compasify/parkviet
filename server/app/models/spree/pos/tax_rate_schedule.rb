# frozen_string_literal: true

module Spree
  module Pos
    # A future amount for one tax rate. The job applies it on the effective
    # date and leaves the row as the record of the change.
    class TaxRateSchedule < Record
      self.table_name = 'spree_pos_tax_rate_schedules'
      has_prefix_id :postaxsched

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :tax_rate, class_name: 'Spree::TaxRate'

      validates :amount, numericality: { greater_than_or_equal_to: 0 }
      validates :effective_on, presence: true

      scope :pending, -> { where(applied_at: nil) }
    end
  end
end
