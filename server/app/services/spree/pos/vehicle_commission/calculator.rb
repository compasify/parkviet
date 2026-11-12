# frozen_string_literal: true

module Spree
  module Pos
    module VehicleCommission
      # Works out a coach visit's commission:
      #   per_vehicle_amounts[vehicle_type] + per_guest_amount x guests,
      # or nothing when the visit has fewer guests or less revenue than the
      # rule asks. The rule is the bus operator's own one in force on the
      # visit's business date, otherwise the branch's general one; among
      # several, the one that started last (then the newest). The result is
      # the snapshot a closed visit keeps.
      module Calculator
        module_function

        def rule_for(visit)
          rules = CommissionRule.for_store(visit.store).where(branch_id: visit.branch_id).effective_on(visit.business_date)
          ordered = ->(scope) { scope.order(Arel.sql('starts_on DESC NULLS LAST'), id: :desc).first }
          (visit.bus_operator_id && ordered.call(rules.where(bus_operator_id: visit.bus_operator_id))) ||
            ordered.call(rules.where(bus_operator_id: nil))
        end

        # `rule` is a CommissionRule, or the rule part of an earlier snapshot
        # (a correction after closing keeps the rule the visit closed with).
        def call(rule:, vehicle_type:, guest_count:, revenue:)
          values = rule.is_a?(CommissionRule) ? rule.to_snapshot.deep_stringify_keys : rule&.deep_stringify_keys
          base = { 'rule' => values, 'guest_count' => guest_count, 'revenue' => money(revenue), 'vehicle_type' => vehicle_type }
          return base.merge(zero('no_rule')) if values.nil?

          if guest_count < values['min_guests'].to_i
            return base.merge(zero('min_guests'))
          elsif revenue < BigDecimal(values['min_revenue'].to_s)
            return base.merge(zero('min_revenue'))
          end

          vehicle = BigDecimal(values.dig('per_vehicle_amounts', vehicle_type).to_s.presence || '0')
          guests = BigDecimal(values['per_guest_amount'].to_s) * guest_count
          base.merge('vehicle_amount' => money(vehicle), 'guest_amount' => money(guests), 'amount' => money(vehicle + guests),
                     'qualified' => true, 'reason' => nil)
        end

        def zero(reason)
          { 'vehicle_amount' => '0.0', 'guest_amount' => '0.0', 'amount' => '0.0', 'qualified' => false, 'reason' => reason }
        end

        def money(value)
          BigDecimal(value.to_s).to_s('F')
        end
      end
    end
  end
end
