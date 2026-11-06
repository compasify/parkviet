# frozen_string_literal: true

class CreateSpreePosCustomers < ActiveRecord::Migration[8.1]
  def change
    create_table :spree_pos_customers do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }
      t.references :customer, foreign_key: { to_table: :spree_customers }
      t.bigint :created_by_id, null: false
      t.string :name, null: false, limit: 120
      t.string :phone, limit: 32
      t.string :normalized_phone, limit: 32
      t.string :email, limit: 254
      t.timestamps
    end
    add_foreign_key :spree_pos_customers, :spree_admin_users, column: :created_by_id
    add_index :spree_pos_customers, [:store_id, :normalized_phone], name: 'idx_pos_customers_store_phone'
    add_index :spree_pos_customers, [:store_id, :email], name: 'idx_pos_customers_store_email'

    add_reference :spree_pos_workspaces, :pos_customer, foreign_key: { to_table: :spree_pos_customers }
  end
end
