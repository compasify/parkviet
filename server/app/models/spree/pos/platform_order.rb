# frozen_string_literal: true

module Spree
  module Pos
    # A delivery platform's order, entered by hand at the counter. It names
    # the POS sale (the workspace) that carries the lines and the money, and
    # keeps what the platform owes for it: the gross the sale settled with a
    # `platform_receivable` tender, the commission (the branch rate's
    # estimate until settlement records the platform's figure) and the net
    # the platform pays. Settling changes none of the sale's amounts.
    class PlatformOrder < Record
      self.table_name = 'spree_pos_platform_orders'
      has_prefix_id :posplatorder

      STATUSES = %w[accepted ready completed canceled].freeze
      OPEN = %w[accepted ready].freeze
      REF_FORMAT = /\A[A-Za-z0-9][A-Za-z0-9._-]{0,63}\z/
      PICKUP_MAX = 32

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :branch, class_name: 'Spree::Pos::Branch'
      belongs_to :workspace, class_name: 'Spree::Pos::Workspace'
      belongs_to :entered_by, class_name: staff_class_name
      belongs_to :settled_by, class_name: staff_class_name, optional: true

      validates :platform, inclusion: { in: PlatformSetting::PLATFORMS }
      validates :status, inclusion: { in: STATUSES }
      validates :platform_order_ref, format: { with: REF_FORMAT }
      validates :pickup_code, length: { maximum: PICKUP_MAX }
      validates :currency, presence: true
      validates :cancel_reason, length: { maximum: 200 }
      validates :settlement_reference, length: { maximum: 120 }

      scope :for_store, ->(store) { where(store_id: store.id) }
      scope :unsettled, -> { where(status: 'completed', settled_at: nil) }

      def open?
        OPEN.include?(status)
      end

      # The commission at the branch's rate, rounded to the currency.
      def self.estimate(gross, rate, currency)
        exponent = ::Money::Currency.find(currency.to_s)&.exponent || 2
        (gross * rate / 100).round(exponent)
      end

      # Amounts from a gross, at the order's own rate.
      def assign_gross(gross)
        commission = self.class.estimate(gross, commission_rate, currency)
        assign_attributes(gross_amount: gross, commission_amount: commission, net_amount: gross - commission)
      end

      def to_pos
        {
          id: prefixed_id, workspace_id: workspace.prefixed_id, order_id: workspace.order.prefixed_id,
          order_number: workspace.order_number, business_date: workspace.business_date&.iso8601,
          platform: platform, platform_order_ref: platform_order_ref, pickup_code: pickup_code, status: status,
          gross_amount: money(gross_amount), commission_rate: commission_rate.to_s('F'),
          commission_amount: money(commission_amount), net_amount: money(net_amount), currency: currency,
          entered_at: created_at&.iso8601, ready_at: ready_at&.iso8601, completed_at: completed_at&.iso8601,
          canceled_at: canceled_at&.iso8601, cancel_reason: cancel_reason, settled_at: settled_at&.iso8601,
          settlement_reference: settlement_reference, items: items_pos
        }
      end

      private

      def items_pos
        SaleLine.where(workspace_id: workspace_id).includes(:line_modifiers, variant: :product).order(:id).map do |line|
          { name: line.variant.product.name, quantity: line.sale_quantity.to_s('F'),
            modifiers: line.line_modifiers.map(&:name), note: line.note.presence }
        end
      end

      def money(value)
        BigDecimal(value.to_s).to_s('F')
      end
    end
  end
end
