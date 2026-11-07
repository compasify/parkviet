# frozen_string_literal: true

module Spree
  module Pos
    # Close barrier shared by every drawer cash writer and by shift close.
    #
    # A writer holds the shift row FOR UPDATE inside its own transaction and
    # requires it to be open; close takes the same lock, so a close and a cash
    # post serialize: the post either commits before the close reads its
    # cutoff (and is counted) or waits and then fails with `shift_closed`.
    #
    # Lock order, everywhere: workspace (CommandExecutor) -> shift (this
    # barrier) -> credit account / parent funds / allocation / order rows.
    # Never take the shift lock after a funds or account lock.
    module ShiftBarrier
      module_function

      def hold!(shift)
        raise ArgumentError, 'The shift barrier must be held inside a transaction.' unless Shift.connection.transaction_open?

        # NO KEY UPDATE conflicts with itself (holders serialize) but not with
        # foreign-key share locks of rows that merely reference the shift.
        shift.lock!('FOR NO KEY UPDATE')
        raise Conflict.new('Shift is closed.', reason: 'shift_closed') unless shift.open?

        shift
      end
    end
  end
end
