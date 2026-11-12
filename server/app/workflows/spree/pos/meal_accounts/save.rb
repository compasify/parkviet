# frozen_string_literal: true

module Spree
  module Pos
    module MealAccounts
      # Creates or changes a meal account. A new account opens the eater's
      # meal wallet and, without `customer_id`, a customer profile from the
      # name and phone (or email). Locking (`status: locked`) refuses new
      # meals and wallet payments; the balance stays. The account's version
      # moves on every change, so approvals asked for earlier stop matching.
      module Save
        FIELDS = %w[employee_code name phone email customer_id group_label meal_sponsor_id pay_mode daily_meal_limit
                    meal_windows low_balance_threshold status].freeze
        COMMAND = 'meal_account.save'

        module_function

        def call(store:, staff:, key:, branch_id:, attributes:, account_id: nil)
          values = attributes.to_h.stringify_keys.slice(*FIELDS)
          payload = { 'command' => COMMAND, 'branch_id' => branch_id.to_s, 'account_id' => account_id.to_s.presence,
                      'attributes' => values }
          branch = Guard.branch!(store, branch_id)
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload,
                               authorize: -> { Guard.manage!(store, staff, branch) }) do
            ModulePolicy.require!(branch, Guard::MODULE)
            account = account_id.present? ? Guard.account!(store, account_id).tap(&:lock!) : nil
            account = save!(store, staff, account, values)
            AuditEntry.record!(store: store, actor: staff, action: COMMAND, subject: account,
                               metadata: { branch_id: branch.prefixed_id, fields: values.keys.sort, created: account_id.blank? || nil }.compact)
            account.reload.to_pos
          end
        end

        # Shared with Import. Raises Conflict `meal_account_invalid` with the
        # field for a value the account cannot take.
        def save!(store, staff, account, values)
          account ||= build(store, staff, values)
          profile = account.customer_profile
          profile.name = values['name'] if values.key?('name') && values['customer_id'].blank?
          profile.phone = values['phone'] if values.key?('phone') && values['customer_id'].blank?
          profile.email = values['email'] if values.key?('email') && values['customer_id'].blank? && profile.customer.nil?
          account.employee_code = values['employee_code'] if values.key?('employee_code')
          account.group_label = Guard.text!(values['group_label'], 120, 'group_label') if values.key?('group_label')
          account.meal_sponsor = sponsor(store, values['meal_sponsor_id']) if values.key?('meal_sponsor_id')
          account.pay_mode = values['pay_mode'].to_s if values.key?('pay_mode')
          account.daily_meal_limit = integer(values['daily_meal_limit'], 'daily_meal_limit') if values.key?('daily_meal_limit')
          account.meal_windows = windows(values['meal_windows']) if values.key?('meal_windows')
          account.low_balance_threshold = threshold(values['low_balance_threshold'], store) if values.key?('low_balance_threshold')
          account.status = values['status'].to_s if values.key?('status')
          account.revision += 1 if account.persisted?
          persist!(profile, account)
          account
        end

        def build(store, staff, values)
          profile = if values['customer_id'].present?
                      CustomerProfile.locate(CustomerProfile.for_store(store), values['customer_id']) || raise(ActiveRecord::RecordNotFound)
                    else
                      CustomerProfile.new(store: store, created_by: staff)
                    end
          wallet = StoredValueAccount.new(store: store, customer_profile: profile, kind: 'meal', currency: store.default_currency,
                                          status: 'active')
          MealAccount.new(store: store, customer_profile: profile, stored_value_account: wallet, status: 'active')
        end

        def persist!(profile, account)
          invalid!(profile) if profile.changed? && !profile.valid?
          invalid!(account) unless account.valid?
          profile.save! if profile.changed?
          account.stored_value_account.save! if account.stored_value_account.new_record?
          account.save!
        rescue ActiveRecord::RecordNotUnique
          raise Conflict.new('This employee code is already used.', reason: 'meal_account_invalid', details: { field: 'employee_code' })
        end

        def invalid!(record)
          field = record.errors.attribute_names.first.to_s
          raise Conflict.new(record.errors.full_messages.first || 'The account is invalid.', reason: 'meal_account_invalid',
                                                                                             details: { field: field })
        end

        def sponsor(store, sponsor_id)
          return nil if sponsor_id.blank?

          Guard.sponsor!(store, sponsor_id)
        end

        def integer(value, field)
          return nil if value.nil? || value.to_s.strip.empty?

          Integer(value.to_s, 10)
        rescue ArgumentError
          raise Conflict.new('The number is invalid.', reason: 'meal_account_invalid', details: { field: field })
        end

        def threshold(value, store)
          return nil if value.nil? || value.to_s.strip.empty?

          parsed = Record.money(value.to_s)
          return parsed if parsed && Record.countable_money?(parsed, store.default_currency)

          raise Conflict.new('The amount is invalid.', reason: 'meal_account_invalid', details: { field: 'low_balance_threshold' })
        end

        # [{ key, from, to, limit }] as sent; the model checks the shape.
        def windows(value)
          list = value.is_a?(String) ? JSON.parse(value) : Array(value)
          list.map do |window|
            row = window.respond_to?(:to_unsafe_h) ? window.to_unsafe_h : window.to_h
            row = row.stringify_keys.slice('key', 'from', 'to', 'limit')
            row['limit'] = integer(row['limit'], 'meal_windows') if row.key?('limit')
            row.compact
          end
        rescue JSON::ParserError, TypeError, NoMethodError
          raise Conflict.new('The meal times are invalid.', reason: 'meal_account_invalid', details: { field: 'meal_windows' })
        end
      end
    end
  end
end
