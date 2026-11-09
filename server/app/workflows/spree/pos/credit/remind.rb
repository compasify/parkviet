# frozen_string_literal: true

module Spree
  module Pos
    module Credit
      # Notes that a debt reminder ("nhắc nợ") was just sent to the customer
      # of a credit account (shared to Zalo or copied): stamps the account's
      # `last_reminded_at` and audits who sent it from which branch. Nothing
      # about the debt changes. One reminder per key; a retry of the same key
      # replays the first result.
      #
      # Staff who see the customer's contact unmasked at the branch (collect,
      # approve or manage credit there) may remind, for an account that owes
      # something at that branch.
      class Remind
        SENDERS = [Capabilities::PAYMENT, Capabilities::APPROVE, Capabilities::CREDIT_MANAGE].freeze
        CHANNELS = %w[share copy].freeze

        def self.call(store:, staff:, key:, branch_id:, account_id:, via: nil)
          channel = via.to_s.presence || 'share'
          raise Conflict.new('Reminder channel is invalid.', reason: 'reminder_channel_invalid') unless CHANNELS.include?(channel)

          branch = Branch.locate(Branch.for_store(store), branch_id)
          account = CreditAccount.locate(CreditAccount.for_store(store), account_id)
          raise ActiveRecord::RecordNotFound if branch.nil? || account.nil?

          payload = { 'command' => 'credit.remind', 'branch_id' => branch.prefixed_id, 'credit_account_id' => account.prefixed_id,
                      'via' => channel }
          authorize = lambda do
            policy = AccessPolicy.new(store: store, staff: staff)
            raise CanCan::AccessDenied if branch.disabled? || SENDERS.none? { |capability| policy.allows?(branch, capability) }
          end
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: authorize) do
            owed = ReceivableEntry.balance_sum(ReceivableEntry.where(credit_account_id: account.id, branch_id: branch.id))
            raise Conflict.new('The customer owes nothing at this branch.', reason: 'reminder_nothing_owed') unless owed.positive?

            account.lock!
            # Not a change of terms: `updated_at`/`updated_by` stay as they were.
            account.update_columns(last_reminded_at: Time.current)
            AuditEntry.record!(store: store, actor: staff, action: 'credit.remind', subject: account,
                               metadata: { branch_id: branch.prefixed_id, via: channel, balance: owed.to_s('F') })
            { 'credit_account_id' => account.prefixed_id, 'last_reminded_at' => account.last_reminded_at.iso8601 }
          end
        end
      end
    end
  end
end
