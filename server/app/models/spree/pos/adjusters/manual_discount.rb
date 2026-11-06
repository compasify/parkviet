# frozen_string_literal: true

module Spree
  module Pos
    module Adjusters
      # Runs after core promotions and before tax. Owns only manual discounts
      # linked through POS allocation rows (order-wide and SaleLine intents).
      class ManualDiscount < Spree::Adjusters::Base
        def update
          return unless order.is_a?(Spree::Order) && order.persisted?

          workspace = Spree::Pos::Workspace.find_by(order_id: order.id)
          return unless workspace

          order_intent = Spree::Pos::DiscountIntent.find_by(workspace_id: workspace.id)
          line_intents = Spree::Pos::LineDiscountIntent.where(workspace_id: workspace.id).to_a
          return if order_intent.nil? && line_intents.empty?

          raise Spree::Pos::Conflict, 'Discount cannot be recalculated after a payment exists.' if order.payments.exists?

          lines = order.line_items.to_a.sort_by(&:id)
          sale_lines = Spree::Pos::SaleLine.where(workspace_id: workspace.id).index_by(&:line_item_id)
          line_intent_by_sale = line_intents.index_by(&:sale_line_id)
          owned_ids = owned_discount_ids(order_intent, line_intents)
          other_discounts = order.discounts.where.not(id: owned_ids).group(:line_item_id).sum(:amount)
          order_bases = lines.map { |line| line.amount + (other_discounts[line.id] || 0) }
          # Direct price reductions precede invoice discounts. Existing flat and
          # percentage line intents retain their historical after-invoice order.
          target_shares = lines.each_with_index.map do |line, index|
            sale_line = sale_lines[line.id]
            intent = sale_line && line_intent_by_sale[sale_line.id]
            if intent&.value_type == 'unit_price'
              Spree::Pos::TargetPriceDiscount.call(sale_line: sale_line, base: order_bases[index], value: intent.value, currency: order.currency)
            elsif intent&.value_type&.start_with?('item_')
              Spree::Pos::LineDiscountIntent.item_override_amount(base: order_bases[index], value: intent.value, value_type: intent.value_type, currency: order.currency)
            else
              BigDecimal('0')
            end
          end
          order_bases = order_bases.each_with_index.map { |base, index| base - target_shares[index] }
          order_shares = if order_intent
                           Spree::Pos::DiscountCalculator.call(bases: order_bases, value: order_intent.value, value_type: order_intent.value_type, currency: order.currency)
                         else
                           lines.map { BigDecimal('0') }
                         end

          Spree::Pos::DiscountIntent.transaction do
            order.discounts.where(id: owned_ids).destroy_all
            lines.each_with_index do |line, index|
              order_share = order_shares[index]
              if order_intent && !order_share.zero?
                discount = order.discounts.create!(line_item: line, kind: 'manual', label: order_intent.reason, amount: -order_share, value_type: order_intent.value_type)
                order_intent.allocations.create!(discount: discount)
              end
              sale_line = sale_lines[line.id]
              line_intent = sale_line && line_intent_by_sale[sale_line.id]
              next unless line_intent

              line_base = line.amount + (other_discounts[line.id] || 0) - order_share
              line_share = if line_intent.value_type == 'unit_price' || line_intent.value_type.start_with?('item_')
                             target_shares[index]
                           else
                             Spree::Pos::DiscountCalculator.call(bases: [line_base], value: line_intent.value, value_type: line_intent.value_type, currency: order.currency).first
                           end
              next if line_share.zero?

              discount = order.discounts.create!(line_item: line, kind: 'manual', label: line_intent.reason, amount: -line_share, value_type: line_intent.value_type == 'unit_price' ? 'flat' : line_intent.value_type.delete_prefix('item_'))
              line_intent.allocations.create!(discount: discount)
            end
          end
        rescue Spree::Pos::DiscountCalculator::InvalidDiscount
          raise Spree::Pos::Conflict, 'Discount exceeds the current eligible amount or cannot be represented.'
        end

        private

        def owned_discount_ids(order_intent, line_intents)
          scopes = []
          scopes << Spree::Pos::DiscountAllocation.where(discount_intent_id: order_intent.id) if order_intent
          scopes << Spree::Pos::DiscountAllocation.where(line_discount_intent_id: line_intents.map(&:id)) if line_intents.any?
          return Spree::Pos::DiscountAllocation.none.select(:discount_id) if scopes.empty?

          scopes.reduce { |combined, scope| combined.or(scope) }.select(:discount_id)
        end
      end
    end
  end
end
