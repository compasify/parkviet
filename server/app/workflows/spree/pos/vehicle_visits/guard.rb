# frozen_string_literal: true

module Spree
  module Pos
    module VehicleVisits
      # Shared rules of a rest stop's coach visits (module
      # `fnb.vehicle_commission`): who works them, finding records, and the
      # field checks every command repeats.
      module Guard
        MODULE = 'fnb.vehicle_commission'

        module_function

        # Opening visits, changing open ones, closing them and putting
        # orders on them: the people who meet coaches and the counter.
        def operate!(store, staff, branch)
          policy = AccessPolicy.new(store: store, staff: staff)
          keys = [Capabilities::VEHICLE_VISIT_OPERATE, Capabilities::VEHICLE_VISIT_MANAGE]
          raise CanCan::AccessDenied if branch.disabled? || keys.none? { |key| policy.allows?(branch, key) }
        end

        # Operators, rules, settings, paying out, corrections and voids.
        def manage!(store, staff, branch)
          policy = AccessPolicy.new(store: store, staff: staff)
          raise CanCan::AccessDenied if branch.disabled? || !policy.allows?(branch, Capabilities::VEHICLE_VISIT_MANAGE)
        end

        # Reading visits: their people, the counter and report readers.
        def read!(store, staff, branch)
          policy = AccessPolicy.new(store: store, staff: staff)
          keys = [Capabilities::VEHICLE_VISIT_OPERATE, Capabilities::VEHICLE_VISIT_MANAGE, Capabilities::OPEN_SHIFT,
                  Capabilities::REPORT_READ]
          raise CanCan::AccessDenied if keys.none? { |key| policy.allows?(branch, key) }
        end

        # Drivers' phone numbers and transfer references in full.
        def full_details?(store, staff, branch)
          AccessPolicy.new(store: store, staff: staff).allows?(branch, Capabilities::VEHICLE_VISIT_MANAGE)
        end

        def branch!(store, branch_id)
          Branch.locate(Branch.for_store(store), branch_id) || raise(ActiveRecord::RecordNotFound)
        end

        def visit!(store, visit_id)
          VehicleVisit.locate(VehicleVisit.for_store(store), visit_id) || raise(ActiveRecord::RecordNotFound)
        end

        def operator!(store, operator_id, active: true)
          return nil if operator_id.blank?

          operator = BusOperator.locate(BusOperator.for_store(store), operator_id) || raise(ActiveRecord::RecordNotFound)
          raise Conflict.new('This bus operator is archived.', reason: 'bus_operator_archived') if active && !operator.active?

          operator
        end

        def plate!(value)
          plate = VehicleVisit.normalize_plate(value)
          raise Conflict.new('The plate is invalid.', reason: 'vehicle_plate_invalid') if plate.nil? || plate.length > VehicleVisit::PLATE_MAX

          plate
        end

        def vehicle_type!(value)
          type = value.to_s.presence || 'other'
          raise Conflict.new('The vehicle type is invalid.', reason: 'vehicle_type_invalid') unless VehicleVisit::VEHICLE_TYPES.include?(type)

          type
        end

        def guests!(value)
          count = value.is_a?(Integer) ? value : (Integer(value.to_s, 10) rescue nil) # rubocop:disable Style/RescueModifier
          raise Conflict.new('The guest count is invalid.', reason: 'vehicle_guests_invalid') unless count&.between?(0, 999)

          count
        end

        def text!(value, max, field)
          string = value.to_s.squish
          raise Conflict.new("The #{field} is too long.", reason: 'vehicle_visit_invalid', details: { field: field }) if string.length > max

          string.presence
        end

        def revision!(visit, revision)
          return if visit.revision.to_s == revision.to_s

          raise Conflict.new('The visit changed; read it again.', reason: 'vehicle_visit_changed', revision: visit.revision)
        end

        def status!(visit, *allowed)
          return if allowed.include?(visit.status)

          reason = case visit.status
                   when 'paid' then 'vehicle_visit_paid'
                   when 'voided' then 'vehicle_visit_voided'
                   when 'open' then 'vehicle_visit_open'
                   else 'vehicle_visit_closed'
                   end
          raise Conflict.new('The visit cannot do that now.', reason: reason, details: { status: visit.status })
        end

        def audit!(visit, staff, action, metadata = {})
          AuditEntry.record!(store: visit.store, actor: staff, action: action, subject: visit,
                             metadata: { plate: visit.plate, status: visit.status, guest_count: visit.guest_count,
                                         commission_amount: visit.commission_amount&.to_s('F') }.compact.merge(metadata))
        end

        def to_pos(visit, staff)
          visit.to_pos(full_phone: full_details?(visit.store, staff, visit.branch),
                       workspaces_count: visit.workspaces.count)
        end
      end
    end
  end
end
