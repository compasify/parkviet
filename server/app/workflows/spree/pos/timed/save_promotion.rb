# frozen_string_literal: true

module Spree
  module Pos
    module Timed
      # Adds or changes a branch's timed promotion (free minutes), or
      # archives it. A promotion is read when a session is priced, so a
      # change reaches the running clocks and the clocks stopped after it;
      # a stopped clock keeps the bonus line it was billed with.
      module SavePromotion
        COMMAND = 'timed_promotion.save'
        FIELDS = %w[name kind threshold_minutes bonus_minutes resource_kinds active_windows status].freeze

        module_function

        def call(store:, staff:, key:, branch_id:, attributes:, promotion_id: nil)
          branch = Guard.branch!(store, branch_id)
          values = attributes.to_h.deep_stringify_keys.slice(*FIELDS)
          payload = { 'command' => COMMAND, 'branch_id' => branch.prefixed_id, 'promotion_id' => promotion_id.to_s.presence,
                      'values' => values.to_json }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: -> { Guard.manage!(store, staff, branch) }) do
            ModulePolicy.require!(branch, Guard::MODULE)
            promotion = if promotion_id
                          TimedPromotion.locate(TimedPromotion.for_store(store).where(branch_id: branch.id), promotion_id)&.lock! ||
                            raise(ActiveRecord::RecordNotFound)
                        else
                          TimedPromotion.new(store: store, branch: branch, status: 'active')
                        end
            before = promotion.persisted? ? promotion.to_pos : nil
            assign!(promotion, values)
            unless promotion.valid?
              raise Conflict.new('The promotion is invalid.', reason: 'timed_promotion_invalid',
                                                              details: { fields: promotion.errors.attribute_names.map(&:to_s) })
            end

            promotion.save!
            AuditEntry.record!(store: store, actor: staff, action: COMMAND, subject: promotion,
                               metadata: { before: before, after: promotion.to_pos })
            Realtime.publish(branch, 'resource.updated', id: promotion.prefixed_id, refs: { timed_promotion_id: promotion.prefixed_id })
            promotion.to_pos
          end
        end

        def assign!(promotion, values)
          promotion.name = values['name'].to_s.strip if values.key?('name')
          promotion.kind = values['kind'].to_s if values.key?('kind')
          promotion.status = values['status'].to_s if values.key?('status')
          %w[threshold_minutes bonus_minutes].each do |field|
            promotion[field] = integer!(values[field], field) if values.key?(field)
          end
          if values.key?('resource_kinds')
            kinds = values['resource_kinds']
            invalid!('resource_kinds') unless kinds.is_a?(Array)
            promotion.resource_kinds = kinds.map { |code| code.to_s.strip }.reject(&:empty?).uniq
          end
          promotion.active_windows = OperatingHours.normalize!(values['active_windows'], field: 'active_windows') if values.key?('active_windows')
        end

        def integer!(value, field)
          Integer(value.to_s, 10)
        rescue ArgumentError
          invalid!(field)
        end

        def invalid!(field)
          raise Conflict.new('The promotion is invalid.', reason: 'timed_promotion_invalid', details: { fields: [field] })
        end
      end
    end
  end
end
