# frozen_string_literal: true

module Spree
  module Pos
    module Collections
      # Undoes one collection child: voids its core Payment, marks the
      # allocation reversed and posts a receivable reversal, returning the
      # child's money to the parent's available bucket. A child whose Payment
      # was already refunded in part is refused as a whole: refunded money has
      # left and must never come back to available through a reversal.
      # Lock order: account -> parent funds -> allocation.
      class Reverse
        def self.call(store:, staff:, key:, collection_id:, allocation_id:, reason:)
          payload = { 'command' => 'collection.reverse', 'collection_id' => collection_id.to_s,
                      'allocation_id' => allocation_id.to_s, 'reason' => reason.to_s }
          authorize = lambda do
            collection = Allocate.collection!(store, collection_id)
            raise CanCan::AccessDenied unless AccessPolicy.new(store: store, staff: staff).allows?(collection.branch, Capabilities::RESOLVE)
          end
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: authorize) do
            raise Conflict, 'A reason is required.' if reason.to_s.strip.blank?

            collection = Allocate.collection!(store, collection_id)
            allocation = FundsAllocation.locate(FundsAllocation.where(collection_id: collection.id), allocation_id)
            raise ActiveRecord::RecordNotFound if allocation.nil?

            collection.credit_account.lock!
            collection.received_funds.lock!
            allocation.lock!
            raise Conflict, 'Allocation is not active.' unless allocation.status == 'active'
            if allocation.consumed.positive?
              raise Conflict.new('Part of this allocation was already refunded; it cannot be reversed.', reason: 'allocation_consumed')
            end

            # Posted returns granted refund entitlement against money this
            # child brought in. Return posting takes the same account lock, so
            # the figures cannot move under this check.
            granted = ReturnOperation.where(order_id: allocation.order_id, entitlement_status: 'posted').sum(:refund_entitlement)
            if granted > Returns::Guard.paid(allocation.order) - allocation.amount
              raise Conflict.new('Refund entitlement of a return depends on this collection; it cannot be reversed.',
                                 reason: 'return_entitlement_depends_on_collection')
            end

            allocation.payment&.void!
            allocation.update!(status: 'reversed', reversed_at: Time.current)
            entry = ReceivableEntry.create!(
              store: store, credit_account: collection.credit_account, branch: collection.branch, order: allocation.order,
              workspace: allocation.workspace, funds_allocation: allocation, actor: staff, kind: 'collection_reversal',
              amount: allocation.amount, currency: allocation.currency, metadata: { reason: reason.to_s.strip }
            )
            AuditEntry.record!(store: store, actor: staff, action: 'collection.reverse', subject: collection,
                               metadata: { allocation_id: allocation.prefixed_id, entry_id: entry.prefixed_id,
                                           amount: allocation.amount.to_s('F'), reason: reason.to_s.strip })
            collection.reload.to_pos
          end
        end
      end
    end
  end
end
