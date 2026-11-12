# frozen_string_literal: true

module Spree
  module Pos
    module MealWallets
      # Money put on a meal wallet: one actual receipt (ReceivedFunds) with
      # no order on the collector's own open shift, the way a deposit or a
      # debt payment is taken. It is money held for the eater, not revenue;
      # the wallet's top-up line points at the receipt, and meals are later
      # paid from it oldest first. Cash enters the drawer; a transfer needs
      # its reference and receiving account. The answer carries the top-up
      # slip as a receipt-kind print document.
      module TopUp
        ACTION = 'meal_wallet.top_up'

        module_function

        def call(store:, staff:, key:, branch_id:, meal_account_id:, kind:, amount:, handed_amount: nil, reference: nil,
                 receiving_account: nil, confirm_duplicate: nil)
          kept = Record.money(amount.to_s)
          handed = handed_amount.present? ? Record.money(handed_amount.to_s) : kept
          payload = {
            'command' => ACTION, 'branch_id' => branch_id.to_s, 'meal_account_id' => meal_account_id.to_s, 'kind' => kind.to_s,
            'amount' => kept&.to_s('F'), 'handed_amount' => handed&.to_s('F'), 'reference' => reference.to_s.presence,
            'receiving_account' => receiving_account.to_s.presence
          }.merge(ReceiptReferenceGuard.payload_flag(confirm_duplicate))
          branch = MealAccounts::Guard.branch!(store, branch_id)
          account = MealAccounts::Guard.account!(store, meal_account_id)
          authorize = lambda do
            raise CanCan::AccessDenied if branch.disabled?
            raise CanCan::AccessDenied unless AccessPolicy.new(store: store, staff: staff).allows?(branch, Capabilities::PAYMENT)
          end
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: authorize) do
            ModulePolicy.require!(branch, MealAccounts::Guard::MODULE)
            currency = account.stored_value_account.currency
            funds, money = StoredValue.receive!(store: store, staff: staff, branch: branch, kind: kind, amount: kept, handed: handed,
                                                currency: currency, reference: reference, receiving_account: receiving_account,
                                                confirm_duplicate: confirm_duplicate) do
              account.lock!
              raise Conflict.new('This meal account is locked.', reason: 'meal_account_locked') unless account.active?
            end
            entry = StoredValue.top_up!(account: account.stored_value_account, funds: funds, actor: staff)
            account.bump!
            AuditEntry.record!(store: store, actor: staff, action: ACTION, subject: account,
                               metadata: { entry_id: entry.prefixed_id, funds_id: funds.prefixed_id, amount: kept.to_s('F'),
                                           kind: kind.to_s, change: money[:change].to_s('F'), branch_id: branch.prefixed_id })
            OutboxEntry.record!(store: store, event_type: 'meal_wallet.topped_up', aggregate: account,
                                payload: { 'meal_account_id' => account.prefixed_id, 'funds_id' => funds.prefixed_id })
            balance = account.stored_value_account.balance
            { 'account' => account.reload.to_pos(balance: balance), 'entry' => entry.to_pos, 'funds' => funds.to_pos,
              'document' => slip(account, branch, staff, kept, balance, money, kind.to_s) }
          end
        end

        def slip(account, branch, staff, amount, balance, cash, kind)
          text = Kitchen::TicketDocument
          lines = [
            { 'kind' => 'title', 'title' => 'NẠP VÍ SUẤT ĂN', 'number' => account.employee_code },
            text.text([account.customer_profile.name], bold: true, align: 'center'),
            { 'kind' => 'divider', 'style' => 'solid' },
            text.text(["Số tiền nạp: #{money(amount)}"], bold: true),
            text.text(["#{kind == 'cash' ? 'Tiền mặt' : 'Chuyển khoản'} · Khách đưa #{money(cash[:handed])} · Thối #{money(cash[:change])}"]),
            text.text(["Số dư: #{money(balance)}"], bold: true),
            text.text(["Thu ngân: #{StaffName.call(staff)}"]),
            text.text([PrintDocuments::Text.document_time(Workspace.database_now.iso8601, branch.timezone)], align: 'center')
          ]
          PrintDocuments.wrap('receipt', {
                                'documentType' => nil, 'page' => BottleKeeps::Label::PAGE, 'banners' => [], 'header' => lines,
                                'meta' => [{ 'label' => 'Mã', 'value' => account.employee_code }],
                                'lines' => { 'layout' => 'stacked', 'items' => [] },
                                'totals' => [], 'payments' => [], 'payQr' => nil, 'notes' => [], 'footer' => [], 'disclaimer' => nil
                              })
        end

        def money(value)
          PrintDocuments::Text.money(value)
        end
      end
    end
  end
end
