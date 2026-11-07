# frozen_string_literal: true

# Opens serial/lot-tracked stock for a variant at a branch location the way an
# opening balance leaves it: the core shelf holds exactly the typed units and
# the pair is enrolled. Setup only; behaviour specs use the POS workflows.
module PosTraceHelpers
  def trace_core_to!(location, variant, quantity)
    level = location.stock_level_or_create(variant)
    delta = quantity - level.reload.count_on_hand
    location.adjust(variant, delta, reason: 'spec setup') unless delta.zero?
  end

  def enroll_serials!(branch, variant, serials, opened_by:)
    location = branch.stock_location
    trace_core_to!(location, variant, serials.size)
    serials.each do |serial|
      Spree::Pos::SerialUnit.create!(store_id: branch.store_id, variant: variant, stock_location: location, serial: serial)
    end
    Spree::Pos::TraceEnrollment.create!(store_id: branch.store_id, variant: variant, stock_location: location, branch: branch,
                                        opened_by: opened_by, tracked_mode: 'serial', opening_quantity: serials.size)
  end

  # lots: [[code, expiry_on, quantity], ...]
  def enroll_lots!(branch, variant, lots, opened_by:)
    location = branch.stock_location
    trace_core_to!(location, variant, lots.sum { |row| row[2] })
    created = lots.map do |code, expiry_on, quantity|
      Spree::Pos::InventoryLot.create!(store_id: branch.store_id, variant: variant, stock_location: location, lot_code: code,
                                       expiry_on: expiry_on, received_quantity: quantity, on_hand: quantity)
    end
    Spree::Pos::TraceEnrollment.create!(store_id: branch.store_id, variant: variant, stock_location: location, branch: branch,
                                        opened_by: opened_by, tracked_mode: 'lot', opening_quantity: lots.sum { |row| row[2] })
    created
  end

  def track_variant!(store, variant, mode, sale_unit: 'item', base_unit: nil, ratio: [1, 1])
    Spree::Pos::UnitDefinition.ensure_defaults!(store)
    sale = Spree::Pos::UnitDefinition.find_by!(store: store, code: sale_unit)
    base = Spree::Pos::UnitDefinition.find_by!(store: store, code: base_unit || sale.base_code)
    record = Spree::Pos::VariantUnit.find_or_initialize_by(store: store, variant: variant)
    record.update!(sale_unit: sale, base_unit: base, price_unit: sale, ratio_numerator: ratio[0], ratio_denominator: ratio[1],
                   tracked_mode: mode, status: 'active', version: (record.version || 0) + 1)
    record
  end
end
