# frozen_string_literal: true

module Spree
  module Pos
    module LiabilityPayouts
      # Confirms the money physically left custody, with evidence. The confirmer
      # must not be the requester. Cash leaves the confirmer's own open drawer in
      # the funds' branch, so the outflow lands on the shift that actually paid.
      class Confirm
        AWAITING = %w[requested reserved unknown].freeze

        def self.call(store:, staff:, key:, payout_id:, evidence_kind:, reference: nil, paid_from: nil)
          payload = { 'command' => 'liability_payout.confirm', 'payout_id' => payout_id.to_s,
                      'evidence_kind' => evidence_kind.to_s, 'reference' => reference.to_s.presence,
                      'paid_from' => paid_from.to_s.presence }
          authorize = -> { Guard.authorize_resolve!(store, staff, Guard.payout!(store, payout_id).branch) }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: authorize) do
            payout = Guard.payout!(store, payout_id)
            raise Conflict, 'Payout is not awaiting confirmation.' unless AWAITING.include?(payout.status)
            raise Conflict, 'A payout must be confirmed by someone other than its requester.' if payout.requester_id == staff.id

            funds = payout.received_funds
            expected = funds.kind == 'cash' ? 'cash_count' : 'bank_manual'
            raise Conflict, 'Payout evidence does not match the funds kind.' unless evidence_kind.to_s == expected
            raise Conflict, 'Bank payout evidence needs the transfer reference.' if expected == 'bank_manual' && reference.blank?

            # Held cash is not in a drawer: refused, or a custody-only outflow.
            from_drawer = expected == 'cash_count' && CustodyPayout.drawer?(funds, paid_from, reference)
            drawer = from_drawer ? open_drawer!(store, staff, funds.branch) : nil
            # Close barrier before the funds lock (shift -> funds lock order).
            ShiftBarrier.hold!(drawer) if drawer
            funds.with_lock do
              payout.lock!
              raise Conflict, 'Payout is not awaiting confirmation.' unless AWAITING.include?(payout.status)
              # Custody may have been reconciled while this waited for the lock.
              if expected == 'cash_count' && CustodyPayout.drawer?(funds, paid_from, reference) != from_drawer
                raise Conflict.new('The cash custody changed; try again.', reason: 'retry')
              end

              PayoutEvidence.create!(store: store, liability_payout: payout, actor: staff, kind: expected,
                                     reference: reference.presence, attested_at: Time.current,
                                     metadata: expected == 'cash_count' ? CustodyPayout.metadata(from_drawer) : {})
              if drawer
                CashMovement.create!(
                  store: store, branch: funds.branch, register: drawer.register, shift: drawer,
                  received_funds: funds, liability_payout: payout, actor: staff, kind: 'payout',
                  amount: -payout.amount, currency: payout.currency,
                  source_type: payout.class.name, source_id: payout.id
                )
              end
              payout.update!(status: 'confirmed', confirmed_at: Time.current)
            end
            AuditEntry.record!(store: store, actor: staff, action: 'liability_payout.confirm', subject: funds,
                               metadata: { payout_id: payout.prefixed_id, shift_id: drawer&.prefixed_id })
            OutboxEntry.record!(store: store, event_type: 'liability_payout.confirmed', aggregate: payout,
                                payload: { 'payout_id' => payout.prefixed_id })
            payout.to_pos
          end
        end

        def self.open_drawer!(store, staff, branch)
          shift = Shift.for_store(store).find_by(branch_id: branch.id, owner_id: staff.id, status: 'open')
          raise Conflict, 'Cash payouts need your own open shift in this branch.' if shift.nil?

          shift
        end
      end
    end
  end
end
