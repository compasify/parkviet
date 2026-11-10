# frozen_string_literal: true

# PIN for shared devices. Only the bcrypt digest is stored; a manager can
# clear it and cannot read it.
class AddPinToPosStaffMemberships < ActiveRecord::Migration[8.1]
  def change
    change_table :spree_pos_staff_memberships, bulk: true do |t|
      t.string :pin_digest
      t.datetime :pin_set_at
    end
  end
end
