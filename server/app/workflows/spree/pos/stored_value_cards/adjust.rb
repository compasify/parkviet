# frozen_string_literal: true

module Spree
  module Pos
    module StoredValueCards
      # Corrects a prepaid card by hand, with a note, for a mistake no other
      # command undoes: a money card by a signed `amount` (never outside the
      # money its receipts still hold), a minutes card by signed `minutes`
      # (no money moves; see StoredValue.adjust_minutes!). Needs an approval
      # of `stored_value.adjust` (for the amount, unsigned; no amount for
      # minutes) unless the requester approves.
      module Adjust
        ACTION = Approval::STORED_VALUE_ADJUST_ACTION

        module_function

        def call(store:, staff:, key:, branch_id:, card_id:, note:, amount: nil, minutes: nil, approval_id: nil)
          branch = Guard.branch!(store, branch_id)
          card = Guard.card!(store, card_id)
          payload = { 'command' => ACTION, 'branch_id' => branch.prefixed_id, 'card_id' => card.prefixed_id, 'amount' => amount.to_s.presence,
                      'minutes' => minutes.to_s.presence, 'note' => note.to_s.presence, 'approval_id' => approval_id.to_s.presence }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: -> { Guard.collect!(store, staff, branch) }) do
            ModulePolicy.require!(branch, Guard::MODULE)
            text = Guard.text!(note, 200, 'note')
            raise Conflict.new('A correction needs a note.', reason: 'stored_value_invalid', details: { field: 'note' }) if text.nil?

            card.lock!
            if card.minutes?
              count = Guard.minutes!(minutes, allow_negative: true)
              approval = MealAccounts::Guard.approve!(card, staff, branch, ACTION, nil, approval_id)
              entries = StoredValue.adjust_minutes!(account: card, minutes: count, actor: staff, note: text)
            else
              value = Guard.amount!(amount, card.currency, allow_negative: true)
              approval = MealAccounts::Guard.approve!(card, staff, branch, ACTION, value.abs, approval_id)
              entries = [StoredValue.adjust!(account: card, amount: value, actor: staff, note: text)]
            end
            card.bump!
            AuditEntry.record!(store: store, actor: staff, action: ACTION, subject: card,
                               metadata: { entries: entries.map(&:prefixed_id), amount: value&.to_s('F'), minutes: count,
                                           approval_id: approval&.prefixed_id })
            { 'card' => card.reload.to_pos, 'entries' => entries.map(&:to_pos) }
          end
        end
      end
    end
  end
end
