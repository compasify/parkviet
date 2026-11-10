# frozen_string_literal: true

# A branch may print a document type with its own template instead of the
# store default; without a row (or while the chosen template is disabled)
# the store default applies.
class CreateSpreePosBranchReceiptTemplates < ActiveRecord::Migration[8.1]
  def change
    create_table :spree_pos_branch_receipt_templates do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }
      t.references :branch, null: false, index: false, foreign_key: { to_table: :spree_pos_branches }
      t.string :document_type, null: false
      t.references :receipt_template, null: false, foreign_key: { to_table: :spree_pos_receipt_templates }
      t.timestamps
    end
    add_index :spree_pos_branch_receipt_templates, %i[branch_id document_type], unique: true,
                                                                                name: 'idx_pos_branch_receipt_templates_type'
  end
end
