# frozen_string_literal: true

require_relative '../../../support/pos_return_helpers'
require_relative '../../../support/pos_race_helpers'
require_relative '../../../support/pos_trace_helpers'

# Serial and lot stock racing over two database connections: every trace
# writer of a (variant, location) pair takes the core stock level row first,
# so contenders queue there and the loser sees the winner's committed state.
RSpec.describe 'POS traceability races', type: :integration do
  include PosReturnHelpers
  include PosTraceHelpers

  include_context 'with committed POS race rows'

  manage = Spree::Pos::Capabilities::INVENTORY_MANAGE

  before do
    @branch = returns_branch(store)
    @cashiers = 2.times.map { credit_staff(store, @branch, PosReturnHelpers::RETURNS + [manage]) }
  end

  def tracked_product(mode)
    # Committed rows outlive the factory's per-process SKU sequence.
    product = create(:product, store: store, status: 'active', name: "Hang #{SecureRandom.hex(3)}", sku: "TRACE-#{SecureRandom.hex(5)}")
    product.default_variant.set_price(store.default_currency, 10_000)
    Spree::Pos::BranchProduct.create!(branch: @branch, product: product)
    track_variant!(store, product.default_variant, mode)
    product
  end

  def draft(staff)
    editor_id = SecureRandom.uuid
    register = open_drawer(store, @branch, staff)
    created = Spree::Pos::Workspaces::Create.call(store: store, staff: staff, register_id: register.prefixed_id,
                                                  key: SecureRandom.uuid, editor_id: editor_id)
    PosCreditHelpers::Sale.new(workspace: Spree::Pos::Workspace.find_by_prefix_id!(created['id']), cashier: staff, editor_id: editor_id)
  end

  def add(sale, product, **params)
    workspace = sale.workspace.reload
    Spree::Pos::Workspaces::ManageLineItem.add(workspace: workspace, staff: sale.cashier, revision: workspace.revision,
                                               lease_generation: workspace.lease_generation, editor_id: sale.editor_id,
                                               key: SecureRandom.uuid, variant_id: product.default_variant.prefixed_id, **params)
  end

  def level(product)
    @branch.stock_location.stock_level(product.default_variant).reload
  end

  it 'gives the same serial to one of two counters' do
    phone = tracked_product('serial')
    enroll_serials!(@branch, phone.default_variant, ['IMEI-RACE'], opened_by: @cashiers.first)
    sales = @cashiers.map { |staff| draft(staff) }

    results = race(level(phone)) { |index| add(sales[index], phone, quantity: 1, serial_codes: ['IMEI-RACE']) }

    expect(results.map(&:first)).to contain_exactly(:success, :conflict)
    expect(results.find { |(kind, _)| kind == :conflict }.last).to include('held by another counter')
    expect(Spree::Pos::TraceAllocation.where(serial_unit: Spree::Pos::SerialUnit.find_by!(serial: 'IMEI-RACE'), status: 'reserved').count).to eq(1)
  end

  it 'lets only one of two sales take the last lot unit' do
    milk = tracked_product('lot')
    enroll_lots!(@branch, milk.default_variant, [['LAST', Date.current + 5, 1]], opened_by: @cashiers.first)
    sales = @cashiers.map { |staff| draft(staff).tap { |sale| add(sale, milk, quantity: 1) } }

    results = race(level(milk)) { |index| take_tender(sales[index], 'cash', 10_000) }

    expect(results.map(&:first)).to contain_exactly(:success, :conflict)
    expect(results.find { |(kind, _)| kind == :conflict }.last).to include('available in sellable lots')
    last_lot = Spree::Pos::InventoryLot.find_by!(lot_code: 'LAST')
    expect(Spree::Pos::TraceAllocation.where(inventory_lot: last_lot, status: 'reserved').sum(:quantity)).to eq(1)
    expect(Spree::Pos::ReceivedFunds.where(workspace_id: sales.map { |sale| sale.workspace.id }).count).to eq(1)
  end

  it 'never moves lot units a racing sale has reserved' do
    milk = tracked_product('lot')
    lot = enroll_lots!(@branch, milk.default_variant, [['MOVE', Date.current + 5, 3]], opened_by: @cashiers.first).first
    target = returns_branch(store)
    Spree::Pos::BranchProduct.create!(branch: target, product: milk)
    Spree::Pos::StaffMembership.create!(store: store, branch: target, staff: @cashiers.last, capabilities: [manage], status: 'active')
    Spree::Pos::TraceEnrollment.create!(store: store, variant: milk.default_variant, stock_location: target.stock_location, branch: target,
                                        opened_by: @cashiers.last, tracked_mode: 'lot', opening_quantity: 0)
    sale = draft(@cashiers.first)
    add(sale, milk, quantity: 2)

    results = race(level(milk)) do |index|
      if index.zero?
        take_tender(sale, 'cash', 20_000)
      else
        Spree::Pos::Inventory::TransferTraceability.call(store: store, staff: @cashiers.last, key: SecureRandom.uuid,
                                                         from_branch_id: @branch.prefixed_id, to_branch_id: target.prefixed_id,
                                                         variant_id: milk.default_variant.prefixed_id,
                                                         lots: [{ lot_id: lot.prefixed_id, quantity: 2 }])
      end
    end

    lot.reload
    reserved = Spree::Pos::TraceAllocation.where(inventory_lot_id: lot.id, status: 'reserved').sum(:quantity)
    moved = Spree::Pos::InventoryLot.find_by(stock_location_id: target.stock_location_id, lot_code: 'MOVE')&.on_hand.to_i
    expect(results.map(&:first)).to include(:success)
    expect(results.map(&:first)).not_to include(:error)
    expect(reserved + moved).to be <= 3
    expect(lot.on_hand).to eq(3 - moved)
    expect(reserved).to be <= lot.on_hand
    expect(level(milk).count_on_hand).to eq(lot.on_hand)
    expect(results.count { |(kind, _)| kind == :success }).to eq(1)
  end
end
