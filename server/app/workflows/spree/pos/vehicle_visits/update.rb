# frozen_string_literal: true

module Spree
  module Pos
    module VehicleVisits
      # Changes an open visit: the guest count is typed in or corrected until
      # the visit closes, and so are its driver and operator. After closing,
      # changes go through Adjust and its approval.
      module Update
        COMMAND = 'vehicle_visit.update'

        module_function

        def call(store:, staff:, key:, visit_id:, attributes:, revision:)
          visit = Guard.visit!(store, visit_id)
          values = attributes.to_h.transform_keys(&:to_s).slice(*Open::FIELDS)
          payload = { 'command' => COMMAND, 'visit_id' => visit.prefixed_id, 'revision' => revision.to_s }.
                    merge(values.transform_values(&:to_s))
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload,
                               authorize: -> { Guard.operate!(store, staff, visit.branch) }) do
            ModulePolicy.require!(visit.branch, Guard::MODULE)
            visit.lock!
            Guard.status!(visit, 'open')
            Guard.revision!(visit, revision)
            before = visit.slice('guest_count', 'plate', 'vehicle_type').transform_values(&:to_s)
            changes = {}
            changes[:plate] = Guard.plate!(values['plate']) if values.key?('plate')
            changes[:vehicle_type] = Guard.vehicle_type!(values['vehicle_type']) if values.key?('vehicle_type')
            changes[:guest_count] = Guard.guests!(values['guest_count']) if values.key?('guest_count')
            changes[:bus_operator] = Guard.operator!(store, values['bus_operator_id']) if values.key?('bus_operator_id')
            changes[:driver_name] = Guard.text!(values['driver_name'], 120, 'driver_name') if values.key?('driver_name')
            changes[:driver_phone] = Guard.text!(values['driver_phone'], 32, 'driver_phone') if values.key?('driver_phone')
            changes[:note] = Guard.text!(values['note'], 500, 'note') if values.key?('note')
            visit.update!(changes.merge(revision: visit.revision + 1))
            Guard.audit!(visit, staff, COMMAND, before: before)
            Guard.to_pos(visit, staff)
          end
        end
      end
    end
  end
end
