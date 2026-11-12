# frozen_string_literal: true

module Spree
  module Pos
    class Workspace < Record
      self.table_name = 'spree_pos_workspaces'
      has_prefix_id :posworkspace

      LEASE_TTL = 120.seconds
      # Where the sale came from; `counter` unless the cashier picks another.
      # Delivery platforms are set only by entering a platform order.
      PLATFORM_SOURCES = %w[grabfood shopeefood].freeze
      PICKABLE_SOURCES = %w[counter facebook zalo other].freeze
      ORDER_SOURCES = (PICKABLE_SOURCES + PLATFORM_SOURCES).freeze
      # How the sale is served. Retail stays `counter`; F&B modules read the value.
      SERVICE_MODES = %w[counter dine_in takeaway delivery tab timed].freeze
      # The name the counter calls out with the call number.
      GUEST_NAME_MAX = 60
      # Served at a table or room: these modes may point at a resource.
      RESOURCE_MODES = %w[dine_in timed].freeze
      OPEN_STATUSES = %w[editing parked].freeze

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :branch, class_name: 'Spree::Pos::Branch'
      belongs_to :register, class_name: 'Spree::Pos::Register', optional: true
      belongs_to :shift, class_name: 'Spree::Pos::Shift'
      belongs_to :order, class_name: 'Spree::Order'
      belongs_to :pos_customer, class_name: 'Spree::Pos::CustomerProfile', optional: true
      belongs_to :lease_holder, class_name: staff_class_name, optional: true
      # The table or room the order is served at. Moving tables changes it.
      belongs_to :resource, class_name: 'Spree::Pos::Resource', optional: true
      # The coach visit of a rest stop whose guests this order was sold to.
      belongs_to :vehicle_visit, class_name: 'Spree::Pos::VehicleVisit', optional: true

      validates :operational_status, inclusion: { in: %w[editing parked canceled completed] }
      validates :note, length: { maximum: 1000 }
      validates :order_source, inclusion: { in: ORDER_SOURCES }
      validates :service_mode, inclusion: { in: SERVICE_MODES }
      validates :business_date, presence: true
      validates :guest_name, length: { maximum: GUEST_NAME_MAX }
      validates :order_number, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
      validates :guest_count, numericality: { only_integer: true, in: 0..999 }, allow_nil: true
      validates :table_label, length: { maximum: 4 }
      # Who a bar tab is for ("Anh Nam áo xanh"); open tabs are found by it.
      TAB_NAME_MAX = 60
      validates :tab_name, length: { maximum: TAB_NAME_MAX }
      validate :resource_fits_order
      validate :source_is_immutable
      validate :order_number_is_kept
      validate :business_date_is_fixed
      before_validation :assign_business_date, on: :create

      scope :for_store, ->(store) { where(store_id: store.id) }

      def self.database_now
        connection.select_value('SELECT clock_timestamp()').to_time
      end

      # Clock for a business date: the database clock, the same one leases use.
      # A separate name so specs can freeze it without freezing leases.
      def self.business_now
        database_now
      end

      def self.editor_digest(editor_id)
        id = editor_id.to_s
        raise Conflict, 'A valid editor ID is required.' unless id.match?(/\A[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\z/i)

        Digest::SHA256.hexdigest(id)
      end

      # Served by many hands: an order at a table, or a bar tab. Waiters and
      # other counters add to it without its lease.
      def shared_service?
        resource_id.present? || service_mode == 'tab'
      end

      def lease_current?(staff, editor_id)
        lease_holder_id == staff.id && lease_editor_digest == self.class.editor_digest(editor_id) &&
          lease_expires_at.present? && lease_expires_at > self.class.database_now
      end

      # Tender statuses that commit the order snapshot: money may have moved or be
      # moving, so items, prices, discounts and the customer must stay as quoted.
      SNAPSHOT_LOCKING_TENDERS = %w[prepared confirmed unknown].freeze

      def snapshot_locked?
        order.completed? || order.payments.where.not(status: %w[void invalid failed]).exists? ||
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
          note: note,
          order_source: order_source,
          service_mode: service_mode,
          business_date: business_date&.iso8601,
          order_number: order_number,
          guest_name: guest_name,
          resource: resource&.to_ref,
          guest_count: guest_count,
          table_label: table_label,
          tab_name: tab_name,
          vehicle_visit_id: VehicleVisit.prefixed_for(vehicle_visit_id),
          opened_at: created_at&.iso8601,
          total: money(order.total)
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
        sale_lines = Spree::Pos::SaleLine.where(workspace_id: id).includes(:line_discount_intent, :added_by, line_modifiers: :modifier_option, line_components: :variant).
                     index_by(&:line_item_id)
        # Every line reads its variant, product, base price and discounts; load
        # them in a few queries instead of five or six per line.
        lines = order.line_items.includes(variant: %i[product prices], discounts: :promotion_action).to_a.sort_by(&:id)
        snapshot_locked = snapshot_locked?
        manual_total = discounts.select { |row| row.kind == 'manual' }.sum(&:amount)
        coupon_promo = order.promotions.detect { |promo| promo.coupon_code? || promo.code.present? }
        coupon_code = order.coupon_code.presence || coupon_promo&.code
        coupon_amount = discounts.select { |row| row.kind == 'promotion' && (coupon_promo.nil? || row.promotion_id == coupon_promo.id) }.sum(&:amount)
        now = self.class.database_now
        memo = {}
        # How far the kitchen got with each line of a table order, one query.
        kitchen = shared_service? ? kitchen_status_by_line : {}
        # The clock of each timed line; no query for an order without one.
        timed = Timed::Sessions.for_workspace(self, sale_lines.values.select { |sale| sale.kind == Timed::Lines::KIND }.map(&:id), now: now)
        traces = sale_lines.values.to_h do |sale|
          [sale.prefixed_id, Spree::Pos::Inventory::AllocateTraceability.line_trace(sale, branch, now: now, memo: memo,
                                                                                                 completed: operational_status == 'completed')]
        end
        summary.merge(
          trace: Spree::Pos::Inventory::AllocateTraceability.workspace_trace(self, traces),
          customer: customer_pos,
          line_items: lines.map do |line|
            sale = sale_lines[line.id]
            quoted_price = sale&.unit_price || line.price
            core = {
              id: line.prefixed_id, variant_id: line.variant.prefixed_id, product_id: line.variant.product.prefixed_id,
              name: line.variant.product.name, sku: line.variant.sku, quantity: line.quantity,
              price: money(line.price),
              list_price: money(snapshot_locked ? quoted_price : (SalesChannel.price(line.variant, store: store, currency: order.currency, order: order)&.amount || quoted_price)),
              amount: money(line.amount),
              net_amount: money(line.amount + line.discounts.to_a.sum(&:amount)),
              discounts: line.discounts.to_a.map { |row|
                { id: row.prefixed_id, kind: row.kind, label: row.label, amount: money(row.amount) }
              }
            }
            item_promotions = line.discounts.to_a.select { |row| row.promotion? && row.promotion_action&.discount_scope == :line_item }
            line_intent = sale&.line_discount_intent
            manual_amount = line_intent ? line_intent.allocations.joins(:discount).sum('spree_discounts.amount') : BigDecimal('0')
            item_amount = item_promotions.sum(&:amount) + manual_amount
            core[:item_net_amount] = money(line.amount + item_amount)
            explicit_item = line_intent&.value_type&.start_with?('item_')
            single_percent = !line_intent && item_promotions.one? && item_promotions.first.value_type == 'percent' && item_promotions.first.value.present?
            core[:item_discount] = {
              amount: money(item_amount), source: line_intent ? (line_intent.source == 'cover_credit' ? 'cover_credit' : 'manual') : (item_promotions.any? ? 'promotion' : 'none'),
              value_type: explicit_item ? line_intent.value_type.delete_prefix('item_') : (single_percent ? 'percent' : 'flat'),
              value: explicit_item ? line_intent.value : (single_percent ? money(item_promotions.first.value) : money(item_amount.abs)),
              labels: item_promotions.map(&:label)
            }
            if sale
              row = core.merge(sale.to_pos(line)).merge(trace: traces[sale.prefixed_id])
              row[:timed_session] = timed[sale.id] if sale.kind == Timed::Lines::KIND
              shared_service? ? row.merge(kitchen_status: kitchen.fetch(sale.id, {})) : row
            else
              core.merge(sale_line_id: nil, trace: nil)
            end
          end,
          discount: intent && {
            id: intent.prefixed_id, value_type: intent.value_type, value: intent.value,
            reason: intent.reason, amount: money(intent.allocations.joins(:discount).sum('spree_discounts.amount'))
          },
          coupon: coupon_code && {
            code: coupon_code.to_s.upcase, name: coupon_promo&.name, amount: money(coupon_amount)
          },
          # An order to deliver: deliverer, fee and delivery status.
          delivery: Spree::Pos::Delivery.find_by(workspace_id: id)&.to_pos,
          # Read only where they can exist, so counter sales add no queries.
          service_charge: branch.service_charge_rate && ServiceCharges::Apply.to_pos(self),
          # A VIP table's minimum and the fee still owed below it.
          minimum_spend: resource_id && Fnb::MinimumSpend.to_pos(self),
          # What the door tickets of the order still pay for in drinks.
          drink_credit: Fnb::DrinkCredit.to_pos(self, sale_lines.values),
          prebill: resource_id && prebill_pos,
          payment_request: resource_id && PaymentRequest.open.find_by(workspace_id: id)&.to_pos,
          # The booking seated at this table and the deposits it brought.
          reservation: resource_id && reservation_pos,
          # Who told the kitchen what, and when; table orders are sent many times.
          kitchen_sends: (KitchenSend.where(workspace_id: id).includes(:staff, :device).order(:sequence).map(&:to_pos) if shared_service?),
          totals: {
            item_total: money(order.item_total), discount_total: money(discounts.sum(&:amount)),
            fee_total: money(order.fee_total),
            fees: order.fees.map { |fee| { kind: fee.kind, label: fee.label, amount: money(fee.amount) } },
            manual_discount_total: money(manual_total), included_tax_total: money(order.included_tax_total),
            additional_tax_total: money(order.additional_tax_total), total: money(order.total),
            currency: order.currency,
            taxes: TaxBreakdown.for(order)
          },
          financial: financial_pos
        )
      end

      # Sent quantity of each sale line by kitchen status (new, preparing,
      # ready, served), from the fire tickets of this order.
      def kitchen_status_by_line
        KitchenTicketItem.joins(:kitchen_ticket).where(spree_pos_kitchen_tickets: { workspace_id: id, kind: 'fire' }).
          where(status: %w[new preparing ready served]).where.not(sale_line_id: nil).
          group(:sale_line_id, :status).sum(:quantity).each_with_object({}) do |((line_id, status), quantity), rows|
            (rows[line_id] ||= {})[status] = quantity.to_s('F')
          end
      end

      # The latest pre-bill; `stale` once the order changed after it was printed.
      def prebill_pos
        print = PrebillPrint.where(workspace_id: id).order(:sequence).last
        print && print.to_pos.merge(stale: print.status == 'superseded' || (print.status == 'current' && print.revision != revision))
      end

      # The booking seated at this table, if any, with its deposits.
      def reservation_pos
        booking = Reservation.includes(deposits: :received_funds).find_by(workspace_id: id)
        return nil if booking.nil?

        {
          id: booking.prefixed_id, guest_name: booking.guest_name, party_size: booking.party_size,
          status: booking.status, revision: booking.revision,
          deposit_held: money(booking.deposits.select(&:held?).sum(&:amount)),
          deposits: booking.deposits.map(&:to_pos)
        }
      end

      def financial_pos
        return nil unless defined?(Spree::Pos::TenderAttempt)

        funds = Spree::Pos::ReceivedFunds.where(workspace_id: id).to_a
        attempts = Spree::Pos::TenderAttempt.where(workspace_id: id).order(:id).to_a
        # Debt collections settle the order later from a receipt that may also
        # pay other orders; they are the receivable's business, not this sale's.
        allocations = Spree::Pos::FundsAllocation.where(workspace_id: id, status: 'active', collection_id: nil)
        allocated = allocations.sum(:amount)
        allocated_funds = Spree::Pos::ReceivedFunds.where(id: allocations.select(:received_funds_id)).to_a
        received_funds = (funds + allocated_funds).uniq(&:id)
        received = received_funds.select { |row| row.status == 'received' }.sum(&:received_net)
        {
          received: money(received), allocated: money(allocated),
          unapplied: money(received_funds.sum { |row| Spree::Pos::FundsBalance.new(row).available }),
          remaining: money([order.total - allocated, 0].max), change_due: money(funds.sum(&:change_amount)),
          # Tips handed over on top of the bill; kept off the order.
          tip: money(Spree::Pos::TipRecord.where(workspace_id: id).sum(:amount)),
          attempts: attempts.map(&:to_pos), credit: credit_pos
        }
      end

      # Approved-but-uncommitted credit for the current snapshot, and after a
      # credit sale the receivable from the ledger (never core amount_due).
      def credit_pos
        reservation = Spree::Pos::CreditReservation.holding.find_by(workspace_id: id)
        entries = Spree::Pos::ReceivableEntry.where(order_id: order_id)
        debit = entries.find_by(kind: 'debit')
        {
          approved: reservation && money(reservation.amount), approval_id: reservation&.approval&.prefixed_id,
          debt: debit && money(debit.amount), due_on: debit&.due_on&.iso8601,
          balance: debit && money(Spree::Pos::ReceivableEntry.balance_sum(entries))
        }
      end

      def money(value)
        BigDecimal(value.to_s).to_s('F')
      end

      # The one sanctioned change of a draft's shift: ShiftRebind moving a draft
      # without money off its cashier's closed shift.
      def rebind_shift!(shift)
        @shift_rebind = true
        update!(shift: shift, register: shift.register)
      ensure
        @shift_rebind = false
      end

      private

      def resource_fits_order
        return if resource_id.nil?

        errors.add(:service_mode, :invalid) unless RESOURCE_MODES.include?(service_mode)
        errors.add(:resource, :invalid) if resource && resource.branch_id != branch_id
      end

      def assign_business_date
        return if business_date.present? || branch.nil?

        self.business_date = BusinessDay.for(branch, self.class.business_now)
      end

      def business_date_is_fixed
        return if new_record?

        errors.add(:business_date, :invalid) if will_save_change_to_business_date?
      end

      # A call number, once handed out, belongs to this order for good.
      def order_number_is_kept
        return if new_record? || order_number_was.nil?

        errors.add(:order_number, :invalid) if will_save_change_to_order_number?
      end

      def source_is_immutable
        return if new_record?

        movable = @shift_rebind ? %w[register_id shift_id] : []
        (%w[store_id branch_id register_id shift_id order_id] - movable).each do |attribute|
          errors.add(attribute, :invalid) if will_save_change_to_attribute?(attribute)
        end
      end
    end
  end
end
