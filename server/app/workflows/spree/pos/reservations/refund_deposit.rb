# frozen_string_literal: true

module Spree
  module Pos
    module Reservations
      # Pays a deposit back: what is still available on its receipt is
      # reserved as a LiabilityPayout to the guest, the same payout any
      # unapplied money takes; someone other than the requester confirms the
      # money left (LiabilityPayouts::Confirm). Needs an approval of
      # `reservation.refund_deposit` for that amount unless the requester
      # approves. A deposit partly applied to the bill refunds the rest.
      module RefundDeposit
        ACTION = 'reservation.refund_deposit'

        module_function

        def call(store:, staff:, key:, deposit_id:, beneficiary_name: nil, beneficiary_reference: nil, reason: nil, approval_id: nil)
          payload = { 'command' => ACTION, 'deposit_id' => deposit_id.to_s, 'beneficiary_name' => beneficiary_name.to_s.presence,
                      'beneficiary_reference' => beneficiary_reference.to_s.presence, 'reason' => reason.to_s.presence,
                      'approval_id' => approval_id.to_s.presence }
          deposit = Guard.deposit!(store, deposit_id)
          reservation = deposit.reservation
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload,
                               authorize: -> { Guard.resolve!(store, staff, reservation.branch) }) do
            reservation.lock!
            deposit.lock!
            raise Conflict.new('This deposit is already settled.', reason: 'deposit_settled') unless %w[held applied].include?(deposit.status)

            funds = deposit.received_funds
            amount = FundsBalance.new(funds).available
            raise Conflict.new('Nothing of this deposit is left to refund.', reason: 'deposit_none') unless amount.positive?

            approval = Guard.approve!(reservation, staff, ACTION, amount, approval_id)
            payout = nil
            funds.with_lock do
              raise Conflict, 'Amount exceeds available unapplied funds.' if FundsBalance.new(funds).available < amount

              payout = LiabilityPayout.create!(
                store: store, received_funds: funds, branch: funds.branch, requester: staff, status: 'reserved',
                amount: amount, currency: funds.currency, beneficiary_name: beneficiary_name.presence || reservation.guest_name,
                beneficiary_reference: beneficiary_reference.presence || reservation.phone,
                reason: reason.presence || "Hoàn cọc đặt bàn #{reservation.prefixed_id}"
              )
            end
            deposit.update!(status: 'refunded', liability_payout: payout, resolved_at: Time.current)
            reservation.bump!
            AuditEntry.record!(store: store, actor: staff, action: ACTION, subject: reservation,
                               metadata: { deposit_id: deposit.prefixed_id, payout_id: payout.prefixed_id, amount: amount.to_s('F'),
                                           approval_id: approval&.prefixed_id })
            OutboxEntry.record!(store: store, event_type: 'liability_payout.requested', aggregate: payout,
                                payload: { 'payout_id' => payout.prefixed_id, 'funds_id' => funds.prefixed_id })
            reservation.reload.to_pos
          end
        end
      end
    end
  end
end
