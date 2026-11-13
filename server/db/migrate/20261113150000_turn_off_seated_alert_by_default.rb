# frozen_string_literal: true

# Eating out is not timed in Vietnam: minutes seated are shown for reference
# only, and the long-seated alert is off until a branch turns it on.
class TurnOffSeatedAlertByDefault < ActiveRecord::Migration[8.1]
  def up
    change_column_default :spree_pos_branches, :seated_alert_minutes, from: 60, to: nil
    execute 'UPDATE spree_pos_branches SET seated_alert_minutes = NULL WHERE seated_alert_minutes = 60'
  end

  def down
    change_column_default :spree_pos_branches, :seated_alert_minutes, from: nil, to: 60
  end
end
