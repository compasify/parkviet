# frozen_string_literal: true

# When the seller last sent the customer a debt reminder ("nhắc nợ"), shown
# on the list of customers who owe. Who sent it is in the audit log.
class AddLastRemindedAtToSpreePosCreditAccounts < ActiveRecord::Migration[8.1]
  def change
    add_column :spree_pos_credit_accounts, :last_reminded_at, :datetime
  end
end
