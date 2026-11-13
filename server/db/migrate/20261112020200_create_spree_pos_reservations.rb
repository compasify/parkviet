# frozen_string_literal: true

# Bookings of tables and rooms, the time each one holds them, and the
# deposits taken for them. Two active holds of one table can never overlap:
# the database refuses it (btree_gist exclusion), whatever the application
# checked first. A deposit is money kept for the guest (ReceivedFunds
# without an order), so it only names the funds and how it was resolved.
class CreateSpreePosReservations < ActiveRecord::Migration[8.1]
  def change
    enable_extension 'btree_gist'

    create_table :spree_pos_reservations do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }, index: false
      t.references :branch, null: false, foreign_key: { to_table: :spree_pos_branches }, index: false
      t.references :customer_profile, foreign_key: { to_table: :spree_pos_customers }
      t.string :guest_name, null: false
      t.string :phone
      t.integer :party_size, null: false
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false
      t.string :source, null: false, default: 'phone'
      t.string :status, null: false, default: 'booked'
      t.text :note
      t.references :workspace, foreign_key: { to_table: :spree_pos_workspaces, on_delete: :nullify }
      t.references :created_by, null: false, foreign_key: { to_table: :spree_admin_users }
      # Approvals of a deposit refund or forfeit are bound to this version.
      t.integer :revision, null: false, default: 0
      t.datetime :seated_at
      t.datetime :canceled_at
      t.timestamps
    end
    add_index :spree_pos_reservations, %i[branch_id starts_at], name: 'idx_pos_reservations_branch_time'
    add_check_constraint :spree_pos_reservations,
                         "status IN ('booked', 'seated', 'completed', 'no_show', 'canceled') AND " \
                         "source IN ('phone', 'walk_in', 'online') AND party_size BETWEEN 1 AND 999 AND ends_at > starts_at",
                         name: 'chk_pos_reservations_values'

    create_table :spree_pos_reservation_resources do |t|
      t.references :reservation, null: false, foreign_key: { to_table: :spree_pos_reservations, on_delete: :cascade }
      t.references :resource, null: false, foreign_key: { to_table: :spree_pos_resources }, index: false
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false
      t.boolean :active, null: false, default: true
      t.timestamps
    end
    add_check_constraint :spree_pos_reservation_resources, 'ends_at > starts_at', name: 'chk_pos_reservation_resources_range'
    add_exclusion_constraint :spree_pos_reservation_resources, 'resource_id WITH =, tsrange(starts_at, ends_at) WITH &&',
                             using: :gist, where: 'active = true', name: 'excl_pos_reservation_resources_overlap'

    create_table :spree_pos_reservation_deposits do |t|
      t.references :reservation, null: false, foreign_key: { to_table: :spree_pos_reservations }
      t.references :received_funds, null: false, foreign_key: { to_table: :spree_pos_received_funds }, index: { unique: true }
      t.decimal :amount, precision: 19, scale: 4, null: false
      t.string :currency, null: false
      t.string :status, null: false, default: 'held'
      t.references :resolution_order, foreign_key: { to_table: :spree_orders }
      t.references :liability_payout, foreign_key: { to_table: :spree_pos_liability_payouts }
      t.references :funds_allocation, foreign_key: { to_table: :spree_pos_funds_allocations }
      t.references :actor, null: false, foreign_key: { to_table: :spree_admin_users }
      t.datetime :resolved_at
      t.timestamps
    end
    add_check_constraint :spree_pos_reservation_deposits,
                         "status IN ('held', 'applied', 'refunded', 'forfeited') AND amount > 0",
                         name: 'chk_pos_reservation_deposits_values'

    change_table :spree_pos_branches, bulk: true do |t|
      # A booking still waiting this long after its time becomes a no-show.
      t.integer :reservation_grace_minutes, null: false, default: 15
      # How long a booking holds its table unless the booking says otherwise.
      t.integer :reservation_duration_minutes, null: false, default: 120
      # The service sold when a deposit is forfeited (a taxed "holding fee").
      t.references :reservation_fee_product, foreign_key: { to_table: :spree_products }, index: false
    end
  end
end
