# frozen_string_literal: true

module Spree
  module Pos
    # A place at a branch where menu items are made: a kitchen, a bar, or the
    # pass that checks plates. It shows its tickets on a kitchen screen, prints
    # them on its printer, or both. One station of a branch is the default, the
    # one an item goes to when no route names it.
    class KitchenStation < Record
      self.table_name = 'spree_pos_kitchen_stations'
      has_prefix_id :poskstation

      KINDS = %w[prep bar expo].freeze
      MAX_MINUTES = 240

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :branch, class_name: 'Spree::Pos::Branch'
      belongs_to :printer, class_name: 'Spree::Pos::Printer', optional: true
      has_many :station_routes, class_name: 'Spree::Pos::StationRoute', dependent: :delete_all
      has_many :kitchen_tickets, class_name: 'Spree::Pos::KitchenTicket', dependent: :restrict_with_error

      validates :name, presence: true, length: { maximum: 80 }, uniqueness: { scope: :branch_id }
      validates :kind, inclusion: { in: KINDS }
      validates :warn_after_minutes, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: MAX_MINUTES }
      validates :late_after_minutes, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: MAX_MINUTES }
      validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
      validate :late_after_warn
      validate :same_branch

      scope :for_store, ->(store) { where(store_id: store.id) }
      scope :active, -> { where(active: true) }
      scope :ordered, -> { order(:position, :id) }

      def to_pos
        {
          id: prefixed_id, branch_id: branch.prefixed_id, name: name, kind: kind, printer_id: printer&.prefixed_id,
          printer_name: printer&.name, kds_enabled: kds_enabled, is_default: is_default,
          warn_after_minutes: warn_after_minutes, late_after_minutes: late_after_minutes, position: position, active: active
        }
      end

      private

      def late_after_warn
        return if warn_after_minutes.nil? || late_after_minutes.nil? || late_after_minutes >= warn_after_minutes

        errors.add(:late_after_minutes, :greater_than_or_equal_to, count: warn_after_minutes)
      end

      def same_branch
        errors.add(:branch, :invalid) if branch && branch.store_id != store_id
        errors.add(:printer, :invalid) if printer && printer.branch_id != branch_id
      end
    end
  end
end
