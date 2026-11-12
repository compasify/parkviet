# frozen_string_literal: true

module Spree
  module Pos
    module Timed
      # A minutes card on a clock. `call` puts the card read from its QR code
      # or tag on a running clock (or at Start); nothing is taken yet. When
      # the clock stops, `charge!` takes the card's minutes for the play time
      # after any package: each of its lots pays its own price per minute to
      # the order (a completed core Payment and a FundsAllocation, the way a
      # deposit settles an order), so the card's money becomes revenue only
      # for minutes played. Minutes the card does not have stay on the bill.
      module ApplyMinutesCard
        COMMAND = 'timed.minutes_card'

        module_function

        # @return [Hash] 'workspace' and 'timed_session'
        def call(session:, staff:, key:, card_token:)
          workspace = session.workspace
          card = Guard.minutes_card!(workspace.store, card_token)
          payload = { 'command' => COMMAND, 'timed_session_id' => session.prefixed_id, 'card_id' => card.prefixed_id }
          CommandExecutor.call(store: workspace.store, actor: staff, key: key, payload: payload, workspace: workspace,
                               authorize: -> { Guard.operate!(workspace, staff) }) do
            ModulePolicy.require!(workspace.branch, Guard::MODULE)
            session.lock!
            Guard.running!(session)
            Guard.editable!(workspace)
            raise Conflict.new('The card is in another currency.', reason: 'stored_value_kind_invalid') if card.currency != session.currency

            before = session.stored_value_account&.prefixed_id
            session.update!(stored_value_account: card, quote_version: session.quote_version + 1)
            workspace.update!(revision: workspace.revision + 1)
            AuditEntry.record!(store: workspace.store, actor: staff, action: COMMAND, subject: workspace,
                               metadata: { timed_session_id: session.prefixed_id, card_id: card.prefixed_id, previous_card_id: before })
            Guard.announce!(session, workspace)
            { 'workspace' => workspace.to_pos, 'timed_session' => Sessions.to_pos(session.reload) }
          end
        end

        # The card's lots, locked, for the stop's quote; nil without a usable card.
        def lots!(session)
          card = session.stored_value_account
          return nil if card.nil?

          card.lock!
          card.active? ? StoredValue.lots(card, lock: true) : nil
        end

        # Takes the minutes the stop's quote gave the card. The money taken
        # is exactly the card line's amount on the bill.
        def charge!(session, quote, staff)
          minutes = quote.card_minutes
          return [] unless session.stored_value_account && minutes.positive?

          entries = StoredValue.spend_minutes!(account: session.stored_value_account, workspace: session.workspace, minutes: minutes,
                                               actor: staff)
          card_line = quote.lines.find { |line| line.kind == 'card' }
          taken = entries.sum(BigDecimal('0')) { |entry| -entry.amount }
          if entries.sum { |entry| -entry.minutes.to_i } != minutes || card_line.nil? || taken != card_line.amount
            raise Conflict.new('The card changed while the clock stopped.', reason: 'stored_value_changed')
          end

          session.stored_value_account.bump!
          AuditEntry.record!(store: session.store, actor: staff, action: 'stored_value.spend_minutes', subject: session.stored_value_account,
                             metadata: { timed_session_id: session.prefixed_id, workspace_id: session.workspace.prefixed_id,
                                         minutes: minutes, amount: taken.to_s('F'),
                                         allocations: entries.filter_map { |entry| entry.funds_allocation&.prefixed_id } })
          entries
        end

        # Whether the card already paid the session (its bill can no longer change).
        def charged?(session)
          session.stored_value_account_id.present? &&
            StoredValueEntry.where(stored_value_account_id: session.stored_value_account_id, workspace_id: session.workspace_id).
              where('minutes < 0').exists?
        end
      end
    end
  end
end
