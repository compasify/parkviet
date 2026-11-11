# frozen_string_literal: true

module Spree
  module Pos
    module Reservations
      # Changes a waiting booking: its guest, party, time or tables. The
      # tables are held again for the new time; a clash is refused.
      module Update
        module_function

        def call(store:, staff:, key:, reservation_id:, attributes:, resource_ids: nil)
          attrs = attributes.to_h.stringify_keys.slice(*Create::FIELDS)
          payload = { 'command' => 'reservation.update', 'reservation_id' => reservation_id.to_s, 'attributes' => attrs,
                      'resource_ids' => resource_ids && Array(resource_ids).map(&:to_s) }
          reservation = Guard.reservation!(store, reservation_id)
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload,
                               authorize: -> { Guard.manage!(store, staff, reservation.branch) }) do
            reservation.lock!
            Guard.booked!(reservation)
            branch = reservation.branch
            before = reservation.to_pos.slice(:starts_at, :ends_at, :party_size, :resources)
            resources = resource_ids.nil? ? reservation.holds.includes(:resource).map(&:resource) : Guard.resources!(branch, resource_ids)
            starts_at, ends_at = Guard.period!(branch, attrs['starts_at'] || reservation.starts_at.iso8601,
                                               attrs['ends_at'] || (attrs['starts_at'] ? nil : reservation.ends_at.iso8601))
            party = attrs.key?('party_size') ? Guard.party_size!(attrs['party_size']) : reservation.party_size
            Guard.capacity!(resources, party)
            old = reservation.holds.includes(:resource).map(&:resource)
            reservation.holds.delete_all
            reservation.holds.reset
            reservation.assign_attributes(starts_at: starts_at, ends_at: ends_at, party_size: party)
            reservation.guest_name = Guard.text!(attrs['guest_name'], 80, 'name') || reservation.guest_name if attrs.key?('guest_name')
            reservation.phone = Guard.text!(attrs['phone'], 20, 'phone') if attrs.key?('phone')
            reservation.note = Guard.text!(attrs['note'], 500, 'note') if attrs.key?('note')
            reservation.customer_profile = Guard.customer!(store, attrs['customer_id']) if attrs.key?('customer_id')
            reservation.revision += 1
            reservation.save!
            Guard.hold!(reservation, resources, starts_at, ends_at)
            AuditEntry.record!(store: store, actor: staff, action: 'reservation.update', subject: reservation,
                               metadata: { before: before, after: reservation.reload.to_pos.slice(:starts_at, :ends_at, :party_size, :resources) })
            (old + resources).uniq(&:id).each do |resource|
              Realtime.publish(branch, 'resource.updated', id: resource.prefixed_id, refs: { reservation_id: reservation.prefixed_id })
            end
            reservation.to_pos
          end
        end
      end
    end
  end
end
