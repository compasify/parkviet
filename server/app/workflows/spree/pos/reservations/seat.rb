# frozen_string_literal: true

module Spree
  module Pos
    module Reservations
      # The party arrived: a dine-in order opens on the first table the
      # booking holds (Tables::Open, the same opening as any table), the
      # booking becomes seated and points at that order. Its deposits are
      # applied when the order is paid (ApplyDeposit). When the order is
      # completed the booking is completed and lets its tables go (finish!).
      module Seat
        module_function

        def call(store:, staff:, key:, reservation_id:, editor_id:, guest_count: nil)
          payload = { 'command' => 'reservation.seat', 'reservation_id' => reservation_id.to_s,
                      'editor_digest' => Workspace.editor_digest(editor_id), 'guest_count' => guest_count&.to_s }
          reservation = Guard.reservation!(store, reservation_id)
          branch = reservation.branch
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload,
                               authorize: -> { Tables::Guard.serve!(store, staff, branch) }) do
            reservation.lock!
            Guard.booked!(reservation)
            hold = reservation.holds.order(:id).first || raise(Conflict.new('This booking holds no table.', reason: 'reservation_resources_invalid'))
            opened = Tables::Open.call(store: store, staff: staff, key: "#{key}:open", editor_id: editor_id,
                                       branch_id: branch.prefixed_id, resource_id: hold.resource.prefixed_id,
                                       guest_count: guest_count.presence || reservation.party_size)
            workspace = Workspace.find_by_prefix_id(opened['id'])
            reservation.update!(status: 'seated', workspace: workspace, seated_at: Time.current, revision: reservation.revision + 1)
            AuditEntry.record!(store: store, actor: staff, action: 'reservation.seat', subject: reservation,
                               metadata: { workspace_id: workspace.prefixed_id, resource_id: hold.resource.prefixed_id })
            Guard.announce!(branch, reservation)
            { 'reservation' => reservation.reload.to_pos, 'workspace' => opened }
          end
        end

        # From Workspaces::Complete: the seated booking of a paid order is done.
        def finish!(workspace)
          Reservation.where(workspace_id: workspace.id, status: 'seated').find_each do |reservation|
            Guard.release!(reservation)
            reservation.update!(status: 'completed', revision: reservation.revision + 1)
          end
        end
      end
    end
  end
end
