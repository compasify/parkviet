# frozen_string_literal: true

module Spree
  module Pos
    module VehicleVisits
      # Pays a closed visit's commission to its driver, once.
      #
      # - `cash` is a cash out from the payer's own open shift: a
      #   CashMovementRequest "Hoa hồng xe <plate>" whose evidence is the
      #   visit, confirmed by a second person like any cash out
      #   (Shifts::ConfirmCashMovement), so the drawer changes only then and
      #   the shift's count reconciles it. The visit is `paid` from the
      #   request on; if the request is canceled the visit can be paid again.
      # - `transfer` records the bank transfer reference; no drawer moves.
      #
      # The visit row is locked first, then the shift barrier, so two
      # payouts of one visit cannot both pass; the request is unique per
      # visit and the command is idempotent by key.
      module Pay
        COMMAND = 'vehicle_visit.pay'
        METHODS = VehicleVisit::PAYOUT_METHODS

        module_function

        def call(store:, staff:, key:, visit_id:, payout_method:, transfer_reference: nil)
          visit = Guard.visit!(store, visit_id)
          payload = { 'command' => COMMAND, 'visit_id' => visit.prefixed_id, 'payout_method' => payout_method.to_s,
                      'transfer_reference' => transfer_reference.to_s.strip.presence }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload,
                               authorize: -> { Guard.manage!(store, staff, visit.branch) }) do
            ModulePolicy.require!(visit.branch, Guard::MODULE)
            raise Conflict.new('Choose cash or transfer.', reason: 'payout_method_invalid') unless METHODS.include?(payout_method.to_s)

            visit.lock!
            payable!(visit)
            payout_method.to_s == 'cash' ? cash!(visit, staff) : transfer!(visit, staff, transfer_reference)
            Guard.audit!(visit, staff, COMMAND, payout_method: visit.payout_method,
                                                cash_movement_request_id: visit.cash_movement_request&.prefixed_id)
            Guard.to_pos(visit, staff)
          end
        end

        def payable!(visit)
          again = visit.paid? && visit.payout_method == 'cash' && visit.cash_movement_request.status == 'canceled'
          Guard.status!(visit, 'closed') unless again
          return if visit.commission_amount.to_d.positive?

          raise Conflict.new('This visit earned no commission.', reason: 'vehicle_commission_zero')
        end

        def cash!(visit, staff)
          shift = Shift.for_store(visit.store).open_now.find_by(branch_id: visit.branch_id, owner_id: staff.id)
          raise Conflict.new('Open your shift at this branch to pay in cash.', reason: 'shift_required') if shift.nil?

          FeaturePolicy.require!(shift.branch, :cash_moves)
          amount = visit.commission_amount
          reason, evidence = Shifts::PostCashMovement.validate!('cash_out', amount, shift.currency, "Hoa hồng xe #{visit.plate}",
                                                               visit.prefixed_id)
          ShiftBarrier.hold!(shift)
          Shifts::PostCashMovement.ensure_cash!(shift, amount)
          request = CashMovementRequest.create!(
            store: visit.store, branch: shift.branch, shift: shift, requester: staff, kind: 'cash_out', status: 'requested',
            amount: amount, currency: shift.currency, reason: reason, evidence_reference: evidence
          )
          AuditEntry.record!(store: visit.store, actor: staff, action: 'cash.move_request', subject: shift,
                             metadata: { request_id: request.prefixed_id, kind: 'cash_out', amount: amount.to_s('F'),
                                         reason: reason, evidence_reference: evidence, vehicle_visit_id: visit.prefixed_id })
          visit.update!(status: 'paid', payout_method: 'cash', cash_movement_request: request, transfer_reference: nil,
                        paid_at: Time.current, paid_by: staff, revision: visit.revision + 1)
        end

        def transfer!(visit, staff, transfer_reference)
          reference = Guard.text!(transfer_reference, 120, 'transfer_reference')
          raise Conflict.new('Type the transfer reference.', reason: 'transfer_reference_required') if reference.nil?

          visit.update!(status: 'paid', payout_method: 'transfer', transfer_reference: reference, cash_movement_request: nil,
                        paid_at: Time.current, paid_by: staff, revision: visit.revision + 1)
        end
      end
    end
  end
end
