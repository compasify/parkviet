# frozen_string_literal: true

module Spree
  module Pos
    module Credit
      # Creates or changes a customer's credit terms. A new account is homed at
      # the branch named in the request; afterwards only credit managers of that
      # home branch administer it. Lowering the limit or suspending never
      # touches posted debt or committed sales; it only stops new reservations
      # that would not fit. A reservation approved before the limit was lowered
      # was within the terms when granted and may still commit.
      class Configure
        def self.call(store:, staff:, key:, branch_id: nil, customer_id: nil, account_id: nil, credit_limit: nil,
                      due_days: nil, status: nil)
          limit = credit_limit.nil? ? nil : Record.money(credit_limit.to_s)
          payload = {
            'command' => 'credit.configure', 'branch_id' => branch_id.to_s.presence, 'customer_id' => customer_id.to_s.presence,
            'account_id' => account_id.to_s.presence, 'credit_limit' => limit&.to_s('F'),
            'due_days' => due_days.to_s.presence, 'status' => status.to_s.presence
          }
          authorize = lambda do
            branch = account_id.present? ? existing!(store, account_id).branch : home_branch!(store, branch_id)
            raise CanCan::AccessDenied unless AccessPolicy.new(store: store, staff: staff).allows?(branch, Capabilities::CREDIT_MANAGE)
          end
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: authorize) do
            invalid_limit = !credit_limit.nil? && (limit.nil? || !Record.countable_money?(limit, store.default_currency))
            raise Conflict, 'Credit limit is invalid.' if invalid_limit

            days = due_days.nil? ? nil : parse_days(due_days)
            account = account_id.present? ? existing!(store, account_id) : build(store, staff, customer_id, home_branch!(store, branch_id))
            account.lock! if account.persisted?
            before = account.persisted? ? account.slice(:credit_limit, :due_days, :status) : {}
            account.credit_limit = limit unless limit.nil?
            account.due_days = days unless days.nil?
            account.status = status.to_s if status.present?
            account.updated_by = staff
            raise Conflict, 'Credit limit and due days are required.' if account.credit_limit.nil? || account.due_days.nil?

            account.save!
            AuditEntry.record!(store: store, actor: staff, action: 'credit.configure', subject: account,
                               metadata: { branch_id: account.branch.prefixed_id, before: before.transform_values(&:to_s),
                                           after: account.slice(:credit_limit, :due_days, :status).transform_values(&:to_s) })
            account.to_pos
          end
        end

        def self.parse_days(value)
          Integer(value.to_s, 10)
        rescue ArgumentError
          raise Conflict, 'Due days are invalid.'
        end

        def self.home_branch!(store, branch_id)
          branch = Branch.locate(Branch.for_store(store), branch_id)
          raise ActiveRecord::RecordNotFound if branch.nil?

          branch
        end

        def self.existing!(store, account_id)
          account = CreditAccount.locate(CreditAccount.for_store(store), account_id)
          raise ActiveRecord::RecordNotFound if account.nil?

          account
        end

        def self.build(store, staff, customer_id, branch)
          profile = CustomerProfile.locate(CustomerProfile.for_store(store), customer_id)
          raise ActiveRecord::RecordNotFound if profile.nil?
          if CreditAccount.for_store(store).exists?(customer_profile_id: profile.id, currency: store.default_currency)
            raise Conflict, 'This customer already has a credit account.'
          end

          CreditAccount.new(store: store, customer_profile: profile, branch: branch, currency: store.default_currency,
                            status: 'active', updated_by: staff)
        end
      end
    end
  end
end
