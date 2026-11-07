# frozen_string_literal: true

module Spree
  module Pos
    # Recall search: where a lot code or serial is in stock and which sales,
    # orders and customers got it. Limited to the branches where the reader
    # holds pos.inventory.trace (stock at their locations, sales made there);
    # customer phones are masked like order history unless the reader may
    # see them at the sale branch.
    class TraceRecall
      UNMASKED = [Capabilities::PAYMENT, Capabilities::APPROVE, Capabilities::CREDIT_MANAGE].freeze
      LIMIT = 100

      def initialize(store:, policy:)
        @store = store
        @policy = policy
      end

      # Lot codes are only unique per variant, so `variant_id` narrows the
      # search; sales are paged, stock lists capped, and `truncated` says so.
      # Returns [data, meta].
      def call(lot_code: nil, serial: nil, variant_id: nil, page: 1, limit: 25)
        lot_code = lot_code.to_s.strip.presence
        serial = serial.to_s.strip.presence
        raise Conflict.new('Search by one lot code or one serial number.', reason: 'recall_query_invalid') if lot_code.nil? == serial.nil?

        branches = Branch.for_store(store).to_a.select { |branch| policy.allows?(branch, Capabilities::INVENTORY_TRACE) }
        raise CanCan::AccessDenied if branches.empty?

        page = [page.to_i, 1].max
        limit = limit.to_i.clamp(1, LIMIT)
        location_ids = branches.map(&:stock_location_id)
        lots = lot_code ? InventoryLot.for_store(store).where(lot_code: lot_code) : InventoryLot.none
        units = serial ? SerialUnit.for_store(store).where(serial: serial) : SerialUnit.none
        if variant_id.present?
          variant = Spree::Variant.find_by_prefix_id(variant_id.to_s)
          raise ActiveRecord::RecordNotFound if variant.nil?

          lots = lots.where(variant_id: variant.id)
          units = units.where(variant_id: variant.id)
        end
        allocations = TraceAllocation.sold.where(store_id: store.id).
                      where(lot_code ? { inventory_lot_id: lots.select(:id) } : { serial_unit_id: units.select(:id) }).
                      joins(:workspace).where(spree_pos_workspaces: { branch_id: branches.map(&:id) })
        count = allocations.count
        rows = allocations.includes(:serial_unit, :inventory_lot, variant: :product, sale_line: [], workspace: %i[branch pos_customer], order: []).
               order(id: :desc).offset((page - 1) * limit).limit(limit).to_a
        stock_lots = lots.where(stock_location_id: location_ids).includes(variant: :product).order(:id).limit(LIMIT + 1).to_a
        stock_units = units.where(stock_location_id: location_ids).includes(variant: :product).order(:id).limit(LIMIT + 1).to_a
        data = {
          query: { lot_code: lot_code, serial: serial, variant_id: variant_id.presence },
          lots: stock_lots.first(LIMIT).map(&:to_pos), serial_units: stock_units.first(LIMIT).map(&:to_pos),
          sales: rows.map { |allocation| sale(allocation) }
        }
        pages = count.zero? ? 0 : (count.to_f / limit).ceil
        meta = { page: page, limit: limit, count: count, pages: pages,
                 truncated: stock_lots.length > LIMIT || stock_units.length > LIMIT || page < pages }
        [data, meta]
      end

      private

      attr_reader :store, :policy

      def sale(allocation)
        workspace = allocation.workspace
        order = allocation.order
        profile = workspace.pos_customer
        mask = UNMASKED.none? { |capability| policy.allows?(workspace.branch, capability) }
        {
          order_id: order.prefixed_id, order_number: order.number, branch_id: workspace.branch.prefixed_id,
          branch_name: workspace.branch.name, sold_at: (order.completed_at || allocation.committed_at)&.iso8601,
          sale_line_id: allocation.sale_line.prefixed_id, variant_id: allocation.variant.prefixed_id,
          sku: allocation.variant.sku, name: allocation.variant.product.name,
          quantity: allocation.quantity, returned_quantity: allocation.returned_quantity,
          base_unit: allocation.sale_line.base_unit_code, lot_code: allocation.inventory_lot&.lot_code,
          expiry_on: allocation.inventory_lot&.expiry_on&.iso8601, serial: allocation.serial_unit&.serial,
          status: allocation.status, customer: profile && ReceivableProjection.customer(profile, mask)
        }
      end
    end
  end
end
