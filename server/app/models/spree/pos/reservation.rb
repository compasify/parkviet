# frozen_string_literal: true

module Spree
  module Pos
    # A booking of one or more tables or rooms for a party at a time. The
    # tables are held by its ReservationResource rows, which the database
    # keeps from overlapping. Seating the party opens a table order; money
    # taken in advance is a ReservationDeposit (funds kept for the guest,
    # never revenue until it is applied to an order or forfeited).
    class Reservation < Record
      self.table_name = 'spree_pos_reservations'
      has_prefix_id :posresv

      STATUSES = %w[booked seated completed no_show canceled].freeze
      SOURCES = %w[phone walk_in online].freeze
      # Statuses that still hold their tables.
      HOLDING = %w[booked seated].freeze

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :branch, class_name: 'Spree::Pos::Branch'
      belongs_to :customer_profile, class_name: 'Spree::Pos::CustomerProfile', optional: true
      belongs_to :workspace, class_name: 'Spree::Pos::Workspace', optional: true
      belongs_to :created_by, class_name: staff_class_name
      has_many :holds, -> { order(:id) }, class_name: 'Spree::Pos::ReservationResource', dependent: :destroy, inverse_of: :reservation
      has_many :deposits, -> { order(:id) }, class_name: 'Spree::Pos::ReservationDeposit', dependent: :restrict_with_error,
                                             inverse_of: :reservation

      validates :guest_name, presence: true, length: { maximum: 80 }
      validates :phone, length: { maximum: 20 }
      validates :note, length: { maximum: 500 }
      validates :party_size, numericality: { only_integer: true, in: 1..999 }
      validates :status, inclusion: { in: STATUSES }
      validates :source, inclusion: { in: SOURCES }
      validate :ends_after_start

      scope :for_store, ->(store) { where(store_id: store.id) }

      def to_pos
        {
          id: prefixed_id, branch_id: branch.prefixed_id, status: status, source: source,
          guest_name: guest_name, phone: phone, party_size: party_size, note: note,
          starts_at: starts_at.iso8601, ends_at: ends_at.iso8601, revision: revision,
          customer_id: customer_profile&.prefixed_id, workspace_id: workspace&.prefixed_id,
          seated_at: seated_at&.iso8601, canceled_at: canceled_at&.iso8601,
          resources: holds.map { |hold| hold.resource.to_ref },
          deposits: deposits.map(&:to_pos),
          deposit_held: money(deposits.select { |row| row.status == 'held' }.sum(&:amount))
        }
      end

      def bump!
        update!(revision: revision + 1)
      end

      private

      def money(value)
        BigDecimal(value.to_s).to_s('F')
      end

      def ends_after_start
        errors.add(:ends_at, :invalid) if starts_at && ends_at && ends_at <= starts_at
      end
    end
  end
end
