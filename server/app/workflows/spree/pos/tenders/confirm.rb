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
                      receiving_account: nil, terminal_ref: nil, confirm_duplicate: nil, tip_amount: nil)
          handed = Record.money(handed_amount.to_s) if handed_amount.present?
          tip = tip_amount.present? ? Record.money(tip_amount.to_s) : BigDecimal('0')
          received = Record.money(received_amount.to_s) if received_amount.present?
          payload = {
            'command' => 'tender.confirm', 'revision' => revision, 'lease_generation' => lease_generation,
            'editor_digest' => Workspace.editor_digest(editor_id), 'attempt_id' => attempt_id.to_s,
            'handed_amount' => handed&.to_s('F'), 'received_amount' => received&.to_s('F'), 'evidence_kind' => evidence_kind.to_s.presence,
            'reference' => reference.to_s.presence, 'receiving_account' => receiving_account.to_s.presence,
            'terminal_ref' => terminal_ref.to_s.presence
          }.merge(tip_amount.present? ? { 'tip_amount' => tip&.to_s('F') || tip_amount.to_s } : {}).merge(ReceiptReferenceGuard.payload_flag(confirm_duplicate))
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

            raise Conflict.new('The tip is invalid.', reason: 'tip_invalid') if tip.nil? || tip.negative?
            if tip.positive? && !Fnb::Tips::KINDS.include?(kind)
              raise Conflict.new('A tip is taken in cash or by bank transfer.', reason: 'tip_invalid')
            end

            money = money_for(kind, attempt, handed, received, tip)
            raise Conflict, 'Amounts must be whole amounts in the order currency.' unless countable?(money, order.currency)

            evidence = evidence_for(kind, evidence_kind, reference, receiving_account, terminal_ref)
            # A kiosk never attests money: only the bank's webhook is its evidence.
            if (evidence != 'vietqr_webhook' || tip.positive?) && Kiosks::Policy.service_account?(staff)
              raise Conflict.new('A kiosk confirms only a transfer the bank reported.', reason: 'kiosk_evidence_forbidden')
            end
            duplicate_ids = bank_duplicates!(kind, workspace, staff, reference: reference, receiving_account: receiving_account,
                                                                     confirm_duplicate: confirm_duplicate, evidence: evidence)

            attempt.lock!
            raise Conflict, 'Tender attempt is not prepared.' unless attempt.status == 'prepared'

            # VietQR settles its own core payment (the bank webhook or the
            # cashier's attestation completes it) and the receipt records the
            # bank's reference, so the money reads as an ordinary transfer.
            settled = nil
            if kind == 'vietqr'
              settled = VietqrTender.confirm!(attempt: attempt, evidence_kind: evidence, reference: reference,
                                              receiving_account: receiving_account)
              reference = settled[:reference]
              receiving_account = settled[:receiving_account]
            end

            funds = nil
            allocation = nil
            workspace.order.with_lock do
              funds = ReceivedFunds.create!(
                store: workspace.store, workspace: workspace, branch: workspace.branch, register: workspace.register,
                shift: workspace.shift, tender_attempt: attempt, actor: staff, kind: funds_kind(kind), status: 'received',
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
                payment = settled&.dig(:payment)
                if payment.nil?
                  core_method = PaymentMethodResolver.new(store: workspace.store).core_for(attempt.pos_payment_method)
                  raise Conflict.new('Payment method is not available for this store.', reason: 'payment_method_unavailable') if core_method.nil?

                  payment = order.payments.create!(payment_method: core_method, amount: money[:applied])
                  payment.complete!
                end
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
            ReceiptReferenceGuard.audit!(store: workspace.store, staff: staff, funds: funds, duplicate_ids: duplicate_ids)
            Fnb::Tips.record!(workspace, funds, tip) if tip.positive?
            attempt.update!(status: 'confirmed', confirmed_at: Time.current)
            workspace.update!(revision: workspace.revision + 1)
            AuditEntry.record!(store: workspace.store, actor: staff, action: 'tender.confirm', subject: workspace,
                               metadata: { attempt_id: attempt.prefixed_id, funds_id: funds.prefixed_id,
                                           allocation_id: allocation&.prefixed_id, net: money[:net].to_s('F'),
                                           change: money[:change].to_s('F'),
                                           unapplied: (money[:net] - money[:applied]).to_s('F'),
                                           tip: tip.positive? ? tip.to_s('F') : nil }.compact)
            OutboxEntry.record!(store: workspace.store, event_type: 'tender.confirmed', aggregate: funds,
                                payload: { 'funds_id' => funds.prefixed_id, 'workspace_id' => workspace.prefixed_id })
            workspace.to_pos
          end
        end

        # Received funds of a VietQR tender are a bank transfer like any other.
        def self.funds_kind(kind)
          kind == 'vietqr' ? 'bank_manual' : kind
        end

        # Only a reference typed by the cashier can repeat an earlier one; a
        # webhook transfer is deduplicated by spree_vietqr itself.
        def self.bank_duplicates!(kind, workspace, staff, reference:, receiving_account:, confirm_duplicate:, evidence: nil)
          return [] unless kind == 'bank_manual' || evidence == 'vietqr_manual'

          ReceiptReferenceGuard.check!(store: workspace.store, staff: staff, branch: workspace.branch, reference: reference,
                                       receiving_account: receiving_account, confirm_duplicate: confirm_duplicate)
        end

        def self.countable?(money, currency)
          money.values.all? { |value| Record.countable_money?(value, currency) }
        end

        # A tip rides on the receipt but never on the order: it is received
        # (net) and left unapplied, so the order's total and invoice ignore it.
        def self.money_for(kind, attempt, handed, received, tip = BigDecimal('0'))
          case kind
          when 'cash'
            raise Conflict, 'Handed amount is required for cash.' if handed.nil?
            # A short count is not a partial receipt: the cashier cancels and
            # prepares the smaller amount actually handed over.
            raise Conflict, 'Handed cash is less than the tender amount.' if handed < attempt.amount + tip

            { handed: handed, applied: attempt.amount, change: handed - attempt.amount - tip, net: attempt.amount + tip }
          when 'bank_manual'
            actual = received || (attempt.amount + tip)
            raise Conflict, 'Received transfer is less than the tender amount.' if actual < attempt.amount + tip

            { handed: actual, applied: attempt.amount, change: BigDecimal('0'), net: actual }
          when 'vietqr', PosPaymentMethod::PLATFORM_KIND
            # The QR asks for the exact amount; any excess the bank reports is
            # handled by spree_vietqr (store credit), never as POS liability.
            # A platform owes exactly the order's amount.
            { handed: attempt.amount, applied: attempt.amount, change: BigDecimal('0'), net: attempt.amount }
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
          when 'vietqr'
            unless VietqrTender::EVIDENCE_KINDS.include?(evidence_kind.to_s)
              raise Conflict.new('VietQR evidence is required.', reason: 'vietqr_evidence_required')
            end

            evidence_kind.to_s
          when PosPaymentMethod::PLATFORM_KIND
            # The platform's order is the evidence: what it owes for.
            unless evidence_kind.to_s == 'platform_order' && reference.present?
              raise Conflict, 'Platform order evidence is required.'
            end

            'platform_order'
          else
            raise Conflict, 'Unsupported tender kind.'
          end
        end
      end
    end
  end
end
