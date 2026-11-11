# frozen_string_literal: true

module Spree
  module Pos
    module PlatformOrders
      # Records that a platform paid the store for completed orders, with
      # the commission it actually kept where that differs from the branch
      # rate's estimate. Only what the platform owes moves: the sales, their
      # tenders and receipts stay exactly as they were.
      module Settle
        MAX_ORDERS = 200

        module_function

        # `orders`: [{ id:, commission_amount: (optional) }]
        def call(store:, staff:, key:, branch:, orders:, reference: nil)
          rows = Array(orders).first(MAX_ORDERS + 1).map { |row| normalize(row) }
          reference = reference.to_s.strip.presence
          payload = { 'command' => 'platform_order.settle', 'branch_id' => branch.prefixed_id, 'orders' => rows,
                      'reference' => reference }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload,
                               authorize: -> { Guard.settle!(store, staff, branch) }) do
            raise Conflict.new('Choose the orders the platform paid.', reason: 'platform_settle_empty') if rows.empty?
            raise Conflict, "Settle at most #{MAX_ORDERS} orders at once." if rows.size > MAX_ORDERS
            raise Conflict, 'The reference is too long.' if reference && reference.length > 120
            raise Conflict, 'An order is listed twice.' if rows.map { |row| row['id'] }.uniq.size != rows.size

            now = Workspace.database_now
            settled = rows.map { |row| settle!(branch, staff, row, reference, now) }
            AuditEntry.record!(store: store, actor: staff, action: 'platform_order.settle', subject: branch,
                               metadata: { reference: reference, orders: settled.map { |order| order_audit(order) } })
            { 'orders' => settled.map(&:to_pos) }
          end
        end

        def normalize(row)
          row = row.respond_to?(:to_unsafe_h) ? row.to_unsafe_h : row.to_h
          row = row.transform_keys(&:to_s)
          { 'id' => row['id'].to_s, 'commission_amount' => row['commission_amount'].to_s.strip.presence }
        end

        def settle!(branch, staff, row, reference, now)
          order = PlatformOrder.locate(PlatformOrder.where(branch_id: branch.id), row['id'])
          raise ActiveRecord::RecordNotFound if order.nil?

          order.lock!
          raise Conflict.new('Only completed orders are settled.', reason: 'platform_order_open') unless order.status == 'completed'
          if order.settled_at
            raise Conflict.new('This order is already settled.', reason: 'platform_order_settled',
                                                                 details: { platform_order_id: order.prefixed_id })
          end

          commission = row['commission_amount'] ? commission!(order, row['commission_amount']) : order.commission_amount
          order.update!(commission_amount: commission, net_amount: order.gross_amount - commission, settled_at: now,
                        settled_by: staff, settlement_reference: reference)
          order
        end

        def commission!(order, value)
          amount = Record.money(value)
          if amount.nil? || amount > order.gross_amount || !Record.countable_money?(amount, order.currency)
            raise Conflict.new('The commission is invalid.', reason: 'platform_commission_invalid',
                                                             details: { platform_order_id: order.prefixed_id })
          end

          amount
        end

        def order_audit(order)
          { id: order.prefixed_id, commission: order.commission_amount.to_s('F'), net: order.net_amount.to_s('F') }
        end
      end
    end
  end
end
