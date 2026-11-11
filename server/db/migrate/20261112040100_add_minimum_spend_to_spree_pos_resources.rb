# frozen_string_literal: true

# The least a VIP table must spend on items. Below it the order carries a
# taxed fee for the difference (Fnb::MinimumSpend).
class AddMinimumSpendToSpreePosResources < ActiveRecord::Migration[8.1]
  def change
    add_column :spree_pos_resources, :minimum_spend, :decimal, precision: 19, scale: 4
    add_column :spree_pos_resources, :minimum_spend_currency, :string, limit: 16
    add_check_constraint :spree_pos_resources,
                         '(minimum_spend IS NULL AND minimum_spend_currency IS NULL) OR ' \
                         '(minimum_spend > 0 AND minimum_spend_currency IS NOT NULL)',
                         name: 'chk_pos_resources_minimum_spend'
  end
end
