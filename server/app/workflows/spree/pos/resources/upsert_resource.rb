# frozen_string_literal: true

module Spree
  module Pos
    module Resources
      # Creates or changes a table of the floor plan: its area, name, kind,
      # seats, shape and place on the area's grid. A table must fit inside
      # its area.
      module UpsertResource
        FIELDS = %w[name kind capacity shape x y w h rotation position resource_type_code minimum_spend].freeze

        module_function

        def call(store:, staff:, key:, branch:, attributes:, resource_id: nil)
          values = attributes.to_h.stringify_keys
          area_id = values['area_id'].to_s.presence
          values = values.slice(*FIELDS)
          payload = { 'command' => 'resource.upsert', 'branch_id' => branch.prefixed_id, 'resource_id' => resource_id.to_s.presence,
                      'area_id' => area_id, 'attributes' => values }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: -> { Guard.manage!(store, staff, branch) }) do
            ModulePolicy.require!(branch, Guard::MODULE)
            resource = resource_id.present? ? Guard.resource!(branch, resource_id) : Resource.new(store: store, branch: branch)
            raise Conflict.new('This table is archived.', reason: 'table_archived') if resource.persisted? && !resource.active?

            before = resource.persisted? ? resource.to_pos : nil
            if area_id || resource.new_record?
              area = Guard.area!(branch, area_id)
              raise Conflict.new('This area is archived.', reason: 'area_archived') unless area.status == 'active'

              resource.area = area
            end
            values['name'] = values['name'].to_s.strip if values.key?('name')
            minimum!(store, resource, values.delete('minimum_spend')) if values.key?('minimum_spend')
            resource.assign_attributes(values)
            fits!(resource)
            resource.save!
            AuditEntry.record!(store: store, actor: staff, action: before ? 'resource.update' : 'resource.create', subject: resource,
                               metadata: { before: before&.except(:branch_id), after: resource.to_pos.except(:branch_id) }.compact)
            Guard.changed!(branch, resource)
            resource.to_pos
          end
        end

        # A VIP table's minimum spend, in the store's currency; blank removes it.
        def minimum!(store, resource, value)
          if value.to_s.strip.empty?
            resource.minimum_spend = nil
            resource.minimum_spend_currency = nil
            return
          end

          amount = Record.money(value.to_s.strip)
          currency = store.default_currency
          unless amount&.positive? && Record.countable_money?(amount, currency)
            raise Conflict.new('The minimum spend is invalid.', reason: 'minimum_spend_invalid')
          end

          resource.minimum_spend = amount
          resource.minimum_spend_currency = currency
        end

        def fits!(resource)
          area = resource.area
          return if area.nil? || [resource.x, resource.y, resource.w, resource.h].any? { |value| !value.is_a?(Integer) }
          return if resource.x + resource.w <= area.floor_width && resource.y + resource.h <= area.floor_height

          raise Conflict.new('The table does not fit in its area.', reason: 'resource_outside_area')
        end
      end
    end
  end
end
