# frozen_string_literal: true

module Spree
  module Pos
    # How a branch pays coach commission: a fixed amount per visit by
    # vehicle type, an amount per guest, or both added up, once the visit
    # reaches the minimum guests and revenue. A rule of one bus operator
    # wins over the branch's general rule (no operator). Closed visits keep
    # a copy of the rule they used, so editing a rule changes no past visit.
    class CommissionRule < Record
      self.table_name = 'spree_pos_commission_rules'
      has_prefix_id :poscommrule

      STATUSES = %w[active archived].freeze

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :branch, class_name: 'Spree::Pos::Branch'
      belongs_to :bus_operator, class_name: 'Spree::Pos::BusOperator', optional: true

      validates :name, length: { maximum: 120 }
      validates :status, inclusion: { in: STATUSES }
      validates :per_guest_amount, :min_revenue, numericality: { greater_than_or_equal_to: 0 }
      validates :min_guests, numericality: { only_integer: true, in: 0..999 }
      validate :vehicle_amounts_are_valid
      validate :something_is_paid
      validate :dates_in_order
      validate :same_store

      scope :for_store, ->(store) { where(store_id: store.id) }
      scope :active, -> { where(status: 'active') }

      # Rules in force on a business date at the branch.
      scope :effective_on, lambda { |date|
        active.where('starts_on IS NULL OR starts_on <= ?', date).where('ends_on IS NULL OR ends_on >= ?', date)
      }

      # The amount for a vehicle type, zero when the rule has none.
      def vehicle_amount(vehicle_type)
        BigDecimal((per_vehicle_amounts || {})[vehicle_type.to_s].to_s.presence || '0')
      end

      # What a closed visit keeps of the rule.
      def to_snapshot
        { id: prefixed_id, name: name, bus_operator_id: bus_operator&.prefixed_id,
          per_vehicle_amounts: VehicleVisit::VEHICLE_TYPES.to_h { |type| [type, vehicle_amount(type).to_s('F')] },
          per_guest_amount: per_guest_amount.to_s('F'), min_guests: min_guests, min_revenue: min_revenue.to_s('F'),
          revision: revision }
      end

      def to_pos
        to_snapshot.merge(branch_id: branch.prefixed_id, bus_operator: bus_operator&.to_ref,
                          starts_on: starts_on&.iso8601, ends_on: ends_on&.iso8601, status: status,
                          updated_at: updated_at&.iso8601)
      end

      private

      def vehicle_amounts_are_valid
        values = per_vehicle_amounts
        unless values.is_a?(Hash) && (values.keys - VehicleVisit::VEHICLE_TYPES).empty? &&
               values.values.all? { |value| value.is_a?(Numeric) && value >= 0 }
          errors.add(:per_vehicle_amounts, :invalid)
        end
      end

      def something_is_paid
        return if per_guest_amount.to_d.positive?
        return if per_vehicle_amounts.is_a?(Hash) && per_vehicle_amounts.values.any? { |value| value.is_a?(Numeric) && value.positive? }

        errors.add(:base, :commission_rule_empty, message: 'pays nothing')
      end

      def dates_in_order
        errors.add(:ends_on, :invalid) if starts_on && ends_on && ends_on < starts_on
      end

      def same_store
        errors.add(:branch, :invalid) if branch && branch.store_id != store_id
        errors.add(:bus_operator, :invalid) if bus_operator && bus_operator.store_id != store_id
      end
    end
  end
end
