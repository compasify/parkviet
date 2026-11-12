# frozen_string_literal: true

module Spree
  module Pos
    module VehicleVisits
      # A branch's coach visit settings: how many minutes a visit stays open
      # before it closes by itself.
      module Settings
        COMMAND = 'vehicle_visit.settings'
        WINDOW = (5..1440)

        module_function

        def to_pos(branch)
          { branch_id: branch.prefixed_id, visit_window_minutes: branch.vehicle_visit_window_minutes }
        end

        def call(store:, staff:, key:, branch_id:, visit_window_minutes:)
          branch = Guard.branch!(store, branch_id)
          payload = { 'command' => COMMAND, 'branch_id' => branch.prefixed_id, 'visit_window_minutes' => visit_window_minutes.to_s }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: -> { Guard.manage!(store, staff, branch) }) do
            minutes = Integer(visit_window_minutes.to_s, 10) rescue nil # rubocop:disable Style/RescueModifier
            raise Conflict.new('The minutes are invalid.', reason: 'vehicle_visit_window_invalid') unless minutes && WINDOW.cover?(minutes)

            branch.lock!
            before = branch.vehicle_visit_window_minutes
            branch.update!(vehicle_visit_window_minutes: minutes)
            AuditEntry.record!(store: store, actor: staff, action: COMMAND, subject: branch, metadata: { from: before, to: minutes })
            to_pos(branch)
          end
        end
      end
    end
  end
end
