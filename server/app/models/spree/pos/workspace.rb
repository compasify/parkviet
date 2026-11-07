# frozen_string_literal: true

module Spree
  module Pos
    class Workspace < Record
      self.table_name = 'spree_pos_workspaces'
      has_prefix_id :posworkspace

      LEASE_TTL = 120.seconds

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :branch, class_name: 'Spree::Pos::Branch'
      belongs_to :register, class_name: 'Spree::Pos::Register', optional: true
      belongs_to :shift, class_name: 'Spree::Pos::Shift'
      belongs_to :order, class_name: 'Spree::Order'
      belongs_to :pos_customer, class_name: 'Spree::Pos::CustomerProfile', optional: true
      belongs_to :lease_holder, class_name: staff_class_name, optional: true

      validates :operational_status, inclusion: { in: %w[editing parked canceled completed] }
      validates :note, length: { maximum: 1000 }
      validate :source_is_immutable

      scope :for_store, ->(store) { where(store_id: store.id) }

      def self.database_now
        connection.select_value('SELECT clock_timestamp()').to_time
      end

      def self.editor_digest(editor_id)
        id = editor_id.to_s
        raise Conflict, 'A valid editor ID is required.' unless id.match?(/\A[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\z/i)

        Digest::SHA256.hexdigest(id)
      end

      def lease_current?(staff, editor_id)
        lease_holder_id == staff.id && lease_editor_digest == self.class.editor_digest(editor_id) &&
          lease_expires_at.present? && lease_expires_at > self.class.database_now
      end

      # Tender statuses that commit the order snapshot: money may have moved or be
      # moving, so items, prices, discounts and the customer must stay as quoted.
      SNAPSHOT_LOCKING_TENDERS = %w[prepared confirmed unknown].freeze

      def snapshot_locked?
        order.completed? || order.payments.exists? ||
          TenderAttempt.where(workspace_id: id, status: SNAPSHOT_LOCKING_TENDERS).exists?
      end

      def ensure_snapshot_editable!
        return unless snapshot_locked?

        raise Conflict.new('Order snapshot is locked by a payment or tender.', revision: revision, reason: 'snapshot_locked')
      end

      def summary(total = true)
        {
          id: prefixed_id,
          branch_id: branch.prefixed_id,
          register_id: register&.prefixed_id,
          shift_id: shift.prefixed_id,
          order_id: order.prefixed_id,
          revision: revision,
          lease_generation: lease_generation,
          operational_status: operational_status,
          payments: operational_status == 'completed' || TenderAttempt.where(workspace_id: id).where.not(status: %w[canceled failed]).exists?,
          note: note
        }
      end

      def customer_pos
        pos_customer&.to_pos || (order.customer && {
          id: nil, name: [order.customer.first_name, order.customer.last_name].compact.join(' ').presence,
          phone: order.customer.phone, email: order.customer.email,
          customer_id: order.customer.prefixed_id, has_account: true
        })
      end

      def to_pos
        order.reload
        discounts = order.discounts.to_a
        intent = Spree::Pos::DiscountIntent.find_by(workspace_id: id)
        sale_lines = Spree::Pos::SaleLine.where(workspace_id: id).index_by(&:line_item_id)
        manual_total = discounts.select { |row| row.kind == 'manual' }.sum(&:amount)
        coupon_promo = order.promotions.detect { |promo| promo.coupon_code? || promo.code.present? }
        coupon_code = order.coupon_code.presence || coupon_promo&.code
        coupon_amount = discounts.select { |row| row.kind == 'promotion' && (coupon_promo.nil? || row.promotion_id == coupon_promo.id) }.sum(&:amount)
        summary.merge(
          customer: customer_pos,
          line_items: order.line_items.to_a.sort_by(&:id).map do |line|
            core = {
              id: line.prefixed_id, variant_id: line.variant.prefixed_id, product_id: line.variant.product.prefixed_id,
              name: line.variant.product.name, sku: line.variant.sku, quantity: line.quantity,
              price: money(line.price), list_price: money(line.variant.price_in(order.currency)&.amount || line.price), amount: money(line.amount),
              net_amount: money(line.amount + line.discounts.to_a.sum(&:amount)),
              discounts: line.discounts.to_a.map { |row|
                { id: row.prefixed_id, kind: row.kind, label: row.label, amount: money(row.amount) }
              }
            }
            sale = sale_lines[line.id]
            item_promotions = line.discounts.to_a.select { |row| row.promotion? && row.promotion_action&.discount_scope == :line_item }
            line_intent = sale&.line_discount_intent
            manual_amount = line_intent ? line_intent.allocations.joins(:discount).sum('spree_discounts.amount') : BigDecimal('0')
            item_amount = item_promotions.sum(&:amount) + manual_amount
            core[:item_net_amount] = money(line.amount + item_amount)
            explicit_item = line_intent&.value_type&.start_with?('item_')
            single_percent = !line_intent && item_promotions.one? && item_promotions.first.value_type == 'percent' && item_promotions.first.value.present?
            core[:item_discount] = {
              amount: money(item_amount), source: line_intent ? 'manual' : (item_promotions.any? ? 'promotion' : 'none'),
              value_type: explicit_item ? line_intent.value_type.delete_prefix('item_') : (single_percent ? 'percent' : 'flat'),
              value: explicit_item ? line_intent.value : (single_percent ? money(item_promotions.first.value) : money(item_amount.abs)),
              labels: item_promotions.map(&:label)
            }
            sale ? core.merge(sale.to_pos(line)) : core.merge(sale_line_id: nil)
          end,
          discount: intent && {
            id: intent.prefixed_id, value_type: intent.value_type, value: intent.value,
            reason: intent.reason, amount: money(intent.allocations.joins(:discount).sum('spree_discounts.amount'))
          },
          coupon: coupon_code && {
            code: coupon_code.to_s.upcase, name: coupon_promo&.name, amount: money(coupon_amount)
          },
          totals: {
            item_total: money(order.item_total), discount_total: money(discounts.sum(&:amount)),
            manual_discount_total: money(manual_total), included_tax_total: money(order.included_tax_total),
            additional_tax_total: money(order.additional_tax_total), total: money(order.total),
            currency: order.currency
          },
          financial: financial_pos
        )
      end

      def financial_pos
        return nil unless defined?(Spree::Pos::TenderAttempt)

        funds = Spree::Pos::ReceivedFunds.where(workspace_id: id).to_a
        attempts = Spree::Pos::TenderAttempt.where(workspace_id: id).order(:id).to_a
        allocations = Spree::Pos::FundsAllocation.where(workspace_id: id, status: 'active')
        allocated = allocations.sum(:amount)
        allocated_funds = Spree::Pos::ReceivedFunds.where(id: allocations.select(:received_funds_id)).to_a
        received_funds = (funds + allocated_funds).uniq(&:id)
        received = received_funds.select { |row| row.status == 'received' }.sum(&:received_net)
        {
          received: money(received), allocated: money(allocated),
          unapplied: money(received_funds.sum { |row| Spree::Pos::FundsBalance.new(row).available }),
          remaining: money([order.total - allocated, 0].max), change_due: money(funds.sum(&:change_amount)),
          attempts: attempts.map(&:to_pos)
        }
      end

      def money(value)
        BigDecimal(value.to_s).to_s('F')
      end

      private

      def source_is_immutable
        return if new_record?

        %w[store_id branch_id register_id shift_id order_id].each do |attribute|
          errors.add(attribute, :invalid) if will_save_change_to_attribute?(attribute)
        end
      end
    end
  end
end
