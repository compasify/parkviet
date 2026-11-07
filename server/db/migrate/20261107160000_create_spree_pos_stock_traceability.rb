# frozen_string_literal: true

# Typed stock traceability for opt-in tracked variants (serial/IMEI units or
# batch lots with expiry) at branch stock locations.
#
# - An enrollment opens a (variant, stock location) pair for tracking after
#   an opening balance whose typed total equals the core count there. From
#   then on core stock writes of that pair are only accepted from the POS
#   trace workflows, which change typed records and core counters together.
# - Serial units are unique per store, variant and serial.
# - Lots hold integer base units: on hand (sellable while the lot is active)
#   and quarantined units (held, never sellable).
# - A trace allocation ties one sale line to one serial unit or one lot for a
#   quantity in base units: reserved for a draft (owner-bound, with a TTL),
#   committed when the order is placed, consumed when the goods are handed
#   over. A serial can hold at most one live allocation.
# - Trace returns take quantities back from allocations, exactly once.
# - Inventory adjustments are counts that may wait for an approval.
class CreateSpreePosStockTraceability < ActiveRecord::Migration[8.1]
  def change
    add_column :spree_pos_branches, :lot_selection, :string, limit: 16, null: false, default: 'fefo'
    add_column :spree_pos_branches, :adjustment_approval_threshold, :bigint
    add_check_constraint :spree_pos_branches, "lot_selection IN ('fefo', 'cashier_pick')", name: 'chk_pos_branches_lot_selection'
    add_check_constraint :spree_pos_branches, 'adjustment_approval_threshold IS NULL OR adjustment_approval_threshold >= 0',
                         name: 'chk_pos_branches_adjustment_threshold'

    create_table :spree_pos_trace_enrollments do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }
      t.references :variant, null: false, foreign_key: { to_table: :spree_variants }, index: false
      t.references :stock_location, null: false, foreign_key: { to_table: :spree_stock_locations }
      t.references :branch, null: false, foreign_key: { to_table: :spree_pos_branches }
      t.references :opened_by, null: false
      t.string :tracked_mode, null: false, limit: 16
      t.bigint :opening_quantity, null: false
      t.timestamps
    end
    add_foreign_key :spree_pos_trace_enrollments, :spree_admin_users, column: :opened_by_id
    add_index :spree_pos_trace_enrollments, %i[variant_id stock_location_id], unique: true, name: 'idx_pos_trace_enrollments_pair'
    add_check_constraint :spree_pos_trace_enrollments, "tracked_mode IN ('serial', 'lot')", name: 'chk_pos_trace_enrollments_mode'
    add_check_constraint :spree_pos_trace_enrollments, 'opening_quantity >= 0', name: 'chk_pos_trace_enrollments_opening'

    create_table :spree_pos_inventory_lots do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }
      t.references :variant, null: false, foreign_key: { to_table: :spree_variants }, index: false
      t.references :stock_location, null: false, foreign_key: { to_table: :spree_stock_locations }, index: false
      t.references :source_lot, foreign_key: { to_table: :spree_pos_inventory_lots }
      t.references :quarantined_by
      t.string :lot_code, null: false, limit: 64
      t.date :expiry_on
      t.string :status, null: false, default: 'active', limit: 16
      t.bigint :received_quantity, null: false, default: 0
      t.bigint :on_hand, null: false, default: 0
      t.bigint :quarantined_quantity, null: false, default: 0
      t.string :quarantine_reason, limit: 200
      t.datetime :quarantined_at
      t.timestamps
    end
    add_index :spree_pos_inventory_lots, %i[stock_location_id variant_id lot_code], unique: true, name: 'idx_pos_inventory_lots_code'
    add_index :spree_pos_inventory_lots, %i[variant_id stock_location_id status expiry_on], name: 'idx_pos_inventory_lots_fefo'
    add_index :spree_pos_inventory_lots, %i[store_id lot_code], name: 'idx_pos_inventory_lots_recall'
    add_check_constraint :spree_pos_inventory_lots, "status IN ('active', 'quarantined', 'expired')", name: 'chk_pos_inventory_lots_status'
    add_check_constraint :spree_pos_inventory_lots, 'on_hand >= 0 AND quarantined_quantity >= 0 AND received_quantity >= 0',
                         name: 'chk_pos_inventory_lots_quantities'

    create_table :spree_pos_serial_units do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }, index: false
      t.references :variant, null: false, foreign_key: { to_table: :spree_variants }
      t.references :stock_location, null: false, foreign_key: { to_table: :spree_stock_locations }
      t.string :serial, null: false, limit: 100
      t.string :status, null: false, default: 'in_stock', limit: 16
      t.string :quarantine_reason, limit: 200
      t.datetime :returned_at
      t.timestamps
    end
    add_index :spree_pos_serial_units, %i[store_id variant_id serial], unique: true, name: 'idx_pos_serial_units_identity'
    add_index :spree_pos_serial_units, %i[store_id serial], name: 'idx_pos_serial_units_recall'
    add_check_constraint :spree_pos_serial_units,
                         "status IN ('in_stock', 'reserved', 'sold', 'returned', 'quarantined', 'removed')",
                         name: 'chk_pos_serial_units_status'

    create_table :spree_pos_trace_allocations do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }, index: false
      t.references :workspace, null: false, foreign_key: { to_table: :spree_pos_workspaces }
      t.references :sale_line, null: false, foreign_key: { to_table: :spree_pos_sale_lines, on_delete: :cascade }
      t.references :order, null: false, foreign_key: { to_table: :spree_orders }
      t.references :variant, null: false, foreign_key: { to_table: :spree_variants }, index: false
      t.references :stock_location, null: false, foreign_key: { to_table: :spree_stock_locations }, index: false
      t.references :inventory_lot, foreign_key: { to_table: :spree_pos_inventory_lots }
      t.references :serial_unit, foreign_key: { to_table: :spree_pos_serial_units }, index: false
      t.references :fulfillment_item, foreign_key: { to_table: :spree_fulfillment_items }
      t.string :status, null: false, default: 'reserved', limit: 16
      t.bigint :quantity, null: false
      t.bigint :returned_quantity, null: false, default: 0
      t.integer :lease_generation, null: false
      t.boolean :picked, null: false, default: false
      t.datetime :expires_at
      t.datetime :committed_at
      t.datetime :consumed_at
      t.datetime :released_at
      t.timestamps
    end
    # One live allocation per serial: a second counter reserving the same unit
    # fails here even if both passed the application checks. A consumed
    # allocation is history: a unit returned to stock can be sold again.
    add_index :spree_pos_trace_allocations, :serial_unit_id, unique: true, where: "status IN ('reserved', 'committed')",
                                                             name: 'idx_pos_trace_allocations_live_serial'
    add_index :spree_pos_trace_allocations, :serial_unit_id, name: 'idx_pos_trace_allocations_serial'
    add_index :spree_pos_trace_allocations, %i[inventory_lot_id status], name: 'idx_pos_trace_allocations_lot_status'
    add_index :spree_pos_trace_allocations, %i[status expires_at], name: 'idx_pos_trace_allocations_expiry'
    add_check_constraint :spree_pos_trace_allocations, "status IN ('reserved', 'committed', 'consumed', 'released')",
                         name: 'chk_pos_trace_allocations_status'
    add_check_constraint :spree_pos_trace_allocations, '(inventory_lot_id IS NULL) <> (serial_unit_id IS NULL)',
                         name: 'chk_pos_trace_allocations_subject'
    add_check_constraint :spree_pos_trace_allocations,
                         'quantity > 0 AND returned_quantity >= 0 AND returned_quantity <= quantity AND (serial_unit_id IS NULL OR quantity = 1)',
                         name: 'chk_pos_trace_allocations_quantity'

    create_table :spree_pos_trace_returns do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }, index: false
      t.references :return_operation, null: false, foreign_key: { to_table: :spree_pos_return_operations }
      t.references :trace_allocation, null: false, foreign_key: { to_table: :spree_pos_trace_allocations }
      t.references :return_lot, foreign_key: { to_table: :spree_pos_inventory_lots }
      t.bigint :quantity, null: false
      t.string :condition, null: false, limit: 16
      t.string :status, null: false, default: 'reserved', limit: 16
      t.datetime :received_at
      t.timestamps
    end
    add_check_constraint :spree_pos_trace_returns, "status IN ('reserved', 'received', 'canceled')", name: 'chk_pos_trace_returns_status'
    add_check_constraint :spree_pos_trace_returns, "condition IN ('resellable', 'damaged')", name: 'chk_pos_trace_returns_condition'
    add_check_constraint :spree_pos_trace_returns, 'quantity > 0', name: 'chk_pos_trace_returns_quantity'

    create_table :spree_pos_inventory_adjustments do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }
      t.references :branch, null: false, foreign_key: { to_table: :spree_pos_branches }
      t.references :variant, null: false, foreign_key: { to_table: :spree_variants }
      t.references :stock_location, null: false, foreign_key: { to_table: :spree_stock_locations }, index: false
      t.references :requester, null: false
      t.references :applier
      t.references :approval, foreign_key: { to_table: :spree_pos_approvals }
      t.string :status, null: false, default: 'pending_approval', limit: 32
      t.string :reason, null: false, limit: 200
      t.jsonb :lines, null: false, default: []
      t.bigint :delta, null: false, default: 0
      t.boolean :requires_approval, null: false, default: false
      t.integer :revision, null: false, default: 1
      t.datetime :applied_at
      t.datetime :canceled_at
      t.timestamps
    end
    add_foreign_key :spree_pos_inventory_adjustments, :spree_admin_users, column: :requester_id
    add_foreign_key :spree_pos_inventory_adjustments, :spree_admin_users, column: :applier_id
    add_index :spree_pos_inventory_adjustments, %i[branch_id status], name: 'idx_pos_inventory_adjustments_branch'
    add_check_constraint :spree_pos_inventory_adjustments, "status IN ('pending_approval', 'applied', 'canceled')",
                         name: 'chk_pos_inventory_adjustments_status'

    reversible do |direction|
      direction.up do
        execute "UPDATE spree_pos_variant_units SET tracked_mode = 'serial' WHERE tracked_mode = 'serial_lot'"
      end
    end
  end
end
