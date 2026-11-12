# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../../support/pos_vehicle_helpers'

# A coach at a rest stop: the counter opens its visit and sells its guests'
# orders on it, closing the visit keeps the commission worked out then, and
# paying it in cash is a cash out request on the payer's drawer that a
# second person confirms, once per visit. The commission is the stop's
# expense: orders and their e-invoices keep their full price.
RSpec.describe 'Coach visits' do
  include PosVehicleHelpers

  let(:store) { Spree::Store.default }
  let(:branch) { rest_stop_branch(store) }
  let(:cashier) { credit_staff(store, branch, PosVehicleHelpers::STOP_CASHIER) }
  let(:manager) { credit_staff(store, branch, PosVehicleHelpers::STOP_MANAGER) }

  def cash_expected(staff)
    shift = Spree::Pos::Shift.for_store(store).open_now.find_by!(branch_id: branch.id, owner_id: staff.id)
    Spree::Pos::CashbookProjection.new(shift).expected
  end

  it 'sells orders to a visit, closes it with the commission and leaves the orders at full price' do
    commission_rule!(store, manager, branch, per_vehicle_amounts: { 'seat_29' => '100000' }, per_guest_amount: '5000')
    visit = open_visit!(store, cashier, branch, guest_count: 20)
    sales = Array.new(3) { stop_sale(store, branch, cashier, price: 120_000) }
    sales.each { |sale| attach_visit(sale, visit) }
    expect(sales.first.workspace.reload.to_pos[:vehicle_visit_id]).to eq(visit.prefixed_id)
    sales.each { |sale| complete_in_cash(sale) }

    close_visit(visit, cashier)

    expect(visit).to have_attributes(status: 'closed', revenue_amount: 360_000, commission_amount: 200_000, closed_by_id: cashier.id)
    expect(visit.commission_snapshot).to include('guest_count' => 20, 'revenue' => '360000.0', 'vehicle_amount' => '100000.0',
                                                 'guest_amount' => '100000.0', 'amount' => '200000.0')
    sales.each do |sale|
      order = sale.workspace.reload.order
      expect(order.total).to eq(120_000)
      expect(order.adjustment_total).to eq(0)
    end
    expect(Spree::Pos::AuditEntry.where(subject_type: visit.class.name, subject_id: visit.id).pluck(:action)).
      to include('vehicle_visit.open', 'vehicle_visit.close')
  end

  it 'refuses putting a completed order on a visit, or an order on a closed one' do
    visit = open_visit!(store, cashier, branch)
    done = stop_sale(store, branch, cashier, price: 50_000)
    complete_in_cash(done)
    expect(refusal { attach_visit(done, visit) }.reason).to eq('workspace_completed')

    close_visit(visit, cashier)
    open_sale = stop_sale(store, branch, cashier, price: 50_000)
    expect(refusal { attach_visit(open_sale, visit) }.reason).to eq('vehicle_visit_closed')
  end

  it 'keeps the snapshot when the rule changes after closing' do
    rule = commission_rule!(store, manager, branch, per_vehicle_amounts: { 'seat_29' => '100000' }, per_guest_amount: '0')
    visit = close_visit(open_visit!(store, cashier, branch), cashier)
    Spree::Pos::VehicleVisits::SaveCommissionRule.call(store: store, staff: manager, key: SecureRandom.uuid, branch_id: branch.prefixed_id,
                                                       rule_id: rule.prefixed_id,
                                                       attributes: { 'per_vehicle_amounts' => { 'seat_29' => '300000' } })

    expect(rule.reload.vehicle_amount('seat_29')).to eq(300_000)
    expect(visit.reload.commission_amount).to eq(100_000)
    expect(visit.commission_snapshot.dig('rule', 'per_vehicle_amounts', 'seat_29')).to eq('100000.0')
  end

  it 'pays in cash through one cash out request a second person confirms, and only once' do
    commission_rule!(store, manager, branch, per_vehicle_amounts: { 'seat_29' => '100000' }, per_guest_amount: '0')
    visit = open_visit!(store, cashier, branch)
    sale = stop_sale(store, branch, cashier, price: 300_000)
    attach_visit(sale, visit)
    complete_in_cash(sale)
    close_visit(visit, cashier)
    before = cash_expected(cashier)

    key = SecureRandom.uuid
    first = pay_visit(visit, cashier, key: key)
    replay = pay_visit(visit, cashier, key: key)
    again = refusal { pay_visit(visit, cashier) }

    expect(again.reason).to eq('vehicle_visit_paid')
    expect(replay).to eq(first)
    requests = Spree::Pos::CashMovementRequest.where(evidence_reference: visit.prefixed_id)
    expect(requests.count).to eq(1)
    request = requests.first
    expect(request).to have_attributes(kind: 'cash_out', status: 'requested', amount: 100_000, reason: "Hoa hồng xe #{visit.plate}")
    expect(visit.reload).to have_attributes(status: 'paid', payout_method: 'cash', cash_movement_request_id: request.id)
    expect(visit.payout_status).to eq('requested')
    # The drawer moves only when someone else confirms.
    expect(cash_expected(cashier)).to eq(before)

    Spree::Pos::Shifts::ConfirmCashMovement.call(store: store, staff: manager, key: SecureRandom.uuid, request_id: request.prefixed_id,
                                                 decision: 'confirm')

    expect(cash_expected(cashier)).to eq(before - 100_000)
    expect(visit.reload.payout_status).to eq('paid')
  end

  it 'pays again after the cash out request was canceled, and records transfers without the drawer' do
    commission_rule!(store, manager, branch, per_vehicle_amounts: { 'seat_29' => '100000' }, per_guest_amount: '0')
    sale = stop_sale(store, branch, cashier, price: 300_000)
    complete_in_cash(sale)
    visit = close_visit(open_visit!(store, cashier, branch), cashier)
    before = cash_expected(cashier)
    pay_visit(visit, cashier)
    request = visit.reload.cash_movement_request
    Spree::Pos::Shifts::ConfirmCashMovement.call(store: store, staff: cashier, key: SecureRandom.uuid, request_id: request.prefixed_id,
                                                 decision: 'cancel', note: 'Tài xế lấy chuyển khoản')
    expect(visit.reload.payout_status).to eq('canceled')

    expect(refusal { pay_visit(visit, cashier, payout_method: 'transfer') }.reason).to eq('transfer_reference_required')
    pay_visit(visit, cashier, payout_method: 'transfer', transfer_reference: 'FT2611120001')

    expect(visit.reload).to have_attributes(status: 'paid', payout_method: 'transfer', transfer_reference: 'FT2611120001',
                                            cash_movement_request_id: nil)
    expect(visit.payout_status).to eq('paid')
    expect(cash_expected(cashier)).to eq(before)
  end

  it 'refuses paying a visit that earned nothing, or in cash without an open shift' do
    zero = close_visit(open_visit!(store, cashier, branch), cashier)
    expect(refusal { pay_visit(zero, cashier) }.reason).to eq('vehicle_commission_zero')

    commission_rule!(store, manager, branch)
    visit = close_visit(open_visit!(store, manager, branch, plate: '29B-55555'), manager)
    expect(refusal { pay_visit(visit, manager) }.reason).to eq('shift_required')
  end

  it 'corrects a closed visit only with an approval of someone else, keeping the rule it closed with' do
    rule = commission_rule!(store, manager, branch, per_vehicle_amounts: { 'seat_29' => '100000' }, per_guest_amount: '5000')
    visit = close_visit(open_visit!(store, cashier, branch, guest_count: 20), cashier)
    rule.update!(per_guest_amount: 50_000)
    adjust = lambda do |approval_id = nil, **values|
      Spree::Pos::VehicleVisits::Adjust.call(store: store, staff: cashier, key: SecureRandom.uuid, visit_id: visit.prefixed_id,
                                             revision: visit.reload.revision, note: 'Đếm lại khách', approval_id: approval_id, **values)
    end

    error = refusal { adjust.call(guest_count: 30) }
    expect(error.reason).to eq('approval_required')
    expect(visit.reload).to have_attributes(guest_count: 20, commission_amount: 200_000)

    approval = Spree::Pos::Approval.create!(store: store, branch: branch, approver: manager, requester: cashier,
                                            subject_type: visit.class.name, subject_id: visit.id,
                                            action: Spree::Pos::Approval::VEHICLE_VISIT_ADJUST_ACTION,
                                            revision: visit.revision.to_s, expires_at: 10.minutes.from_now, status: 'active')
    adjust.call(approval.prefixed_id, guest_count: 30)

    expect(visit.reload).to have_attributes(guest_count: 30, commission_amount: 250_000)
    expect(visit.commission_snapshot['adjustments'].last).to include('guest_count' => 20, 'amount' => '200000.0',
                                                                     'approval_id' => approval.prefixed_id)
    expect(approval.reload.status).to eq('consumed')
    expect(Spree::Pos::AuditEntry.where(subject_type: visit.class.name, subject_id: visit.id, action: 'vehicle_visit.adjust')).to exist
    # The used approval does not work twice.
    expect { adjust.call(approval.prefixed_id, commission_amount: '1') }.to raise_error(Spree::Pos::Conflict)
  end

  it 'voids an unpaid visit with a reason and closes visits past their window by themselves' do
    allow(Spree::Pos::Workspace).to receive(:database_now).and_call_original
    visit = open_visit!(store, cashier, branch)
    stale = open_visit!(store, cashier, branch, plate: '43C-77777')
    stale.update_columns(arrived_at: 2.hours.ago, closes_at: 1.hour.ago)

    expect(refusal do
      Spree::Pos::VehicleVisits::Void.call(store: store, staff: cashier, key: SecureRandom.uuid, visit_id: visit.prefixed_id, reason: '')
    end.reason).to eq('reason_required')
    Spree::Pos::VehicleVisits::Void.call(store: store, staff: cashier, key: SecureRandom.uuid, visit_id: visit.prefixed_id,
                                         reason: 'Mở nhầm')
    Spree::Pos::CloseStaleVehicleVisitsJob.perform_now

    expect(visit.reload).to have_attributes(status: 'voided', void_reason: 'Mở nhầm')
    expect(stale.reload).to have_attributes(status: 'closed', auto_closed: true, closed_by_id: cashier.id, commission_amount: 0)
  end

  it 'leaves the visit commands to their capabilities and the module' do
    seller = credit_staff(store, branch, [PosVehicleHelpers::CAPS::OPEN_SHIFT, PosVehicleHelpers::CAPS::PAYMENT])
    expect { open_visit!(store, seller, branch) }.to raise_error(CanCan::AccessDenied)

    operator = credit_staff(store, branch, [PosVehicleHelpers::CAPS::VEHICLE_VISIT_OPERATE])
    visit = close_visit(open_visit!(store, operator, branch), operator)
    expect { pay_visit(visit, operator) }.to raise_error(CanCan::AccessDenied)

    set_pos_module(branch, 'fnb.vehicle_commission', false)
    expect(refusal { open_visit!(store, operator, branch) }.reason).to eq(Spree::Pos::ModulePolicy::DISABLED)
  end
end
