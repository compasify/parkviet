# frozen_string_literal: true

module Spree
  module Pos
    module Shifts
      # Shared rules for counting, approving and closing a shift.
      module Guard
        CLOSE_ACTION = 'shift.close'

        module_function

        def shift!(store, shift_id)
          shift = Shift.locate(Shift.for_store(store), shift_id)
          raise ActiveRecord::RecordNotFound if shift.nil?

          shift
        end

        # The shift owner closes their own drawer; a manager with recovery
        # rights at the branch may close it for an absent cashier.
        def closer?(store, staff, shift)
          policy = AccessPolicy.new(store: store, staff: staff)
          return false unless policy.active_staff?

          (shift.owner_id == staff.id && policy.allows?(shift.branch, Capabilities::OPEN_SHIFT)) ||
            policy.allows?(shift.branch, Capabilities::RECOVER)
        end

        def authorize_closer!(store, staff, shift)
          raise CanCan::AccessDenied unless closer?(store, staff, shift)
        end

        def counted!(value, currency)
          amount = Record.money(value.to_s)
          if amount.nil? || amount.negative? || !Record.countable_money?(amount, currency)
            raise Conflict.new('Counted cash must be a whole amount of at least zero.', reason: 'amount_invalid')
          end

          amount
        end

        def reason!(value)
          text = value.to_s.strip
          raise Conflict.new('Reason is too long.', reason: 'reason_invalid') if text.length > 200

          text.presence
        end

        # A variance beyond the branch threshold needs a reason and an
        # approval; without a configured threshold every non-zero variance does.
        def requires_approval?(branch, variance)
          return false if variance.zero?

          threshold = branch.variance_threshold
          threshold.nil? || variance.abs > threshold
        end

        # Movements are inserted under the shift barrier, so their ids are
        # ordered with the count: any id above the count's cutoff came after it.
        def count_stale?(shift)
          return true if shift.closing_counted_at.nil?

          CashMovement.where(shift_id: shift.id).where('id > ?', shift.closing_cutoff_movement_id.to_i).exists?
        end

        def last_movement_id(shift)
          CashMovement.where(shift_id: shift.id).maximum(:id)
        end

        def usable_approval(shift)
          Approval.where(store_id: shift.store_id, subject_type: Shift.name, subject_id: shift.id, action: CLOSE_ACTION,
                         status: 'active', revision: shift.revision.to_s).order(id: :desc).detect(&:usable?)
        end

        # What the counter sees after a blind count: never before it.
        def preview(shift, projection = CashbookProjection.new(shift))
          counted = shift.closing_counted
          base = { shift_id: shift.prefixed_id, branch_id: shift.branch.prefixed_id, currency: shift.currency,
                   revision: shift.revision, status: shift.status, counted: counted&.to_s('F'),
                   variance_threshold: shift.branch.variance_threshold&.to_s('F'), reason: shift.closing_reason,
                   counted_at: shift.closing_counted_at&.iso8601,
                   counted_by_id: shift.closing_counted_by&.prefixed_id }
          return base.merge(expected: nil, variance: nil, requires_approval: nil, stale: nil, approval: nil) if counted.nil?

          expected = projection.expected
          variance = counted - expected
          approval = usable_approval(shift)
          base.merge(
            expected: expected.to_s('F'), variance: variance.to_s('F'), stale: count_stale?(shift),
            requires_approval: requires_approval?(shift.branch, variance),
            approval: approval && { id: approval.prefixed_id, approver_id: approval.approver.prefixed_id,
                                    approver_name: StaffName.call(approval.approver), amount: approval.amount&.to_s('F'),
                                    expires_at: approval.expires_at.iso8601 }
          )
        end
      end
    end
  end
end
