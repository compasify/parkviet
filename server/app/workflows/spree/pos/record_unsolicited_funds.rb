# frozen_string_literal: true

module Spree
  module Pos
    # Records an actual receipt that arrived without a prepared tender
    # (unsolicited/late bank transfer or late cash). The fact is posted to
    # unapplied liability; it never completes or hands over an order.
    #
    # Fresh cash goes into the caller's own open drawer. Cash that is not in
    # that drawer (attested after its shift closed, kept in the safe) is
    # recorded as `held`: it writes no drawer movement, so a closed shift's
    # snapshot and the current shift's expected cash stay untouched until the
    # custody is reconciled.
    class RecordUnsolicitedFunds
      def self.call(store:, staff:, key:, branch_id:, shift_id:, kind:, handed_amount:, reference: nil,
                    receiving_account: nil, custody: nil, custody_note: nil, workspace_id: nil)
        handed = Record.money(handed_amount.to_s)
        custody = custody.to_s.presence || 'drawer'
        payload = {
          'command' => 'funds.record_unsolicited', 'branch_id' => branch_id.to_s, 'shift_id' => shift_id.to_s,
          'kind' => kind.to_s, 'handed_amount' => handed&.to_s('F'), 'reference' => reference.to_s.presence,
          'receiving_account' => receiving_account.to_s.presence, 'custody' => custody,
          'custody_note' => custody_note.to_s.presence, 'workspace_id' => workspace_id.to_s.presence
        }
        authorize = lambda do
          branch = branch!(store, branch_id)
          policy = AccessPolicy.new(store: store, staff: staff)
          # Only fresh cash into the caller's own drawer is a cashier action;
          # transfers and held cash need a resolver to attest them.
          needed = kind.to_s == 'cash' && custody == 'drawer' ? Capabilities::PAYMENT : Capabilities::RESOLVE
          raise CanCan::AccessDenied unless policy.allows?(branch, needed) || policy.allows?(branch, Capabilities::RESOLVE)
        end
        CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: authorize) do
          branch = branch!(store, branch_id)
          shift = Shift.locate(Shift.for_store(store).where(branch_id: branch.id), shift_id)
          raise ActiveRecord::RecordNotFound if shift.nil?
          raise Conflict, 'Kind is invalid.' unless %w[cash bank_manual].include?(kind.to_s)
          raise Conflict, 'Custody is invalid.' unless %w[drawer held].include?(custody)

          workspace = nil
          if workspace_id.present?
            workspace = Workspace.locate(Workspace.for_store(store).where(branch_id: branch.id), workspace_id)
            raise ActiveRecord::RecordNotFound if workspace.nil?
          end
          currency = workspace&.order&.currency || store.default_currency
          validate_amount!(handed, currency)
          validate_source!(kind.to_s, custody, shift, staff, reference, receiving_account, custody_note)

          funds = ReceivedFunds.create!(
            store: store, workspace: workspace, branch: branch, register: shift.register, shift: shift,
            actor: staff, kind: kind.to_s, status: 'attention', handed_amount: handed, applied_amount: 0,
            change_amount: 0, received_net: handed, currency: currency, reference: reference.presence,
            receiving_account: receiving_account.presence, custody: kind.to_s == 'cash' ? custody : 'drawer',
            custody_note: custody_note.presence, received_at: Time.current
          )
          if kind.to_s == 'cash' && custody == 'drawer'
            CashMovement.create!(
              store: store, branch: branch, register: shift.register, shift: shift, received_funds: funds,
              actor: staff, kind: 'receipt', amount: handed, currency: funds.currency,
              source_type: funds.class.name, source_id: funds.id
            )
          end
          AuditEntry.record!(store: store, actor: staff, action: 'funds.record_unsolicited', subject: funds,
                             metadata: { amount: handed.to_s('F'), kind: kind.to_s, custody: funds.custody })
          OutboxEntry.record!(store: store, event_type: 'funds.unsolicited_recorded', aggregate: funds,
                              payload: { 'funds_id' => funds.prefixed_id })
          funds.to_pos
        end
      end

      def self.branch!(store, branch_id)
        branch = Branch.locate(Branch.for_store(store), branch_id)
        raise ActiveRecord::RecordNotFound if branch.nil?

        branch
      end

      def self.validate_amount!(handed, currency)
        raise Conflict, 'Amount is invalid.' if handed.nil? || handed <= 0
        raise Conflict, 'Amount must be a whole amount in the currency.' unless Record.countable_money?(handed, currency)
      end

      def self.validate_source!(kind, custody, shift, staff, reference, receiving_account, custody_note)
        if kind == 'bank_manual'
          raise Conflict, 'Bank transfer evidence is required.' if reference.blank? || receiving_account.blank?
        elsif custody == 'drawer'
          unless shift.status == 'open' && shift.owner_id == staff.id
            raise Conflict, 'Cash can only be added to your own open shift; record it as held cash instead.'
          end
        elsif custody_note.blank?
          raise Conflict, 'Held cash needs a custody note.'
        end
      end
    end
  end
end
