# frozen_string_literal: true

module Spree
  # Second half of the traceability guard: a shelf count of a tracked
  # (variant, location) pair may not be written directly or removed except
  # through a checked stock movement or a POS trace workflow.
  module StockLevelDecorator
    def self.prepended(base)
      base.validate :pos_traceability_count_guard, on: :update
      base.before_destroy :pos_traceability_destroy_guard, prepend: true
    end

    private

    def pos_traceability_count_guard
      return unless will_save_change_to_count_on_hand?
      return if ActiveSupport::IsolatedExecutionState[:spree_pos_applying_movement].to_i.positive?

      refusal = Spree::Pos::StockIntegration.level_refusal(self)
      errors.add(:count_on_hand, refusal) if refusal
    end

    def pos_traceability_destroy_guard
      refusal = Spree::Pos::StockIntegration.level_refusal(self)
      return unless refusal

      # `destroy` returns false with this error; `destroy!` raises
      # RecordNotDestroyed carrying it.
      errors.add(:base, refusal)
      throw :abort
    end
  end

  StockLevel.prepend(StockLevelDecorator)
end
