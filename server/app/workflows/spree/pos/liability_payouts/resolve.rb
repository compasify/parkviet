# frozen_string_literal: true

module Spree
  module Pos
    module LiabilityPayouts
      # Resolves an uncertain payout. `unknown` keeps the reservation;
      # `failed_no_effect` releases it only with explicit no-effect evidence.
      class Resolve
        def self.call(store:, staff:, key:, payout_id:, outcome:, reference: nil)
          payload = { 'command' => 'liability_payout.resolve', 'payout_id' => payout_id.to_s,
                      'outcome' => outcome.to_s, 'reference' => reference.to_s.presence }
          authorize = -> { Guard.authorize_resolve!(store, staff, Guard.payout!(store, payout_id).branch) }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: authorize) do
            payout = Guard.payout!(store, payout_id)
            raise Conflict, 'Payout cannot be resolved from this state.' unless %w[requested reserved unknown].include?(payout.status)

            payout.received_funds.with_lock do
              payout.lock!
              case outcome.to_s
              when 'unknown'
                PayoutEvidence.create!(store: store, liability_payout: payout, actor: staff, kind: evidence_kind(payout),
                                       reference: reference.presence, attested_at: Time.current)
                payout.update!(status: 'unknown')
              when 'failed_no_effect'
                PayoutEvidence.create!(store: store, liability_payout: payout, actor: staff, kind: 'failed_no_effect',
                                       reference: reference.presence, attested_at: Time.current)
                payout.update!(status: 'failed', resolved_at: Time.current)
              when 'cancel'
                payout.update!(status: 'canceled', resolved_at: Time.current)
              else
                raise Conflict, 'Payout resolution outcome is invalid.'
              end
            end
            AuditEntry.record!(store: store, actor: staff, action: 'liability_payout.resolve', subject: payout.received_funds,
                               metadata: { payout_id: payout.prefixed_id, outcome: outcome.to_s })
            payout.to_pos
          end
        end

        def self.evidence_kind(payout)
          payout.received_funds.kind == 'cash' ? 'cash_count' : 'bank_manual'
        end
      end
    end
  end
end
