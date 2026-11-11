# frozen_string_literal: true

# How long each kitchen item took and whether it was late, written when it
# becomes ready, and how often it was called back. Kitchen timing reports
# read these columns; the board reads items of a ticket by status.
class AddRecallAndTimingToPosKitchenTicketItems < ActiveRecord::Migration[8.1]
  def change
    change_table :spree_pos_kitchen_ticket_items, bulk: true do |t|
      t.datetime :recalled_at
      t.integer :recall_count, null: false, default: 0
      t.integer :prep_seconds
      t.boolean :late, null: false, default: false
    end
    add_check_constraint :spree_pos_kitchen_ticket_items, 'recall_count >= 0 AND (prep_seconds IS NULL OR prep_seconds >= 0)',
                         name: 'chk_pos_kitchen_ticket_items_timing'
    add_index :spree_pos_kitchen_ticket_items, %i[kitchen_ticket_id status], name: 'idx_pos_kitchen_ticket_items_status'
    add_index :spree_pos_kitchen_ticket_items, :ready_at, where: 'ready_at IS NOT NULL', name: 'idx_pos_kitchen_ticket_items_ready'
  end
end
