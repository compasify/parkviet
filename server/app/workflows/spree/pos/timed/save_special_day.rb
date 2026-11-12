# frozen_string_literal: true

module Spree
  module Pos
    module Timed
      # A branch's holidays and weekend days, which decide the kind of day
      # play time is priced at. Sessions already stopped keep the kind of
      # day they were billed at in their quote lines.
      module SaveSpecialDay
        COMMAND = 'special_day.save'
        REMOVE_COMMAND = 'special_day.remove'
        WEEKEND_COMMAND = 'branch.weekend_days.save'

        module_function

        def call(store:, staff:, key:, branch_id:, attributes:, special_day_id: nil)
          branch = Guard.branch!(store, branch_id)
          values = attributes.to_h.deep_stringify_keys.slice('date', 'name', 'holiday_surcharge_percent')
          payload = { 'command' => COMMAND, 'branch_id' => branch.prefixed_id, 'special_day_id' => special_day_id.to_s.presence,
                      'values' => values.to_json }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: -> { Guard.manage!(store, staff, branch) }) do
            day = special_day_id ? day!(store, branch, special_day_id) : SpecialDay.new(store: store, branch: branch)
            day.date = date!(values['date']) if values.key?('date')
            day.name = values['name'].to_s.strip if values.key?('name')
            day.holiday_surcharge_percent = percent!(values['holiday_surcharge_percent']) if values.key?('holiday_surcharge_percent')
            unless day.valid?
              reason = day.errors.of_kind?(:date, :taken) ? 'special_day_duplicate' : 'special_day_invalid'
              raise Conflict.new('The holiday is invalid.', reason: reason, details: { fields: day.errors.attribute_names.map(&:to_s) })
            end

            day.save!
            AuditEntry.record!(store: store, actor: staff, action: COMMAND, subject: day, metadata: day.to_pos.except(:id))
            day.to_pos
          end
        end

        def remove(store:, staff:, key:, branch_id:, special_day_id:)
          branch = Guard.branch!(store, branch_id)
          payload = { 'command' => REMOVE_COMMAND, 'branch_id' => branch.prefixed_id, 'special_day_id' => special_day_id.to_s }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: -> { Guard.manage!(store, staff, branch) }) do
            day = day!(store, branch, special_day_id)
            snapshot = day.to_pos
            day.destroy!
            AuditEntry.record!(store: store, actor: staff, action: REMOVE_COMMAND, subject: branch, metadata: snapshot)
            snapshot
          end
        end

        # Days of the week (0 Sunday to 6 Saturday) priced as weekend.
        def weekend_days(store:, staff:, key:, branch_id:, days:)
          branch = Guard.branch!(store, branch_id)
          list = Array(days).map { |day| Integer(day.to_s, 10) }.uniq.sort
          payload = { 'command' => WEEKEND_COMMAND, 'branch_id' => branch.prefixed_id, 'days' => list }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: -> { Guard.manage!(store, staff, branch) }) do
            raise Conflict.new('Weekend days are 0 (Sunday) to 6 (Saturday).', reason: 'weekend_days_invalid') unless list.all? { |day| day.between?(0, 6) }

            before = branch.weekend_days
            branch.update!(weekend_days: list)
            AuditEntry.record!(store: store, actor: staff, action: WEEKEND_COMMAND, subject: branch, metadata: { before: before, after: list })
            { branch_id: branch.prefixed_id, weekend_days: list }
          end
        rescue ArgumentError
          raise Conflict.new('Weekend days are 0 (Sunday) to 6 (Saturday).', reason: 'weekend_days_invalid')
        end

        def day!(store, branch, day_id)
          day = SpecialDay.locate(SpecialDay.for_store(store).where(branch_id: branch.id), day_id)
          raise ActiveRecord::RecordNotFound if day.nil?

          day.lock!
        end

        def date!(value)
          Date.iso8601(value.to_s)
        rescue Date::Error
          raise Conflict.new('Dates use YYYY-MM-DD.', reason: 'special_day_invalid', details: { fields: ['date'] })
        end

        def percent!(value)
          return nil if value.to_s.strip.empty?

          BigDecimal(value.to_s.strip)
        rescue ArgumentError
          raise Conflict.new('The surcharge is invalid.', reason: 'special_day_invalid', details: { fields: ['holiday_surcharge_percent'] })
        end
      end
    end
  end
end
