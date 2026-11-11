# frozen_string_literal: true

# The print queue. `attempts` also fences reports: a report names the attempt
# it belongs to, and `attempt_reports` keeps what each attempt said so a retry
# of the same report changes nothing.
class CreatePosPrintJobs < ActiveRecord::Migration[8.1]
  def change
    create_table :spree_pos_print_jobs do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }, index: false
      t.references :branch, null: false, foreign_key: { to_table: :spree_pos_branches }
      t.references :printer, null: false, index: false, foreign_key: { to_table: :spree_pos_printers, on_delete: :restrict }
      t.string :kind, null: false
      t.jsonb :document, null: false
      t.string :source_type
      t.bigint :source_id
      t.integer :source_revision
      t.string :status, null: false, default: 'queued'
      t.integer :attempts, null: false, default: 0
      t.references :claimed_by_device, foreign_key: { to_table: :spree_pos_devices }
      t.datetime :claim_expires_at
      t.datetime :printed_at
      t.string :last_error
      t.jsonb :attempt_reports, null: false, default: {}
      t.string :idempotency_key, null: false
      t.bigint :created_by_id
      t.references :copy_of, foreign_key: { to_table: :spree_pos_print_jobs, on_delete: :restrict }
      t.references :receipt_print, foreign_key: { to_table: :spree_pos_receipt_prints, on_delete: :restrict }
      t.timestamps
    end
    add_foreign_key :spree_pos_print_jobs, :spree_admin_users, column: :created_by_id
    add_index :spree_pos_print_jobs, %i[printer_id status id], name: 'idx_pos_print_jobs_queue'
    add_index :spree_pos_print_jobs, %i[store_id idempotency_key], unique: true, name: 'idx_pos_print_jobs_key'
    add_index :spree_pos_print_jobs, %i[source_type source_id], name: 'idx_pos_print_jobs_source'
    add_index :spree_pos_print_jobs, :claim_expires_at, where: "status = 'claimed'", name: 'idx_pos_print_jobs_leases'
    add_check_constraint :spree_pos_print_jobs,
                         "kind IN ('receipt', 'prebill', 'kitchen_ticket', 'void_ticket', 'cup_label', 'checklist', 'table_qr', 'test')",
                         name: 'chk_pos_print_jobs_kind'
    add_check_constraint :spree_pos_print_jobs,
                         "status IN ('queued', 'claimed', 'printed', 'failed', 'canceled')",
                         name: 'chk_pos_print_jobs_status'
    add_check_constraint :spree_pos_print_jobs, 'attempts >= 0', name: 'chk_pos_print_jobs_attempts'
  end
end
