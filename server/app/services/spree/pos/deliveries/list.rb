# frozen_string_literal: true

module Spree
  module Pos
    module Deliveries
      # The "orders to deliver" list of a branch: completed sales marked for
      # delivery, pending ones oldest first, or the ones delivered today
      # (branch time) newest first. Money comes from posted facts: the order
      # total, what receipts and collections paid, and the open debt from the
      # receivable ledger. Customer phone and address print in full, since
      # whoever delivers needs to call and find the door.
      module List
        RECENT_DELIVERERS = 8

        module_function

        def scope(store:, branch:, status:)
          rows = Delivery.for_store(store).where(branch_id: branch.id).
                 joins(:workspace).where(spree_pos_workspaces: { operational_status: 'completed' })
          if status == 'delivered'
            today = Time.now.in_time_zone(branch.timezone).beginning_of_day
            rows.where(status: 'delivered').where(spree_pos_deliveries: { delivered_at: today.. }).
              order(delivered_at: :desc, id: :desc)
          else
            rows.where(status: 'pending').order(:created_at, :id)
          end
        end

        def rows(deliveries)
          deliveries = Array(deliveries)
          return [] if deliveries.empty?

          ActiveRecord::Associations::Preloader.new(
            records: deliveries, associations: [:delivered_by, { order: [], workspace: :pos_customer }]
          ).call
          order_ids = deliveries.map(&:order_id)
          paid = FundsAllocation.where(order_id: order_ids, status: 'active').group(:order_id).sum(:amount)
          owed = ReceivableEntry.where(order_id: order_ids).group(:order_id).sum(Arel.sql(ReceivableEntry::SIGNED_SQL))
          deliveries.map { |delivery| serialize(delivery, paid, owed) }
        end

        def row(delivery)
          rows([delivery]).first
        end

        # Distinct names typed lately at the branch, most recent first, for
        # a quick pick on the sale screen.
        def recent_deliverers(store:, branch:)
          Delivery.for_store(store).where(branch_id: branch.id).where.not(deliverer: nil).
            group(:deliverer).order(Arel.sql('MAX(updated_at) DESC')).limit(RECENT_DELIVERERS).pluck(:deliverer)
        end

        def serialize(delivery, paid, owed)
          order = delivery.order
          profile = delivery.workspace.pos_customer
          delivery.to_pos.merge(
            order_id: order.prefixed_id, order_number: order.number, workspace_id: delivery.workspace.prefixed_id,
            placed_at: order.completed_at&.iso8601, currency: order.currency, total: money(order.total),
            paid: money(paid[order.id] || 0), owed: money([owed[order.id] || 0, 0].max),
            customer: profile && { name: profile.name, phone: profile.phone, address: profile.address }
          ).deep_stringify_keys
        end

        def money(value)
          BigDecimal(value.to_s).to_s('F')
        end
      end
    end
  end
end
