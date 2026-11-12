# frozen_string_literal: true

module Spree
  module Pos
    class Branch < Record
      self.table_name = 'spree_pos_branches'
      has_prefix_id :posbranch

      # Shared with BusinessProfiles, which checks profile branch defaults
      # against the same rules without touching the database.
      LOT_SELECTIONS = %w[fefo cashier_pick].freeze
      RETURN_WINDOW_DAYS = (0..3650)
      PROFILE_KEY_FORMAT = /\A[a-z_]{2,40}\z/

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :stock_location, class_name: 'Spree::StockLocation'
      belongs_to :receiving_stock_location, class_name: 'Spree::StockLocation', optional: true
      # Where cup labels print (CupLabels::Issue); size and fields in `cup_label_settings`.
      belongs_to :cup_label_printer, class_name: 'Spree::Pos::Printer', optional: true
      # Table orders are booked on this register's open shift.
      belongs_to :table_register, class_name: 'Spree::Pos::Register', optional: true
      # Tax of the service charge; nil taxes it under the store's default category.
      belongs_to :service_charge_tax_category, class_name: 'Spree::TaxCategory', optional: true
      # The service sold when a booking's deposit is kept.
      belongs_to :reservation_fee_product, class_name: 'Spree::Product', optional: true
      has_many :registers, class_name: 'Spree::Pos::Register', dependent: :restrict_with_error
      has_many :memberships, class_name: 'Spree::Pos::StaffMembership', dependent: :restrict_with_error

      before_validation :keep_receiving_note

      validates :name, :code, :timezone, :status, presence: true
      validates :code, uniqueness: { scope: :store_id }, format: { with: /\A[a-z0-9][a-z0-9_-]{0,31}\z/ }
      validates :status, inclusion: { in: %w[active disabled] }
      validates :return_window_days, numericality: { only_integer: true, greater_than_or_equal_to: RETURN_WINDOW_DAYS.min,
                                                     less_than_or_equal_to: RETURN_WINDOW_DAYS.max },
                                     allow_nil: true
      validates :lot_selection, inclusion: { in: LOT_SELECTIONS }
      validates :adjustment_approval_threshold, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
      # The industry profile the branch was set up with. Code never checks
      # it (modules decide behaviour), and a key the catalog no longer lists
      # is kept as it is.
      validates :profile_key, format: { with: PROFILE_KEY_FORMAT }
      validates :profile_version, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
      # Shift close: a count whose variance exceeds this needs a reason and an
      # approval. Nil means every non-zero variance needs one.
      validates :variance_threshold, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
      # Customer display freshness window in seconds; nil uses the default.
      # Must be accepted in device UAT before a branch relies on the display.
      validates :display_freshness_ttl_seconds, numericality: { only_integer: true, in: 5..120 }, allow_nil: true
      validates :timezone, format: { with: /\A[A-Za-z0-9_+\-\/]{1,64}\z/ }
      validates :business_day_cutoff, presence: true
      validates :staff_session_idle_minutes, numericality: { only_integer: true, in: 5..240 }
      # When orders reach the kitchen: as the sale completes, or when the
      # cashier sends them (Kitchen::Send).
      validates :kitchen_send_trigger, inclusion: { in: %w[on_complete manual] }
      # Percent of the items after discounts; nil means no service charge.
      validates :service_charge_rate, numericality: { greater_than: 0, less_than_or_equal_to: 50 }, allow_nil: true
      # How guests' orders from the table QR are taken: each approved by staff,
      # or within the limits added and sent to the kitchen by themselves.
      QR_ORDER_MODES = %w[staff_approval direct_to_kitchen].freeze
      validates :qr_order_mode, inclusion: { in: QR_ORDER_MODES }
      validates :qr_order_auto_limit, numericality: { greater_than: 0 }, allow_nil: true
      validates :qr_order_auto_max_items, numericality: { only_integer: true, in: 1..50 }
      validates :kiosk_idle_seconds, numericality: { only_integer: true, in: 15..600 }
      validates :kiosk_qr_timeout_seconds, numericality: { only_integer: true, in: 60..900 }
      validate :void_reasons_are_codes
      validate :locations_belong_to_store
      validate :table_settings_of_store
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
          variance_threshold: variance_threshold&.to_s('F'),
          display_freshness_ttl_seconds: display_freshness_ttl_seconds,
          lot_selection: lot_selection, adjustment_approval_threshold: adjustment_approval_threshold,
          profile_key: profile_key, profile_version: profile_version,
          business_day_cutoff: cutoff_label,
          staff_session_idle_minutes: staff_session_idle_minutes,
          kitchen_send_trigger: kitchen_send_trigger,
          void_reasons: void_reasons
        }
      end

      private

      def cutoff_label
        value = business_day_cutoff
        return '04:00' if value.blank?
        return value.strftime('%H:%M') if value.respond_to?(:strftime)

        value.to_s[/\d{2}:\d{2}/] || '04:00'
      end

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

      # Why a sent item may be taken back here: short codes the screens label.
      VOID_REASON_FORMAT = /\A[a-z0-9_]{1,40}\z/
      VOID_REASONS_MAX = 20

      def void_reasons_are_codes
        reasons = void_reasons
        return if reasons.is_a?(Array) && reasons.size <= VOID_REASONS_MAX && reasons.uniq.size == reasons.size &&
                  reasons.all? { |code| code.is_a?(String) && code.match?(VOID_REASON_FORMAT) }

        errors.add(:void_reasons, :invalid)
      end

      def table_settings_of_store
        errors.add(:table_register, :invalid) if table_register && table_register.branch_id != id
        if service_charge_tax_category && service_charge_tax_category.respond_to?(:store_id) &&
           service_charge_tax_category.store_id.present? && service_charge_tax_category.store_id != store_id
          errors.add(:service_charge_tax_category, :invalid)
        end
        modes = service_charge_applies_to
        errors.add(:service_charge_applies_to, :invalid) unless modes.is_a?(Array) && (modes - Workspace::SERVICE_MODES).empty? && modes.uniq.size == modes.size
      end

      def locations_belong_to_store
        [stock_location, receiving_stock_location].compact.each do |location|
          errors.add(:stock_location, :invalid) if location.store_id != store_id
        end
      end
    end
  end
end
