# frozen_string_literal: true

module Spree
  module Pos
    module Shifts
      # Closes a shift on its blind count and writes the immutable snapshot.
      #
      # Under the shift barrier (the same lock every drawer cash writer takes)
      # it re-checks the checklist, recomputes expected cash from the shift's
      # CashMovements and fixes the cutoff at the last movement id. A count
      # older than the latest movement is stale and must be redone. A variance
      # beyond the branch threshold needs a reason and spends an approval
      # bound to this count. Once closed, cash posts to the shift fail with
      # `shift_closed`; retrying the close returns the same snapshot.
      class Close
        def self.call(store:, staff:, key:, shift_id:, reason: nil, approval_id: nil)
          payload = { 'command' => 'shift.close', 'shift_id' => shift_id.to_s, 'reason' => reason.to_s.strip.presence,
                      'approval_id' => approval_id.to_s.presence }
          authorize = lambda do
            shift = Guard.shift!(store, shift_id)
            Guard.authorize_closer!(store, staff, shift) unless shift.closure
          end
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: authorize) do
            shift = Guard.shift!(store, shift_id)
            existing = shift.closure
            if existing
              Guard.authorize_closer!(store, staff, shift) unless existing.closer_id == staff.id
              next existing.to_pos
            end

            close!(store, staff, shift, Guard.reason!(reason), approval_id)
          end
        end

        def self.close!(store, staff, shift, reason, approval_id)
          begin
            ShiftBarrier.hold!(shift)
          rescue Conflict => e
            # A concurrent close (another key) won the barrier: same snapshot.
            closure = ShiftClosure.find_by(shift_id: shift.id)
            return closure.to_pos if e.reason == 'shift_closed' && closure

            raise
          end
          raise Conflict.new('Count the drawer before closing.', reason: 'count_required') if shift.closing_counted.nil?
          if shift.closing_counted_by_id != staff.id
            raise Conflict.new('Only the person who counted the drawer can close it; count again.',
                               reason: 'recount_required')
          end
          raise Conflict.new('Cash moved after the count; count the drawer again.', reason: 'count_stale') if Guard.count_stale?(shift)

          checklist = ShiftChecklist.new(shift)
          raise CloseBlocked, checklist if checklist.blocked?

          projection = CashbookProjection.new(shift)
          expected = projection.expected
          counted = shift.closing_counted
          variance = counted - expected
          note = reason || shift.closing_reason
          approval = nil
          if Guard.requires_approval?(shift.branch, variance)
            # The approver judged the reason recorded with the count; it is the one kept.
            note = shift.closing_reason
            raise Conflict.new('A variance this large needs a reason with the count.', reason: 'reason_required') if note.blank?

            approval = approval_for(shift, approval_id)
            raise Conflict.new('This variance needs an approval.', reason: 'approval_required') if approval.nil?

            approval.consume!(action: Guard::CLOSE_ACTION, amount: variance, currency: shift.currency,
                              revision: shift.revision, subject: shift, requester: staff)
          end

          now = Time.current
          closure = ShiftClosure.create!(
            store: store, branch: shift.branch, register: shift.register, shift: shift, closer: staff,
            approver: approval&.approver, approval: approval, currency: shift.currency, opening_float: shift.opening_float,
            inflow_total: projection.inflow_total, outflow_total: projection.outflow_total, expected: expected,
            counted: counted, variance: variance, variance_threshold: shift.branch.variance_threshold, reason: note,
            cutoff_movement_id: projection.last_movement_id, movement_count: projection.movement_count,
            breakdown: projection.breakdown, opened_at: shift.opened_at, closed_at: now
          )
          shift.update!(status: 'closed', closed_at: now)
          AuditEntry.record!(store: store, actor: staff, action: 'shift.close', subject: shift,
                             metadata: { closure_id: closure.prefixed_id, expected: expected.to_s('F'),
                                         counted: counted.to_s('F'), variance: variance.to_s('F'),
                                         approval_id: approval&.prefixed_id })
          OutboxEntry.record!(store: store, event_type: 'shift.closed', aggregate: closure,
                              payload: { 'shift_id' => shift.prefixed_id, 'closure_id' => closure.prefixed_id })
          ReceiptBuilder.issue_safely!(closure, actor: staff) # closing slip; never blocks the close
          closure.to_pos
        end

        def self.approval_for(shift, approval_id)
          if approval_id.present?
            Approval.locate(Approval.for_store(shift.store).where(branch_id: shift.branch_id), approval_id)
          else
            Guard.usable_approval(shift)
          end
        end
      end
    end
  end
end
