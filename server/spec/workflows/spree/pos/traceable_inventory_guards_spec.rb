# frozen_string_literal: true

require_relative '../../../support/pos_return_helpers'
require_relative '../../../support/pos_trace_helpers'

# Edges of serial/lot stock: website and dashboard checkout refused before
# payment, core cancels of POS orders, counts racing sales, written-off
# quarantine, completion backstops, drift episodes and refused inputs.
RSpec.describe 'POS traceable inventory guards', type: :request do
  include PosReturnHelpers
  include PosTraceHelpers

  let(:store) { create(:store, default_currency: 'VND', supported_currencies: 'VND') }
  let(:branch) { returns_branch(store) }
  let(:inventory_caps) { [Spree::Pos::Capabilities::INVENTORY_MANAGE, Spree::Pos::Capabilities::INVENTORY_TRACE] }
  let(:manager) { credit_staff(store, branch, PosReturnHelpers::APPROVER + inventory_caps) }
  let(:cashier) { credit_staff(store, branch, PosReturnHelpers::RETURNS + [Spree::Pos::Capabilities::INVENTORY_MANAGE]) }

  def product_for(price: 10_000)
    product = create(:product, store: store, status: 'active', name: "Hang #{SecureRandom.hex(3)}")
    product.default_variant.set_price(store.default_currency, price)
    Spree::Pos::BranchProduct.create!(branch: branch, product: product)
    product
  end

  def start_sale(staff = cashier)
    editor_id = SecureRandom.uuid
    register = Spree::Pos::Shift.for_store(store).open_now.find_by(branch_id: branch.id, owner_id: staff.id)&.register ||
      open_drawer(store, branch, staff)
    created = Spree::Pos::Workspaces::Create.call(store: store, staff: staff, register_id: register.prefixed_id,
                                                  key: SecureRandom.uuid, editor_id: editor_id)
    PosCreditHelpers::Sale.new(workspace: Spree::Pos::Workspace.find_by_prefix_id!(created['id']), cashier: staff, editor_id: editor_id)
  end

  def add_line(sale, product, **params)
    workspace = sale.workspace.reload
    Spree::Pos::Workspaces::ManageLineItem.add(workspace: workspace, staff: sale.cashier, revision: workspace.revision,
                                               lease_generation: workspace.lease_generation, editor_id: sale.editor_id,
                                               key: SecureRandom.uuid, variant_id: product.default_variant.prefixed_id, **params)
  end

  def complete(sale)
    take_tender(sale, 'cash', sale.workspace.reload.order.total.to_i)
    Spree::Pos::Workspaces::Complete.call(**editing_args(sale))
  end

  def conflict_reason
    yield
    raise 'expected a conflict'
  rescue Spree::Pos::Conflict => e
    e.reason
  end

  def count(staff, product, **params)
    Spree::Pos::Inventory::AdjustTraceability.create(store: store, staff: staff, key: SecureRandom.uuid, branch_id: branch.prefixed_id,
                                                     variant_id: product.default_variant.prefixed_id, reason: 'Kiểm kê', **params)
  end

  def approve_and_apply(adjustment)
    Spree::Pos::Inventory::AdjustTraceability.approve(store: store, staff: manager, key: SecureRandom.uuid, adjustment_id: adjustment['id'])
    Spree::Pos::Inventory::AdjustTraceability.apply(store: store, staff: cashier, key: SecureRandom.uuid, adjustment_id: adjustment['id'])
  end

  def shelf(product)
    branch.stock_location.stock_level(product.default_variant).reload
  end

  it 'refuses a tracked item in website and dashboard carts before any payment' do
    milk = product_for
    plain = product_for
    track_variant!(store, milk.default_variant, 'lot')
    enroll_lots!(branch, milk.default_variant, [['W1', Date.current + 9, 3]], opened_by: manager)
    cart = create(:cart, store: store, currency: 'VND')

    refused = Spree::Carts::AddItem.call(cart: cart, variant: milk.default_variant, quantity: 1)
    expect(refused).to be_failure
    expect(refused.error.to_s).to include('can only be sold at the counter')
    expect(cart.reload.line_items).to be_empty
    expect(Spree::Carts::AddItem.call(cart: cart, variant: plain.default_variant, quantity: 1)).to be_success
    %w[carts.complete.validate carts.upsert_items.validate orders.add_item.validate].each do |key|
      expect(Spree.hooks.for(key).map(&:class)).to include(Spree::Pos::TraceCheckoutGuard)
    end

    workflow = Struct.new(:cart, :errors) do
      def reject! = raise(Spree::Pos::Conflict, errors.full_messages.to_sentence)
    end.new(cart.reload, ActiveModel::Errors.new(cart))
    cart.line_items.first.update_columns(variant_id: milk.default_variant.id)
    expect { Spree::Pos::TraceCheckoutGuard.new.call(workflow) }.to raise_error(Spree::Pos::Conflict, /counter/)
  end

  it 'opens tracked stock only while no placed order still holds units there' do
    milk = product_for
    branch.stock_location.restock(milk.default_variant, 5)
    sale = start_sale
    add_line(sale, milk, quantity: 2)
    complete(sale)
    expect(shelf(milk).allocated_count).to eq(2)
    track_variant!(store, milk.default_variant, 'lot')
    open = lambda do
      Spree::Pos::Inventory::OpenBalance.call(store: store, staff: cashier, key: SecureRandom.uuid, branch_id: branch.prefixed_id,
                                              variant_id: milk.default_variant.prefixed_id, lots: [{ lot_code: 'O1', quantity: 5 }])
    end
    expect(conflict_reason { open.call }).to eq('enrollment_allocated')
    hand_over(sale)
    error = nil
    begin
      Spree::Pos::Inventory::OpenBalance.call(store: store, staff: cashier, key: SecureRandom.uuid, branch_id: branch.prefixed_id,
                                              variant_id: milk.default_variant.prefixed_id, lots: [{ lot_code: 'O1', quantity: 5 }])
    rescue Spree::Pos::Conflict => e
      error = e
    end
    expect(error.reason).to eq('opening_unreconciled')
    expect(error.details).to eq(typed_on_hand: 5, core_on_hand: 3)
  end

  it 'refuses a core cancel that would free tracked units still sold to a POS order' do
    phone = product_for
    track_variant!(store, phone.default_variant, 'serial')
    enroll_serials!(branch, phone.default_variant, ['C-1'], opened_by: manager)
    sale = start_sale
    add_line(sale, phone, quantity: 1, serial_codes: ['C-1'])
    complete(sale)

    order = sale.workspace.reload.order
    outcome = begin
      Spree.order_cancel_workflow.call(order: order)
    rescue ActiveRecord::RecordInvalid => e
      e
    end
    expect(outcome).to be_a(ActiveRecord::RecordInvalid).or(satisfy { |result| result.respond_to?(:failure?) && result.failure? })
    expect(order.reload).not_to be_canceled
    expect(Spree::Pos::TraceAllocation.where(order_id: order.id).pluck(:status)).to eq(['committed'])
    expect(Spree::Pos::SerialUnit.find_by!(serial: 'C-1').status).to eq('sold')
    expect(shelf(phone).allocated_count).to eq(1)
  end

  it 'refuses a count that would take units a sale reserved after the count was made' do
    milk = product_for
    track_variant!(store, milk.default_variant, 'lot')
    lot = enroll_lots!(branch, milk.default_variant, [['K1', Date.current + 9, 3]], opened_by: manager).first
    pending = count(cashier, milk, lots: [{ lot_id: lot.prefixed_id, counted: 1 }])
    sale = start_sale(manager)
    add_line(sale, milk, quantity: 2)
    take_tender(sale, 'cash', 20_000)

    expect(conflict_reason { approve_and_apply(pending) }).to eq('trace_count_below_held')
    expect(lot.reload.on_hand).to eq(3)
    expect(conflict_reason { count(cashier, milk, lots: [{ lot_id: lot.prefixed_id, counted: 3 }]) }).to eq('count_no_change')
    expect(conflict_reason { count(cashier, milk, lots: [{ lot_id: lot.prefixed_id, counted: 3 }, { lot_id: lot.prefixed_id, counted: 2 }]) }).
      to eq('duplicate_lot')
  end

  it 'stops a handover with a conflict when the lot no longer holds the sold units' do
    milk = product_for
    track_variant!(store, milk.default_variant, 'lot')
    lot = enroll_lots!(branch, milk.default_variant, [['H1', Date.current + 9, 2]], opened_by: manager).first
    sale = start_sale
    add_line(sale, milk, quantity: 2)
    complete(sale)
    lot.update_columns(on_hand: 1, quarantined_quantity: 1)

    expect(conflict_reason { hand_over(sale) }).to eq('trace_lot_short')
    expect(shelf(milk).count_on_hand).to eq(2)
  end

  it 'writes quarantined lot units off through an approved count' do
    milk = product_for
    track_variant!(store, milk.default_variant, 'lot')
    lot = enroll_lots!(branch, milk.default_variant, [['Q1', Date.current + 9, 5]], opened_by: manager).first
    lot.update!(on_hand: 3, quarantined_quantity: 2)

    adjustment = count(cashier, milk, lots: [{ lot_id: lot.prefixed_id, counted_quarantined: 0 }])
    expect(adjustment).to include('status' => 'pending_approval', 'delta' => -2, 'requires_approval' => true)
    expect(adjustment['lines'].first).to include('before' => 3, 'after' => 3, 'quarantined_before' => 2, 'quarantined_after' => 0)
    approve_and_apply(adjustment)
    expect(lot.reload).to have_attributes(on_hand: 3, quarantined_quantity: 0)
    expect(shelf(milk).count_on_hand).to eq(3)
    expect(Spree::Pos::StockIntegration.blocked_reason(branch, milk.default_variant)).to be_nil
  end

  it 'never completes an enrolled item without allocations, nor across split fulfillment lines' do
    milk = product_for
    branch.stock_location.restock(milk.default_variant, 4)
    sale = start_sale
    add_line(sale, milk, quantity: 1)
    track_variant!(store, milk.default_variant, 'lot')
    enroll_lots!(branch, milk.default_variant, [['B1', Date.current + 9, 4]], opened_by: manager)
    expect(conflict_reason { complete(sale) }).to eq('trace_allocation_missing')

    split = start_sale
    add_line(split, milk, quantity: 2)
    workspace = split.workspace.reload
    Spree::Pos::Workspaces::ReserveTrace.call(workspace: workspace, staff: cashier, revision: workspace.revision,
                                              lease_generation: workspace.lease_generation, editor_id: split.editor_id, key: SecureRandom.uuid)
    order = workspace.order
    fulfillment = order.fulfillments.create!(stock_location: branch.stock_location, cost: 0)
    line_item = order.line_items.first
    2.times { fulfillment.fulfillment_items.create!(variant: line_item.variant, line_item: line_item, order: order, quantity: 1, status: 'on_hand') }
    expect(conflict_reason { Spree::Pos::Inventory::AllocateTraceability.commit!(workspace.reload) }).to eq('trace_fulfillment_mismatch')
  end

  it 'keeps retired tracked modes out of the database' do
    milk = product_for
    branch.stock_location.restock(milk.default_variant, 2)
    sale = start_sale
    add_line(sale, milk, quantity: 1)
    line = Spree::Pos::SaleLine.find_by!(workspace_id: sale.workspace.id)
    expect do
      ActiveRecord::Base.transaction(requires_new: true) { line.update_columns(tracked_mode: 'serial_lot') }
    end.to raise_error(ActiveRecord::StatementInvalid, /chk_pos_sale_lines_tracked/)
  end

  it 'raises attention once per drift episode and again after a reconciled pair drifts anew' do
    phone = product_for
    track_variant!(store, phone.default_variant, 'serial')
    enrollment = enroll_serials!(branch, phone.default_variant, %w[D-1 D-2], opened_by: manager)
    alerts = -> { Spree::Pos::OutboxEntry.where(event_type: 'stock.trace_drift', aggregate_id: enrollment.id).count }

    shelf(phone).update_columns(count_on_hand: 4)
    2.times { Spree::Pos::ReleaseTraceReservationsJob.perform_now }
    Spree::Pos::StockIntegration.check_drift!(enrollment.reload)
    expect(alerts.call).to eq(1)

    approve_and_apply(count(cashier, phone))
    expect(Spree::Pos::StockIntegration.check_drift!(enrollment.reload)).to be_nil
    expect(enrollment.reload.drift_signature).to be_nil

    shelf(phone).update_columns(count_on_hand: 1, updated_at: 1.minute.from_now)
    Spree::Pos::ReleaseTraceReservationsJob.perform_now
    expect(alerts.call).to eq(2)
  end

  it 'refuses serial items in pack units, quarantined lots on receipt, and keeps serials on a same-quantity update' do
    phone = product_for
    track_variant!(store, phone.default_variant, 'serial', sale_unit: 'pack')
    enroll_serials!(branch, phone.default_variant, ['P-1'], opened_by: manager)
    sale = start_sale
    expect(conflict_reason { add_line(sale, phone, quantity: 1, serial_codes: ['P-1'], sale_unit_code: 'pack') }).to eq('trace_serial_unit_mismatch')

    track_variant!(store, phone.default_variant, 'serial')
    add_line(sale, phone, quantity: 1, serial_codes: ['P-1'])
    line = Spree::Pos::SaleLine.find_by!(workspace_id: sale.workspace.id)
    workspace = sale.workspace.reload
    Spree::Pos::Workspaces::ManageLineItem.update_quantity(workspace: workspace, staff: cashier, revision: workspace.revision,
                                                           lease_generation: workspace.lease_generation, editor_id: sale.editor_id,
                                                           key: SecureRandom.uuid, sale_line_id: line.prefixed_id, quantity: 1)
    expect(Spree::Pos::TraceAllocation.where(sale_line_id: line.id).pluck(:status)).to eq(['reserved'])

    milk = product_for
    track_variant!(store, milk.default_variant, 'lot')
    lot = enroll_lots!(branch, milk.default_variant, [['R1', Date.current + 9, 2]], opened_by: manager).first
    lot.update!(status: 'quarantined')
    expect(conflict_reason do
      Spree::Pos::Inventory::ReceiveTraceability.call(store: store, staff: cashier, key: SecureRandom.uuid, branch_id: branch.prefixed_id,
                                                      variant_id: milk.default_variant.prefixed_id,
                                                      lots: [{ lot_code: 'R1', expiry_on: lot.expiry_on.iso8601, quantity: 1 }])
    end).to eq('lot_quarantined')

    level = shelf(milk)
    expect(level.destroy).to be(false)
    expect(level.errors.full_messages.to_sentence).to match(/tracked by serial or lot/)
    expect { level.destroy! }.to raise_error(ActiveRecord::RecordNotDestroyed)
  end

  it 'releases expired reservations in the writers lock order' do
    phone = product_for
    track_variant!(store, phone.default_variant, 'serial')
    enroll_serials!(branch, phone.default_variant, ['E-1'], opened_by: manager)
    sale = start_sale
    add_line(sale, phone, quantity: 1, serial_codes: ['E-1'])
    Spree::Pos::TraceAllocation.where(workspace_id: sale.workspace.id).update_all(expires_at: 1.minute.ago)
    Spree::Pos::Inventory::AllocateTraceability.expire_stale!
    expect(Spree::Pos::TraceAllocation.where(workspace_id: sale.workspace.id).pluck(:status)).to eq(['released'])
    expect(Spree::Pos::SerialUnit.find_by!(serial: 'E-1').status).to eq('in_stock')
  end
end
