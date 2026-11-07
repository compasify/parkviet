# frozen_string_literal: true

module Spree
  module Pos
    module Tenders
      # Attests one actual receipt for a prepared attempt. Cash keeps
      # handed/applied/change separate; the core Payment is only the applied
      # part. A bank transfer larger than the attempt is still one receipt: the
      # excess stays unapplied on the parent ReceivedFunds as liability and
      # never becomes a Payment.
      class Confirm
        def self.call(workspace:, staff:, revision:, lease_generation:, editor_id:, key:, attempt_id:,
                      handed_amount: nil, received_amount: nil, evidence_kind: nil, reference: nil,
                      receiving_account: nil, terminal_ref: nil)
          handed = Record.money(handed_amount.to_s) if handed_amount.present?
          received = Record.money(received_amount.to_s) if received_amount.present?
          payload = {
            'command' => 'tender.confirm', 'revision' => revision, 'lease_generation' => lease_generation,
            'editor_digest' => Workspace.editor_digest(editor_id), 'attempt_id' => attempt_id.to_s,
            'handed_amount' => handed&.to_s('F'), 'received_amount' => received&.to_s('F'), 'evidence_kind' => evidence_kind.to_s.presence,
            'reference' => reference.to_s.presence, 'receiving_account' => receiving_account.to_s.presence,
            'terminal_ref' => terminal_ref.to_s.presence
          }
          authorize = lambda do
            Guard.authorize_editor!(workspace, staff)
            Guard.authorize_collect!(workspace, staff)
          end
          CommandExecutor.call(store: workspace.store, actor: staff, key: key, payload: payload, workspace: workspace, authorize: authorize) do
            Guard.validate_editor!(workspace, staff, revision, lease_generation, editor_id)
            Guard.validate_open_shift!(workspace)
            Guard.tracked_guard!(workspace)
            attempt = TenderAttempt.locate(TenderAttempt.where(workspace_id: workspace.id), attempt_id)
            raise ActiveRecord::RecordNotFound if attempt.nil?
            raise Conflict, 'Tender attempt is not prepared.' unless attempt.status == 'prepared'
            raise Conflict, 'Tender snapshot is stale; cancel and prepare again.' if attempt.order_total_snapshot != workspace.order.total

            order = workspace.order
            raise Conflict, 'Order total changed after tender was prepared.' if order.total != attempt.order_total_snapshot

            kind = attempt.pos_payment_method.kind
            raise Conflict, 'Amount is invalid.' if (handed_amount.present? && handed.nil?) || (received_amount.present? && received.nil?)

            money = money_for(kind, attempt, handed, received)
            raise Conflict, 'Amounts must be whole amounts in the order currency.' unless countable?(money, order.currency)

            evidence = evidence_for(kind, evidence_kind, reference, receiving_account, terminal_ref)

            attempt.lock!
            raise Conflict, 'Tender attempt is not prepared.' unless attempt.status == 'prepared'

            funds = nil
            allocation = nil
            workspace.order.with_lock do
              funds = ReceivedFunds.create!(
                store: workspace.store, workspace: workspace, branch: workspace.branch, register: workspace.register,
                shift: workspace.shift, tender_attempt: attempt, actor: staff, kind: kind, status: 'received',
                handed_amount: money[:handed], applied_amount: money[:applied], change_amount: money[:change],
                received_net: money[:net], currency: order.currency, reference: reference.presence,
                receiving_account: receiving_account.presence, received_at: Time.current
              )
              ReceiptEvidence.create!(
                store: workspace.store, tender_attempt: attempt, actor: staff, kind: evidence,
                reference: reference.presence, receiving_account: receiving_account.presence,
                terminal_ref: terminal_ref.presence, attested_at: Time.current
              )
              if money[:applied].positive?
                core_method = PaymentMethodResolver.new(store: workspace.store).core_for(attempt.pos_payment_method)
                raise Conflict, 'Payment method is not available for this store.' if core_method.nil?

                payment = order.payments.create!(payment_method: core_method, amount: money[:applied])
                payment.complete!
                allocation = FundsAllocation.create!(
                  store: workspace.store, received_funds: funds, workspace: workspace, order: order,
                  payment: payment, status: 'active', amount: money[:applied], currency: order.currency
                )
              end
              if kind == 'cash' && money[:net].positive?
                CashMovement.create!(
                  store: workspace.store, branch: workspace.branch, register: workspace.register, shift: workspace.shift,
                  received_funds: funds, actor: staff, kind: 'receipt', amount: money[:net], currency: order.currency,
                  source_type: funds.class.name, source_id: funds.id
                )
              end
            end
            attempt.update!(status: 'confirmed', confirmed_at: Time.current)
            workspace.update!(revision: workspace.revision + 1)
            AuditEntry.record!(store: workspace.store, actor: staff, action: 'tender.confirm', subject: workspace,
                               metadata: { attempt_id: attempt.prefixed_id, funds_id: funds.prefixed_id,
                                           allocation_id: allocation&.prefixed_id, net: money[:net].to_s('F'),
                                           change: money[:change].to_s('F'),
                                           unapplied: (money[:net] - money[:applied]).to_s('F') })
            OutboxEntry.record!(store: workspace.store, event_type: 'tender.confirmed', aggregate: funds,
                                payload: { 'funds_id' => funds.prefixed_id, 'workspace_id' => workspace.prefixed_id })
            workspace.to_pos
          end
        end

        def self.countable?(money, currency)
          money.values.all? { |value| Record.countable_money?(value, currency) }
        end

        def self.money_for(kind, attempt, handed, received)
          case kind
          when 'cash'
            raise Conflict, 'Handed amount is required for cash.' if handed.nil?
            # A short count is not a partial receipt: the cashier cancels and
            # prepares the smaller amount actually handed over.
            raise Conflict, 'Handed cash is less than the tender amount.' if handed < attempt.amount

            { handed: handed, applied: attempt.amount, change: handed - attempt.amount, net: attempt.amount }
          when 'bank_manual'
            actual = received || attempt.amount
            raise Conflict, 'Received transfer is less than the tender amount.' if actual < attempt.amount

            { handed: actual, applied: attempt.amount, change: BigDecimal('0'), net: actual }
          else
            raise Conflict, 'Unsupported tender kind.'
          end
        end

        def self.evidence_for(kind, evidence_kind, reference, receiving_account, _terminal_ref)
          case kind
          when 'cash'
            raise Conflict, 'Cash count evidence is required.' unless evidence_kind.to_s == 'cash_count'

            'cash_count'
          when 'bank_manual'
            unless evidence_kind.to_s == 'bank_manual' && reference.present? && receiving_account.present?
              raise Conflict,
                    'Bank transfer evidence is required.'
            end

            'bank_manual'
          else
            raise Conflict, 'Unsupported tender kind.'
          end
        end
      end
    end
  end
end
