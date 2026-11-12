# frozen_string_literal: true

module Spree
  module Pos
    module VehicleVisits
      # A coach arrives: its plate, operator, type, driver and guests. The
      # visit closes by itself after the branch's `vehicle_visit_window_minutes`.
      # The same plate already open today is allowed (two coaches of one
      # company can share a plate prefix typed wrong) and answered with the
      # warning `plate_open_today`.
      module Open
        COMMAND = 'vehicle_visit.open'
        FIELDS = %w[plate vehicle_type bus_operator_id driver_name driver_phone guest_count note].freeze

        module_function

        def call(store:, staff:, key:, branch_id:, attributes:)
          branch = Guard.branch!(store, branch_id)
          values = attributes.to_h.transform_keys(&:to_s).slice(*FIELDS)
          payload = { 'command' => COMMAND, 'branch_id' => branch.prefixed_id }.merge(values.transform_values(&:to_s))
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: -> { Guard.operate!(store, staff, branch) }) do
            ModulePolicy.require!(branch, Guard::MODULE)
            now = Workspace.database_now
            plate = Guard.plate!(values['plate'])
            date = BusinessDay.for(branch, Workspace.business_now)
            warnings = []
            warnings << 'plate_open_today' if VehicleVisit.open_now.where(branch_id: branch.id, plate: plate, business_date: date).exists?
            visit = VehicleVisit.create!(
              store: store, branch: branch, bus_operator: Guard.operator!(store, values['bus_operator_id']), plate: plate,
              vehicle_type: Guard.vehicle_type!(values['vehicle_type']),
              driver_name: Guard.text!(values['driver_name'], 120, 'driver_name'),
              driver_phone: Guard.text!(values['driver_phone'], 32, 'driver_phone'),
              guest_count: Guard.guests!(values['guest_count'].presence || 0), note: Guard.text!(values['note'], 500, 'note'),
              arrived_at: now, closes_at: now + branch.vehicle_visit_window_minutes.minutes, business_date: date,
              opened_by: staff, currency: store.default_currency, status: 'open'
            )
            Guard.audit!(visit, staff, COMMAND, warnings: warnings.presence)
            Guard.to_pos(visit, staff).merge(warnings: warnings)
          end
        end
      end
    end
  end
end
