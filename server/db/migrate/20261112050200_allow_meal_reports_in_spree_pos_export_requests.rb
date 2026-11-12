# frozen_string_literal: true

# Exports of the canteen's meal report and a sponsor's statement, and of the
# bar report, which the allowed list had missed.
class AllowMealReportsInSpreePosExportRequests < ActiveRecord::Migration[8.1]
  BEFORE = %w[sales receipts cashbook receivables closures ingredient_usage menu_margin platforms].freeze
  AFTER = (BEFORE + %w[bar meals meal_statement]).freeze

  def up
    replace(AFTER)
  end

  def down
    replace(BEFORE)
  end

  private

  def replace(types)
    remove_check_constraint :spree_pos_export_requests, name: 'chk_pos_export_requests_report'
    add_check_constraint :spree_pos_export_requests, "report_type IN (#{types.map { |type| "'#{type}'" }.join(', ')})",
                         name: 'chk_pos_export_requests_report'
  end
end
