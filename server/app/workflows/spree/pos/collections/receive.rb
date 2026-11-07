# frozen_string_literal: true

module Spree
  module Pos
    module Collections
      # Records one actual debt payment as one parent ReceivedFunds on the
      # collector's own open shift (cash also enters that drawer), then
      # allocates it to one or more debtor orders. `amount` is the money kept:
      # for cash, handed minus change; for a transfer, what actually arrived.
      # Whatever is not allocated stays available on the parent for a later
      # allocation or a liability payout; it is never a negative debt.
      class Receive
        def self.call(store:, staff:, key:, branch_id:, credit_account_id:, kind:, amount:, allocations:,
                      handed_amount: nil, reference: nil, receiving_account: nil, note: nil, confirm_duplicate: nil)
          kept = Record.money(amount.to_s)
          handed = handed_amount.present? ? Record.money(handed_amount.to_s) : kept
          rows = Allocate.normalize(allocations)
          payload = {
            'command' => 'collection.receive', 'branch_id' => branch_id.to_s, 'credit_account_id' => credit_account_id.to_s,
            'kind' => kind.to_s, 'amount' => kept&.to_s('F'), 'handed_amount' => handed&.to_s('F'),
            'reference' => reference.to_s.presence, 'receiving_account' => receiving_account.to_s.presence,
            'note' => note.to_s.presence, 'allocations' => rows
          }.merge(ReceiptReferenceGuard.payload_flag(confirm_duplicate))
          authorize = lambda do
            raise CanCan::AccessDenied unless AccessPolicy.new(store: store, staff: staff).allows?(branch!(store, branch_id), Capabilities::PAYMENT)
          end
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: authorize) do
            branch = branch!(store, branch_id)
            raise CanCan::AccessDenied if branch.disabled?

            account = CreditAccount.locate(CreditAccount.for_store(store), credit_account_id)
            raise ActiveRecord::RecordNotFound if account.nil?

            money = validate!(kind.to_s, kept, handed, account.currency, reference, receiving_account)
            shift = Shift.for_store(store).open_now.find_by(branch_id: branch.id, owner_id: staff.id)
            raise Conflict.new('Open your own shift before collecting debt.', reason: 'shift_required') if shift.nil?

            duplicate_ids = if kind.to_s == 'bank_manual'
                              ReceiptReferenceGuard.check!(store: store, staff: staff, branch: branch, reference: reference,
                                                           receiving_account: receiving_account,
                                                           confirm_duplicate: confirm_duplicate)
                            else
                              []
                            end
            account.lock!
            funds = ReceivedFunds.create!(
              store: store, branch: branch, register: shift.register, shift: shift, actor: staff, kind: kind.to_s,
              status: 'received', handed_amount: money[:handed], applied_amount: kept, change_amount: money[:change],
              received_net: kept, currency: account.currency, reference: reference.presence,
              receiving_account: receiving_account.presence, custody: 'drawer', received_at: Time.current
            )
            if kind.to_s == 'cash'
              CashMovement.create!(
                store: store, branch: branch, register: shift.register, shift: shift, received_funds: funds, actor: staff,
                kind: 'receipt', amount: kept, currency: funds.currency, source_type: funds.class.name, source_id: funds.id
              )
            end
            collection = Collection.create!(store: store, credit_account: account, received_funds: funds, branch: branch,
                                            actor: staff, note: note.to_s.presence)
            ReceiptReferenceGuard.audit!(store: store, staff: staff, funds: funds, duplicate_ids: duplicate_ids)
            Allocate.apply!(collection: collection, rows: rows, staff: staff) if rows.any?
            AuditEntry.record!(store: store, actor: staff, action: 'collection.receive', subject: collection,
                               metadata: { funds_id: funds.prefixed_id, amount: kept.to_s('F'), kind: kind.to_s,
                                           change: money[:change].to_s('F'), allocations: rows })
            OutboxEntry.record!(store: store, event_type: 'collection.received', aggregate: collection,
                                payload: { 'collection_id' => collection.prefixed_id, 'funds_id' => funds.prefixed_id })
            collection.reload.to_pos
          end
        end

        def self.branch!(store, branch_id)
          branch = Branch.locate(Branch.for_store(store), branch_id)
          raise ActiveRecord::RecordNotFound if branch.nil?

          branch
        end

        def self.validate!(kind, kept, handed, currency, reference, receiving_account)
          raise Conflict, 'Kind is invalid.' unless %w[cash bank_manual].include?(kind)
          raise Conflict, 'Amount is invalid.' if kept.nil? || kept <= 0 || handed.nil?
          unless Record.countable_money?(kept, currency) && Record.countable_money?(handed, currency)
            raise Conflict, 'Amounts must be whole amounts in the currency.'
          end

          if kind == 'cash'
            raise Conflict, 'Handed cash is less than the amount collected.' if handed < kept

            { handed: handed, change: handed - kept }
          else
            raise Conflict, 'Bank transfer evidence is required.' if reference.blank? || receiving_account.blank?
            raise Conflict, 'A transfer has no change; record the amount that arrived.' if handed != kept

            { handed: kept, change: BigDecimal('0') }
          end
        end
      end
    end
  end
end
