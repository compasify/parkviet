# frozen_string_literal: true

# The payment methods a branch offers. A branch without rows offers every
# active method of the store, so branches that never chose keep working.
class CreateSpreePosBranchPaymentMethods < ActiveRecord::Migration[8.1]
  def change
    create_table :spree_pos_branch_payment_methods do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }
      t.references :branch, null: false, index: false, foreign_key: { to_table: :spree_pos_branches }
      t.references :pos_payment_method, null: false, foreign_key: { to_table: :spree_pos_payment_methods }
      t.timestamps
    end
    add_index :spree_pos_branch_payment_methods, %i[branch_id pos_payment_method_id], unique: true,
                                                                                      name: 'idx_pos_branch_payment_methods_unique'
  end
end
