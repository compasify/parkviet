# frozen_string_literal: true

class CreatePosWalkInOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :pos_walk_in_orders do |t|
      t.references :order, null: false, index: { unique: true }, foreign_key: { to_table: :spree_orders }
      t.timestamps
    end
  end
end
