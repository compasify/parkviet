# frozen_string_literal: true

module Spree
  module Pos
    module VehicleVisits
      # Adds or changes a branch's commission rule, or archives it. Visits
      # already closed keep the copy of the rule they closed with.
      module SaveCommissionRule
        COMMAND = 'commission_rule.save'
        FIELDS = %w[name bus_operator_id per_guest_amount min_guests min_revenue starts_on ends_on status].freeze

        module_function

        def call(store:, staff:, key:, branch_id:, attributes:, rule_id: nil)
          branch = Guard.branch!(store, branch_id)
          values = attributes.to_h.deep_stringify_keys.slice(*FIELDS, 'per_vehicle_amounts')
          payload = { 'command' => COMMAND, 'branch_id' => branch.prefixed_id, 'rule_id' => rule_id.to_s.presence,
                      'values' => values.to_json }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: -> { Guard.manage!(store, staff, branch) }) do
            rule = rule_id ? rule!(store, branch, rule_id) : CommissionRule.new(store: store, branch: branch)
            assign!(store, rule, values)
            raise Conflict.new('The rule is invalid.', reason: 'commission_rule_invalid', details: { fields: rule.errors.attribute_names }) unless rule.valid?

            rule.revision += 1 if rule.persisted?
            rule.save!
            AuditEntry.record!(store: store, actor: staff, action: COMMAND, subject: rule, metadata: rule.to_snapshot.merge(status: rule.status))
            rule.to_pos
          end
        end

        def rule!(store, branch, rule_id)
          rule = CommissionRule.locate(CommissionRule.for_store(store).where(branch_id: branch.id), rule_id)
          raise ActiveRecord::RecordNotFound if rule.nil?

          rule.lock!
        end

        def assign!(store, rule, values)
          rule.name = Guard.text!(values['name'], 120, 'name') if values.key?('name')
          rule.bus_operator = Guard.operator!(store, values['bus_operator_id']) if values.key?('bus_operator_id')
          rule.per_vehicle_amounts = vehicle_amounts!(values['per_vehicle_amounts']) if values.key?('per_vehicle_amounts')
          rule.per_guest_amount = money!(values['per_guest_amount']) if values.key?('per_guest_amount')
          rule.min_revenue = money!(values['min_revenue']) if values.key?('min_revenue')
          rule.min_guests = Guard.guests!(values['min_guests'].presence || 0) if values.key?('min_guests')
          rule.starts_on = date!(values['starts_on']) if values.key?('starts_on')
          rule.ends_on = date!(values['ends_on']) if values.key?('ends_on')
          rule.status = values['status'] if values.key?('status')
        end

        # Amounts by vehicle type, kept as JSON numbers; a type left empty pays nothing.
        def vehicle_amounts!(value)
          hash = value.respond_to?(:to_unsafe_h) ? value.to_unsafe_h : value
          raise Conflict.new('The amounts by vehicle are invalid.', reason: 'commission_rule_invalid') unless hash.is_a?(Hash)

          hash.to_h.each_with_object({}) do |(type, amount), out|
            raise Conflict.new('The vehicle type is invalid.', reason: 'vehicle_type_invalid') unless VehicleVisit::VEHICLE_TYPES.include?(type.to_s)
            next if amount.to_s.strip.empty?

            parsed = money!(amount)
            out[type.to_s] = parsed.frac.zero? ? parsed.to_i : parsed.to_f
          end
        end

        def money!(value)
          parsed = Record.money(value.to_s.strip.presence || '0')
          raise Conflict.new('The amount is invalid.', reason: 'amount_invalid') if parsed.nil?

          parsed
        end

        def date!(value)
          return nil if value.to_s.strip.empty?

          Date.iso8601(value.to_s)
        rescue Date::Error
          raise Conflict.new('Dates use YYYY-MM-DD.', reason: 'commission_rule_invalid')
        end
      end
    end
  end
end
