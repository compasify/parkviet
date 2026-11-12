# frozen_string_literal: true

module Spree
  module Pos
    module MealWallets
      # Part of paying a meal order: the eater's wallet pays their part. The
      # money was received when the wallet was topped up, so nothing new is
      # received here: the top-up receipts, oldest first, are allocated to
      # the order (a completed core Payment each, the way a deposit or a
      # debt collection settles an order) and the wallet gets matching spend
      # lines. `amount` defaults to the eater's part still unpaid (SplitPlan).
      # Runs under the order's lease like every payment step. A balance that
      # falls below the account's threshold leaves a `meal_wallet.low_balance`
      # outbox event for a later parent or employee notice.
      module Pay
        COMMAND = 'meal_wallet.pay'
        LOW_BALANCE_EVENT = 'meal_wallet.low_balance'

        module_function

        def call(workspace:, staff:, revision:, lease_generation:, editor_id:, key:, amount: nil)
          payload = { 'command' => COMMAND, 'revision' => revision, 'lease_generation' => lease_generation,
                      'editor_digest' => Workspace.editor_digest(editor_id), 'amount' => amount.to_s.presence }
          authorize = lambda do
            Tenders::Guard.authorize_editor!(workspace, staff)
            Tenders::Guard.authorize_collect!(workspace, staff)
          end
          CommandExecutor.call(store: workspace.store, actor: staff, key: key, payload: payload, workspace: workspace, authorize: authorize) do
            Tenders::Guard.validate_editor!(workspace, staff, revision, lease_generation, editor_id)
            Tenders::Guard.collect_on_own_shift!(workspace, staff)
            Tenders::Guard.validate_open_shift!(workspace)
            SalesChannel.validate_uncommitted_order!(workspace)
            Tenders::Guard.tracked_guard!(workspace)
            if TenderAttempt.where(workspace: workspace, status: %w[prepared unknown]).exists?
              raise Conflict, 'A prepared tender already reserves this snapshot.'
            end

            account = MealAccounts::Guard.for_workspace(workspace)
            raise Conflict.new('No meal account is on this order.', reason: 'meal_account_missing') if account.nil?

            account.lock!
            raise Conflict.new('This meal account is locked.', reason: 'meal_account_locked') unless account.active?

            share = amount!(workspace, account, amount)
            wallet = account.stored_value_account
            entries = StoredValue.spend!(account: wallet, workspace: workspace, amount: share, actor: staff)
            workspace.update!(revision: workspace.revision + 1)
            account.bump!
            balance = wallet.balance
            low_balance!(account, balance)
            AuditEntry.record!(store: workspace.store, actor: staff, action: COMMAND, subject: workspace,
                               metadata: { meal_account_id: account.prefixed_id, amount: share.to_s('F'),
                                           allocations: entries.map { |entry| entry.funds_allocation.prefixed_id } })
            { 'workspace' => workspace.to_pos, 'meal' => MealAccounts::Status.call(account, workspace) }
          end
        end

        # What the wallet pays: the eater's unpaid part by default, never
        # more than the order still owes.
        def amount!(workspace, account, amount)
          order = workspace.order
          paid = FundsAllocation.where(workspace: workspace, status: 'active').sum(:amount)
          owed = order.total - paid
          part = BigDecimal(MealAccounts::SplitPlan.call(workspace, account: account)[:employee_amount]) - paid
          share = amount.present? ? MealAccounts::Guard.amount!(amount, order.currency) : [part, owed].min
          raise Conflict.new('Nothing is left for the wallet to pay.', reason: 'meal_wallet_nothing_due') unless share.positive?
          raise Conflict, 'Amount exceeds the remaining balance.' if share > owed

          share
        end

        def low_balance!(account, balance)
          threshold = account.low_balance_threshold
          return if threshold.nil? || balance >= threshold

          OutboxEntry.record!(store: account.store, event_type: LOW_BALANCE_EVENT, aggregate: account,
                              payload: { 'meal_account_id' => account.prefixed_id, 'customer_id' => account.customer_profile.prefixed_id,
                                         'balance' => balance.to_s('F'), 'threshold' => threshold.to_s('F') })
        end
      end
    end
  end
end
