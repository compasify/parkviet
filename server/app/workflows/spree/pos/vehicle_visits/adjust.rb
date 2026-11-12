# frozen_string_literal: true

module Spree
  module Pos
    module VehicleVisits
      # Corrects a closed, unpaid visit: its guest count (the commission is
      # worked out again with the rule the visit closed with) or its
      # commission typed by hand, with a reason. Always needs an approval of
      # `vehicle_visit.adjust` granted by someone else and bound to the
      # visit's revision, since a raised guest count pays the driver more.
      # The snapshot keeps the values before the correction.
      module Adjust
        ACTION = Approval::VEHICLE_VISIT_ADJUST_ACTION

        module_function

        def call(store:, staff:, key:, visit_id:, revision:, note:, guest_count: nil, commission_amount: nil, approval_id: nil)
          visit = Guard.visit!(store, visit_id)
          payload = { 'command' => ACTION, 'visit_id' => visit.prefixed_id, 'revision' => revision.to_s,
                      'guest_count' => guest_count.to_s.presence, 'commission_amount' => commission_amount.to_s.presence,
                      'note' => note.to_s.squish, 'approval_id' => approval_id.to_s.presence }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload,
                               authorize: -> { Guard.manage!(store, staff, visit.branch) }) do
            ModulePolicy.require!(visit.branch, Guard::MODULE)
            visit.lock!
            Guard.status!(visit, 'closed')
            Guard.revision!(visit, revision)
            text = Guard.text!(note, 200, 'note')
            raise Conflict.new('Say why the visit is corrected.', reason: 'reason_required') if text.nil?
            if guest_count.blank? && commission_amount.blank?
              raise Conflict.new('Change the guests or the commission.', reason: 'vehicle_visit_invalid')
            end

            guests = guest_count.present? ? Guard.guests!(guest_count) : visit.guest_count
            amount = commission_amount.present? ? amount!(commission_amount, visit.currency) : nil
            approval = approve!(visit, staff, approval_id)
            before = { 'guest_count' => visit.guest_count, 'amount' => visit.commission_amount.to_s('F') }
            snapshot = recompute(visit, guests, amount)
            snapshot['adjustments'] = Array(visit.commission_snapshot['adjustments']) +
                                      [before.merge('note' => text, 'approval_id' => approval.prefixed_id, 'at' => Time.current.iso8601)]
            visit.update!(guest_count: guests, commission_amount: BigDecimal(snapshot['amount']), commission_snapshot: snapshot,
                          revision: visit.revision + 1)
            Guard.audit!(visit, staff, ACTION, before: before, note: text, approval_id: approval.prefixed_id,
                                               approver_id: approval.approver.prefixed_id)
            Guard.to_pos(visit, staff)
          end
        end

        def recompute(visit, guests, amount)
          kept = visit.commission_snapshot.deep_dup
          if amount
            kept.merge('guest_count' => guests, 'amount' => amount.to_s('F'), 'manual' => true)
          else
            fresh = VehicleCommission::Calculator.call(rule: kept['rule'], vehicle_type: visit.vehicle_type, guest_count: guests,
                                                       revenue: visit.revenue_amount || 0)
            kept.merge(fresh).merge('manual' => false)
          end
        end

        def amount!(value, currency)
          parsed = Record.money(value)
          raise Conflict.new('The amount is invalid.', reason: 'amount_invalid') if parsed.nil? || !Record.countable_money?(parsed, currency)

          parsed
        end

        def approve!(visit, staff, approval_id)
          message = 'Correcting a closed visit needs approval.'
          details = { action: ACTION, subject_id: visit.prefixed_id, revision: visit.revision }
          raise Conflict.new(message, reason: 'approval_required', details: details) if approval_id.blank?

          approval = Approval.locate(Approval.for_store(visit.store).where(branch_id: visit.branch_id), approval_id)
          raise Conflict.new(message, reason: 'approval_required', details: details) if approval.nil?

          approval.consume!(action: ACTION, amount: nil, currency: nil, revision: visit.revision, subject: visit, requester: staff)
          AuditEntry.record!(store: visit.store, actor: staff, action: 'approval.consume', subject: approval,
                             metadata: { approval_action: ACTION, approver_id: approval.approver.prefixed_id })
          approval
        end
      end
    end
  end
end
