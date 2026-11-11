# frozen_string_literal: true

module Spree
  module Pos
    module Reservations
      # Books tables or rooms of a branch for a party at a time. The tables
      # are held for the whole booking; another booking overlapping one of
      # them is refused (Guard.hold!).
      module Create
        FIELDS = %w[guest_name phone party_size starts_at ends_at source note customer_id].freeze

        module_function

        def call(store:, staff:, key:, branch_id:, resource_ids:, attributes:)
          attrs = attributes.to_h.stringify_keys.slice(*FIELDS)
          payload = { 'command' => 'reservation.create', 'branch_id' => branch_id.to_s,
                      'resource_ids' => Array(resource_ids).map(&:to_s), 'attributes' => attrs }
          branch = Guard.branch!(store, branch_id)
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload,
                               authorize: -> { Guard.manage!(store, staff, branch) }) do
            ModulePolicy.require!(branch, Guard::MODULE)
            resources = Guard.resources!(branch, resource_ids)
            starts_at, ends_at = Guard.period!(branch, attrs['starts_at'], attrs['ends_at'])
            party = Guard.party_size!(attrs['party_size'])
            Guard.capacity!(resources, party)
            reservation = Reservation.create!(
              store: store, branch: branch, created_by: staff, status: 'booked',
              guest_name: Guard.text!(attrs['guest_name'], 80, 'name') || raise(Conflict.new('A name is required.', reason: 'reservation_invalid')),
              phone: Guard.text!(attrs['phone'], 20, 'phone'), party_size: party, starts_at: starts_at, ends_at: ends_at,
              source: Reservation::SOURCES.include?(attrs['source'].to_s) ? attrs['source'].to_s : 'phone',
              note: Guard.text!(attrs['note'], 500, 'note'), customer_profile: Guard.customer!(store, attrs['customer_id'])
            )
            Guard.hold!(reservation, resources, starts_at, ends_at)
            AuditEntry.record!(store: store, actor: staff, action: 'reservation.create', subject: reservation,
                               metadata: { resource_ids: resources.map(&:prefixed_id), starts_at: starts_at.iso8601,
                                           ends_at: ends_at.iso8601, party_size: party })
            Guard.announce!(branch, reservation)
            reservation.reload.to_pos
          end
        end
      end
    end
  end
end
