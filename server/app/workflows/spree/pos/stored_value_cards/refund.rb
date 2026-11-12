# frozen_string_literal: true

module Spree
  module Pos
    module StoredValueCards
      # Pays a prepaid card back: `amount` of a money card (all of it by
      # default), or everything left on a minutes card with its minutes. It
      # is reserved as LiabilityPayouts on the card's receipts, oldest
      # first, and someone other than the requester confirms the money left
      # (LiabilityPayouts::Confirm). Needs an approval of
      # `stored_value.refund` for that amount unless the requester approves.
      module Refund
        ACTION = Approval::STORED_VALUE_REFUND_ACTION

        module_function

        def call(store:, staff:, key:, branch_id:, card_id:, amount: nil, beneficiary_name: nil, beneficiary_reference: nil,
                 reason: nil, approval_id: nil)
          branch = Guard.branch!(store, branch_id)
          card = Guard.card!(store, card_id)
          payload = { 'command' => ACTION, 'branch_id' => branch.prefixed_id, 'card_id' => card.prefixed_id,
                      'amount' => amount.to_s.presence, 'beneficiary_name' => beneficiary_name.to_s.presence,
                      'beneficiary_reference' => beneficiary_reference.to_s.presence, 'reason' => reason.to_s.presence,
                      'approval_id' => approval_id.to_s.presence }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: -> { Guard.collect!(store, staff, branch) }) do
            ModulePolicy.require!(branch, Guard::MODULE)
            card.lock!
            raise Conflict.new('A minutes card is paid back whole.', reason: 'stored_value_amount_invalid') if card.minutes? && amount.present?

            value = amount.present? ? Guard.amount!(amount, card.currency) : card.balance
            raise Conflict.new('Nothing is left on this card.', reason: StoredValue::INSUFFICIENT) unless value.positive?

            approval = MealAccounts::Guard.approve!(card, staff, branch, ACTION, value, approval_id)
            entries = StoredValue.refund!(account: card, amount: value, actor: staff,
                                          beneficiary_name: beneficiary_name.presence || card.holder_name.presence || "Thẻ #{card.card_hint}",
                                          beneficiary_reference: beneficiary_reference.presence || card.card_hint,
                                          reason: Guard.text!(reason, 200, 'reason'))
            card.bump!
            payouts = entries.map(&:liability_payout)
            AuditEntry.record!(store: store, actor: staff, action: ACTION, subject: card,
                               metadata: { amount: value.to_s('F'), minutes: entries.sum { |entry| entry.minutes.to_i },
                                           approval_id: approval&.prefixed_id, payouts: payouts.map(&:prefixed_id) })
            payouts.each do |payout|
              OutboxEntry.record!(store: store, event_type: 'liability_payout.requested', aggregate: payout,
                                  payload: { 'payout_id' => payout.prefixed_id, 'funds_id' => payout.received_funds.prefixed_id })
            end
            { 'card' => card.reload.to_pos, 'payouts' => payouts.map(&:to_pos) }
          end
        end
      end
    end
  end
end
