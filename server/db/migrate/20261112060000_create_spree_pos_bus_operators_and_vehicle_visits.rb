# frozen_string_literal: true

# A rest stop's coach visits. A bus operator (nhà xe) is a name the stop
# pays commission to; a visit is one coach stopping with its driver, plate,
# type and guest count. Closing a visit stores the commission worked out at
# that moment (the snapshot); paying it records how it left the stop: a
# cash out request on the payer's drawer or a bank transfer reference. A
# cash out request pays one visit only.
class CreateSpreePosBusOperatorsAndVehicleVisits < ActiveRecord::Migration[8.1]
  def change
    create_table :spree_pos_bus_operators do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }, index: false
      t.string :name, null: false, limit: 120
      t.string :phone, limit: 32
      t.string :note, limit: 500
      t.string :status, null: false, limit: 16, default: 'active'
      t.timestamps
    end
    add_index :spree_pos_bus_operators, %i[store_id name], unique: true, name: 'idx_pos_bus_operators_name'
    add_check_constraint :spree_pos_bus_operators, "status IN ('active', 'archived')", name: 'chk_pos_bus_operators_status'

    create_table :spree_pos_vehicle_visits do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }, index: false
      t.references :branch, null: false, foreign_key: { to_table: :spree_pos_branches }, index: false
      t.references :bus_operator, foreign_key: { to_table: :spree_pos_bus_operators }
      t.string :plate, null: false, limit: 20
      t.string :vehicle_type, null: false, limit: 16, default: 'other'
      t.string :driver_name, limit: 120
      t.string :driver_phone, limit: 32
      t.integer :guest_count, null: false, default: 0
      t.datetime :arrived_at, null: false
      t.datetime :closes_at, null: false
      t.datetime :closed_at
      t.string :status, null: false, limit: 16, default: 'open'
      t.date :business_date, null: false
      t.references :opened_by, null: false, foreign_key: { to_table: :spree_admin_users }, index: false
      t.references :closed_by, foreign_key: { to_table: :spree_admin_users }, index: false
      t.boolean :auto_closed, null: false, default: false
      t.jsonb :commission_snapshot
      t.decimal :commission_amount, precision: 19, scale: 4
      t.decimal :revenue_amount, precision: 19, scale: 4
      t.string :currency, null: false, limit: 3
      t.datetime :paid_at
      t.references :paid_by, foreign_key: { to_table: :spree_admin_users }, index: false
      t.string :payout_method, limit: 16
      t.references :cash_movement_request, foreign_key: { to_table: :spree_pos_cash_movement_requests }, index: { unique: true }
      t.string :transfer_reference, limit: 120
      t.string :void_reason, limit: 200
      t.string :note, limit: 500
      t.integer :revision, null: false, default: 0
      t.timestamps
    end
    add_index :spree_pos_vehicle_visits, %i[branch_id business_date], name: 'idx_pos_vehicle_visits_day'
    add_index :spree_pos_vehicle_visits, %i[branch_id plate status], name: 'idx_pos_vehicle_visits_plate'
    add_index :spree_pos_vehicle_visits, :closes_at, where: "status = 'open'", name: 'idx_pos_vehicle_visits_open_until'
    add_check_constraint :spree_pos_vehicle_visits,
                         "status IN ('open', 'closed', 'paid', 'voided') AND " \
                         "vehicle_type IN ('seat_16', 'seat_29', 'seat_45', 'other') AND " \
                         'guest_count BETWEEN 0 AND 999 AND closes_at >= arrived_at AND ' \
                         '(commission_amount IS NULL OR commission_amount >= 0) AND ' \
                         "(status IN ('open', 'voided') OR (closed_at IS NOT NULL AND commission_amount IS NOT NULL AND " \
                         'commission_snapshot IS NOT NULL))',
                         name: 'chk_pos_vehicle_visits_values'
    add_check_constraint :spree_pos_vehicle_visits,
                         "(status = 'paid') = (payout_method IS NOT NULL) AND " \
                         "(payout_method IS NULL OR (paid_at IS NOT NULL AND paid_by_id IS NOT NULL AND (" \
                         "(payout_method = 'cash' AND cash_movement_request_id IS NOT NULL AND transfer_reference IS NULL) OR " \
                         "(payout_method = 'transfer' AND transfer_reference IS NOT NULL AND cash_movement_request_id IS NULL))))",
                         name: 'chk_pos_vehicle_visits_payout'

    # How long a visit stays open before it closes by itself.
    add_column :spree_pos_branches, :vehicle_visit_window_minutes, :integer, null: false, default: 60
    add_check_constraint :spree_pos_branches, 'vehicle_visit_window_minutes BETWEEN 5 AND 1440',
                         name: 'chk_pos_branches_vehicle_visit_window'
  end
end
