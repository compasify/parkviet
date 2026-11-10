# frozen_string_literal: true

# Spree 6 tax rates have no starts_at or expires_at. A schedule row is the
# dated amount; ApplyTaxRateScheduleJob writes it onto the rate when due.
class CreateSpreePosTaxRateSchedules < ActiveRecord::Migration[8.1]
  def change
    create_table :spree_pos_tax_rate_schedules do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }
      t.references :tax_rate, null: false, foreign_key: { to_table: :spree_tax_rates }
      t.decimal :amount, precision: 8, scale: 5, null: false
      t.date :effective_on, null: false
      t.datetime :applied_at
      t.timestamps
    end
    add_index :spree_pos_tax_rate_schedules, %i[tax_rate_id effective_on],
              unique: true, name: 'idx_pos_tax_rate_schedules_rate_day'
  end
end
