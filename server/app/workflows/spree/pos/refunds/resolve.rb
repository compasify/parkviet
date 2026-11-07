# frozen_string_literal: true

module Spree
  module Pos
    module Refunds
      # Resolves an uncertain refund payout. `unknown` keeps the reservation
      # (the money may have moved); `failed_no_effect` releases it only with
      # evidence the payout cannot take effect, and needs a resolver;
      # `cancel` withdraws a request whose payout never started: only its
      # requester or an approver, with a reason, and never once an approval
      # was granted for it (the payout may be under way; that path is
      # `unknown`, then `failed_no_effect` with evidence).
      class Resolve
        ALLOWED_FROM = {
          'unknown' => %w[reserved],
          'failed_no_effect' => %w[reserved unknown],
          'cancel' => %w[reserved]
        }.freeze

        def self.call(store:, staff:, key:, refund_id:, outcome:, reference: nil, reason: nil)
          payload = { 'command' => 'refund.resolve', 'refund_id' => refund_id.to_s, 'outcome' => outcome.to_s,
                      'reference' => reference.to_s.strip.presence, 'reason' => reason.to_s.strip.presence }
          authorize = -> { authorize!(store, staff, Guard.request!(store, refund_id), outcome.to_s) }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: authorize) do
            allowed = ALLOWED_FROM[outcome.to_s]
            raise Conflict, 'Refund resolution outcome is invalid.' if allowed.nil?
            if outcome.to_s == 'failed_no_effect' && reference.to_s.strip.blank?
              raise Conflict,
                    'No-effect resolution needs evidence the payout did not happen.'
            end

            request = Guard.request!(store, refund_id)
            request.received_funds.with_lock do
              request.lock!
              raise Conflict.new('Refund cannot be resolved from this state.', reason: 'invalid_state') unless allowed.include?(request.status)

              if outcome.to_s == 'cancel'
                raise Conflict.new('A reason is required to cancel a refund.', reason: 'reason_required') if reason.to_s.strip.blank?
                if request.approval_id
                  raise Conflict.new('An approval was granted for this refund; mark it unknown or failed with evidence instead.',
                                     reason: 'approval_issued')
                end
              end

              case outcome.to_s
              when 'unknown'
                PayoutEvidence.create!(store: store, refund_request: request, actor: staff,
                                       kind: request.method == 'cash' ? 'cash_count' : 'bank_manual',
                                       reference: reference.to_s.strip.presence, attested_at: Time.current, metadata: { outcome: 'unknown' })
                request.update!(status: 'unknown')
              when 'failed_no_effect'
                PayoutEvidence.create!(store: store, refund_request: request, actor: staff, kind: 'failed_no_effect',
                                       reference: reference.to_s.strip, attested_at: Time.current)
                request.update!(status: 'failed', resolved_at: Time.current)
              when 'cancel'
                request.update!(status: 'canceled', resolved_at: Time.current)
              end
            end
            AuditEntry.record!(store: store, actor: staff, action: 'refund.resolve', subject: request.return_operation,
                               metadata: { refund_id: request.prefixed_id, outcome: outcome.to_s,
                                           reason: reason.to_s.strip.presence, reference: reference.to_s.strip.presence })
            request.to_pos
          end
        end

        def self.authorize!(store, staff, request, outcome)
          allowed = case outcome
                    when 'failed_no_effect' then Guard.allows?(store, staff, request.branch, Capabilities::RESOLVE)
                    when 'cancel'
                      Guard.allows?(store, staff, request.branch, Capabilities::APPROVE) ||
                        (request.requester_id == staff.id && Guard.allows?(store, staff, request.branch, Capabilities::RETURN))
                    else Guard.allows?(store, staff, request.branch, Capabilities::RETURN, Capabilities::RESOLVE)
                    end
          raise CanCan::AccessDenied unless allowed
        end
      end
    end
  end
end
