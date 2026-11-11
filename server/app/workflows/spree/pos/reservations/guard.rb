# frozen_string_literal: true

module Spree
  module Pos
    module Reservations
      # Shared rules of booking commands: who books at a branch, which tables
      # a booking may hold, and holding them for a time without overlaps.
      module Guard
        MODULE = 'fnb.reservations'
        MAX_DAYS_AHEAD = 366

        module_function

        # Booking, changing, cancelling and seating: pos.reservation.manage,
        # or store administration.
        def manage!(store, staff, branch)
          access = AccessPolicy.new(store: store, staff: staff)
          raise CanCan::AccessDenied if branch.disabled?
          return if access.permission?('write_pos_topology') || access.allows?(branch, Capabilities::RESERVATION_MANAGE)

          raise CanCan::AccessDenied
        end

        def read!(store, staff, branch)
          Resources::Guard.read!(store, staff, branch)
        end

        def branch!(store, branch_id)
          Branch.locate(Branch.for_store(store), branch_id) || raise(ActiveRecord::RecordNotFound)
        end

        def reservation!(store, reservation_id)
          Reservation.locate(Reservation.for_store(store), reservation_id) || raise(ActiveRecord::RecordNotFound)
        end

        def booked!(reservation)
          return if reservation.status == 'booked'

          raise Conflict.new('This booking is no longer waiting.', revision: reservation.revision, reason: 'reservation_not_booked',
                                                                   details: { status: reservation.status })
        end

        # Active tables or rooms of the branch, in the order sent.
        def resources!(branch, resource_ids)
          ids = Array(resource_ids).map(&:to_s).uniq
          raise Conflict.new('Choose at least one table.', reason: 'reservation_resources_invalid') unless ids.size.between?(1, 10)

          ids.map do |id|
            resource = Resource.locate(Resource.where(branch_id: branch.id), id)
            raise ActiveRecord::RecordNotFound if resource.nil?
            raise Conflict.new('This table is archived.', reason: 'table_archived') unless resource.active?

            resource
          end
        end

        # [starts_at, ends_at]: ISO times; the end defaults to the branch's booking length.
        def period!(branch, starts_at, ends_at)
          start = parse!(starts_at)
          finish = ends_at.present? ? parse!(ends_at) : start + branch.reservation_duration_minutes.minutes
          raise Conflict.new('A booking ends after it starts.', reason: 'reservation_time_invalid') unless finish > start
          raise Conflict.new('A booking lasts at most a day.', reason: 'reservation_time_invalid') if finish - start > 1.day

          now = Workspace.database_now
          raise Conflict.new('This time has already passed.', reason: 'reservation_time_invalid') if finish <= now
          raise Conflict.new('This time is too far ahead.', reason: 'reservation_time_invalid') if start > now + MAX_DAYS_AHEAD.days

          [start, finish]
        end

        def parse!(value)
          Time.iso8601(value.to_s)
        rescue ArgumentError
          raise Conflict.new('The booking time is invalid.', reason: 'reservation_time_invalid')
        end

        # A party larger than the tables can seat is refused when every
        # table has a known capacity.
        def capacity!(resources, party_size)
          capacities = resources.map(&:capacity)
          return if capacities.any?(&:zero?) || capacities.sum >= party_size

          raise Conflict.new('These tables are too small for the party.', reason: 'reservation_capacity',
                                                                          details: { capacity: capacities.sum })
        end

        # Holds every table for the period; another active hold overlapping
        # it is refused, first by a read with a clear answer and in the end by
        # the database's exclusion constraint.
        def hold!(reservation, resources, starts_at, ends_at)
          resources.sort_by(&:id).each(&:lock!)
          clash = ReservationResource.overlapping(starts_at, ends_at).where(resource_id: resources.map(&:id)).
                  where.not(reservation_id: reservation.id).includes(:resource).to_a
          overlap!(clash.map { |row| row.resource.prefixed_id }) if clash.any?

          resources.each do |resource|
            ReservationResource.transaction(requires_new: true) do
              reservation.holds.create!(resource: resource, starts_at: starts_at, ends_at: ends_at, active: true)
            end
          end
        rescue ActiveRecord::ExclusionViolation
          overlap!(resources.map(&:prefixed_id))
        end

        def overlap!(resource_ids)
          raise Conflict.new('A table is already booked for this time.', reason: 'reservation_overlap',
                                                                         details: { resource_ids: resource_ids.uniq })
        end

        # Refunding or forfeiting a deposit: an approver needs nothing more;
        # anyone else brings an approval of this booking as it is now, for
        # this amount. Returns the consumed approval, or nil.
        def approve!(reservation, staff, action, amount, approval_id)
          policy = AccessPolicy.new(store: reservation.store, staff: staff)
          return nil if policy.allows?(reservation.branch, Capabilities::APPROVE)

          message = 'Deposit approval is required.'
          raise Conflict.new(message, reason: 'approval_required', details: { action: action }) if approval_id.blank?

          approval = Approval.locate(Approval.for_store(reservation.store).where(branch_id: reservation.branch_id), approval_id)
          raise Conflict.new(message, reason: 'approval_required', details: { action: action }) if approval.nil?

          approval.consume!(action: action, amount: amount, currency: reservation.store.default_currency,
                            revision: reservation.revision, subject: reservation, requester: staff)
          AuditEntry.record!(store: reservation.store, actor: staff, action: 'approval.consume', subject: approval,
                             metadata: { approval_action: action, approver_id: approval.approver.prefixed_id, amount: amount.to_s('F') })
          approval
        end

        # Who may ask for a deposit to be resolved: the people who book, and cashiers.
        def resolve!(store, staff, branch)
          access = AccessPolicy.new(store: store, staff: staff)
          raise CanCan::AccessDenied if branch.disabled?
          return if [Capabilities::RESERVATION_MANAGE, Capabilities::OPEN_SHIFT].any? { |key| access.allows?(branch, key) }

          raise CanCan::AccessDenied
        end

        def deposit!(store, deposit_id)
          deposit = ReservationDeposit.locate(ReservationDeposit.joins(:reservation).where(spree_pos_reservations: { store_id: store.id }),
                                              deposit_id)
          deposit || raise(ActiveRecord::RecordNotFound)
        end

        def release!(reservation)
          reservation.holds.update_all(active: false, updated_at: Time.current)
        end

        def announce!(branch, reservation)
          reservation.holds.includes(:resource).each do |hold|
            Realtime.publish(branch, 'resource.updated', id: hold.resource.prefixed_id, refs: { reservation_id: reservation.prefixed_id })
          end
        end

        def text!(value, max, field)
          string = value.to_s.strip
          raise Conflict.new("The #{field} is too long.", reason: 'reservation_invalid') if string.length > max

          string.presence
        end

        def party_size!(value)
          count = value.is_a?(Integer) ? value : (Integer(value.to_s, 10) rescue nil) # rubocop:disable Style/RescueModifier
          raise Conflict.new('The party size is invalid.', reason: 'reservation_invalid') unless count&.between?(1, 999)

          count
        end

        def customer!(store, customer_id)
          return nil if customer_id.blank?

          CustomerProfile.locate(CustomerProfile.where(store_id: store.id), customer_id) || raise(ActiveRecord::RecordNotFound)
        end
      end
    end
  end
end
