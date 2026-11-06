# frozen_string_literal: true

module Spree
  module Pos
    module LiabilityPayouts
      # Confirms the money physically left custody, with evidence. Cash paid
      # from the drawer of the funds' shift writes a source-unique movement.
      class Confirm
        def self.call(store:, staff:, key:, payout_id:, evidence_kind:, reference: nil)
          payload = { 'command' => 'liability_payout.confirm', 'payout_id' => payout_id.to_s,
                      'evidence_kind' => evidence_kind.to_s, 'reference' => reference.to_s.presence }
          authorize = -> { Guard.authorize_resolve!(store, staff, Guard.payout!(store, payout_id).branch) }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: authorize) do
            payout = Guard.payout!(store, payout_id)
            raise Conflict, 'Payout is not awaiting confirmation.' unless %w[requested reserved unknown].include?(payout.status)

            expected = payout.received_funds.kind == 'cash' ? 'cash_count' : 'bank_manual'
            raise Conflict, 'Payout evidence does not match the funds kind.' unless evidence_kind.to_s == expected

            payout.received_funds.with_lock do
              payout.lock!
              raise Conflict, 'Payout is not awaiting confirmation.' unless %w[requested reserved unknown].include?(payout.status)

              PayoutEvidence.create!(store: store, liability_payout: payout, actor: staff, kind: expected,
                                     reference: reference.presence, attested_at: Time.current)
              if expected == 'cash_count'
                funds = payout.received_funds
                CashMovement.create!(
                  store: store, branch: funds.branch, register: funds.register, shift: funds.shift,
                  received_funds: funds, liability_payout: payout, actor: staff, kind: 'payout',
                  amount: -payout.amount, currency: payout.currency,
                  source_type: payout.class.name, source_id: payout.id
                )
              end
              payout.update!(status: 'confirmed', confirmed_at: Time.current)
            end
            AuditEntry.record!(store: store, actor: staff, action: 'liability_payout.confirm', subject: payout.received_funds,
                               metadata: { payout_id: payout.prefixed_id })
            OutboxEntry.record!(store: store, event_type: 'liability_payout.confirmed', aggregate: payout,
                                payload: { 'payout_id' => payout.prefixed_id })
            payout.to_pos
          end
        end
      end
    end
  end
end
