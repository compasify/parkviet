# frozen_string_literal: true

module Spree
  module Pos
    module Shifts
      # Raised when the close checklist still has blocking items; carries them
      # so the cashier is sent to the right workspace, attempt or payout.
      class CloseBlocked < Conflict
        attr_reader :checklist

        def initialize(checklist)
          super('Resolve the listed items before closing the shift.', reason: 'close_blocked')
          @checklist = checklist
        end
      end
    end
  end
end
