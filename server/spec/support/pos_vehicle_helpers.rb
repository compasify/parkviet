# frozen_string_literal: true

require_relative 'pos_credit_helpers'

# Rest stop scenarios through the real workflows: a branch with coach
# commission on, visits opened by the counter, orders sold to a visit and
# paid in cash, and commission rules saved by their command.
module PosVehicleHelpers
  include PosCreditHelpers

  CAPS = Spree::Pos::Capabilities
  # Sells, takes cash and pays commission from their own drawer.
  STOP_CASHIER = [CAPS::OPEN_SHIFT, CAPS::PAYMENT, CAPS::CASH_MOVE, CAPS::VEHICLE_VISIT_OPERATE, CAPS::VEHICLE_VISIT_MANAGE].freeze
  # Confirms cash outs and grants approvals.
  STOP_MANAGER = [CAPS::OPEN_SHIFT, CAPS::PAYMENT, CAPS::CASH_MOVE, CAPS::APPROVE, CAPS::REPORT_READ,
                  CAPS::REPORT_EXPORT, CAPS::VEHICLE_VISIT_MANAGE].freeze

  def rest_stop_branch(store)
    credit_branch(store).tap { |branch| set_pos_module(branch, 'fnb.vehicle_commission', true) }
  end

  def commission_rule!(store, staff, branch, **attributes)
    values = { 'per_vehicle_amounts' => { 'seat_29' => '100000', 'seat_45' => '150000' }, 'per_guest_amount' => '10000' }.
             merge(attributes.transform_keys(&:to_s))
    result = Spree::Pos::VehicleVisits::SaveCommissionRule.call(store: store, staff: staff, key: SecureRandom.uuid,
                                                                branch_id: branch.prefixed_id, attributes: values)
    Spree::Pos::CommissionRule.find_by_prefix_id!(result['id'])
  end

  def bus_operator!(store, staff, branch, name: "Nhà xe #{SecureRandom.hex(3)}")
    result = Spree::Pos::VehicleVisits::SaveBusOperator.call(store: store, staff: staff, key: SecureRandom.uuid,
                                                             branch_id: branch.prefixed_id, attributes: { 'name' => name })
    Spree::Pos::BusOperator.find_by_prefix_id!(result['id'])
  end

  def open_visit!(store, staff, branch, plate: '51B-123.45', vehicle_type: 'seat_29', guest_count: 20, **attributes)
    values = { 'plate' => plate, 'vehicle_type' => vehicle_type, 'guest_count' => guest_count.to_s, 'driver_name' => 'Anh Tư',
               'driver_phone' => '0909123456' }.merge(attributes.transform_keys(&:to_s))
    result = Spree::Pos::VehicleVisits::Open.call(store: store, staff: staff, key: SecureRandom.uuid, branch_id: branch.prefixed_id,
                                                  attributes: values)
    Spree::Pos::VehicleVisit.find_by_prefix_id!(result['id'])
  end

  def attach_visit(sale, visit)
    Spree::Pos::VehicleVisits::AttachWorkspace.call(**editing_args(sale), visit_id: visit&.prefixed_id)
  end

  def close_visit(visit, staff)
    Spree::Pos::VehicleVisits::Close.call(store: visit.store, staff: staff, key: SecureRandom.uuid, visit_id: visit.prefixed_id)
    visit.reload
  end

  def pay_visit(visit, staff, payout_method: 'cash', key: SecureRandom.uuid, **)
    Spree::Pos::VehicleVisits::Pay.call(store: visit.store, staff: staff, key: key, visit_id: visit.prefixed_id,
                                        payout_method: payout_method, **)
  end

  # A cash order of one item on the cashier's open shift (opened on first use).
  def stop_sale(store, branch, cashier, price:)
    shift = Spree::Pos::Shift.for_store(store).open_now.find_by(branch_id: branch.id, owner_id: cashier.id)
    return credit_sale(store, branch, price: price, cashier: cashier) if shift.nil?

    editor_id = SecureRandom.uuid
    created = Spree::Pos::Workspaces::Create.call(store: store, staff: cashier, register_id: shift.register.prefixed_id,
                                                  key: SecureRandom.uuid, editor_id: editor_id)
    workspace = Spree::Pos::Workspace.find_by_prefix_id!(created['id'])
    product = create(:product, store: store, status: 'active', name: "Món #{SecureRandom.hex(3)}")
    product.default_variant.set_price(workspace.order.currency, price)
    Spree::Pos::BranchProduct.create!(branch: branch, product: product)
    branch.stock_location.restock(product.default_variant, 10)
    Spree::Pos::Workspaces::ManageLineItem.add(workspace: workspace, staff: cashier, revision: workspace.revision, key: SecureRandom.uuid,
                                               lease_generation: workspace.lease_generation, editor_id: editor_id,
                                               variant_id: product.default_variant.prefixed_id, quantity: 1)
    PosCreditHelpers::Sale.new(workspace: workspace.reload, cashier: cashier, editor_id: editor_id, product: product)
  end

  def complete_in_cash(sale)
    take_tender(sale, 'cash', sale.workspace.reload.order.total)
    Spree::Pos::Workspaces::Complete.call(**editing_args(sale))
    sale.workspace.reload
  end

  def refusal(&)
    yield
    raise 'expected a refusal'
  rescue Spree::Pos::Conflict => e
    e
  end
end
