# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../../support/pos_platform_helpers'

# After entry: the kitchen makes it ready, the driver's pickup completes the
# sale through the money core with what the platform owes (never a drawer),
# a platform cancel voids what the kitchen has, and settling records what
# the platform paid without touching the sale.
RSpec.describe 'Platform order lifecycle' do
  include PosPlatformHelpers

  let(:store) { menu_store }
  let(:branch) { platform_branch(store, rate: 25) }
  let(:counter) { platform_counter(store, branch) }
  let(:milk_tea) { menu_item!(store, branch, name: 'Trà sữa', price: 30_000) }
  let!(:kitchen) { kitchen_station!(branch, name: 'Bar', kind: 'bar', default: true) }
  let(:screen) { kitchen_screen!(branch, Spree::Pos::Device.new_token) }
  let(:order) { enter_platform(store, counter, lines: [platform_line(size(milk_tea), quantity: 2, price: 40_000)]) }

  it 'turns ready when the kitchen finishes it, and back when an item is recalled' do
    expect(order.status).to eq('accepted')
    bump_platform(order, screen)
    expect(order.reload).to have_attributes(status: 'ready')
    expect(order.ready_at).to be_present

    item = Spree::Pos::KitchenTicketItem.joins(:kitchen_ticket).find_by!(spree_pos_kitchen_tickets: { workspace_id: order.workspace_id })
    Spree::Pos::Kitchen::ChangeItemStatus.call(item: item, action: 'recall', actor: screen)
    expect(order.reload).to have_attributes(status: 'accepted', ready_at: nil)
  end

  it 'is marked ready by hand once, and a second tap changes nothing' do
    key = SecureRandom.uuid
    Spree::Pos::PlatformOrders::MarkReady.call(platform_order: order, staff: counter.cashier, key: key)
    expect(order.reload.status).to eq('ready')
    Spree::Pos::PlatformOrders::MarkReady.call(platform_order: order, staff: counter.cashier, key: SecureRandom.uuid)
    expect(Spree::Pos::AuditEntry.where(action: 'platform_order.ready', subject_id: order.workspace_id).count).to eq(1)
  end

  it 'completes on pickup with a platform receivable tender and no drawer movement' do
    bump_platform(order, screen)
    movements = Spree::Pos::CashMovement.where(shift_id: order.workspace.shift_id).count
    key = SecureRandom.uuid
    result = complete_platform(order, counter, key: key)
    expect(complete_platform(order, counter, key: key)).to eq(result)

    workspace = order.workspace.reload
    expect(workspace.operational_status).to eq('completed')
    expect(workspace.order.reload).to be_placed
    attempt = Spree::Pos::TenderAttempt.where(workspace_id: workspace.id).sole
    expect(attempt).to have_attributes(status: 'confirmed', amount: 80_000)
    expect(attempt.pos_payment_method).to have_attributes(kind: 'platform_receivable', code: 'platform_receivable')
    funds = Spree::Pos::ReceivedFunds.where(workspace_id: workspace.id).sole
    expect(funds).to have_attributes(kind: 'platform_receivable', received_net: 80_000, change_amount: 0,
                                     reference: "grabfood:#{order.platform_order_ref}")
    expect(Spree::Pos::ReceiptEvidence.where(tender_attempt_id: attempt.id).sole.kind).to eq('platform_order')
    allocation = Spree::Pos::FundsAllocation.where(workspace_id: workspace.id).sole
    expect(allocation.payment).to have_attributes(status: 'completed', amount: 80_000)
    expect(Spree::Pos::CashMovement.where(shift_id: workspace.shift_id).count).to eq(movements)
    expect(order.reload).to have_attributes(status: 'completed', gross_amount: 80_000, commission_amount: 20_000,
                                            net_amount: 60_000, settled_at: nil)
    expect(order.completed_at).to be_present
    snapshot = Spree::Pos::ReceiptSnapshot.find_by!(source_type: 'sale', source_id: workspace.id)
    expect(snapshot.payload.dig('receipts', 0, 'method')).to eq('platform_receivable')

    expect { complete_platform(order, counter) }.
      to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('platform_order_completed') }
  end

  it 'completes before the kitchen is done too: the driver may wait at the counter' do
    complete_platform(order, counter)
    expect(order.reload.status).to eq('completed')
  end

  it 'asks for an approval to cancel what the kitchen has, then voids it and cancels the draft' do
    expect do
      Spree::Pos::PlatformOrders::Cancel.call(platform_order: order, staff: counter.cashier, key: SecureRandom.uuid,
                                              editor_id: counter.editor_id)
    end.to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('approval_required') }
    expect(order.reload.status).to eq('accepted')

    approver = platform_counter(store, branch, capabilities: PosCreditHelpers::CASHIER + [Spree::Pos::Capabilities::APPROVE,
                                                                                          Spree::Pos::Capabilities::TAKEOVER])
    Spree::Pos::PlatformOrders::Cancel.call(platform_order: order, staff: approver.cashier, key: SecureRandom.uuid,
                                            editor_id: approver.editor_id, reason: 'Khách hủy trên app')
    expect(order.reload).to have_attributes(status: 'canceled', cancel_reason: 'Khách hủy trên app')
    expect(order.workspace.reload.operational_status).to eq('canceled')
    items = Spree::Pos::KitchenTicketItem.joins(:kitchen_ticket).where(spree_pos_kitchen_tickets: { workspace_id: order.workspace_id })
    expect(items.map(&:status).uniq).to eq(['voided'])
    # The kitchen void: a void ticket per sent line, with the platform's reason and the approval.
    tickets = Spree::Pos::KitchenTicket.where(workspace_id: order.workspace_id)
    expect(tickets.where(kind: 'void').count).to eq(Spree::Pos::KitchenVoid.where(workspace_id: order.workspace_id).count)
    expect(Spree::Pos::KitchenVoid.where(workspace_id: order.workspace_id).pluck(:reason_code).uniq).to eq(['platform_canceled'])
    void = Spree::Pos::AuditEntry.where(action: 'kitchen.void_sent', subject_id: order.workspace_id).first!
    expect(void.metadata).to include('reason_code' => 'platform_canceled')
    expect(order.workspace.order_number).to eq(1)

    expect { complete_platform(order, counter) }.
      to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('platform_order_canceled') }
  end

  it 'cancels without an approval when the kitchen has nothing left of it' do
    bump_platform(order, screen)
    Spree::Pos::Kitchen::ChangeItemStatus.serve_order(workspace: order.workspace, actor: screen)
    Spree::Pos::PlatformOrders::Cancel.call(platform_order: order, staff: counter.cashier, key: SecureRandom.uuid,
                                            editor_id: counter.editor_id)
    expect(order.reload).to have_attributes(status: 'canceled', cancel_reason: 'platform_canceled')
  end

  describe 'settling' do
    let(:resolver) { credit_staff(store, branch, [Spree::Pos::Capabilities::RESOLVE]) }

    it 'records what the platform paid and kept, and leaves the sale as it was' do
      complete_platform(order, counter)
      total = order.workspace.order.reload.total
      funds = Spree::Pos::ReceivedFunds.where(workspace_id: order.workspace_id).sole.attributes

      result = Spree::Pos::PlatformOrders::Settle.call(store: store, staff: resolver, key: SecureRandom.uuid, branch: branch,
                                                       orders: [{ id: order.prefixed_id, commission_amount: '18000' }],
                                                       reference: 'GRAB-0311')
      expect(result['orders'].sole).to include('commission_amount' => '18000.0', 'net_amount' => '62000.0',
                                               'settlement_reference' => 'GRAB-0311')
      expect(order.reload).to have_attributes(commission_amount: 18_000, net_amount: 62_000, settled_by: resolver)
      expect(order.workspace.order.reload.total).to eq(total)
      expect(Spree::Pos::ReceivedFunds.where(workspace_id: order.workspace_id).sole.attributes).to eq(funds)

      expect do
        Spree::Pos::PlatformOrders::Settle.call(store: store, staff: resolver, key: SecureRandom.uuid, branch: branch,
                                                orders: [{ id: order.prefixed_id }])
      end.to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('platform_order_settled') }
    end

    it 'settles only completed orders, at the estimate unless told otherwise, and only for a resolver' do
      expect do
        Spree::Pos::PlatformOrders::Settle.call(store: store, staff: resolver, key: SecureRandom.uuid, branch: branch,
                                                orders: [{ id: order.prefixed_id }])
      end.to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('platform_order_open') }

      complete_platform(order, counter)
      expect do
        Spree::Pos::PlatformOrders::Settle.call(store: store, staff: counter.cashier, key: SecureRandom.uuid, branch: branch,
                                                orders: [{ id: order.prefixed_id }])
      end.to raise_error(CanCan::AccessDenied)
      expect do
        Spree::Pos::PlatformOrders::Settle.call(store: store, staff: resolver, key: SecureRandom.uuid, branch: branch,
                                                orders: [{ id: order.prefixed_id, commission_amount: '90000' }])
      end.to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('platform_commission_invalid') }

      Spree::Pos::PlatformOrders::Settle.call(store: store, staff: resolver, key: SecureRandom.uuid, branch: branch,
                                              orders: [{ id: order.prefixed_id }])
      expect(order.reload).to have_attributes(commission_amount: 20_000, net_amount: 60_000)
      expect(order.settled_at).to be_present
    end
  end
end
