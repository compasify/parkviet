# frozen_string_literal: true

module Spree
  module Pos
    module Fnb
      # A VIP table's minimum spend. While the order's items are below the
      # table's minimum, the order carries an order-level Spree::Fee for the
      # difference ("Phụ thu mức tối thiểu"), taxed under the branch's
      # service charge tax category like the service charge. It runs inside
      # every money recalculation (Workspaces::ApplyDiscount.recalculate!), so
      # the fee follows the lines: more items shrink it, reaching the minimum
      # removes it, and it is never negative. The fee is written only when its
      # amount changes. A manager can waive it on one order (WaiveMinimumSpend).
      module MinimumSpend
        KIND = Spree::FeeDecorator::MINIMUM_SPEND_KIND
        LABEL = 'Phụ thu mức tối thiểu'
        MODULE = Tables::Guard::MODULE

        module_function

        # Returns true when the fee changed (and the order was re-summed).
        def call(workspace)
          order = workspace.order
          existing = order.fees.select { |fee| fee.kind == KIND }
          minimum = minimum_for(workspace)
          return false if minimum.nil? && existing.empty?

          target = minimum && !workspace.minimum_spend_waived ? shortfall(order, minimum) : BigDecimal('0')
          fee = existing.first
          changed = existing.size > 1
          existing.drop(1).each(&:destroy!)
          metadata = { 'tax_category_id' => workspace.branch.service_charge_tax_category_id, 'minimum' => minimum&.to_s('F') }.compact
          if target.zero?
            changed ||= fee.present?
            fee&.destroy!
          elsif fee
            unless fee.amount == target && fee.metadata.to_h == metadata
              fee.update!(amount: target, metadata: metadata)
              changed = true
            end
          else
            order.fees.create!(kind: KIND, label: LABEL, amount: target, metadata: metadata)
            changed = true
          end
          return false unless changed

          order.fees.reset
          Spree.order_recalculate_totals_workflow.call(order: order)
          order.reload
          true
        end

        # The table's minimum in the order currency, while the branch runs tables.
        def minimum_for(workspace)
          resource = workspace.resource
          return nil if resource&.minimum_spend.nil? || resource.minimum_spend_currency != workspace.order.currency

          ModulePolicy.enabled?(workspace.branch, MODULE) ? resource.minimum_spend : nil
        end

        def shortfall(order, minimum)
          [minimum - BigDecimal(order.item_total.to_s), BigDecimal('0')].max
        end

        def to_pos(workspace)
          minimum = minimum_for(workspace)
          return nil if minimum.nil?

          fee = workspace.order.fees.detect { |row| row.kind == KIND }
          { minimum: workspace.money(minimum), amount: workspace.money(fee&.amount || 0), waived: workspace.minimum_spend_waived }
        end
      end
    end
  end
end
