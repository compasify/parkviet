# frozen_string_literal: true

module Spree
  module Pos
    module VehicleVisits
      # "The coach left": closes an open visit and keeps its commission. The
      # revenue is the total of the visit's completed orders; the rule is
      # picked and applied by VehicleCommission::Calculator, and the result is
      # stored as the visit's snapshot, so a rule edited later changes
      # nothing here. Orders still open stay on the visit but no longer add
      # to it. CloseStaleVehicleVisitsJob closes visits past their window the
      # same way, as the person who opened them.
      module Close
        COMMAND = 'vehicle_visit.close'

        module_function

        def call(store:, staff:, key:, visit_id:)
          visit = Guard.visit!(store, visit_id)
          payload = { 'command' => COMMAND, 'visit_id' => visit.prefixed_id }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload,
                               authorize: -> { Guard.operate!(store, staff, visit.branch) }) do
            ModulePolicy.require!(visit.branch, Guard::MODULE)
            close!(visit, staff)
            Guard.to_pos(visit, staff)
          end
        end

        # Under the visit's row lock. Returns false when it was not open.
        def close!(visit, actor, auto: false)
          visit.lock!
          if auto
            return false unless visit.open?
          else
            Guard.status!(visit, 'open')
          end

          revenue = revenue_of(visit)
          snapshot = VehicleCommission::Calculator.call(rule: VehicleCommission::Calculator.rule_for(visit), vehicle_type: visit.vehicle_type,
                                                        guest_count: visit.guest_count, revenue: revenue)
          visit.update!(status: 'closed', closed_at: Workspace.database_now, closed_by: actor, auto_closed: auto,
                        revenue_amount: revenue, commission_amount: BigDecimal(snapshot['amount']),
                        commission_snapshot: snapshot, revision: visit.revision + 1)
          Guard.audit!(visit, actor, COMMAND, auto: auto || nil, revenue: revenue.to_s('F'), rule_id: snapshot.dig('rule', 'id'))
          true
        end

        def revenue_of(visit)
          orders = Spree::Order.complete.where(id: Workspace.where(vehicle_visit_id: visit.id, operational_status: 'completed').select(:order_id))
          BigDecimal(orders.sum(:total).to_s)
        end
      end
    end
  end
end
