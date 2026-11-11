# frozen_string_literal: true

module Spree
  module Pos
    module Reports
      # What completed sales used of each ingredient, by business date and
      # menu item, in the ingredient's stock unit, at the cost per stock unit
      # copied when the sale completed. Read from recipe consumptions; an
      # ingredient without a cost price counts as zero and is flagged.
      class IngredientUsage < Grouped
        COLUMNS = %w[business_date ingredient ingredient_sku menu_item quantity unit cost cost_missing].freeze
        COST_SQL = 'SUM(base_quantity * COALESCE(unit_cost, 0))'

        def summary
          totals = consumptions.group(:ingredient_variant_id, :base_unit_code).
                   pluck(:ingredient_variant_id, :base_unit_code, Arel.sql('SUM(base_quantity)'), Arel.sql(COST_SQL))
          variants = variants_by_id(totals.map(&:first))
          shortages = StockDiscrepancy.where(source: 'recipe', workspace_id: workspaces.select(:id))
          {
            total_cost: money(totals.sum { |row| BigDecimal(row[3].to_s) }),
            ingredients: totals.sort_by { |row| -row[2].to_i }.map do |variant_id, unit, quantity, cost|
              { ingredient: variant_label(variants[variant_id]), ingredient_sku: variants[variant_id]&.sku.presence,
                quantity: quantity.to_i, unit: unit, cost: money(cost) }
            end,
            shortages: shortages.count, open_shortages: shortages.open_now.count
          }
        end

        private

        def build_rows
          table = RecipeConsumption.table_name
          grouped = consumptions.joins(:sale_line).
                    group("#{table}.business_date", "#{table}.ingredient_variant_id", "#{table}.base_unit_code",
                          'spree_pos_sale_lines.variant_id').
                    order("#{table}.business_date DESC", "#{table}.ingredient_variant_id", 'spree_pos_sale_lines.variant_id').
                    pluck("#{table}.business_date", "#{table}.ingredient_variant_id", "#{table}.base_unit_code",
                          'spree_pos_sale_lines.variant_id', Arel.sql("SUM(#{table}.base_quantity)"),
                          Arel.sql("SUM(#{table}.base_quantity * COALESCE(#{table}.unit_cost, 0))"),
                          Arel.sql("BOOL_OR(#{table}.unit_cost IS NULL)"))
          variants = variants_by_id(grouped.flat_map { |row| [row[1], row[3]] })
          grouped.map do |date, ingredient_id, unit, item_id, quantity, cost, missing|
            ingredient = variants[ingredient_id]
            { business_date: date.iso8601, ingredient: variant_label(ingredient), ingredient_sku: ingredient&.sku.presence,
              menu_item: variant_label(variants[item_id]), quantity: quantity.to_i, unit: unit, cost: money(cost),
              cost_missing: missing == true }
          end
        end

        def variants_by_id(ids)
          Spree::Variant.with_deleted.includes(:product, :option_values).where(id: ids.uniq).index_by(&:id)
        end
      end
    end
  end
end
