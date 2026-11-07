# frozen_string_literal: true

# Partial indexes for the operational metrics: the few rows that still need
# attention (unresolved tenders, undelivered outbox entries, held cash) are
# found without scanning the history of a busy branch or store.
class AddPosOperationalMetricsIndexes < ActiveRecord::Migration[8.1]
  def change
    add_index :spree_pos_tender_attempts, %i[branch_id created_at], where: "status IN ('prepared', 'unknown')",
                                                                    name: 'idx_pos_tender_attempts_unresolved'
    add_index :spree_pos_outbox_entries, %i[store_id status available_at], where: "status IN ('pending', 'failed')",
                                                                           name: 'idx_pos_outbox_undelivered'
    add_index :spree_pos_received_funds, :branch_id, where: "kind = 'cash' AND custody = 'held'",
                                                     name: 'idx_pos_received_funds_held_cash'
  end
end
