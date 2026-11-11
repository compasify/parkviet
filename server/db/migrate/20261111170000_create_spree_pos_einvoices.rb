# frozen_string_literal: true

# One e-invoice of a completed POS order, issued through the store's
# provider after completion. An order has at most one original invoice; a
# replacement points at the invoice it replaces. Lines, totals and seller
# are snapshots taken from the order and the settings, never re-read.
class CreateSpreePosEinvoices < ActiveRecord::Migration[8.1]
  STATUSES = "status IN ('pending', 'issuing', 'issued', 'failed', 'canceled', 'replaced', 'adjusted')"

  def change
    create_table :spree_pos_einvoices do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }
      t.references :branch, null: false, foreign_key: { to_table: :spree_pos_branches }
      t.references :order, null: false, foreign_key: { to_table: :spree_orders }
      t.references :workspace, null: false, foreign_key: { to_table: :spree_pos_workspaces }
      t.references :original_einvoice, foreign_key: { to_table: :spree_pos_einvoices }
      t.references :created_by, null: false, foreign_key: { to_table: :spree_admin_users }
      t.string :relation, limit: 16, null: false, default: 'original'
      t.string :invoice_type, limit: 16, null: false
      t.string :provider, limit: 40
      t.string :status, limit: 16, null: false, default: 'pending'
      t.jsonb :buyer, null: false, default: {}
      t.jsonb :seller, null: false, default: {}
      t.jsonb :lines_snapshot, null: false, default: []
      t.jsonb :totals_snapshot, null: false, default: {}
      t.string :payment_method, limit: 16
      t.string :currency, limit: 3, null: false
      t.string :template_code, limit: 1
      t.string :symbol, limit: 6
      t.string :number, limit: 16
      t.string :provider_ref, limit: 100
      t.string :cqt_code, limit: 40
      t.string :lookup_code, limit: 64
      t.string :lookup_url, limit: 300
      t.datetime :issued_at
      t.datetime :signed_at
      t.datetime :sent_to_cqt_at
      t.integer :attempts, null: false, default: 0
      t.datetime :next_attempt_at
      t.text :last_error
      t.datetime :buyer_token_expires_at
      t.datetime :buyer_submitted_at
      t.datetime :canceled_at
      t.string :cancel_reason, limit: 200
      t.timestamps
    end
    add_index :spree_pos_einvoices, :order_id, unique: true, where: "relation = 'original'", name: 'idx_pos_einvoices_original_order'
    add_index :spree_pos_einvoices, %i[store_id status next_attempt_at], name: 'idx_pos_einvoices_queue'
    add_check_constraint :spree_pos_einvoices, STATUSES, name: 'chk_pos_einvoices_status'
    add_check_constraint :spree_pos_einvoices, "invoice_type IN ('cash_register', 'coded')", name: 'chk_pos_einvoices_type'
    add_check_constraint :spree_pos_einvoices, "relation IN ('original', 'replacement')", name: 'chk_pos_einvoices_relation'
    add_check_constraint :spree_pos_einvoices, "(relation = 'original') = (original_einvoice_id IS NULL)",
                         name: 'chk_pos_einvoices_original'
  end
end
