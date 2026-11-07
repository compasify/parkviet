# frozen_string_literal: true

require_relative '../../../support/pos_shift_helpers'
require_relative '../../../support/pos_trace_helpers'

# One counter sale of advanced goods end to end on the installed core:
# scale labels and unit conversion become exact base quantities, each line
# draws its own serials or FEFO lots, handover consumes exactly those
# allocations once, the receipt prints them, and a partial return goes back
# to the lot or serial the line actually sold, with the shelf, the typed
# stock and the entitlement all still in line.
RSpec.describe 'POS traceability end to end', type: :request do
  include PosShiftHelpers
  include PosTraceHelpers

  let(:store) { create(:store, default_currency: 'VND', supported_currencies: 'VND') }
  let(:branch) { returns_branch(store) }
  let(:keeper) do
    caps = Spree::Pos::Capabilities
    credit_staff(store, branch, PosShiftHelpers::MANAGER + [caps::INVENTORY_MANAGE, caps::INVENTORY_TRACE])
  end
  let(:cashier) { credit_staff(store, branch, PosShiftHelpers::LEAD) }

  def product_for(price:)
    product = create(:product, store: store, status: 'active', name: "Hang #{SecureRandom.hex(3)}")
    product.default_variant.set_price(store.default_currency, price)
    Spree::Pos::BranchProduct.create!(branch: branch, product: product)
    product
  end

  def ean(body)
    sum = body.chars.each_with_index.sum { |char, index| char.to_i * (index.even? ? 1 : 3) }
    "#{body}#{(10 - (sum % 10)) % 10}"
  end

  def add(sale, **params)
    workspace = sale.workspace.reload
    Spree::Pos::Workspaces::ManageLineItem.add(workspace: workspace, staff: sale.cashier, revision: workspace.revision,
                                               lease_generation: workspace.lease_generation, editor_id: sale.editor_id,
                                               key: SecureRandom.uuid, **params)
  end

  def allocations(line)
    Spree::Pos::TraceAllocation.where(sale_line_id: line.id).order(:id).to_a
  end

  def reconciled?(product)
    Spree::Pos::StockIntegration.blocked_reason(branch, product.default_variant).nil?
  end

  def shelf(product)
    branch.stock_location.stock_level(product.default_variant).reload.count_on_hand
  end

  it 'carries labels, conversions, serials and lots from the sale through handover to a partial return' do
    cheese = product_for(price: 200_000) # per kg
    cheese_unit = track_variant!(store, cheese.default_variant, 'lot', sale_unit: 'kg', base_unit: 'g')
    cheese_unit.update!(label_code: '12345')
    Spree::Pos::LabelFormat.create!(store: store, branch: branch, name: 'Cân quầy', prefix: '21', kind: 'weight',
                                    item_code_length: 5, value_length: 5, value_decimals: 0, value_unit_code: 'g')
    enroll_lots!(branch, cheese.default_variant, [['CH-LATE', Date.current + 30, 3_000], ['CH-EARLY', Date.current + 3, 1_000]],
                 opened_by: keeper)
    water = product_for(price: 240_000) # per case of 24 bottles
    track_variant!(store, water.default_variant, 'lot', sale_unit: 'case', base_unit: 'chai', ratio: [24, 1])
    enroll_lots!(branch, water.default_variant, [['W-1', Date.current + 90, 30]], opened_by: keeper)
    phone = product_for(price: 3_000_000)
    track_variant!(store, phone.default_variant, 'serial')
    enroll_serials!(branch, phone.default_variant, %w[IMEI-100 IMEI-200 IMEI-300], opened_by: keeper)

    editor_id = SecureRandom.uuid
    register = open_drawer(store, branch, cashier)
    created = Spree::Pos::Workspaces::Create.call(store: store, staff: cashier, register_id: register.prefixed_id,
                                                  key: SecureRandom.uuid, editor_id: editor_id)
    sale = PosCreditHelpers::Sale.new(workspace: Spree::Pos::Workspace.find_by_prefix_id!(created['id']), cashier: cashier,
                                      editor_id: editor_id, product: nil)

    first_label = ean('211234501250')  # 1250 g
    second_label = ean('211234500800') # 800 g
    add(sale, label_barcode: first_label, measurement_event_id: SecureRandom.uuid)
    add(sale, label_barcode: second_label, measurement_event_id: SecureRandom.uuid)
    add(sale, variant_id: water.default_variant.prefixed_id, sale_quantity: '1', sale_unit_code: 'case')
    add(sale, variant_id: phone.default_variant.prefixed_id, quantity: 2, serial_codes: %w[IMEI-100 IMEI-300])

    lines = Spree::Pos::SaleLine.where(workspace_id: sale.workspace.id).order(:id).to_a
    heavy, light, case_line, phones = lines
    expect(lines.map(&:base_quantity)).to eq([1250, 800, 24, 2])
    expect([heavy.label_barcode, light.label_barcode]).to eq([first_label, second_label])
    expect(lines.map(&:line_item_id).uniq.length).to eq(4)
    expect(heavy.line_item.reload).to have_attributes(quantity: 1250, price: BigDecimal('200'))
    expect(case_line.line_item.reload).to have_attributes(quantity: 24, price: BigDecimal('10000'))
    # 250000 + 160000 + 240000 + 6000000
    expect(sale.workspace.reload.order.total).to eq(BigDecimal('6650000'))

    take_tender(sale, 'cash', 6_650_000)
    Spree::Pos::Workspaces::Complete.call(**editing_args(sale))
    hand_over(sale)
    hand_over(sale)

    lot_rows = ->(line) { allocations(line).map { |row| [row.inventory_lot&.lot_code, row.quantity, row.status] } }
    expect(lot_rows.call(heavy)).to eq([['CH-EARLY', 1000, 'consumed'], ['CH-LATE', 250, 'consumed']])
    expect(lot_rows.call(light)).to eq([['CH-LATE', 800, 'consumed']])
    expect(lot_rows.call(case_line)).to eq([['W-1', 24, 'consumed']])
    expect(allocations(phones).map { |row| [row.serial_unit.serial, row.status] }).to eq([%w[IMEI-100 consumed], %w[IMEI-300 consumed]])
    lines.each do |line|
      expect(allocations(line).sum(&:quantity)).to eq(line.base_quantity)
      expect(allocations(line).map { |row| row.fulfillment_item.line_item_id }.uniq).to eq([line.line_item_id])
    end
    expect(Spree::Pos::SerialUnit.where(serial: %w[IMEI-100 IMEI-300]).pluck(:status)).to eq(%w[sold sold])
    expect([shelf(cheese), shelf(water), shelf(phone)]).to eq([1_950, 6, 1])
    expect([cheese, water, phone]).to all(satisfy { |product| reconciled?(product) })

    receipt = Spree::Pos::ReceiptSnapshot.find_by!(source_type: 'sale', source_id: sale.workspace.id)
    traces = receipt.payload['lines'].map { |row| row['trace'] }
    expect(traces[0].map { |row| [row['lot_code'], row['quantity']] }).to eq([['CH-EARLY', 1000], ['CH-LATE', 250]])
    expect(traces[3].map { |row| row['serial'] }).to eq(%w[IMEI-100 IMEI-300])

    prepare = lambda do |line, quantity, **detail|
      Spree::Pos::Returns::Prepare.call(
        store: store, staff: cashier, key: SecureRandom.uuid, branch_id: branch.prefixed_id, order_id: sale.workspace.order.prefixed_id,
        reason: 'Khách trả một phần',
        lines: [{ 'sale_line_id' => line.prefixed_id, 'quantity' => quantity, 'condition' => 'resellable' }.merge(detail.stringify_keys)]
      )
    end
    # The second package drew only CH-LATE; the first package's CH-EARLY is not its provenance.
    expect { prepare.call(light, 300, lot_code: 'CH-EARLY') }.to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('trace_lot_mismatch') }
    light_return = receive_return(store, cashier, prepare.call(light, 300, lot_code: 'CH-LATE'))
    phone_return = receive_return(store, cashier, prepare.call(phones, 1, serial_codes: ['IMEI-300']))
    expect { prepare.call(phones, 1, serial_codes: ['IMEI-300']) }.to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('trace_already_returned') }

    # 300 g at 200 per g; one phone.
    expect(light_return['entitlement_total']).to eq('60000.0')
    expect(phone_return['entitlement_total']).to eq('3000000.0')
    expect(allocations(light).first.returned_quantity).to eq(300)
    expect(allocations(heavy).sum(&:returned_quantity)).to eq(0)
    returned = Spree::Pos::TraceReturn.where(return_operation_id: operation(light_return).id).sole
    expect(returned.trace_allocation.sale_line_id).to eq(light.id)
    expect(returned.trace_allocation.inventory_lot.lot_code).to eq('CH-LATE')
    expect(Spree::Pos::InventoryLot.find_by!(stock_location_id: branch.stock_location_id, lot_code: 'CH-LATE').on_hand).to eq(2_250)
    expect(Spree::Pos::InventoryLot.find_by!(stock_location_id: branch.stock_location_id, lot_code: 'CH-EARLY').on_hand).to eq(0)
    expect(Spree::Pos::SerialUnit.find_by!(serial: 'IMEI-300')).to have_attributes(status: 'in_stock', stock_location_id: branch.stock_location_id)
    expect(Spree::Pos::SerialUnit.find_by!(serial: 'IMEI-100').status).to eq('sold')
    expect([shelf(cheese), shelf(phone)]).to eq([2_250, 2])
    expect([cheese, water, phone]).to all(satisfy { |product| reconciled?(product) })

    recall, = Spree::Pos::TraceRecall.new(store: store, policy: Spree::Pos::AccessPolicy.new(store: store, staff: keeper)).call(lot_code: 'CH-LATE')
    expect(recall[:sales].map { |row| [row[:order_number], row[:quantity]] }).
      to contain_exactly([sale.workspace.order.number, 250], [sale.workspace.order.number, 800])
  end
end
