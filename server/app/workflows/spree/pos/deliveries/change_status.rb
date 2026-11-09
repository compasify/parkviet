# frozen_string_literal: true

module Spree
  module Pos
    module Deliveries
      # Marks a completed delivery order `delivered` (Đã giao), or back to
      # `pending` when tapped by mistake. Only the delivery row changes: the
      # sale, its stock and its money were posted at completion. Idempotent
      # per key; tapping a row already in the asked status changes nothing
      # and audits nothing. Not gated by the `delivery` switch, so orders
      # already sold for delivery can always be finished.
      class ChangeStatus
        # Staff who sell or collect at the branch hand orders over.
        HANDLERS = [Capabilities::OPEN_SHIFT, Capabilities::PAYMENT].freeze

        def self.call(store:, staff:, key:, delivery_id:, status:, deliverer: nil)
          status = status.to_s
          raise Conflict.new('Delivery status is invalid.', reason: 'delivery_status_invalid') unless Delivery::STATUSES.include?(status)

          delivery = Delivery.locate(Delivery.for_store(store), delivery_id)
          raise ActiveRecord::RecordNotFound if delivery.nil?

          payload = { 'command' => "delivery.#{status}", 'delivery_id' => delivery.prefixed_id, 'deliverer' => deliverer.to_s.presence }
          authorize = -> { authorize!(store, staff, delivery) }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: authorize) do
            delivery.lock!
            unless delivery.workspace.operational_status == 'completed'
              raise Conflict.new('The order is not completed yet.', reason: 'delivery_not_placed')
            end

            name = deliverer.nil? ? delivery.deliverer : Assign.deliverer!(deliverer) || delivery.deliverer
            if delivery.status != status || name != delivery.deliverer
              before = { status: delivery.status, deliverer: delivery.deliverer }
              delivered = status == 'delivered'
              delivery.update!(status: status, deliverer: name,
                               delivered_at: delivered ? (delivery.delivered_at || Time.current) : nil,
                               delivered_by: delivered ? (delivery.delivered_by || staff) : nil)
              AuditEntry.record!(store: store, actor: staff, action: "delivery.#{status}", subject: delivery,
                                 metadata: { order_id: delivery.order.prefixed_id, before: before, deliverer: name })
            end
            List.row(delivery.reload)
          end
        end

        def self.authorize!(store, staff, delivery)
          policy = AccessPolicy.new(store: store, staff: staff)
          raise CanCan::AccessDenied if delivery.branch.disabled? || HANDLERS.none? { |capability| policy.allows?(delivery.branch, capability) }
        end
      end
    end
  end
end
