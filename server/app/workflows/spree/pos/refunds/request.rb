# frozen_string_literal: true

module Spree
  module Pos
    module Refunds
      # Reserves part of a return's refund entitlement against one original
      # receipt, through the allocation child that paid the order. The amount
      # is bounded at once by the return's remaining refund entitlement, by
      # what that child can still give back (its face amount less refunds and
      # other reserved or unknown requests) and so by the parent receipt it
      # belongs to. No money moves and no core Refund exists until a payout is
      # confirmed with evidence. Lock order: return -> parent funds -> child.
      class Request
        def self.call(store:, staff:, key:, return_id:, allocation_id:, amount:, method:, beneficiary_reference: nil)
          parsed = Record.money(amount.to_s)
          payload = { 'command' => 'refund.request', 'return_id' => return_id.to_s, 'allocation_id' => allocation_id.to_s,
                      'amount' => parsed&.to_s('F'), 'method' => method.to_s, 'beneficiary_reference' => beneficiary_reference.to_s.strip.presence }
          authorize = lambda do
            operation = Returns::Guard.operation!(store, return_id)
            raise CanCan::AccessDenied unless Guard.allows?(store, staff, operation.branch, Capabilities::RETURN)
          end
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: authorize) do
            raise Conflict, 'Refund method is invalid.' unless %w[cash bank_manual].include?(method.to_s)
            raise Conflict, 'A bank refund needs the beneficiary account.' if method.to_s == 'bank_manual' && beneficiary_reference.to_s.strip.blank?

            operation = Returns::Guard.operation!(store, return_id)
            operation.lock!
            raise Conflict, 'Amount is invalid.' if parsed.nil? || parsed <= 0
            raise Conflict, 'Amount must be a whole amount in the currency.' unless Record.countable_money?(parsed, operation.currency)
            unless operation.entitlement_status == 'posted'
              raise Conflict.new('The return has no posted refund entitlement yet.',
                                 reason: 'entitlement_not_posted')
            end
            if parsed > operation.refundable_remaining
              raise Conflict.new('Amount exceeds the refund entitlement left on this return.',
                                 reason: 'exceeds_entitlement')
            end

            allocation = FundsAllocation.locate(FundsAllocation.where(order_id: operation.order_id), allocation_id)
            raise ActiveRecord::RecordNotFound if allocation.nil?

            funds = allocation.received_funds
            request = nil
            funds.with_lock do
              allocation.lock!
              if allocation.payment.nil? || allocation.status != 'active' || allocation.payment.status != 'completed'
                raise Conflict,
                      'This payment cannot be refunded.'
              end
              raise Conflict.new('Amount exceeds what this payment can still refund.', reason: 'exceeds_payment') if parsed > allocation.refundable

              reserved = RefundRequest.reserving.where(payment_id: allocation.payment_id).sum(:amount)
              if parsed > allocation.payment.credit_allowed - reserved
                raise Conflict.new('Amount exceeds what this payment can still refund.',
                                   reason: 'exceeds_payment')
              end

              request = RefundRequest.create!(
                store: store, branch: operation.branch, return_operation: operation, funds_allocation: allocation,
                received_funds: funds, payment: allocation.payment, order: operation.order, requester: staff,
                method: method.to_s, status: 'reserved', amount: parsed, currency: operation.currency,
                beneficiary_reference: beneficiary_reference.to_s.strip.presence&.slice(0, 120)
              )
            end
            AuditEntry.record!(store: store, actor: staff, action: 'refund.request', subject: operation,
                               metadata: { refund_id: request.prefixed_id, amount: parsed.to_s('F'), method: method.to_s,
                                           funds_id: funds.prefixed_id, allocation_id: allocation.prefixed_id })
            OutboxEntry.record!(store: store, event_type: 'refund.requested', aggregate: request,
                                payload: { 'refund_id' => request.prefixed_id, 'return_id' => operation.prefixed_id })
            request.to_pos
          end
        end
      end
    end
  end
end
