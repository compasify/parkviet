# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../../support/pos_table_helpers'

# A booking's deposit is money kept for the guest: a receipt with no order
# and no revenue. It comes off the bill when the party eats, goes back with
# an approval, or is kept with an approval as a taxed holding-fee sale.
RSpec.describe 'POS reservation deposits' do
  include PosTableHelpers

  let(:store) { menu_store }
  let(:branch) { table_branch(store).tap { |row| set_pos_module(row, 'fnb.reservations', true) } }
  let(:caps) { Spree::Pos::Capabilities }
  let(:cashier) { credit_staff(store, branch, PosCreditHelpers::CASHIER + [caps::TABLE_SERVE, caps::RESERVATION_MANAGE]) }
  let(:manager) { credit_staff(store, branch, [caps::APPROVE]) }
  let(:table) { table!(area!(branch), name: 'Bàn VIP', capacity: 6) }
  let(:dish) { menu_product!(store, branch, name: 'Lẩu hải sản', price: 150_000) }

  before { table_register!(branch, cashier) }

  def book(at: 2.hours.from_now)
    result = Spree::Pos::Reservations::Create.call(
      store: store, staff: cashier, key: SecureRandom.uuid, branch_id: branch.prefixed_id, resource_ids: [table.prefixed_id],
      attributes: { 'guest_name' => 'Anh Tuấn', 'phone' => '0912345678', 'party_size' => 4, 'starts_at' => at.iso8601 }
    )
    Spree::Pos::Reservation.find_by_prefix_id!(result.with_indifferent_access[:id])
  end

  def take_deposit(reservation, amount: 200_000, kind: 'cash')
    Spree::Pos::Reservations::TakeDeposit.call(store: store, staff: cashier, key: SecureRandom.uuid, reservation_id: reservation.prefixed_id,
                                               kind: kind, amount: amount.to_s)
    reservation.deposits.reload.last
  end

  def approval(reservation, action, amount)
    Spree::Pos::Approval.create!(store: store, branch: branch, approver: manager, requester: cashier, action: action,
                                 amount: amount, currency: store.default_currency, revision: reservation.reload.revision.to_s,
                                 subject_type: 'Spree::Pos::Reservation', subject_id: reservation.id, status: 'active',
                                 expires_at: 10.minutes.from_now)
  end

  it 'takes the deposit into the drawer without an order or revenue' do
    reservation = book
    orders = Spree::Order.count

    deposit = take_deposit(reservation)

    expect(deposit).to have_attributes(status: 'held', amount: 200_000)
    funds = deposit.received_funds
    expect(funds).to have_attributes(workspace_id: nil, status: 'received', received_net: 200_000, kind: 'cash')
    expect(Spree::Pos::FundsBalance.new(funds).available).to eq(200_000)
    expect(Spree::Pos::CashMovement.where(received_funds_id: funds.id).sum(:amount)).to eq(200_000)
    expect(Spree::Order.count).to eq(orders)
    expect(Spree::Payment.where(source_id: funds.id)).to be_empty
    expect(reservation.reload.to_pos[:deposit_held]).to eq('200000.0')
  end

  it 'takes the deposit off the bill of the seated party and completes the booking with the order' do
    reservation = book(at: 20.minutes.from_now)
    take_deposit(reservation)
    editor_id = SecureRandom.uuid
    seated = Spree::Pos::Reservations::Seat.call(store: store, staff: cashier, key: SecureRandom.uuid,
                                                 reservation_id: reservation.prefixed_id, editor_id: editor_id)
    workspace = Spree::Pos::Workspace.find_by_prefix_id!(seated['workspace']['id'])
    order = PosTableHelpers::TableOrder.new(workspace: workspace, cashier: cashier, editor_id: editor_id)
    add_dish(order, dish, quantity: 2)
    expect(workspace.reload.to_pos[:reservation]).to include(id: reservation.prefixed_id, deposit_held: '200000.0')

    result = Spree::Pos::Reservations::ApplyDeposit.call(**editing_args(order))

    expect(result.dig(:financial, :remaining) || result.dig('financial', 'remaining')).to eq('100000.0')
    deposit = reservation.deposits.reload.sole
    expect(deposit).to have_attributes(status: 'applied', resolution_order_id: workspace.order_id)
    expect(deposit.funds_allocation).to have_attributes(amount: 200_000, workspace_id: workspace.id)
    expect { Spree::Pos::Reservations::ApplyDeposit.call(**editing_args(order)) }.
      to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('deposit_none') }

    take_tender(order, 'cash', 100_000)
    Spree::Pos::Workspaces::Complete.call(**editing_args(order))

    expect(workspace.order.reload.payment_total).to eq(300_000)
    expect(reservation.reload.status).to eq('completed')
    expect(reservation.holds.active).to be_empty
  end

  it 'refunds the deposit only with an approval, as a payout to the guest' do
    reservation = book
    deposit = take_deposit(reservation)
    refund = lambda do |approval_id = nil|
      Spree::Pos::Reservations::RefundDeposit.call(store: store, staff: cashier, key: SecureRandom.uuid, deposit_id: deposit.prefixed_id,
                                                   approval_id: approval_id)
    end

    expect { refund.call }.to raise_error(Spree::Pos::Conflict) { |error|
      expect(error.reason).to eq('approval_required')
      expect(error.details[:action]).to eq('reservation.refund_deposit')
    }
    expect(Spree::Pos::LiabilityPayout.where(received_funds_id: deposit.received_funds_id)).to be_empty

    granted = approval(reservation, Spree::Pos::Reservations::RefundDeposit::ACTION, 200_000)
    refund.call(granted.prefixed_id)

    payout = Spree::Pos::LiabilityPayout.find_by!(received_funds_id: deposit.received_funds_id)
    expect(payout).to have_attributes(status: 'reserved', amount: 200_000, beneficiary_name: 'Anh Tuấn', requester_id: cashier.id)
    expect(deposit.reload).to have_attributes(status: 'refunded', liability_payout_id: payout.id)
    expect(granted.reload.status).to eq('consumed')
  end

  it 'keeps the deposit of a no-show as a completed holding-fee sale' do
    fee = menu_product!(store, branch, name: 'Phí giữ chỗ', price: 1).product
    reservation = book
    deposit = take_deposit(reservation)
    forfeit = lambda do |approval_id = nil|
      Spree::Pos::Reservations::ForfeitDeposit.call(store: store, staff: cashier, key: SecureRandom.uuid, deposit_id: deposit.prefixed_id,
                                                    approval_id: approval_id)
    end
    expect { forfeit.call }.to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('reservation_not_ended') }

    Spree::Pos::Reservations::Cancel.call(store: store, staff: cashier, key: SecureRandom.uuid, reservation_id: reservation.prefixed_id,
                                          status: 'no_show')
    expect { forfeit.call }.to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('reservation_fee_product_missing') }

    branch.update!(reservation_fee_product: fee)
    expect { forfeit.call }.to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('approval_required') }

    result = forfeit.call(approval(reservation, Spree::Pos::Reservations::ForfeitDeposit::ACTION, 200_000).prefixed_id)

    fee_workspace = Spree::Pos::Workspace.find_by_prefix_id!(result.with_indifferent_access[:fee_workspace_id])
    fee_order = fee_workspace.order.reload
    expect(fee_order.completed_at).to be_present
    expect(fee_order.total).to eq(200_000)
    expect(fee_order.line_items.map(&:variant)).to eq([fee.default_variant])
    expect(fee_order.payments.completed.sum(:amount)).to eq(200_000)
    expect(deposit.reload).to have_attributes(status: 'forfeited', resolution_order_id: fee_order.id)
    expect(Spree::Pos::FundsBalance.new(deposit.received_funds.reload).available).to eq(0)
  end
end
