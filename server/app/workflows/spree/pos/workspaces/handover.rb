# frozen_string_literal: true

module Spree
  module Pos
    module Workspaces
      # Phase 6: handover only after guarded completion (placed order, strict
      # branch location). Delegates to the strict fulfillment workflow.
      class Handover
        def self.call(workspace:, staff:, key:) = Orders::Handover.call(workspace:, staff:, key:)
      end
    end
  end
end
