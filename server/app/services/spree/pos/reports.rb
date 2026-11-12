# frozen_string_literal: true

module Spree
  module Pos
    # Server-side POS reports. Each report keeps its own date meaning: sales
    # by the order's completed time, returns by when goods came back, receipts
    # by when money actually arrived (booked time shown separately), the
    # cashbook by shift, receivables as of today from the ledger, closures by
    # close time; recipe usage, menu margin and delivery platforms by the
    # sale's business date. Dates are days in the branch's timezone.
    module Reports
      TYPES = %w[sales receipts cashbook receivables closures ingredient_usage menu_margin platforms bar meals meal_statement
                 vehicle_commissions].freeze

      def self.klass(type)
        case type.to_s
        when 'sales' then Sales
        when 'receipts' then Receipts
        when 'cashbook' then Cashbook
        when 'receivables' then Receivables
        when 'closures' then Closures
        when 'ingredient_usage' then IngredientUsage
        when 'menu_margin' then MenuMargin
        when 'platforms' then Platforms
        when 'bar' then Bar
        when 'meals' then Meals
        when 'meal_statement' then MealStatement
        when 'vehicle_commissions' then VehicleCommissions
        # Read on screen only, so not in TYPES (the exportable reports).
        when 'attendants' then Attendants
        else raise ActiveRecord::RecordNotFound
        end
      end

      # `values` are raw request strings; unknown keys are rejected.
      def self.build(type, scope:, values:)
        report = klass(type)
        report.new(scope: scope, filters: Filters.new(scope: scope, values: values, report: report))
      end
    end
  end
end
