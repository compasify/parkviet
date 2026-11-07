# frozen_string_literal: true

module Spree
  module Pos
    module LiabilityPayouts
      module Guard
        module_function

        def authorize_resolve!(store, staff, branch)
          policy = AccessPolicy.new(store: store, staff: staff)
          raise CanCan::AccessDenied unless policy.allows?(branch, Capabilities::RESOLVE)
        end

        def funds!(store, funds_id)
          funds = ReceivedFunds.locate(ReceivedFunds.for_store(store), funds_id)
          raise ActiveRecord::RecordNotFound if funds.nil?

          funds
        end

        def payout!(store, payout_id)
          payout = LiabilityPayout.locate(LiabilityPayout.for_store(store), payout_id)
          raise ActiveRecord::RecordNotFound if payout.nil?

          payout
        end
      end

      # Reserves available unapplied funds for a payout. The reservation is
      # the payout row itself in requested/reserved/unknown status.
      class Request
        ACTION = 'liability_payout.request'

        def self.call(store:, staff:, key:, funds_id:, amount:, beneficiary_name:, beneficiary_reference: nil, reason:, approval_id: nil)
          parsed = Record.money(amount.to_s)
          payload = {
            'command' => ACTION, 'funds_id' => funds_id.to_s, 'amount' => parsed&.to_s('F'),
            'beneficiary_name' => beneficiary_name.to_s, 'beneficiary_reference' => beneficiary_reference.to_s.presence,
            'reason' => reason.to_s, 'approval_id' => approval_id.to_s.presence
          }
          authorize = -> { Guard.authorize_resolve!(store, staff, Guard.funds!(store, funds_id).branch) }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: authorize) do
            funds = Guard.funds!(store, funds_id)
            raise Conflict, 'Amount is invalid.' if parsed.nil? || parsed <= 0
            raise Conflict, 'Amount must be a whole amount in the currency.' unless Record.countable_money?(parsed, funds.currency)
            raise Conflict, 'Beneficiary and reason are required.' if beneficiary_name.blank? || reason.blank?

            # Consuming an approval locks its workspace; take that lock before the
            # funds lock, the same order allocations use, so the two cannot deadlock.
            approve!(store, staff, funds, parsed, approval_id)
            payout = nil
            funds.with_lock do
              raise Conflict, 'Amount exceeds available unapplied funds.' if FundsBalance.new(funds).available < parsed

              payout = LiabilityPayout.create!(
                store: store, received_funds: funds, branch: funds.branch, requester: staff, status: 'reserved',
                amount: parsed, currency: funds.currency, beneficiary_name: beneficiary_name.to_s,
                beneficiary_reference: beneficiary_reference.presence, reason: reason.to_s
              )
            end
            AuditEntry.record!(store: store, actor: staff, action: ACTION, subject: funds,
                               metadata: { payout_id: payout.prefixed_id, amount: parsed.to_s('F') })
            OutboxEntry.record!(store: store, event_type: 'liability_payout.requested', aggregate: payout,
                                payload: { 'payout_id' => payout.prefixed_id, 'funds_id' => funds.prefixed_id })
            payout.to_pos
          end
        end

        def self.approve!(store, staff, funds, amount, approval_id)
          return if AccessPolicy.new(store: store, staff: staff).allows?(funds.branch, Capabilities::APPROVE)

          raise Conflict, 'Payout approval is required.' if approval_id.blank?

          approval = Approval.locate(Approval.for_store(store).where(branch_id: funds.branch_id), approval_id)
          raise Conflict, 'Payout approval is required.' if approval.nil?
          raise Conflict, 'Approval subject is required.' unless funds.workspace.is_a?(Spree::Pos::Workspace)

          approval.consume!(action: ACTION, amount: amount, currency: funds.currency,
                            revision: funds.workspace.revision, subject: funds.workspace, requester: staff)
        end
      end
    end
  end
end
