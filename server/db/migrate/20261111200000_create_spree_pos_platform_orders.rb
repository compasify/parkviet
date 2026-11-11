# frozen_string_literal: true

# Orders from delivery platforms (GrabFood, ShopeeFood) that the cashier types
# in by hand. A branch turns each platform on with its commission rate; every
# order keeps the platform's own reference, unique per branch and platform,
# and what the platform owes the store for it until the money arrives.
#
# The customer paid the platform, so the sale is settled with a
# `platform_receivable` tender: received funds that never enter a drawer,
# with the platform order as its evidence.
class CreateSpreePosPlatformOrders < ActiveRecord::Migration[8.1]
  PLATFORMS = "('grabfood', 'shopeefood')"
  OLD_SOURCES = "order_source IN ('counter', 'facebook', 'zalo', 'other')"
  NEW_SOURCES = "order_source IN ('counter', 'facebook', 'zalo', 'other', 'grabfood', 'shopeefood')"
  OLD_METHOD_KINDS = "kind IN ('cash', 'bank_manual', 'vietqr')"
  NEW_METHOD_KINDS = "kind IN ('cash', 'bank_manual', 'vietqr', 'platform_receivable')"
  OLD_FUNDS_KINDS = "kind IN ('cash', 'bank_manual')"
  NEW_FUNDS_KINDS = "kind IN ('cash', 'bank_manual', 'platform_receivable')"
  OLD_EVIDENCE_KINDS = "kind IN ('cash_count', 'bank_manual', 'external_card', 'vietqr_webhook', 'vietqr_manual')"
  NEW_EVIDENCE_KINDS = "kind IN ('cash_count', 'bank_manual', 'external_card', 'vietqr_webhook', 'vietqr_manual', 'platform_order')"
  OLD_REPORTS = "report_type IN ('sales', 'receipts', 'cashbook', 'receivables', 'closures', 'ingredient_usage', 'menu_margin')"
  NEW_REPORTS = "report_type IN ('sales', 'receipts', 'cashbook', 'receivables', 'closures', 'ingredient_usage', 'menu_margin', " \
                "'platforms')"

  def change
    create_table :spree_pos_platform_settings do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }
      t.references :branch, null: false, foreign_key: { to_table: :spree_pos_branches }, index: false
      t.string :platform, limit: 20, null: false
      # Percent of the order the platform keeps, e.g. 25.00.
      t.decimal :commission_rate, precision: 5, scale: 2, null: false, default: 0
      t.string :status, limit: 16, null: false, default: 'active'
      t.timestamps
    end
    add_index :spree_pos_platform_settings, %i[branch_id platform], unique: true, name: 'idx_pos_platform_settings_branch'
    add_check_constraint :spree_pos_platform_settings, "platform IN #{PLATFORMS}", name: 'chk_pos_platform_settings_platform'
    add_check_constraint :spree_pos_platform_settings, 'commission_rate >= 0 AND commission_rate <= 100',
                         name: 'chk_pos_platform_settings_rate'
    add_check_constraint :spree_pos_platform_settings, "status IN ('active', 'disabled')", name: 'chk_pos_platform_settings_status'

    create_table :spree_pos_platform_orders do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }
      t.references :branch, null: false, foreign_key: { to_table: :spree_pos_branches }, index: false
      t.references :workspace, null: false, foreign_key: { to_table: :spree_pos_workspaces }, index: { unique: true }
      t.string :platform, limit: 20, null: false
      t.string :platform_order_ref, limit: 64, null: false
      t.string :pickup_code, limit: 32
      t.string :status, limit: 16, null: false, default: 'accepted'
      t.decimal :gross_amount, precision: 19, scale: 4, null: false, default: 0
      # The branch's rate when the order was entered; the commission is the
      # estimate from it until settlement records what the platform kept.
      t.decimal :commission_rate, precision: 5, scale: 2, null: false, default: 0
      t.decimal :commission_amount, precision: 19, scale: 4, null: false, default: 0
      t.decimal :net_amount, precision: 19, scale: 4, null: false, default: 0
      t.string :currency, limit: 16, null: false
      t.references :entered_by, null: false, foreign_key: { to_table: :spree_admin_users }
      t.datetime :ready_at
      t.datetime :completed_at
      t.datetime :canceled_at
      t.string :cancel_reason, limit: 200
      t.datetime :settled_at
      t.references :settled_by, foreign_key: { to_table: :spree_admin_users }
      t.string :settlement_reference, limit: 120
      t.timestamps
    end
    add_index :spree_pos_platform_orders, %i[branch_id platform platform_order_ref], unique: true,
                                                                                     name: 'idx_pos_platform_orders_ref'
    add_index :spree_pos_platform_orders, %i[branch_id status], name: 'idx_pos_platform_orders_status'
    add_check_constraint :spree_pos_platform_orders, "platform IN #{PLATFORMS}", name: 'chk_pos_platform_orders_platform'
    add_check_constraint :spree_pos_platform_orders, "status IN ('accepted', 'ready', 'completed', 'canceled')",
                         name: 'chk_pos_platform_orders_status'
    add_check_constraint :spree_pos_platform_orders,
                         'gross_amount >= 0 AND commission_amount >= 0 AND commission_amount <= gross_amount AND ' \
                         'net_amount = gross_amount - commission_amount AND commission_rate >= 0 AND commission_rate <= 100',
                         name: 'chk_pos_platform_orders_amounts'
    add_check_constraint :spree_pos_platform_orders, "settled_at IS NULL OR status = 'completed'",
                         name: 'chk_pos_platform_orders_settled'

    remove_check_constraint :spree_pos_workspaces, OLD_SOURCES, name: 'chk_pos_workspace_order_source'
    add_check_constraint :spree_pos_workspaces, NEW_SOURCES, name: 'chk_pos_workspace_order_source'
    remove_check_constraint :spree_pos_payment_methods, OLD_METHOD_KINDS, name: 'chk_pos_payment_methods_kind'
    add_check_constraint :spree_pos_payment_methods, NEW_METHOD_KINDS, name: 'chk_pos_payment_methods_kind'
    remove_check_constraint :spree_pos_received_funds, OLD_FUNDS_KINDS, name: 'chk_pos_received_funds_kind'
    add_check_constraint :spree_pos_received_funds, NEW_FUNDS_KINDS, name: 'chk_pos_received_funds_kind'
    remove_check_constraint :spree_pos_receipt_evidences, OLD_EVIDENCE_KINDS, name: 'chk_pos_receipt_evidences_kind'
    add_check_constraint :spree_pos_receipt_evidences, NEW_EVIDENCE_KINDS, name: 'chk_pos_receipt_evidences_kind'
    remove_check_constraint :spree_pos_export_requests, OLD_REPORTS, name: 'chk_pos_export_requests_report'
    add_check_constraint :spree_pos_export_requests, NEW_REPORTS, name: 'chk_pos_export_requests_report'
  end
end
