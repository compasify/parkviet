# frozen_string_literal: true

# Exports of the coach commission report.
class AllowVehicleCommissionReportsInSpreePosExportRequests < ActiveRecord::Migration[8.1]
  BEFORE = %w[sales receipts cashbook receivables closures ingredient_usage menu_margin platforms bar meals meal_statement].freeze
  AFTER = (BEFORE + %w[vehicle_commissions]).freeze

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
