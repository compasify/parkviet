# frozen_string_literal: true

module Spree
  # Transactional traceability guard: a core stock movement of a variant that
  # is tracked by serial or lot at that location is refused (as a validation
  # error, before anything is written) unless a POS trace workflow, which
  # keeps the typed records in the same transaction, made it.
  module StockMovementDecorator
    def self.prepended(base)
      base.validate :pos_traceability_guard, on: :create
    end

    private

    def pos_traceability_guard
      refusal = Spree::Pos::StockIntegration.movement_refusal(self)
      errors.add(:base, refusal) if refusal
    end

    # The shelf write a movement makes is the movement's own; the level guard
    # lets it through because the movement was already checked.
    def apply_to_stock_level
      depth = ActiveSupport::IsolatedExecutionState[:spree_pos_applying_movement].to_i
      ActiveSupport::IsolatedExecutionState[:spree_pos_applying_movement] = depth + 1
      super
    ensure
      ActiveSupport::IsolatedExecutionState[:spree_pos_applying_movement] = depth
    end
  end

  StockMovement.prepend(StockMovementDecorator)
end
