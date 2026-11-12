# frozen_string_literal: true

module Spree
  module Pos
    module Timed
      # Adds or changes a branch's rate plan, or archives it. A plan that
      # play time was priced on is never changed: saving it archives that
      # version and writes the next one, so stopped sessions keep the
      # prices they were billed at and running ones price their past
      # segments at the old version. Rules are sent whole and replace the
      # plan's rules.
      module SaveRatePlan
        COMMAND = 'rate_plan.save'
        FIELDS = %w[name resource_type_code variant_id block_minutes grace_minutes minimum_minutes status].freeze
        RULE_FIELDS = %w[day_type start_minute end_minute price_per_hour label].freeze

        module_function

        def call(store:, staff:, key:, branch_id:, attributes:, rate_plan_id: nil)
          branch = Guard.branch!(store, branch_id)
          values = attributes.to_h.deep_stringify_keys.slice(*FIELDS, 'rules')
          payload = { 'command' => COMMAND, 'branch_id' => branch.prefixed_id, 'rate_plan_id' => rate_plan_id.to_s.presence,
                      'values' => values.to_json }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: -> { Guard.manage!(store, staff, branch) }) do
            ModulePolicy.require!(branch, Guard::MODULE)
            current = rate_plan_id ? plan!(store, branch, rate_plan_id) : nil
            raise Conflict.new('An archived plan cannot be changed.', reason: 'rate_plan_archived') if current && !current.active?

            plan = if current.nil?
                     RatePlan.new(store: store, branch: branch, status: 'active', version: 1)
                   elsif current.used? && !archive_only?(values)
                     # The next version, written after this one is archived.
                     next_version(current)
                   else
                     current
                   end

            assign!(store, branch, plan, values)
            raise Conflict.new('The rate plan is invalid.', reason: 'rate_plan_invalid', details: invalid_details(plan)) unless plan.valid?

            if current && !plan.equal?(current)
              current.update_columns(status: 'archived', updated_at: Time.current)
              plan.status = 'active' if values['status'].blank?
            end
            if plan.active? && RatePlan.active.where(branch_id: branch.id, resource_type_code: plan.resource_type_code).where.not(id: [plan.id, current&.id].compact).exists?
              raise Conflict.new('This kind of room already has an active plan.', reason: 'rate_plan_duplicate',
                                                                                  details: { resource_type_code: plan.resource_type_code })
            end

            plan.save!
            AuditEntry.record!(store: store, actor: staff, action: COMMAND, subject: plan,
                               metadata: { version: plan.version, previous_id: plan.previous&.prefixed_id, status: plan.status,
                                           block_minutes: plan.block_minutes, grace_minutes: plan.grace_minutes,
                                           minimum_minutes: plan.minimum_minutes, variant_id: plan.variant.prefixed_id,
                                           rules: plan.rate_rules.map { |rule| rule.to_pos.except(:id) } })
            # Rooms' running quotes change with the plan.
            Realtime.publish(branch, 'resource.updated', id: plan.prefixed_id, refs: { rate_plan_id: plan.prefixed_id })
            plan.reload.to_pos
          end
        end

        def plan!(store, branch, plan_id)
          plan = RatePlan.locate(RatePlan.for_store(store).where(branch_id: branch.id), plan_id)
          raise ActiveRecord::RecordNotFound if plan.nil?

          plan.lock!
        end

        def archive_only?(values)
          values.keys == ['status'] && values['status'] == 'archived'
        end

        def next_version(current)
          plan = RatePlan.new(store: current.store, branch: current.branch, name: current.name, resource_type_code: current.resource_type_code,
                              variant: current.variant, block_minutes: current.block_minutes, grace_minutes: current.grace_minutes,
                              minimum_minutes: current.minimum_minutes, status: 'active', version: current.version + 1, previous: current)
          current.rate_rules.each { |rule| plan.rate_rules.build(rule.attributes.slice(*RULE_FIELDS, 'position')) }
          plan
        end

        def assign!(store, branch, plan, values)
          plan.name = values['name'].to_s.strip if values.key?('name')
          plan.resource_type_code = values['resource_type_code'].to_s.strip if values.key?('resource_type_code')
          plan.variant = variant!(branch, values['variant_id']) if values.key?('variant_id')
          %w[block_minutes grace_minutes minimum_minutes].each do |field|
            plan[field] = integer!(values[field], field) if values.key?(field)
          end
          if values.key?('status')
            status = values['status'].to_s
            raise Conflict.new('The status is invalid.', reason: 'rate_plan_invalid', details: { fields: ['status'] }) unless RatePlan::STATUSES.include?(status)

            plan.status = status
          end
          rules!(plan, values['rules']) if values.key?('rules')
          raise ActiveRecord::RecordNotFound if plan.variant && plan.variant.product&.store_id != store.id
        end

        # The service sold for the time: a product sold at the branch.
        def variant!(branch, variant_id)
          variant = Spree::Variant.find_by_prefix_id(variant_id.to_s)
          raise Conflict.new('Choose the service sold for the time.', reason: 'rate_plan_invalid', details: { fields: ['variant_id'] }) if variant.nil?

          Workspaces::ManageLineItem.sellable_variant!(branch: branch, variant: variant)
        rescue ActiveRecord::RecordNotFound
          raise Conflict.new('This service is not sold at the branch.', reason: 'variant_unavailable', details: { fields: ['variant_id'] })
        end

        def rules!(plan, rows)
          raise Conflict.new('The rules are invalid.', reason: 'rate_plan_invalid', details: { fields: ['rules'] }) unless rows.is_a?(Array)

          plan.rate_rules.each(&:mark_for_destruction) if plan.persisted?
          kept = plan.persisted? ? [] : plan.rate_rules.to_a
          kept.each { |rule| plan.rate_rules.delete(rule) }
          rows.each_with_index do |row, index|
            row = row.respond_to?(:to_unsafe_h) ? row.to_unsafe_h : row
            raise Conflict.new('The rules are invalid.', reason: 'rate_plan_invalid', details: { fields: ['rules'] }) unless row.is_a?(Hash)

            row = row.stringify_keys
            price = Record.money(row['price_per_hour'].to_s.strip)
            raise Conflict.new('The price is invalid.', reason: 'amount_invalid', details: { fields: ['rules'] }) if price.nil? || price.negative?

            plan.rate_rules.build(day_type: row['day_type'].to_s, start_minute: integer!(row['start_minute'], 'start_minute'),
                                  end_minute: integer!(row['end_minute'], 'end_minute'), price_per_hour: price,
                                  label: row['label'].to_s.strip.presence, position: index + 1)
          end
        end

        def integer!(value, field)
          Integer(value.to_s, 10)
        rescue ArgumentError
          raise Conflict.new("#{field} must be a whole number.", reason: 'rate_plan_invalid', details: { fields: [field] })
        end

        def invalid_details(plan)
          rules = plan.rate_rules.reject(&:marked_for_destruction?)
          { fields: (plan.errors.attribute_names + rules.flat_map { |rule| rule.errors.attribute_names.map { |name| "rules.#{name}" } }).uniq.map(&:to_s),
            messages: plan.errors.full_messages }
        end
      end
    end
  end
end
