# frozen_string_literal: true

module Spree
  module Pos
    module Shifts
      # An approver grants the variance of one blind count: the approval is
      # bound to the shift, its count revision, the counter and the exact
      # variance. A new count, a changed reason or a cash movement after the
      # count makes it unusable. Nobody approves their own count.
      class ApproveClose
        def self.call(store:, staff:, key:, shift_id:, revision:)
          payload = { 'command' => 'shift.approve_close', 'shift_id' => shift_id.to_s, 'revision' => revision.to_s }
          authorize = lambda do
            shift = Guard.shift!(store, shift_id)
            raise CanCan::AccessDenied unless AccessPolicy.new(store: store, staff: staff).allows?(shift.branch, Capabilities::APPROVE)
          end
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: authorize) do
            shift = Guard.shift!(store, shift_id)
            ShiftBarrier.hold!(shift)
            raise Conflict.new('The drawer has not been counted.', reason: 'count_required') if shift.closing_counted.nil?
            if revision.to_s != shift.revision.to_s
              raise Conflict.new('The count changed; review it again.', reason: 'revision_stale', revision: shift.revision)
            end
            raise Conflict.new('Cash moved after the count; the drawer must be counted again.', reason: 'count_stale') if Guard.count_stale?(shift)
            raise Conflict.new('Nobody approves their own count.', reason: 'self_approval') if shift.closing_counted_by_id == staff.id

            variance = shift.closing_counted - CashbookProjection.new(shift).expected
            needed = Guard.requires_approval?(shift.branch, variance)
            raise Conflict.new('This variance needs no approval.', reason: 'approval_not_needed') unless needed
            raise Conflict.new('The counter must give a reason for the variance first.', reason: 'reason_required') if shift.closing_reason.blank?

            approval = Approval.create!(
              store: store, branch: shift.branch, approver: staff, requester: shift.closing_counted_by,
              subject_type: Shift.name, subject_id: shift.id, action: Guard::CLOSE_ACTION, amount: variance,
              currency: shift.currency, revision: shift.revision.to_s, expires_at: Approval::MAX_TTL.from_now, status: 'active'
            )
            AuditEntry.record!(store: store, actor: staff, action: 'approval.grant', subject: shift,
                               metadata: { approval_id: approval.prefixed_id, action: approval.action,
                                           variance: variance.to_s('F'), revision: approval.revision })
            Guard.preview(shift)
          end
        end
      end
    end
  end
end
