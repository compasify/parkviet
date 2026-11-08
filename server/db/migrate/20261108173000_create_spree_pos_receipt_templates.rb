# frozen_string_literal: true

# Print templates of a store's POS documents. Every save keeps an immutable
# version, and every recorded print keeps the template, version and paper it
# was printed with, so a reprint can reproduce the original. A template is
# disabled, never deleted, because old prints still point at it.
class CreateSpreePosReceiptTemplates < ActiveRecord::Migration[8.1]
  PAPERS = "('58mm', '80mm', 'a4', 'a5', 'a6')"

  def change
    create_table :spree_pos_receipt_templates do |t|
      t.references :store, null: false, index: false, foreign_key: { to_table: :spree_stores }
      t.string :name, null: false
      t.string :document_type, null: false
      t.string :paper, null: false
      t.string :status, null: false, default: 'active'
      t.boolean :is_default, null: false, default: false
      t.integer :current_version, null: false, default: 1
      t.bigint :created_by_id
      t.bigint :updated_by_id
      t.timestamps
    end
    add_index :spree_pos_receipt_templates, %i[store_id document_type], unique: true,
                                                                        where: "is_default AND status = 'active'",
                                                                        name: 'idx_pos_receipt_templates_default'
    add_index :spree_pos_receipt_templates, %i[store_id document_type status], name: 'idx_pos_receipt_templates_type'
    add_foreign_key :spree_pos_receipt_templates, :spree_admin_users, column: :created_by_id
    add_foreign_key :spree_pos_receipt_templates, :spree_admin_users, column: :updated_by_id
    add_check_constraint :spree_pos_receipt_templates,
                         "document_type IN ('sale', 'prebill', 'payment_ticket', 'return', 'refund', 'shift_closure')",
                         name: 'chk_pos_receipt_templates_document_type'
    add_check_constraint :spree_pos_receipt_templates, "paper IN #{PAPERS}", name: 'chk_pos_receipt_templates_paper'
    add_check_constraint :spree_pos_receipt_templates, "status IN ('active', 'disabled')",
                         name: 'chk_pos_receipt_templates_status'
    add_check_constraint :spree_pos_receipt_templates, 'current_version >= 1',
                         name: 'chk_pos_receipt_templates_current_version'

    create_table :spree_pos_receipt_template_versions do |t|
      t.references :receipt_template, null: false, index: false, foreign_key: { to_table: :spree_pos_receipt_templates }
      t.integer :version, null: false
      t.jsonb :config, null: false
      t.bigint :created_by_id
      t.datetime :created_at, null: false
    end
    add_index :spree_pos_receipt_template_versions, %i[receipt_template_id version], unique: true,
                                                                                     name: 'idx_pos_receipt_template_versions_version'
    add_foreign_key :spree_pos_receipt_template_versions, :spree_admin_users, column: :created_by_id
    add_check_constraint :spree_pos_receipt_template_versions, 'version >= 1',
                         name: 'chk_pos_receipt_template_versions_version'

    add_column :spree_pos_receipt_prints, :receipt_template_id, :bigint
    add_column :spree_pos_receipt_prints, :template_version, :integer
    add_column :spree_pos_receipt_prints, :paper, :string
    add_index :spree_pos_receipt_prints, :receipt_template_id, name: 'idx_pos_receipt_prints_template'
    add_foreign_key :spree_pos_receipt_prints, :spree_pos_receipt_templates, column: :receipt_template_id
    add_check_constraint :spree_pos_receipt_prints, "paper IS NULL OR paper IN #{PAPERS}", name: 'chk_pos_receipt_prints_paper'
  end
end
