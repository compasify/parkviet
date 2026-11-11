# frozen_string_literal: true

module Spree
  module Pos
    module Reports
      # Gross margin by menu item size over completed sales: revenue is the
      # line amount after line promotions and before added tax (order-level
      # discounts stay on the order), cost is what the recipes consumed at
      # the cost copied when the sale completed. A size sold without any
      # consumption shows `costed: false` and a zero cost.
      class MenuMargin < Grouped
        COLUMNS = %w[menu_item sku quantity revenue cost margin margin_rate costed].freeze
        REVENUE_SQL = 'SUM(spree_line_items.price * spree_line_items.quantity + spree_line_items.adjustment_total - ' \
                      'spree_line_items.additional_tax_total)'

        def summary
          rows = all_rows
          revenue = rows.sum { |row| BigDecimal(row[:revenue]) }
          cost = rows.sum { |row| BigDecimal(row[:cost]) }
          { items: rows.size, revenue: money(revenue), cost: money(cost), margin: money(revenue - cost),
            margin_rate: rate(revenue - cost, revenue), uncosted_items: rows.count { |row| !row[:costed] } }
        end

        private

        def build_rows
          sold = menu_lines.joins(:line_item).group('spree_pos_sale_lines.variant_id').
                 pluck('spree_pos_sale_lines.variant_id', Arel.sql('SUM(spree_pos_sale_lines.base_quantity)'), Arel.sql(REVENUE_SQL))
          costs = consumptions.joins(:sale_line).group('spree_pos_sale_lines.variant_id').
                  sum(Arel.sql("#{RecipeConsumption.table_name}.base_quantity * COALESCE(#{RecipeConsumption.table_name}.unit_cost, 0)"))
          variants = Spree::Variant.with_deleted.includes(:product, :option_values).where(id: sold.map(&:first)).index_by(&:id)
          rows = sold.map do |variant_id, quantity, revenue|
            revenue = BigDecimal(revenue.to_s)
            cost = BigDecimal((costs[variant_id] || 0).to_s)
            { menu_item: variant_label(variants[variant_id]), sku: variants[variant_id]&.sku.presence, quantity: quantity.to_i,
              revenue: money(revenue), cost: money(cost), margin: money(revenue - cost), margin_rate: rate(revenue - cost, revenue),
              costed: costs.key?(variant_id) }
          end
          rows.sort_by { |row| [-BigDecimal(row[:revenue]), row[:menu_item]] }
        end

        def menu_lines
          products = MenuItem.for_store(scope.store).select(:product_id)
          SaleLine.where(workspace_id: workspaces.select(:id)).
            where(variant_id: Spree::Variant.with_deleted.where(product_id: products).select(:id))
        end

        # Percent of revenue, one decimal; nil without revenue.
        def rate(margin, revenue)
          return nil unless revenue.positive?

          (margin * 100 / revenue).round(1).to_s('F')
        end
      end
    end
  end
end
