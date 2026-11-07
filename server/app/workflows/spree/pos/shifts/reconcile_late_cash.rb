# frozen_string_literal: true

module Spree
  module Pos
    module Shifts
      # A manager places cash that a closed snapshot or the drawer ledger
      # could not: the overage of a closed shift and/or a held receipt (late
      # cash attested after its shift, recorded without a drawer movement).
      #
      # The outcome says where that money physically is now:
      # - `in_opening_float`: already counted in a later shift's opening float
      #   (`target_shift`, never claiming more than that float); no movement;
      # - `safe` / `handed_over`: in the safe or handed to someone, with a
      #   custody reference; no movement;
      # - `new_physical_inflow`: put into an open drawer now; the only outcome
      #   that posts one CashMovement, to that target shift, under its barrier.
      #
      # The closed snapshot is never rewritten. A closure's linked amounts
      # never exceed its overage; a held receipt is reconciled once. The
      # manager is the approver and must not be the closed shift's owner, its
      # closer, its variance approver, or whoever recorded the held receipt.
      class ReconcileLateCash
        def self.call(store:, staff:, key:, branch_id:, outcome:, reason:, amount: nil, closure_id: nil, funds_id: nil,
                      target_shift_id: nil, custody_reference: nil)
          value = amount.present? ? Record.money(amount.to_s) : nil
          payload = {
            'command' => 'cash.reconcile', 'branch_id' => branch_id.to_s, 'outcome' => outcome.to_s,
            'reason' => reason.to_s.strip, 'amount' => value&.to_s('F'), 'closure_id' => closure_id.to_s.presence,
            'funds_id' => funds_id.to_s.presence, 'target_shift_id' => target_shift_id.to_s.presence,
            'custody_reference' => custody_reference.to_s.strip.presence
          }
          authorize = -> { authorize!(store, staff, branch!(store, branch_id)) }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: authorize) do
            branch = branch!(store, branch_id)
            outcome = outcome.to_s
            note = reason.to_s.strip
            custody = custody_reference.to_s.strip.presence
            validate_input!(outcome, note, custody)
            raise Conflict.new('Link a closed shift or a held receipt.', reason: 'source_required') if closure_id.blank? && funds_id.blank?
            raise Conflict.new('Amount is invalid.', reason: 'amount_invalid') if amount.present? && (value.nil? || !value.positive?)

            # Lock order: target shift -> closure -> held funds.
            target = target_shift!(store, branch, outcome, target_shift_id)
            if outcome == 'new_physical_inflow'
              ShiftBarrier.hold!(target)
            elsif target
              target.lock!('FOR NO KEY UPDATE')
            end
            held = held_funds(store, branch, funds_id)
            closure = closure!(store, branch, closure_id, staff, held)
            funds = funds!(held, staff, closure)
            value = settle_amount!(value, funds, closure, branch)
            check_float!(target, value) if outcome == 'in_opening_float'

            reconciliation = CashReconciliation.create!(
              store: store, branch: branch, shift_closure: closure, received_funds: funds,
              target_shift: target, actor: staff, outcome: outcome, amount: value,
              currency: funds&.currency || closure.currency, reason: note, custody_reference: custody
            )
            movement = post_inflow!(reconciliation, target, funds, staff) if outcome == 'new_physical_inflow'
            AuditEntry.record!(store: store, actor: staff, action: 'cash.reconcile', subject: reconciliation,
                               metadata: { outcome: outcome, amount: value.to_s('F'), closure_id: closure&.prefixed_id,
                                           funds_id: funds&.prefixed_id, target_shift_id: target&.prefixed_id,
                                           movement_id: movement&.prefixed_id })
            reconciliation.reload.to_pos
          end
        end

        def self.validate_input!(outcome, note, custody)
          raise Conflict.new('Custody outcome is invalid.', reason: 'outcome_invalid') unless CashReconciliation::OUTCOMES.include?(outcome)
          raise Conflict.new('A reason is required.', reason: 'reason_required') if note.blank? || note.length > 200
          raise Conflict.new('Custody reference is too long.', reason: 'evidence_invalid') if custody && custody.length > 120
          return unless %w[safe handed_over].include?(outcome) && custody.nil?

          raise Conflict.new('Safe and handover custody need a reference.', reason: 'evidence_required')
        end

        def self.authorize!(store, staff, branch)
          policy = AccessPolicy.new(store: store, staff: staff)
          raise CanCan::AccessDenied unless policy.allows?(branch, Capabilities::APPROVE) && policy.allows?(branch, Capabilities::RESOLVE)
        end

        def self.branch!(store, branch_id)
          branch = Branch.locate(Branch.for_store(store), branch_id)
          raise ActiveRecord::RecordNotFound if branch.nil?

          branch
        end

        def self.target_shift!(store, branch, outcome, target_shift_id)
          if target_shift_id.blank?
            if %w[new_physical_inflow in_opening_float].include?(outcome)
              raise Conflict.new('Choose the shift whose drawer or opening float holds the cash.', reason: 'target_required')
            end

            return
          end
          raise Conflict.new('Only cash put into a drawer or an opening float names a shift.', reason: 'target_invalid') unless %w[
            new_physical_inflow in_opening_float
          ].include?(outcome)

          shift = Shift.locate(Shift.for_store(store).where(branch_id: branch.id), target_shift_id)
          raise ActiveRecord::RecordNotFound if shift.nil?

          shift
        end

        def self.held_funds(store, branch, funds_id)
          return if funds_id.blank?

          funds = ReceivedFunds.locate(ReceivedFunds.for_store(store).where(branch_id: branch.id), funds_id)
          raise ActiveRecord::RecordNotFound if funds.nil?

          funds
        end

        # Held cash attested on a closed shift with an overage is that
        # overage's money: it is linked to (and counted against) the closure
        # even when the caller did not name it, so the closure and the held
        # receipt can never explain the same cash twice.
        def self.closure!(store, branch, closure_id, staff, held)
          closure = if closure_id.present?
                      ShiftClosure.locate(ShiftClosure.for_store(store).where(branch_id: branch.id), closure_id)
                    else
                      held && ShiftClosure.where(shift_id: held.shift_id).where('variance > 0').first
                    end
          raise ActiveRecord::RecordNotFound if closure_id.present? && closure.nil?
          return if closure.nil?

          # Separation of duties: not the cashier, the closer or the variance approver of that shift.
          if [closure.shift.owner_id, closure.closer_id, closure.approver_id].include?(staff.id)
            raise Conflict.new('Nobody reconciles a shift they ran, closed or approved.', reason: 'self_approval')
          end

          closure.lock!
        end

        def self.check_float!(target, value)
          claimed = CashReconciliation.where(target_shift_id: target.id, outcome: 'in_opening_float').sum(:amount)
          return if value <= target.opening_float - claimed

          raise Conflict.new('That opening float cannot hold this much more late cash.', reason: 'exceeds_float')
        end

        def self.funds!(funds, staff, closure)
          return if funds.nil?

          funds.lock!
          unless funds.kind == 'cash' && funds.custody == 'held'
            raise Conflict.new('Only held cash is reconciled here; drawer cash is already counted.', reason: 'not_held')
          end
          raise Conflict.new('Nobody reconciles cash they recorded.', reason: 'self_approval') if funds.actor_id == staff.id
          if CashReconciliation.exists?(received_funds_id: funds.id)
            raise Conflict.new('This held cash is already reconciled.',
                               reason: 'already_reconciled')
          end
          if closure && funds.shift_id != closure.shift_id
            raise Conflict.new('The held cash was attested on a different shift.', reason: 'shift_mismatch')
          end

          funds
        end

        def self.settle_amount!(value, funds, closure, branch)
          value ||= funds&.received_net
          raise Conflict.new('Amount is required.', reason: 'amount_invalid') if value.nil?
          raise Conflict.new('The amount must be the held cash amount.', reason: 'amount_mismatch') if funds && value != funds.received_net

          if closure
            unexplained = closure.variance - closure.reconciled_amount
            unless closure.variance.positive?
              raise Conflict.new('Only an overage of a closed shift can be explained by late cash.',
                                 reason: 'no_overage')
            end
            if value > unexplained
              reason = unexplained.positive? ? 'exceeds_variance' : 'overage_explained'
              raise Conflict.new('The amount exceeds the unexplained overage of that shift.', reason: reason)
            end
          end
          currency = funds&.currency || closure&.currency || branch.store.default_currency
          raise Conflict.new('Amount must be a whole amount.', reason: 'amount_invalid') unless Record.countable_money?(value, currency)

          value
        end

        def self.post_inflow!(reconciliation, target, funds, staff)
          CashMovement.create!(
            store: reconciliation.store, branch: target.branch, register: target.register, shift: target,
            received_funds: funds, cash_reconciliation: reconciliation, actor: staff, kind: 'reconciliation_inflow',
            amount: reconciliation.amount, currency: reconciliation.currency, reason: reconciliation.reason,
            evidence_reference: reconciliation.custody_reference,
            source_type: reconciliation.class.name, source_id: reconciliation.id
          )
        end
      end
    end
  end
end
