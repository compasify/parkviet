# frozen_string_literal: true

require 'csv'

module Spree
  module Pos
    module MealAccounts
      # Imports meal accounts from a CSV with a header row:
      #   employee_code, name, phone, email, group_label, sponsor, daily_meal_limit, pay_mode
      # `sponsor` is a sponsor's name in this store. A known code updates its
      # account, a new one opens an account (and a customer profile, so it
      # needs a phone or an email). All rows or none: any bad row refuses the
      # file with every row's problem (`meal_import_invalid`).
      module Import
        COMMAND = 'meal_account.import'
        COLUMNS = %w[employee_code name phone email group_label sponsor daily_meal_limit pay_mode].freeze
        MAX_ROWS = 5000
        MAX_BYTES = 2.megabytes

        module_function

        def call(store:, staff:, key:, branch_id:, csv:)
          text = csv.to_s
          payload = { 'command' => COMMAND, 'branch_id' => branch_id.to_s, 'digest' => Digest::SHA256.hexdigest(text) }
          branch = Guard.branch!(store, branch_id)
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload,
                               authorize: -> { Guard.manage!(store, staff, branch) }) do
            ModulePolicy.require!(branch, Guard::MODULE)
            rows = parse!(text)
            sponsors = MealSponsor.for_store(store).index_by { |sponsor| sponsor.name.strip.downcase }
            created = 0
            updated = 0
            errors = []
            rows.each.with_index(2) do |row, line|
              existing = MealAccount.for_store(store).find_by(employee_code: MealAccount.normalize_code(row['employee_code']))
              # A savepoint per row, so one refused row leaves the others checkable.
              MealAccount.transaction(requires_new: true) { Save.save!(store, staff, existing&.lock!, values(row, sponsors)) }
              existing ? updated += 1 : created += 1
            rescue Conflict => e
              errors << { line: line, field: e.details&.dig(:field) || 'row', message: e.message }
            end
            if errors.any?
              raise Conflict.new('Some rows cannot be imported.', reason: 'meal_import_invalid', details: { errors: errors.first(100) })
            end

            AuditEntry.record!(store: store, actor: staff, action: COMMAND, subject: branch,
                               metadata: { created: created, updated: updated })
            { 'created' => created, 'updated' => updated }
          end
        end

        def parse!(text)
          raise Conflict.new('The file is too large.', reason: 'meal_import_invalid') if text.bytesize > MAX_BYTES

          table = ::CSV.parse(text.delete_prefix("﻿"), headers: true, skip_blanks: true)
          headers = table.headers.compact.map { |header| header.to_s.strip.downcase }
          missing = %w[employee_code name] - headers
          raise Conflict.new("Missing columns: #{missing.join(', ')}", reason: 'meal_import_invalid') if missing.any?
          raise Conflict.new("At most #{MAX_ROWS} rows.", reason: 'meal_import_invalid') if table.size > MAX_ROWS

          table.map { |row| row.to_h.transform_keys { |header| header.to_s.strip.downcase }.slice(*COLUMNS) }
        rescue ::CSV::MalformedCSVError => e
          raise Conflict.new("The file is not a valid CSV: #{e.message.first(120)}", reason: 'meal_import_invalid')
        end

        def values(row, sponsors)
          values = row.transform_values { |value| value.to_s.strip }.reject { |_, value| value.empty? }
          if values.key?('sponsor')
            sponsor = sponsors[values.delete('sponsor').downcase]
            raise Conflict.new('No sponsor has this name.', reason: 'meal_account_invalid', details: { field: 'sponsor' }) if sponsor.nil?

            values['meal_sponsor_id'] = sponsor.prefixed_id
            values['pay_mode'] ||= 'sponsor'
          end
          values
        end
      end
    end
  end
end
