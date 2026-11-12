# frozen_string_literal: true

module Spree
  module Pos
    module StoredValueCards
      # Sells a prepaid card or puts more on one. Money only enters as an
      # actual receipt (ReceivedFunds with no order) on the collector's own
      # open shift: money held for the card holder, never revenue. A money
      # card holds that money; a minutes card holds `minutes` bought with it,
      # at the price per minute of this top-up. Selling a card (no
      # `card_id`) reads its QR code or tag (`card_token`); only the digest
      # is kept. The answer carries the slip as a receipt-kind document.
      module TopUp
        ACTION = 'stored_value.top_up'

        module_function

        def call(store:, staff:, key:, branch_id:, kind:, amount:, card_id: nil, card_kind: nil, card_token: nil, minutes: nil,
                 holder_name: nil, handed_amount: nil, reference: nil, receiving_account: nil, confirm_duplicate: nil)
          branch = Guard.branch!(store, branch_id)
          currency = store.default_currency
          kept = Guard.amount!(amount, currency)
          handed = handed_amount.present? ? Record.money(handed_amount.to_s) : kept
          digest = card_token.present? ? StoredValueAccount.card_digest(card_token.to_s.strip) : nil
          payload = {
            'command' => ACTION, 'branch_id' => branch.prefixed_id, 'card_id' => card_id.to_s.presence, 'card_kind' => card_kind.to_s.presence,
            'card_digest' => digest, 'minutes' => minutes.to_s.presence, 'holder_name' => holder_name.to_s.strip.presence,
            'kind' => kind.to_s, 'amount' => kept.to_s('F'), 'handed_amount' => handed&.to_s('F'),
            'reference' => reference.to_s.presence, 'receiving_account' => receiving_account.to_s.presence
          }.merge(ReceiptReferenceGuard.payload_flag(confirm_duplicate))
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: -> { Guard.collect!(store, staff, branch) }) do
            ModulePolicy.require!(branch, Guard::MODULE)
            card = card_id.present? ? Guard.card!(store, card_id) : new_card!(store, branch, card_kind, card_token, holder_name, currency)
            count = card.minutes? ? Guard.minutes!(minutes) : nil
            raise Conflict.new('Minutes go on minutes cards only.', reason: 'stored_value_minutes_invalid') if !card.minutes? && minutes.present?

            funds, money = StoredValue.receive!(store: store, staff: staff, branch: branch, kind: kind, amount: kept, handed: handed,
                                                currency: currency, reference: reference, receiving_account: receiving_account,
                                                confirm_duplicate: confirm_duplicate) do
              card.lock!
              raise Conflict.new('This card is closed.', reason: 'stored_value_closed') unless card.active?
            end
            entry = StoredValue.top_up!(account: card, funds: funds, actor: staff, minutes: count)
            card.bump!
            AuditEntry.record!(store: store, actor: staff, action: ACTION, subject: card,
                               metadata: { entry_id: entry.prefixed_id, funds_id: funds.prefixed_id, amount: kept.to_s('F'), minutes: count,
                                           kind: kind.to_s, change: money[:change].to_s('F'), branch_id: branch.prefixed_id,
                                           sold: card_id.blank? })
            OutboxEntry.record!(store: store, event_type: 'stored_value.topped_up', aggregate: card,
                                payload: { 'card_id' => card.prefixed_id, 'funds_id' => funds.prefixed_id })
            card.reload
            { 'card' => card.to_pos, 'entry' => entry.to_pos, 'funds' => funds.to_pos,
              'document' => Guard.slip(card, branch, staff, kept, count, money, kind.to_s) }
          end
        rescue ActiveRecord::RecordNotUnique => e
          raise unless e.message.include?('idx_pos_stored_value_accounts_card')

          raise Conflict.new('This card was already sold.', reason: 'stored_value_card_taken')
        end

        def new_card!(store, branch, card_kind, card_token, holder_name, currency)
          unless StoredValueAccount::CARD_KINDS.include?(card_kind.to_s)
            raise Conflict.new('Choose a money or a minutes card.', reason: 'stored_value_kind_invalid')
          end

          token = card_token.to_s.strip
          raise Conflict.new('Scan the card.', reason: 'stored_value_card_invalid') unless token.match?(StoredValueAccount::CARD_TOKEN)
          raise Conflict.new('This card was already sold.', reason: 'stored_value_card_taken') if StoredValueAccount.find_card(store, token)

          StoredValueAccount.create!(store: store, branch: branch, kind: card_kind.to_s, currency: currency, status: 'active',
                                     card_digest: StoredValueAccount.card_digest(token), card_hint: token.last(4).upcase,
                                     holder_name: Guard.text!(holder_name, 120, 'holder_name'))
        end
      end
    end
  end
end
