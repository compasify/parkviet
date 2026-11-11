# frozen_string_literal: true

# Low-stock thresholds of a branch, in the variant's stock unit, and the two
# recipe reports an export may ask for.
class CreateSpreePosStockAlerts < ActiveRecord::Migration[8.1]
  OLD_REPORTS = "report_type IN ('sales', 'receipts', 'cashbook', 'receivables', 'closures')"
  NEW_REPORTS = "report_type IN ('sales', 'receipts', 'cashbook', 'receivables', 'closures', 'ingredient_usage', 'menu_margin')"

  def change
    create_table :spree_pos_stock_alerts do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }
      t.references :branch, null: false, foreign_key: { to_table: :spree_pos_branches }
      t.references :variant, null: false, foreign_key: { to_table: :spree_variants }
      t.integer :min_quantity, null: false
      t.timestamps
    end
    add_index :spree_pos_stock_alerts, %i[branch_id variant_id], unique: true, name: 'idx_pos_stock_alerts_variant'
    add_check_constraint :spree_pos_stock_alerts, 'min_quantity > 0', name: 'chk_pos_stock_alerts_min'

    remove_check_constraint :spree_pos_export_requests, OLD_REPORTS, name: 'chk_pos_export_requests_report'
    add_check_constraint :spree_pos_export_requests, NEW_REPORTS, name: 'chk_pos_export_requests_report'
  end
end
