# frozen_string_literal: true

module Spree
  module Pos
    module Shifts
      # Records the blind drawer count. The counter submits the cash they
      # counted before seeing what the drawer should hold; the response then
      # shows expected and variance. Every count (and every change of the
      # variance reason) bumps the shift revision, so an approval granted for
      # an earlier count can never close the shift with a different one. The
      # close checklist must be clear before counting.
      class Count
        def self.call(store:, staff:, key:, shift_id:, counted:, reason: nil)
          payload = { 'command' => 'shift.count', 'shift_id' => shift_id.to_s, 'counted' => counted.to_s,
                      'reason' => reason.to_s.strip.presence }
          authorize = -> { Guard.authorize_closer!(store, staff, Guard.shift!(store, shift_id)) }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: authorize) do
            shift = Guard.shift!(store, shift_id)
            amount = Guard.counted!(counted, shift.currency)
            note = Guard.reason!(reason)
            ShiftBarrier.hold!(shift)
            checklist = ShiftChecklist.new(shift)
            raise CloseBlocked, checklist if checklist.blocked?

            projection = CashbookProjection.new(shift)
            shift.update!(closing_counted: amount, closing_reason: note, closing_counted_by: staff,
                          closing_counted_at: Time.current, closing_cutoff_movement_id: Guard.last_movement_id(shift),
                          revision: shift.revision + 1)
            AuditEntry.record!(store: store, actor: staff, action: 'shift.count', subject: shift,
                               metadata: { counted: amount.to_s('F'), expected: projection.expected.to_s('F'),
                                           revision: shift.revision, reason: note })
            Guard.preview(shift, projection)
          end
        end
      end
    end
  end
end
