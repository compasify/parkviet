# frozen_string_literal: true

class CreateSpreePosDiscountIntents < ActiveRecord::Migration[8.1]
  def change
    create_table :spree_pos_discount_intents do |t|
      t.references :workspace, null: false, foreign_key: { to_table: :spree_pos_workspaces }, index: { unique: true }
      t.bigint :actor_id, null: false
      t.string :value_type, null: false
      t.string :value, null: false, limit: 64
      t.string :reason, null: false, limit: 200
      t.timestamps
    end
    add_foreign_key :spree_pos_discount_intents, :spree_admin_users, column: :actor_id
    add_check_constraint :spree_pos_discount_intents, "value_type IN ('flat', 'percent')", name: 'chk_pos_discount_intent_type'

    create_table :spree_pos_discount_allocations do |t|
      t.references :discount_intent, null: false, foreign_key: { to_table: :spree_pos_discount_intents }
      t.references :discount, null: false, index: { unique: true }, foreign_key: { to_table: :spree_discounts, on_delete: :cascade }
      t.timestamps
    end
  end
end
