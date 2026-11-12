# frozen_string_literal: true

module Spree
  module Pos
    module VehicleVisits
      # Cancels a visit opened by mistake, open or closed but never paid,
      # with a reason. A voided visit pays nothing and leaves the report.
      module Void
        COMMAND = 'vehicle_visit.void'

        module_function

        def call(store:, staff:, key:, visit_id:, reason:)
          visit = Guard.visit!(store, visit_id)
          payload = { 'command' => COMMAND, 'visit_id' => visit.prefixed_id, 'reason' => reason.to_s.squish }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload,
                               authorize: -> { Guard.manage!(store, staff, visit.branch) }) do
            visit.lock!
            Guard.status!(visit, 'open', 'closed')
            text = Guard.text!(reason, 200, 'reason')
            raise Conflict.new('Say why the visit is voided.', reason: 'reason_required') if text.nil?

            visit.update!(status: 'voided', void_reason: text, revision: visit.revision + 1)
            Guard.audit!(visit, staff, COMMAND, reason: text)
            Guard.to_pos(visit, staff)
          end
        end
      end
    end
  end
end
