# frozen_string_literal: true

module Spree
  module Pos
    module Resources
      # Creates or changes an area of the floor plan (name, order, grid size).
      module UpsertArea
        FIELDS = %w[name position floor_width floor_height].freeze

        module_function

        def call(store:, staff:, key:, branch:, attributes:, area_id: nil)
          values = attributes.to_h.stringify_keys.slice(*FIELDS)
          payload = { 'command' => 'area.upsert', 'branch_id' => branch.prefixed_id, 'area_id' => area_id.to_s.presence, 'attributes' => values }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: -> { Guard.manage!(store, staff, branch) }) do
            ModulePolicy.require!(branch, Guard::MODULE)
            area = area_id.present? ? Guard.area!(branch, area_id) : Area.new(store: store, branch: branch)
            raise Conflict.new('This area is archived.', reason: 'area_archived') if area.persisted? && area.status != 'active'

            before = area.persisted? ? area.to_pos.slice(*FIELDS.map(&:to_sym)) : nil
            values['name'] = values['name'].to_s.strip if values.key?('name')
            area.assign_attributes(values)
            area.save!
            AuditEntry.record!(store: store, actor: staff, action: before ? 'area.update' : 'area.create', subject: area,
                               metadata: { before: before, after: area.to_pos.slice(*FIELDS.map(&:to_sym)) }.compact)
            Guard.changed!(branch, area)
            area.to_pos
          end
        end
      end
    end
  end
end
