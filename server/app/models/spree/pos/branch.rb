# frozen_string_literal: true

module Spree
  module Pos
    class Branch < Record
      self.table_name = 'spree_pos_branches'
      has_prefix_id :posbranch

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :stock_location, class_name: 'Spree::StockLocation'
      belongs_to :receiving_stock_location, class_name: 'Spree::StockLocation', optional: true
      has_many :registers, class_name: 'Spree::Pos::Register', dependent: :restrict_with_error
      has_many :memberships, class_name: 'Spree::Pos::StaffMembership', dependent: :restrict_with_error

      before_validation :keep_receiving_note

      validates :name, :code, :timezone, :status, presence: true
      validates :code, uniqueness: { scope: :store_id }, format: { with: /\A[a-z0-9][a-z0-9_-]{0,31}\z/ }
      validates :status, inclusion: { in: %w[active disabled] }
      validates :return_window_days, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 3650 },
                                     allow_nil: true
      # Shift close: a count whose variance exceeds this needs a reason and an
      # approval. Nil means every non-zero variance needs one.
      validates :variance_threshold, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
      validates :timezone, format: { with: /\A[A-Za-z0-9_+\-\/]{1,64}\z/ }
      validate :locations_belong_to_store
      validate :stock_location_fixed_for_open_drafts, on: :update

      scope :for_store, ->(store) { where(store_id: store.id) }

      def disabled?
        status == 'disabled'
      end

      # Returns stay off at a branch until a manager sets a window.
      def returns_enabled?
        !return_window_days.nil?
      end

      def to_pos
        {
          id: prefixed_id,
          name: name,
          code: code,
          timezone: timezone,
          status: status,
          stock_location_id: stock_location.prefixed_id,
          receiving_stock_location_id: receiving_stock_location&.prefixed_id,
          receiving_note: receiving_config['note'],
          return_window_days: return_window_days,
          variance_threshold: variance_threshold&.to_s('F')
        }
      end

      private

      def keep_receiving_note
        source = receiving_config.is_a?(Hash) ? receiving_config : {}
        note = source['note'] || source[:note]
        self.receiving_config = note.present? ? { 'note' => note.to_s[0, 200] } : {}
      end

      # Completing a draft fulfils from the branch's current location, so a change
      # now would silently move every open draft to the new warehouse.
      def stock_location_fixed_for_open_drafts
        return unless will_save_change_to_stock_location_id?
        return unless Workspace.where(branch_id: id, operational_status: %w[editing parked]).exists?

        errors.add(:stock_location, :invalid)
      end

      def locations_belong_to_store
        [stock_location, receiving_stock_location].compact.each do |location|
          errors.add(:stock_location, :invalid) if location.store_id != store_id
        end
      end
    end
  end
end
