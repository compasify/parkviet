# frozen_string_literal: true

# Wall-clock time, in the branch timezone, when a new business day starts.
# The default 04:00 keeps sales after midnight on the previous business day.
class AddBusinessDayCutoffToPosBranches < ActiveRecord::Migration[8.1]
  def change
    add_column :spree_pos_branches, :business_day_cutoff, :time, null: false, default: '04:00:00'
  end
end
