# frozen_string_literal: true

module Spree
  module Pos
    # Records an actual receipt that arrived without a prepared tender
    # (unsolicited/late bank transfer or late cash). The fact is posted to
    # unapplied liability; it never completes or hands over an order.
    class RecordUnsolicitedFunds
      def self.call(store:, staff:, key:, branch_id:, shift_id:, kind:, handed_amount:, reference: nil, workspace_id: nil)
        handed = Record.money(handed_amount.to_s)
        payload = {
          'command' => 'funds.record_unsolicited', 'branch_id' => branch_id.to_s, 'shift_id' => shift_id.to_s,
          'kind' => kind.to_s, 'handed_amount' => handed&.to_s('F'), 'reference' => reference.to_s.presence,
          'workspace_id' => workspace_id.to_s.presence
        }
        authorize = lambda do
          branch = Branch.locate(Branch.for_store(store), branch_id)
          raise ActiveRecord::RecordNotFound if branch.nil?

          policy = AccessPolicy.new(store: store, staff: staff)
          raise CanCan::AccessDenied unless policy.allows?(branch, Capabilities::RESOLVE) || policy.allows?(branch, Capabilities::PAYMENT)
        end
        CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: authorize) do
          branch = Branch.locate(Branch.for_store(store), branch_id)
          raise ActiveRecord::RecordNotFound if branch.nil?

          shift = Shift.locate(Shift.for_store(store).where(branch_id: branch.id), shift_id)
          raise ActiveRecord::RecordNotFound if shift.nil?
          raise Conflict, 'Amount is invalid.' if handed.nil? || handed <= 0
          raise Conflict, 'Kind is invalid.' unless %w[cash bank_manual].include?(kind.to_s)

          workspace = nil
          if workspace_id.present?
            workspace = Workspace.locate(Workspace.for_store(store).where(branch_id: branch.id), workspace_id)
            raise ActiveRecord::RecordNotFound if workspace.nil?
          end

          funds = ReceivedFunds.create!(
            store: store, workspace: workspace, branch: branch, register: shift.register, shift: shift,
            actor: staff, kind: kind.to_s, status: 'attention', handed_amount: handed, applied_amount: 0,
            change_amount: 0, received_net: handed, currency: store.default_currency,
            reference: reference.presence, received_at: Time.current
          )
          if kind.to_s == 'cash'
            CashMovement.create!(
              store: store, branch: branch, register: shift.register, shift: shift, received_funds: funds,
              actor: staff, kind: 'receipt', amount: handed, currency: funds.currency,
              source_type: funds.class.name, source_id: funds.id
            )
          end
          AuditEntry.record!(store: store, actor: staff, action: 'funds.record_unsolicited', subject: funds,
                             metadata: { amount: handed.to_s('F'), kind: kind.to_s })
          OutboxEntry.record!(store: store, event_type: 'funds.unsolicited_recorded', aggregate: funds,
                              payload: { 'funds_id' => funds.prefixed_id })
          funds.to_pos
        end
      end
    end
  end
end
