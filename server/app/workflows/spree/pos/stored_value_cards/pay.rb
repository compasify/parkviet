# frozen_string_literal: true

module Spree
  module Pos
    module StoredValueCards
      # Part of paying an order from a prepaid money card: the money was
      # received when the card was topped up, so nothing new is received.
      # The card's receipts, oldest first, are allocated to the order (a
      # completed core Payment each) and the card gets matching spend
      # lines, so the money becomes revenue with the order. `amount`
      # defaults to what the order still owes, up to the card's balance.
      # Runs under the order's lease like every payment step.
      module Pay
        COMMAND = 'stored_value.pay'

        module_function

        def call(workspace:, staff:, revision:, lease_generation:, editor_id:, key:, card_token: nil, card_id: nil, amount: nil)
          card = card_id.present? ? Guard.card!(workspace.store, card_id) : Guard.by_token!(workspace.store, card_token)
          payload = { 'command' => COMMAND, 'revision' => revision, 'lease_generation' => lease_generation,
                      'editor_digest' => Workspace.editor_digest(editor_id), 'card_id' => card.prefixed_id, 'amount' => amount.to_s.presence }
          authorize = lambda do
            Tenders::Guard.authorize_editor!(workspace, staff)
            Tenders::Guard.authorize_collect!(workspace, staff)
          end
          CommandExecutor.call(store: workspace.store, actor: staff, key: key, payload: payload, workspace: workspace, authorize: authorize) do
            ModulePolicy.require!(workspace.branch, Guard::MODULE)
            Tenders::Guard.validate_editor!(workspace, staff, revision, lease_generation, editor_id)
            Tenders::Guard.collect_on_own_shift!(workspace, staff)
            Tenders::Guard.validate_open_shift!(workspace)
            SalesChannel.validate_uncommitted_order!(workspace)
            Tenders::Guard.tracked_guard!(workspace)
            if TenderAttempt.where(workspace: workspace, status: %w[prepared unknown]).exists?
              raise Conflict, 'A prepared tender already reserves this snapshot.'
            end
            raise Conflict.new('A minutes card pays play time when the clock stops.', reason: 'stored_value_kind_invalid') if card.minutes?

            card.lock!
            share = share!(workspace, card, amount)
            entries = StoredValue.spend!(account: card, workspace: workspace, amount: share, actor: staff)
            workspace.update!(revision: workspace.revision + 1)
            card.bump!
            AuditEntry.record!(store: workspace.store, actor: staff, action: COMMAND, subject: workspace,
                               metadata: { card_id: card.prefixed_id, amount: share.to_s('F'),
                                           allocations: entries.map { |entry| entry.funds_allocation.prefixed_id } })
            { 'workspace' => workspace.to_pos, 'card' => card.reload.to_pos }
          end
        end

        # What the card pays: what the order still owes, up to its balance.
        def share!(workspace, card, amount)
          order = workspace.order
          paid = FundsAllocation.where(workspace: workspace, status: 'active').sum(:amount)
          owed = order.total - paid
          share = amount.present? ? Guard.amount!(amount, order.currency) : [owed, card.balance].min
          raise Conflict.new('Nothing is left for the card to pay.', reason: 'stored_value_nothing_due') unless share.positive?
          raise Conflict, 'Amount exceeds the remaining balance.' if share > owed

          share
        end
      end
    end
  end
end
