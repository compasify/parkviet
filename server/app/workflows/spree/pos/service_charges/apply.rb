# frozen_string_literal: true

module Spree
  module Pos
    module ServiceCharges
      # Keeps an order's service charge equal to the branch rate times its
      # items after discounts, rounded to the currency. Runs inside every
      # money recalculation (Workspaces::ApplyDiscount.recalculate!), so the
      # fee always follows the lines and discounts. The charge is an
      # order-level Spree::Fee, taxed under the branch's service charge tax
      # category (Spree::FeeDecorator); core sums it into the total.
      #
      # It applies when the branch has `fnb.service_charge` on and a rate,
      # the order's service mode is one the branch charges, and the cashier
      # has not waived it on this order.
      module Apply
        KIND = Spree::FeeDecorator::SERVICE_CHARGE_KIND
        LABEL = 'Phí phục vụ'
        MODULE = 'fnb.service_charge'

        module_function

        # Returns true when the fee changed (and the order was re-summed).
        def call(workspace)
          order = workspace.order
          branch = workspace.branch
          existing = order.fees.select { |fee| fee.kind == KIND }
          return false if branch.service_charge_rate.nil? && existing.empty?

          target = applies?(workspace) ? amount_for(workspace) : BigDecimal('0')
          fee = existing.first
          extra = existing.drop(1)
          category = branch.service_charge_tax_category_id
          metadata = { 'tax_category_id' => category, 'rate' => branch.service_charge_rate&.to_s('F') }.compact
          changed = extra.any?
          extra.each(&:destroy!)
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

        def applies?(workspace)
          branch = workspace.branch
          return false if branch.service_charge_rate.nil? || workspace.service_charge_waived
          return false unless Array(branch.service_charge_applies_to).include?(workspace.service_mode)

          ModulePolicy.enabled?(branch, MODULE)
        end

        # rate % of the items after every discount, half up to the currency.
        def amount_for(workspace)
          order = workspace.order
          net = net_item_total(order)
          return BigDecimal('0') unless net.positive?

          exponent = ::Money::Currency.find(order.currency.to_s)&.exponent || 2
          (net * workspace.branch.service_charge_rate / 100).round(exponent, BigDecimal::ROUND_HALF_UP)
        end

        # Discounts are stored as negative amounts.
        def net_item_total(order)
          BigDecimal(order.item_total.to_s) + order.discounts.sum(:amount)
        end

        def to_pos(workspace)
          fee = workspace.order.fees.detect { |row| row.kind == KIND }
          branch = workspace.branch
          { rate: branch.service_charge_rate&.to_s('F'), amount: workspace.money(fee&.amount || 0),
            waived: workspace.service_charge_waived, applies: Array(branch.service_charge_applies_to).include?(workspace.service_mode) }
        end
      end
    end
  end
end
