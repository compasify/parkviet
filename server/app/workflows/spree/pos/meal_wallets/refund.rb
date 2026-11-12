# frozen_string_literal: true

module Spree
  module Pos
    module MealWallets
      # Pays a wallet back, for example when an employee leaves: `amount`
      # (the whole balance by default) is reserved as LiabilityPayouts on the
      # top-up receipts, oldest first, and someone other than the requester
      # confirms the money left (LiabilityPayouts::Confirm). Needs an approval
      # of `meal_wallet.refund` for that amount unless the requester approves.
      module Refund
        ACTION = Approval::MEAL_REFUND_ACTION

        module_function

        def call(store:, staff:, key:, branch_id:, meal_account_id:, amount: nil, beneficiary_name: nil,
                 beneficiary_reference: nil, reason: nil, approval_id: nil)
          payload = { 'command' => ACTION, 'branch_id' => branch_id.to_s, 'meal_account_id' => meal_account_id.to_s,
                      'amount' => amount.to_s.presence, 'beneficiary_name' => beneficiary_name.to_s.presence,
                      'beneficiary_reference' => beneficiary_reference.to_s.presence, 'reason' => reason.to_s.presence,
                      'approval_id' => approval_id.to_s.presence }
          branch = MealAccounts::Guard.branch!(store, branch_id)
          account = MealAccounts::Guard.account!(store, meal_account_id)
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload,
                               authorize: -> { MealAccounts::Guard.request!(store, staff, branch) }) do
            ModulePolicy.require!(branch, MealAccounts::Guard::MODULE)
            account.lock!
            wallet = account.stored_value_account
            value = amount.present? ? MealAccounts::Guard.amount!(amount, wallet.currency) : wallet.balance
            raise Conflict.new('Nothing is left on this wallet.', reason: StoredValue::INSUFFICIENT) unless value.positive?

            approval = MealAccounts::Guard.approve!(account, staff, branch, ACTION, value, approval_id)
            entries = StoredValue.refund!(account: wallet, amount: value, actor: staff,
                                          beneficiary_name: beneficiary_name.presence || account.customer_profile.name,
                                          beneficiary_reference: beneficiary_reference.presence || account.employee_code,
                                          reason: MealAccounts::Guard.text!(reason, 200, 'reason'))
            account.bump!
            payouts = entries.map(&:liability_payout)
            AuditEntry.record!(store: store, actor: staff, action: ACTION, subject: account,
                               metadata: { amount: value.to_s('F'), approval_id: approval&.prefixed_id,
                                           payouts: payouts.map(&:prefixed_id) })
            payouts.each do |payout|
              OutboxEntry.record!(store: store, event_type: 'liability_payout.requested', aggregate: payout,
                                  payload: { 'payout_id' => payout.prefixed_id, 'funds_id' => payout.received_funds.prefixed_id })
            end
            { 'account' => account.reload.to_pos, 'payouts' => payouts.map(&:to_pos) }
          end
        end
      end
    end
  end
end
