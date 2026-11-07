# frozen_string_literal: true

require_relative '../../../support/pos_return_helpers'
require_relative '../../../support/pos_trace_helpers'

# Typed stock for serial/lot-tracked goods through the real POS workflows:
# exact weighted quantities, serial identity, FEFO lots, returns of tracked
# units, the guard on core stock writers, opening balances, inventory
# commands and measured packages of one variant kept apart.
RSpec.describe 'POS traceable inventory', type: :request do
  include PosReturnHelpers
  include PosTraceHelpers

  let(:stock_keeper) { [Spree::Pos::Capabilities::INVENTORY_MANAGE, Spree::Pos::Capabilities::INVENTORY_TRACE] }

  let(:store) { create(:store, default_currency: 'VND', supported_currencies: 'VND') }
  let(:branch) { returns_branch(store) }
  let(:manager) { credit_staff(store, branch, PosReturnHelpers::APPROVER + stock_keeper) }
  let(:cashier) { credit_staff(store, branch, PosReturnHelpers::RETURNS + [Spree::Pos::Capabilities::INVENTORY_MANAGE]) }

  def product_for(price:)
    product = create(:product, store: store, status: 'active', name: "Hang #{SecureRandom.hex(3)}")
    product.default_variant.set_price(store.default_currency, price)
    Spree::Pos::BranchProduct.create!(branch: branch, product: product)
    product
  end

  def variant_of(product) = product.default_variant

  def start_sale(staff = cashier, at: branch)
    editor_id = SecureRandom.uuid
    register = Spree::Pos::Shift.for_store(store).open_now.find_by(branch_id: at.id, owner_id: staff.id)&.register ||
      open_drawer(store, at, staff)
    created = Spree::Pos::Workspaces::Create.call(store: store, staff: staff, register_id: register.prefixed_id,
                                                  key: SecureRandom.uuid, editor_id: editor_id)
    workspace = Spree::Pos::Workspace.find_by_prefix_id!(created['id'])
    PosCreditHelpers::Sale.new(workspace: workspace, cashier: staff, editor_id: editor_id, product: nil)
  end

  def add_line(sale, product, **params)
    workspace = sale.workspace.reload
    Spree::Pos::Workspaces::ManageLineItem.add(workspace: workspace, staff: sale.cashier, revision: workspace.revision,
                                               lease_generation: workspace.lease_generation, editor_id: sale.editor_id,
                                               key: SecureRandom.uuid, variant_id: variant_of(product).prefixed_id, **params)
  end

  def pay_and_complete(sale)
    take_tender(sale, 'cash', sale.workspace.reload.order.total.ceil.to_i)
    Spree::Pos::Workspaces::Complete.call(**editing_args(sale))
  end

  def lines_of(sale)
    Spree::Pos::SaleLine.where(workspace_id: sale.workspace.id).order(:id).to_a
  end

  def allocations(line, statuses = %w[reserved committed consumed])
    Spree::Pos::TraceAllocation.where(sale_line_id: line.id, status: statuses).order(:id).to_a
  end

  def conflict_reason
    yield
    raise 'expected a conflict'
  rescue Spree::Pos::Conflict => e
    e.reason
  end

  def shelf(product, at: branch)
    at.stock_location.stock_level(variant_of(product)).reload
  end

  def reconciled?(product, at: branch)
    Spree::Pos::StockIntegration.blocked_reason(at, variant_of(product)).nil?
  end

  def prepare_tracked_return(sale, line, quantity:, condition: 'resellable', serial_codes: [], lot_code: nil, staff: cashier)
    Spree::Pos::Returns::Prepare.call(
      store: store, staff: staff, key: SecureRandom.uuid, branch_id: branch.prefixed_id, order_id: sale.workspace.order.prefixed_id,
      reason: 'Khách trả', lines: [{ 'sale_line_id' => line.prefixed_id, 'quantity' => quantity, 'condition' => condition,
                                     'serial_codes' => serial_codes, 'lot_code' => lot_code }]
    )
  end

  def other_branch
    @other_branch ||= returns_branch(store).tap do |row|
      Spree::Pos::StaffMembership.create!(store: store, branch: row, staff: manager, capabilities: PosReturnHelpers::APPROVER + stock_keeper,
                                          status: 'active')
    end
  end

  describe 'exact weighted quantities' do
    it 'sells 1,25 kg as 1250 g at the exact price and returns 500 g against the original snapshot' do
      cheese = product_for(price: 120_000)
      track_variant!(store, variant_of(cheese), 'lot', sale_unit: 'kg', base_unit: 'g')
      enroll_lots!(branch, variant_of(cheese), [['PHO-1', Date.current + 20, 5_000]], opened_by: manager)

      sale = start_sale
      add_line(sale, cheese, sale_quantity: '1.25', sale_unit_code: 'kg')
      line = lines_of(sale).first
      expect(line).to have_attributes(base_quantity: 1250, sale_quantity: BigDecimal('1.25'), sale_unit_code: 'kg', base_unit_code: 'g')
      expect(line.line_item.reload).to have_attributes(quantity: 1250, price: BigDecimal('120'))
      expect(sale.workspace.reload.order.total).to eq(BigDecimal('150000'))
      expect { add_line(sale, cheese, sale_quantity: '0.0005', sale_unit_code: 'kg') }.to raise_error(Spree::Pos::Conflict, /represented|precision/)
      expect { add_line(sale, cheese, sale_quantity: '1.2345', sale_unit_code: 'kg') }.to raise_error(Spree::Pos::Conflict, /represented|precision/)
      expect { add_line(sale, cheese, sale_quantity: '1,25', sale_unit_code: 'kg') }.to raise_error(Spree::Pos::Conflict, /invalid/)

      workspace = sale.workspace.reload
      Spree::Pos::Workspaces::ApplyDiscount.call(workspace: workspace, staff: cashier, revision: workspace.revision,
                                                 lease_generation: workspace.lease_generation, editor_id: sale.editor_id,
                                                 key: SecureRandom.uuid, value_type: 'flat', value: '10000', reason: 'Khách quen')
      expect(sale.workspace.reload.order.total).to eq(BigDecimal('140000'))
      pay_and_complete(sale)
      hand_over(sale)
      expect(allocations(line).sum(&:quantity)).to eq(1250)
      expect(Spree::Pos::InventoryLot.find_by!(lot_code: 'PHO-1').on_hand).to eq(3_750)
      expect(shelf(cheese).count_on_hand).to eq(3_750)

      preview = Spree::Pos::Returns::Prepare.preview(store: store, staff: cashier, branch_id: branch.prefixed_id,
                                                     order_id: sale.workspace.order.prefixed_id,
                                                     lines: [{ 'sale_line_id' => line.prefixed_id, 'quantity' => 500 }])
      row = preview[:lines].first
      expect(row[:this_time][:total]).to eq('56000.0')
      expect(row[:this_time][:tax]).to eq('0.0')
      expect(row[:trace]).to eq(mode: 'lot', serials: [], lots: [{ lot_code: 'PHO-1', expiry_on: (Date.current + 20).iso8601, quantity: 500,
                                                                   forced_quarantine: false }])

      received = receive_return(store, cashier, prepare_tracked_return(sale, line, quantity: 500))
      expect(received['entitlement_total']).to eq('56000.0')
      expect(Spree::Pos::InventoryLot.find_by!(lot_code: 'PHO-1').on_hand).to eq(4_250)
      expect(shelf(cheese).count_on_hand).to eq(4_250)
      expect(reconciled?(cheese)).to be(true)
    end
  end

  describe 'serial units' do
    let(:phone) { product_for(price: 5_000_000) }

    before do
      track_variant!(store, variant_of(phone), 'serial')
      enroll_serials!(branch, variant_of(phone), %w[IMEI-1 IMEI-2 IMEI-3], opened_by: manager)
    end

    it 'gives a serial to one counter only and refuses wrong-branch, duplicate and sold serials' do
      enroll_serials!(other_branch, variant_of(phone), ['IMEI-9'], opened_by: manager)
      Spree::Pos::BranchProduct.create!(branch: other_branch, product: phone)
      first = start_sale
      add_line(first, phone, quantity: 1, serial_codes: ['IMEI-1'])
      expect(Spree::Pos::SerialUnit.find_by!(serial: 'IMEI-1').status).to eq('reserved')

      second = start_sale(manager)
      expect(conflict_reason { add_line(second, phone, quantity: 1, serial_codes: ['IMEI-1']) }).to eq('trace_serial_unavailable')
      expect(conflict_reason { add_line(second, phone, quantity: 1, serial_codes: ['IMEI-9']) }).to eq('trace_serial_unavailable')
      expect(conflict_reason { add_line(second, phone, quantity: 1, serial_codes: ['NOPE']) }).to eq('trace_serial_unavailable')
      expect(conflict_reason { add_line(first, phone, quantity: 1, serial_codes: ['IMEI-1']) }).to eq('trace_serial_duplicate')
      expect(conflict_reason { add_line(second, phone, quantity: 1) }).to eq('trace_serial_required')

      take_tender(first, 'cash', 5_000_000)
      args = editing_args(first)
      completed = Spree::Pos::Workspaces::Complete.call(**args)
      expect(Spree::Pos::Workspaces::Complete.call(**args)).to eq(completed)
      line = lines_of(first).first
      expect(allocations(line).map(&:status)).to eq(['committed'])
      expect(shelf(phone)).to have_attributes(count_on_hand: 3, allocated_count: 1)
      hand_over(first)
      hand_over(first)
      expect(allocations(line).map(&:status)).to eq(['consumed'])
      expect(shelf(phone)).to have_attributes(count_on_hand: 2, allocated_count: 0)
      expect(Spree::Pos::SerialUnit.find_by!(serial: 'IMEI-1').status).to eq('sold')
      expect(reconciled?(phone)).to be(true)

      expect(conflict_reason { add_line(second, phone, quantity: 1, serial_codes: ['IMEI-1']) }).to eq('trace_serial_unavailable')
    end

    it 'releases serials of parked and expired drafts and blocks payment until the serial is held again' do
      parked = start_sale
      add_line(parked, phone, quantity: 1, serial_codes: ['IMEI-2'])
      workspace = parked.workspace.reload
      Spree::Pos::Workspaces::ChangeStatus.call(workspace: workspace, staff: cashier, status: 'parked', revision: workspace.revision,
                                                lease_generation: workspace.lease_generation, key: SecureRandom.uuid, editor_id: parked.editor_id)
      expect(Spree::Pos::SerialUnit.find_by!(serial: 'IMEI-2').status).to eq('in_stock')

      workspace.reload
      Spree::Pos::Workspaces::ChangeStatus.call(workspace: workspace, staff: cashier, status: 'editing', revision: workspace.revision,
                                                lease_generation: workspace.lease_generation, key: SecureRandom.uuid, editor_id: parked.editor_id)
      dto = parked.workspace.reload.to_pos
      expect(dto[:trace]).to eq(ready: false, issues: [{ sale_line_id: lines_of(parked).first.prefixed_id, reason: 'trace_serial_released' }])
      workspace = parked.workspace.reload
      Spree::Pos::Workspaces::ReserveTrace.call(workspace: workspace, staff: cashier, revision: workspace.revision,
                                                lease_generation: workspace.lease_generation, editor_id: parked.editor_id, key: SecureRandom.uuid)
      expect(parked.workspace.reload.to_pos[:trace][:ready]).to be(true)

      Spree::Pos::TraceAllocation.where(workspace_id: parked.workspace.id).update_all(expires_at: 1.minute.ago)
      Spree::Pos::ReleaseTraceReservationsJob.perform_now
      expect(Spree::Pos::SerialUnit.find_by!(serial: 'IMEI-2').status).to eq('in_stock')
      other = start_sale(manager)
      add_line(other, phone, quantity: 1, serial_codes: ['IMEI-2'])
      expect { take_tender(parked, 'cash', 5_000_000) }.to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('trace_serial_released') }
      expect(Spree::Pos::ReceivedFunds.where(workspace_id: parked.workspace.id)).to be_empty
    end

    it 'takes a serial back only from the line that sold it, once, and resells it after an exchange' do
      sale = start_sale
      add_line(sale, phone, quantity: 2, serial_codes: %w[IMEI-1 IMEI-2])
      pay_and_complete(sale)
      hand_over(sale)
      line = lines_of(sale).first

      expect(conflict_reason { prepare_tracked_return(sale, line, quantity: 1, serial_codes: ['IMEI-3']) }).to eq('trace_serial_mismatch')
      expect(conflict_reason { prepare_tracked_return(sale, line, quantity: 1) }).to eq('trace_return_detail_required')
      prepared = prepare_tracked_return(sale, line, quantity: 1, serial_codes: ['IMEI-1'])
      expect(conflict_reason { prepare_tracked_return(sale, line, quantity: 1, serial_codes: ['IMEI-1']) }).to eq('trace_already_returned')
      receive_return(store, cashier, prepared)
      expect(Spree::Pos::SerialUnit.find_by!(serial: 'IMEI-1')).to have_attributes(status: 'in_stock', stock_location_id: branch.stock_location_id)
      expect(reconciled?(phone)).to be(true)

      damaged = prepare_tracked_return(sale, line, quantity: 1, serial_codes: ['IMEI-2'], condition: 'damaged')
      Spree::Pos::Returns::Approve.call(store: store, staff: manager, key: SecureRandom.uuid, return_id: damaged['id'])
      receive_return(store, cashier, damaged)
      expect(Spree::Pos::SerialUnit.find_by!(serial: 'IMEI-2').status).to eq('quarantined')
      expect(shelf(phone).count_on_hand).to eq(3)
      expect(reconciled?(phone)).to be(true)

      editor = SecureRandom.uuid
      register = Spree::Pos::Shift.open_now.find_by!(owner: cashier).register
      exchange = Spree::Pos::Exchanges::Execute.call(store: store, staff: cashier, key: SecureRandom.uuid, return_id: prepared['id'],
                                                     editor_id: editor, register_id: register.prefixed_id)
      replacement = Spree::Pos::Workspace.find_by_prefix_id!(exchange['replacement_workspace_id'])
      resale = PosCreditHelpers::Sale.new(workspace: replacement, cashier: cashier, editor_id: editor, product: phone)
      expect(conflict_reason { add_line(resale, phone, quantity: 1, serial_codes: ['IMEI-2']) }).to eq('trace_serial_unavailable')
      add_line(resale, phone, quantity: 1, serial_codes: ['IMEI-1'])
      expect(Spree::Pos::SerialUnit.find_by!(serial: 'IMEI-1').status).to eq('reserved')
    end
  end

  describe 'FEFO lots' do
    let(:milk) { product_for(price: 30_000) }
    let!(:lots) do
      track_variant!(store, variant_of(milk), 'lot')
      enroll_lots!(branch, variant_of(milk), [['LATE', Date.current + 60, 5], ['EARLY', Date.current + 10, 3],
                                              ['OLD', Date.current - 1, 4], ['HELD', Date.current + 5, 4]], opened_by: manager)
    end

    before { lots.last.update!(status: 'quarantined') }

    it 'allocates earliest expiry first, skips expired and quarantined lots and sums to the line quantity' do
      sale = start_sale
      add_line(sale, milk, quantity: 6)
      preview = sale.workspace.reload.to_pos[:line_items].first[:trace]
      expect(preview[:preview]).to eq([{ lot_code: 'EARLY', expiry_on: (Date.current + 10).iso8601, quantity: 3 },
                                       { lot_code: 'LATE', expiry_on: (Date.current + 60).iso8601, quantity: 3 }])
      pay_and_complete(sale)
      line = lines_of(sale).first
      expect(allocations(line).map { |row| [row.inventory_lot.lot_code, row.quantity, row.status] }).
        to eq([['EARLY', 3, 'committed'], ['LATE', 3, 'committed']])
      expect(allocations(line).sum(&:quantity)).to eq(line.base_quantity)
      hand_over(sale)
      expect(lots.map { |lot| [lot.lot_code, lot.reload.on_hand] }).to eq([['LATE', 2], ['EARLY', 0], ['OLD', 4], ['HELD', 4]])
      expect(shelf(milk).count_on_hand).to eq(10)
      expect(reconciled?(milk)).to be(true)

      last = start_sale
      add_line(last, milk, quantity: 2)
      take_tender(last, 'cash', 60_000)
      late = start_sale(manager)
      add_line(late, milk, quantity: 1)
      expect { take_tender(late, 'cash', 30_000) }.to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('trace_insufficient') }
    end

    it 'breaks expiry ties by receipt and refuses a cashier lot pick unless the branch allows it' do
      lots.first.update!(expiry_on: Date.current + 10)
      sale = start_sale
      expect(conflict_reason { add_line(sale, milk, quantity: 1, lot_code: 'LATE') }).to eq('trace_lot_pick_forbidden')
      branch.update!(lot_selection: 'cashier_pick')
      expect(conflict_reason { add_line(sale, milk, quantity: 1, lot_code: 'OLD') }).to eq('trace_lot_invalid')
      add_line(sale, milk, quantity: 4)
      add_line(sale, milk, quantity: 1, lot_code: 'EARLY')
      workspace = sale.workspace.reload
      Spree::Pos::Workspaces::ReserveTrace.call(workspace: workspace, staff: cashier, revision: workspace.revision,
                                                lease_generation: workspace.lease_generation, editor_id: sale.editor_id, key: SecureRandom.uuid)
      first, picked = lines_of(sale)
      expect(allocations(first).map { |row| [row.inventory_lot.lot_code, row.quantity] }).to eq([['LATE', 4]])
      expect(allocations(picked).map { |row| [row.inventory_lot.lot_code, row.quantity, row.picked] }).to eq([['EARLY', 1, true]])
    end

    it 'returns lot units to their lot, refuses a lot the line did not draw from and quarantines damaged units' do
      sale = start_sale
      add_line(sale, milk, quantity: 6)
      pay_and_complete(sale)
      hand_over(sale)
      line = lines_of(sale).first

      expect(conflict_reason { prepare_tracked_return(sale, line, quantity: 1) }).to eq('trace_return_detail_required')
      expect(conflict_reason { prepare_tracked_return(sale, line, quantity: 1, lot_code: 'OLD') }).to eq('trace_lot_mismatch')
      expect(conflict_reason { prepare_tracked_return(sale, line, quantity: 4, lot_code: 'EARLY') }).to eq('trace_already_returned')
      receive_return(store, cashier, prepare_tracked_return(sale, line, quantity: 2, lot_code: 'EARLY'))
      damaged = prepare_tracked_return(sale, line, quantity: 1, lot_code: 'EARLY', condition: 'damaged')
      Spree::Pos::Returns::Approve.call(store: store, staff: manager, key: SecureRandom.uuid, return_id: damaged['id'])
      receive_return(store, cashier, damaged)
      expect(lots[1].reload).to have_attributes(on_hand: 2, quarantined_quantity: 1)
      expect(conflict_reason { prepare_tracked_return(sale, line, quantity: 1, lot_code: 'EARLY') }).to eq('trace_lot_mismatch')
      expect(shelf(milk).count_on_hand).to eq(13)
      expect(reconciled?(milk)).to be(true)
    end
  end

  describe 'core stock writers' do
    let(:phone) { product_for(price: 1_000) }
    let(:plain) { product_for(price: 1_000) }

    before do
      track_variant!(store, variant_of(phone), 'serial')
      enroll_serials!(branch, variant_of(phone), %w[S-1 S-2], opened_by: manager)
      branch.stock_location.restock(variant_of(plain), 5)
    end

    it 'refuses dashboard, feed and transfer writes of a tracked pair and leaves other variants alone' do
      location = branch.stock_location
      level = shelf(phone)
      expect { Spree::StockLevels::Correct.call(stock_level: level, count_on_hand: 9, reason: 'count') }.
        to raise_error(ActiveRecord::RecordInvalid, /tracked by serial or lot/)
      expect { location.restock(variant_of(phone), 1) }.to raise_error(ActiveRecord::RecordInvalid, /tracked by serial or lot/)
      expect { location.unstock(variant_of(phone), 1) }.to raise_error(ActiveRecord::RecordInvalid, /tracked by serial or lot/)
      expect { level.update!(count_on_hand: 7) }.to raise_error(ActiveRecord::RecordInvalid, /tracked by serial or lot/)
      expect(level.destroy).to be(false)
      expect { level.destroy! }.to raise_error(ActiveRecord::RecordNotDestroyed)
      movement = level.stock_movements.new(kind: 'allocated', quantity: 1)
      expect(movement).not_to be_valid
      expect(shelf(phone).count_on_hand).to eq(2)

      expect(Spree::StockLevels::Correct.call(stock_level: shelf(plain), count_on_hand: 9, reason: 'count')).to be_success
      expect(shelf(plain).count_on_hand).to eq(9)
    end

    it 'detects drift from a writer that bypasses the guard and blocks selling until a count' do
      shelf(phone).update_columns(count_on_hand: 5)
      movement = shelf(phone).stock_movements.order(:id).last
      Spree::Pos::StockTraceabilitySubscriber.new.check(Struct.new(:payload).new({ 'id' => movement.prefixed_id }))
      Spree::Pos::ReleaseTraceReservationsJob.perform_now
      Spree::Pos::ReleaseTraceReservationsJob.perform_now
      enrollment = Spree::Pos::TraceEnrollment.find_by!(variant_id: variant_of(phone).id)
      expect(Spree::Pos::OutboxEntry.where(event_type: 'stock.trace_drift', aggregate_id: enrollment.id).count).to eq(1)
      expect(conflict_reason { add_line(start_sale, phone, quantity: 1, serial_codes: ['S-1']) }).to eq('trace_unreconciled')

      count = Spree::Pos::Inventory::AdjustTraceability.create(store: store, staff: cashier, key: SecureRandom.uuid, branch_id: branch.prefixed_id,
                                                               variant_id: variant_of(phone).prefixed_id, reason: 'Kiểm kê')
      expect(count).to include('status' => 'pending_approval', 'delta' => -3)
      Spree::Pos::Inventory::AdjustTraceability.approve(store: store, staff: manager, key: SecureRandom.uuid, adjustment_id: count['id'])
      Spree::Pos::Inventory::AdjustTraceability.apply(store: store, staff: cashier, key: SecureRandom.uuid, adjustment_id: count['id'])
      expect(shelf(phone).count_on_hand).to eq(2)
      expect(reconciled?(phone)).to be(true)
    end
  end

  describe 'opening balances, inventory commands and recall' do
    let(:milk) { product_for(price: 30_000) }

    before do
      track_variant!(store, variant_of(milk), 'lot')
      branch.stock_location.restock(variant_of(milk), 10)
    end

    def open_milk(lots)
      Spree::Pos::Inventory::OpenBalance.call(store: store, staff: cashier, key: SecureRandom.uuid, branch_id: branch.prefixed_id,
                                              variant_id: variant_of(milk).prefixed_id, lots: lots)
    end

    it 'opens tracked stock only when the lots match the shelf, and blocks selling before that' do
      expect(conflict_reason { add_line(start_sale, milk, quantity: 1) }).to eq('trace_not_enrolled')
      expect(conflict_reason { open_milk([{ lot_code: 'A', expiry_on: (Date.current + 9).iso8601, quantity: 9 }]) }).to eq('opening_unreconciled')
      expect(Spree::Pos::InventoryLot.where(variant_id: variant_of(milk).id)).to be_empty

      status = open_milk([{ lot_code: 'A', expiry_on: (Date.current + 9).iso8601, quantity: 6 }, { lot_code: 'B', quantity: 4 }])
      expect(status).to include('enrolled' => true, 'reconciled' => true, 'sellable' => true, 'core_on_hand' => 10, 'typed_on_hand' => 10)
      expect(conflict_reason { open_milk([{ lot_code: 'C', quantity: 10 }]) }).to eq('already_enrolled')
      expect { branch.stock_location.restock(variant_of(milk), 1) }.to raise_error(ActiveRecord::RecordInvalid, /tracked by serial or lot/)
      add_line(start_sale, milk, quantity: 1)
    end

    it 'receives, transfers and counts typed units together with the core shelf' do
      open_milk([{ lot_code: 'A', expiry_on: (Date.current + 9).iso8601, quantity: 10 }])
      Spree::Pos::BranchProduct.create!(branch: other_branch, product: milk)
      Spree::Pos::Inventory::OpenBalance.call(store: store, staff: manager, key: SecureRandom.uuid, branch_id: other_branch.prefixed_id,
                                              variant_id: variant_of(milk).prefixed_id, lots: [])

      expect(conflict_reason do
        Spree::Pos::Inventory::ReceiveTraceability.call(store: store, staff: cashier, key: SecureRandom.uuid, branch_id: branch.prefixed_id,
                                                        variant_id: variant_of(milk).prefixed_id,
                                                        lots: [{ lot_code: 'A', expiry_on: (Date.current + 30).iso8601, quantity: 1 }])
      end).to eq('lot_expiry_mismatch')
      Spree::Pos::Inventory::ReceiveTraceability.call(store: store, staff: cashier, key: SecureRandom.uuid, branch_id: branch.prefixed_id,
                                                      variant_id: variant_of(milk).prefixed_id,
                                                      lots: [{ lot_code: 'N', expiry_on: (Date.current + 40).iso8601, quantity: 5 }])
      expect(shelf(milk).count_on_hand).to eq(15)

      lot_a = Spree::Pos::InventoryLot.find_by!(stock_location_id: branch.stock_location_id, lot_code: 'A')
      result = Spree::Pos::Inventory::TransferTraceability.call(store: store, staff: manager, key: SecureRandom.uuid,
                                                                from_branch_id: branch.prefixed_id, to_branch_id: other_branch.prefixed_id,
                                                                variant_id: variant_of(milk).prefixed_id,
                                                                lots: [{ lot_id: lot_a.prefixed_id, quantity: 4 }])
      expect(result['from']).to include('core_on_hand' => 11, 'typed_on_hand' => 11, 'reconciled' => true)
      expect(result['to']).to include('core_on_hand' => 4, 'typed_on_hand' => 4, 'reconciled' => true)
      moved = Spree::Pos::InventoryLot.find_by!(stock_location_id: other_branch.stock_location_id, lot_code: 'A')
      expect(moved).to have_attributes(expiry_on: lot_a.expiry_on, source_lot_id: lot_a.id, on_hand: 4)

      gain = Spree::Pos::Inventory::AdjustTraceability.create(store: store, staff: cashier, key: SecureRandom.uuid, branch_id: branch.prefixed_id,
                                                              variant_id: variant_of(milk).prefixed_id, reason: 'Kiểm kê',
                                                              lots: [{ lot_id: lot_a.prefixed_id, counted: 7 }])
      expect(gain).to include('status' => 'pending_approval', 'delta' => 1)
      branch.update!(adjustment_approval_threshold: 1)
      applied = Spree::Pos::Inventory::AdjustTraceability.create(store: store, staff: cashier, key: SecureRandom.uuid, branch_id: branch.prefixed_id,
                                                                 variant_id: variant_of(milk).prefixed_id, reason: 'Kiểm kê',
                                                                 lots: [{ lot_id: lot_a.prefixed_id, counted: 7 }])
      expect(applied).to include('status' => 'applied', 'delta' => 1)
      expect(shelf(milk).count_on_hand).to eq(12)
      # The earlier count no longer matches the shelf.
      Spree::Pos::Inventory::AdjustTraceability.approve(store: store, staff: manager, key: SecureRandom.uuid, adjustment_id: gain['id'])
      expect(conflict_reason do
        Spree::Pos::Inventory::AdjustTraceability.apply(store: store, staff: cashier, key: SecureRandom.uuid, adjustment_id: gain['id'])
      end).to eq('count_stale')

      loss = Spree::Pos::Inventory::AdjustTraceability.create(store: store, staff: cashier, key: SecureRandom.uuid, branch_id: branch.prefixed_id,
                                                              variant_id: variant_of(milk).prefixed_id, reason: 'Hư hỏng',
                                                              lots: [{ lot_id: lot_a.prefixed_id, counted: 5 }])
      expect(loss).to include('status' => 'pending_approval', 'delta' => -2, 'requires_approval' => true)
      expect(conflict_reason do
        Spree::Pos::Inventory::AdjustTraceability.apply(store: store, staff: cashier, key: SecureRandom.uuid, adjustment_id: loss['id'])
      end).to eq('approval_required')
      expect do
        Spree::Pos::Inventory::AdjustTraceability.approve(store: store, staff: cashier, key: SecureRandom.uuid, adjustment_id: loss['id'])
      end.to raise_error(CanCan::AccessDenied)
      own = Spree::Pos::Inventory::AdjustTraceability.create(store: store, staff: manager, key: SecureRandom.uuid, branch_id: branch.prefixed_id,
                                                             variant_id: variant_of(milk).prefixed_id, reason: 'Hư hỏng',
                                                             lots: [{ lot_id: lot_a.prefixed_id, counted: 6 }])
      expect(conflict_reason do
        Spree::Pos::Inventory::AdjustTraceability.approve(store: store, staff: manager, key: SecureRandom.uuid, adjustment_id: own['id'])
      end).to eq('self_approval')

      Spree::Pos::Inventory::AdjustTraceability.approve(store: store, staff: manager, key: SecureRandom.uuid, adjustment_id: loss['id'])
      Spree::Pos::Inventory::AdjustTraceability.apply(store: store, staff: cashier, key: SecureRandom.uuid, adjustment_id: loss['id'])
      expect(shelf(milk).count_on_hand).to eq(10)
      expect(lot_a.reload.on_hand).to eq(5)
      expect(reconciled?(milk)).to be(true)
    end

    it 'locks the unit configuration while tracked stock exists and quarantines a recalled lot' do
      open_milk([{ lot_code: 'A', expiry_on: (Date.current + 9).iso8601, quantity: 10 }])
      lot = Spree::Pos::InventoryLot.find_by!(lot_code: 'A')
      sale = start_sale
      add_line(sale, milk, quantity: 2)
      Spree::Pos::Inventory::Quarantine.lot(store: store, staff: cashier, key: SecureRandom.uuid, lot_id: lot.prefixed_id, reason: 'Thu hồi')
      expect(lot.reload.status).to eq('quarantined')
      expect(conflict_reason { take_tender(sale, 'cash', 60_000) }).to eq('trace_insufficient')
      Spree::Pos::Inventory::Quarantine.lot(store: store, staff: cashier, key: SecureRandom.uuid, lot_id: lot.prefixed_id, reason: 'Hết thu hồi',
                                            release: true)
      pay_and_complete(sale)
      hand_over(sale)

      recall, meta = Spree::Pos::TraceRecall.new(store: store, policy: Spree::Pos::AccessPolicy.new(store: store, staff: manager)).call(lot_code: 'A')
      expect(meta).to include(count: 1, truncated: false)
      expect(recall[:sales].map { |row| [row[:order_number], row[:quantity], row[:status]] }).to eq([[sale.workspace.order.number, 2, 'consumed']])
      expect { Spree::Pos::TraceRecall.new(store: store, policy: Spree::Pos::AccessPolicy.new(store: store, staff: cashier)).call(lot_code: 'A') }.
        to raise_error(CanCan::AccessDenied)
    end
  end

  describe 'measured packages of one variant' do
    it 'keeps two weighed lines apart through allocation, fulfillment and a partial return' do
      cheese = product_for(price: 100_000)
      track_variant!(store, variant_of(cheese), 'lot', sale_unit: 'kg', base_unit: 'g')
      enroll_lots!(branch, variant_of(cheese), [['P1', Date.current + 5, 1_000], ['P2', Date.current + 15, 2_000]], opened_by: manager)

      sale = start_sale
      add_line(sale, cheese, sale_quantity: '1.2', sale_unit_code: 'kg', measurement_event_id: SecureRandom.uuid)
      add_line(sale, cheese, sale_quantity: '0.8', sale_unit_code: 'kg', measurement_event_id: SecureRandom.uuid)
      first, second = lines_of(sale)
      expect([first.base_quantity, second.base_quantity]).to eq([1200, 800])
      expect(first.line_item_id).not_to eq(second.line_item_id)
      pay_and_complete(sale)
      hand_over(sale)
      expect(allocations(first).map { |row| [row.inventory_lot.lot_code, row.quantity] }).to eq([['P1', 1000], ['P2', 200]])
      expect(allocations(second).map { |row| [row.inventory_lot.lot_code, row.quantity] }).to eq([['P2', 800]])
      expect(allocations(first).map(&:fulfillment_item).map(&:line_item_id).uniq).to eq([first.line_item_id])
      expect(allocations(second).map(&:fulfillment_item).map(&:line_item_id).uniq).to eq([second.line_item_id])

      receive_return(store, cashier, prepare_tracked_return(sale, second, quantity: 300))
      expect(allocations(second).first.returned_quantity).to eq(300)
      expect(allocations(first).sum(&:returned_quantity)).to eq(0)
      expect(Spree::Pos::ReturnReservation.where(sale_line_id: first.id)).to be_empty
      expect(Spree::Pos::InventoryLot.find_by!(lot_code: 'P2').on_hand).to eq(1_300)
      expect(reconciled?(cheese)).to be(true)
      expect(conflict_reason { prepare_tracked_return(sale, first, quantity: 1) }).to eq('trace_return_detail_required')
      prepare_tracked_return(sale, first, quantity: 1_000, lot_code: 'P1')
    end
  end
end
