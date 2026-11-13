# frozen_string_literal: true

# How long a table may stay seated before the floor flags it. Null turns the
# alert off.
class AddSeatedAlertMinutesToPosBranches < ActiveRecord::Migration[8.1]
  def change
    add_column :spree_pos_branches, :seated_alert_minutes, :integer, default: 60
    add_check_constraint :spree_pos_branches, 'seated_alert_minutes IS NULL OR seated_alert_minutes BETWEEN 10 AND 600',
                         name: 'chk_pos_branches_seated_alert_minutes'
  end
end
