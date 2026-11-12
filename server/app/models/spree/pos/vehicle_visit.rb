# frozen_string_literal: true

module Spree
  module Pos
    # One coach stopping at a rest stop: its plate, operator, type, driver
    # and guests. Orders sold to its guests point at it until they complete.
    #
    #   open -> closed (commission worked out and kept) -> paid
    #   open | closed -> voided
    #
    # The commission is the stop's expense, paid to the driver: it never
    # changes an order's total or its e-invoice. The driver's phone is
    # personal data, shown in full only to people managing visits.
    class VehicleVisit < Record
      self.table_name = 'spree_pos_vehicle_visits'
      has_prefix_id :posvisit

      VEHICLE_TYPES = %w[seat_16 seat_29 seat_45 other].freeze
      STATUSES = %w[open closed paid voided].freeze
      PAYOUT_METHODS = %w[cash transfer].freeze
      PLATE_MAX = 20

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :branch, class_name: 'Spree::Pos::Branch'
      belongs_to :bus_operator, class_name: 'Spree::Pos::BusOperator', optional: true
      belongs_to :opened_by, class_name: staff_class_name
      belongs_to :closed_by, class_name: staff_class_name, optional: true
      belongs_to :paid_by, class_name: staff_class_name, optional: true
      belongs_to :cash_movement_request, class_name: 'Spree::Pos::CashMovementRequest', optional: true
      has_many :workspaces, class_name: 'Spree::Pos::Workspace', dependent: :restrict_with_error

      validates :plate, presence: true, length: { maximum: PLATE_MAX }
      validates :vehicle_type, inclusion: { in: VEHICLE_TYPES }
      validates :status, inclusion: { in: STATUSES }
      validates :payout_method, inclusion: { in: PAYOUT_METHODS }, allow_nil: true
      validates :guest_count, numericality: { only_integer: true, in: 0..999 }
      validates :driver_name, length: { maximum: 120 }
      validates :driver_phone, length: { maximum: 32 }
      validates :transfer_reference, length: { maximum: 120 }
      validates :note, length: { maximum: 500 }
      validates :void_reason, length: { maximum: 200 }
      validates :business_date, :arrived_at, :closes_at, :currency, presence: true
      validate :same_store

      scope :for_store, ->(store) { where(store_id: store.id) }
      scope :open_now, -> { where(status: 'open') }

      # "51b 123.45" and "51B-12345" are the same coach.
      def self.normalize_plate(value)
        value.to_s.upcase.gsub(/[^A-Z0-9]/, '').presence
      end

      def open?
        status == 'open'
      end

      def closed?
        status == 'closed'
      end

      def paid?
        status == 'paid'
      end

      # A cash payout waits for its second person; a canceled one may be
      # made again.
      def payout_status
        return nil unless paid?
        return 'paid' if payout_method == 'transfer'

        cash_movement_request.status == 'confirmed' ? 'paid' : cash_movement_request.status
      end

      def bump!
        update!(revision: revision + 1)
      end

      def to_ref
        { id: prefixed_id, plate: plate, status: status }
      end

      # `full_phone` for people who manage visits; others see the last digits.
      def to_pos(full_phone: false, workspaces_count: nil)
        {
          id: prefixed_id, branch_id: branch.prefixed_id, bus_operator: bus_operator&.to_ref, plate: plate,
          vehicle_type: vehicle_type, driver_name: driver_name,
          driver_phone: full_phone ? driver_phone : driver_phone && Masking.reference(driver_phone),
          guest_count: guest_count, arrived_at: arrived_at.iso8601, closes_at: closes_at.iso8601,
          closed_at: closed_at&.iso8601, auto_closed: auto_closed, status: status, business_date: business_date.iso8601,
          opened_by_name: StaffName.call(opened_by), revenue_amount: revenue_amount&.to_s('F'),
          commission_amount: commission_amount&.to_s('F'), currency: currency, commission: commission_snapshot,
          paid_at: paid_at&.iso8601, payout_method: payout_method, payout_status: payout_status,
          cash_movement_request_id: cash_movement_request&.prefixed_id,
          transfer_reference: transfer_reference && (full_phone ? transfer_reference : Masking.reference(transfer_reference)),
          void_reason: void_reason, note: note, revision: revision, workspaces_count: workspaces_count
        }
      end

      private

      def same_store
        errors.add(:branch, :invalid) if branch && branch.store_id != store_id
        errors.add(:bus_operator, :invalid) if bus_operator && bus_operator.store_id != store_id
      end
    end
  end
end
