# frozen_string_literal: true

class CreateSpreePosBranchProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :spree_pos_branch_products do |t|
      t.references :branch, null: false, foreign_key: { to_table: :spree_pos_branches }
      t.references :product, null: false, foreign_key: { to_table: :spree_products }
      t.timestamps
    end
    add_index :spree_pos_branch_products, [:branch_id, :product_id], unique: true, name: 'idx_pos_branch_product_unique'
  end
end
