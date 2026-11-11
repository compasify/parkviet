# frozen_string_literal: true

module Spree
  module Pos
    module Reservations
      # Which tables of a branch can take a party for a time: active, not
      # out of service or being cleaned, seating at least the party (a
      # capacity of 0 means unknown and is offered last), and held by no
      # other booking that overlaps the time. `except` leaves one booking
      # out, so changing a booking can keep its own tables. Two queries.
      module Availability
        module_function

        def call(branch:, starts_at:, ends_at:, party_size: 1, except: nil)
          busy = ReservationResource.overlapping(starts_at, ends_at).joins(:reservation).
                 where(spree_pos_reservations: { branch_id: branch.id })
          busy = busy.where.not(reservation_id: except.id) if except
          taken = busy.distinct.pluck(:resource_id)
          rows = Resource.active.where(branch_id: branch.id, manual_status: 'available').where.not(id: taken).
                 includes(:area).order(:position, :id).to_a
          fitting = rows.select { |resource| resource.capacity.zero? || resource.capacity >= party_size }
          fitting.sort_by { |resource| [resource.capacity.zero? ? 1 : 0, resource.capacity, resource.position, resource.id] }.map do |resource|
            resource.to_ref.merge(capacity: resource.capacity)
          end
        end
      end
    end
  end
end
