# frozen_string_literal: true

module Spree
  module Pos
    module MealWallets
      # Corrects a wallet balance by a signed `amount` with a note, for a
      # mistake no other command undoes. It moves no money, so the balance
      # stays between zero and what the top-up receipts still hold. Needs an
      # approval of `meal_wallet.adjust` for the amount (unsigned) unless the
      # requester approves.
      module Adjust
        ACTION = Approval::MEAL_ADJUST_ACTION

        module_function

        def call(store:, staff:, key:, branch_id:, meal_account_id:, amount:, note:, approval_id: nil)
          payload = { 'command' => ACTION, 'branch_id' => branch_id.to_s, 'meal_account_id' => meal_account_id.to_s,
                      'amount' => amount.to_s, 'note' => note.to_s.presence, 'approval_id' => approval_id.to_s.presence }
          branch = MealAccounts::Guard.branch!(store, branch_id)
          account = MealAccounts::Guard.account!(store, meal_account_id)
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload,
                               authorize: -> { MealAccounts::Guard.request!(store, staff, branch) }) do
            ModulePolicy.require!(branch, MealAccounts::Guard::MODULE)
            wallet = account.stored_value_account
            value = MealAccounts::Guard.amount!(amount, wallet.currency, allow_negative: true)
            text = MealAccounts::Guard.text!(note, 200, 'note')
            raise Conflict.new('A correction needs a note.', reason: 'meal_account_invalid', details: { field: 'note' }) if text.nil?

            account.lock!
            approval = MealAccounts::Guard.approve!(account, staff, branch, ACTION, value.abs, approval_id)
            entry = StoredValue.adjust!(account: wallet, amount: value, actor: staff, note: text)
            account.bump!
            AuditEntry.record!(store: store, actor: staff, action: ACTION, subject: account,
                               metadata: { entry_id: entry.prefixed_id, amount: value.to_s('F'), approval_id: approval&.prefixed_id })
            { 'account' => account.reload.to_pos, 'entry' => entry.to_pos }
          end
        end
      end
    end
  end
end
