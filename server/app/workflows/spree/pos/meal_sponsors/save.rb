# frozen_string_literal: true

module Spree
  module Pos
    module MealSponsors
      # Creates or changes a meal sponsor. A sponsor is a customer (an
      # existing profile, or one made from the name and phone or email);
      # `credit_limit` and `due_days` set its credit account through
      # Credit::Configure, so they need `pos.credit.manage` at the branch
      # like any credit terms. Without a credit account the sponsor pays
      # nothing yet.
      module Save
        FIELDS = %w[name customer_id phone email statement_day subsidy_mode subsidy_value subsidy_daily_cap status].freeze
        COMMAND = 'meal_sponsor.save'

        module_function

        def call(store:, staff:, key:, branch_id:, attributes:, sponsor_id: nil)
          values = attributes.to_h.stringify_keys
          credit = values.slice('credit_limit', 'due_days').compact
          values = values.slice(*FIELDS)
          payload = { 'command' => COMMAND, 'branch_id' => branch_id.to_s, 'sponsor_id' => sponsor_id.to_s.presence,
                      'attributes' => values, 'credit' => credit }
          branch = MealAccounts::Guard.branch!(store, branch_id)
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload,
                               authorize: -> { MealAccounts::Guard.manage!(store, staff, branch) }) do
            ModulePolicy.require!(branch, MealAccounts::Guard::MODULE)
            sponsor = sponsor_id.present? ? MealAccounts::Guard.sponsor!(store, sponsor_id).tap(&:lock!) : build(store, staff, values)
            assign!(sponsor, values, store)
            persist!(sponsor)
            configure_credit!(store, staff, key, branch, sponsor, credit) if credit.any?
            AuditEntry.record!(store: store, actor: staff, action: COMMAND, subject: sponsor,
                               metadata: { branch_id: branch.prefixed_id, fields: (values.keys + credit.keys).sort })
            sponsor.reload.to_pos
          end
        end

        def build(store, staff, values)
          profile = if values['customer_id'].present?
                      CustomerProfile.locate(CustomerProfile.for_store(store), values['customer_id']) || raise(ActiveRecord::RecordNotFound)
                    else
                      CustomerProfile.new(store: store, created_by: staff, name: values['name'], phone: values['phone'],
                                          email: values['email'])
                    end
          # A customer who already buys on credit keeps that one account.
          account = profile.persisted? ? CreditAccount.for_store(store).find_by(customer_profile_id: profile.id,
                                                                                currency: store.default_currency) : nil
          MealSponsor.new(store: store, customer_profile: profile, credit_account: account, status: 'active')
        end

        def assign!(sponsor, values, store)
          sponsor.name = MealAccounts::Guard.text!(values['name'], 120, 'name') if values.key?('name')
          sponsor.name ||= sponsor.customer_profile.name
          sponsor.statement_day = number(values['statement_day'], 'statement_day') if values.key?('statement_day')
          sponsor.subsidy_mode = values['subsidy_mode'].to_s if values.key?('subsidy_mode')
          sponsor.subsidy_value = money(values['subsidy_value'], 'subsidy_value', store) || 0 if values.key?('subsidy_value')
          sponsor.subsidy_daily_cap = money(values['subsidy_daily_cap'], 'subsidy_daily_cap', store) if values.key?('subsidy_daily_cap')
          sponsor.status = values['status'].to_s if values.key?('status')
        end

        def persist!(sponsor)
          profile = sponsor.customer_profile
          invalid!(profile) if profile.new_record? && !profile.valid?
          invalid!(sponsor) unless sponsor.valid?
          profile.save! if profile.new_record?
          sponsor.save!
        rescue ActiveRecord::RecordNotUnique
          raise Conflict.new('This customer is already a sponsor.', reason: 'meal_sponsor_invalid', details: { field: 'customer_id' })
        end

        # The sponsor's credit terms, through the one credit configuration
        # command (its own authorization and audit).
        def configure_credit!(store, staff, key, branch, sponsor, credit)
          result = Credit::Configure.call(
            store: store, staff: staff, key: "#{key}:credit", branch_id: branch.prefixed_id,
            customer_id: sponsor.credit_account ? nil : sponsor.customer_profile.prefixed_id,
            account_id: sponsor.credit_account&.prefixed_id, credit_limit: credit['credit_limit'], due_days: credit['due_days']
          )
          sponsor.update!(credit_account: CreditAccount.find_by_prefix_id!(result['id'] || result[:id]))
        end

        def invalid!(record)
          field = record.errors.attribute_names.first.to_s
          raise Conflict.new(record.errors.full_messages.first || 'The sponsor is invalid.', reason: 'meal_sponsor_invalid',
                                                                                             details: { field: field })
        end

        def number(value, field)
          Integer(value.to_s, 10)
        rescue ArgumentError
          raise Conflict.new('The number is invalid.', reason: 'meal_sponsor_invalid', details: { field: field })
        end

        def money(value, field, store)
          return nil if value.nil? || value.to_s.strip.empty?

          parsed = Record.money(value.to_s)
          return parsed if parsed && Record.countable_money?(parsed, store.default_currency)

          raise Conflict.new('The amount is invalid.', reason: 'meal_sponsor_invalid', details: { field: field })
        end
      end
    end
  end
end
