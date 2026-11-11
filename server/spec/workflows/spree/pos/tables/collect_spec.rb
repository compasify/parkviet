# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../../support/pos_table_helpers'

# Asking for the bill and collecting it: a cashier other than the owner of
# the table register's shift takes the money on their own shift, unless the
# order already holds money on the first one.
RSpec.describe 'Collecting a table order' do
  include PosTableHelpers

  let(:store) { menu_store }
  let(:branch) { table_branch(store) }
  let(:owner) { credit_staff(store, branch, PosCreditHelpers::CASHIER) }
  let(:collector) { credit_staff(store, branch, PosCreditHelpers::CASHIER) }
  let(:waiter) { credit_staff(store, branch, PosTableHelpers::WAITER) }
  let(:table) { table!(area!(branch), name: 'Bàn 1') }
  let(:dish) { menu_product!(store, branch, price: 50_000) }

  before do
    table_register!(branch, owner)
    open_drawer(store, branch, collector)
  end

  def seated(staff)
    order = open_table(staff, table)
    add_dish(order, dish, quantity: 2)
    order
  end

  def take_over(order, staff)
    editor = SecureRandom.uuid
    # The first editor walked away from the order.
    order.workspace.update_column(:lease_expires_at, 1.minute.ago)
    Spree::Pos::Workspaces::ClaimLease.call(workspace: order.workspace.reload, staff: staff, key: SecureRandom.uuid, editor_id: editor)
    PosTableHelpers::TableOrder.new(workspace: order.workspace.reload, cashier: staff, editor_id: editor)
  end

  describe Spree::Pos::Tables::RequestPayment do
    it 'records one open request per order and tells the branch' do
      order = seated(waiter)
      allow(Spree::Pos::Realtime).to receive(:publish).and_call_original

      first = described_class.call(workspace: order.workspace, staff: waiter, key: SecureRandom.uuid, note: 'Chuyển khoản')
      again = described_class.call(workspace: order.workspace, staff: waiter, key: SecureRandom.uuid)

      expect(Spree::Pos::PaymentRequest.where(workspace_id: order.workspace.id).count).to eq(1)
      expect(first['payment_request']).to include('status' => 'open', 'note' => 'Chuyển khoản')
      expect(again['payment_request']['id']).to eq(first['payment_request']['id'])
      expect(Spree::Pos::Realtime).to have_received(:publish).with(branch, 'payment.requested', hash_including(:id)).once
    end

    it 'is resolved by a cashier' do
      order = seated(waiter)
      described_class.call(workspace: order.workspace, staff: waiter, key: SecureRandom.uuid)
      Spree::Pos::Tables::ResolvePaymentRequest.call(workspace: order.workspace, staff: owner, key: SecureRandom.uuid, status: 'done')
      expect(Spree::Pos::PaymentRequest.find_by!(workspace_id: order.workspace.id)).to have_attributes(status: 'done', resolved_by_id: owner.id)
    end
  end

  it 'books the bill on the collecting cashier’s shift while the order holds no money' do
    order = seated(waiter)
    collected = take_over(order, collector)

    take_tender(collected, 'cash', 100_000)

    shift = Spree::Pos::Shift.open_now.find_by!(owner_id: collector.id)
    expect(collected.workspace.reload.shift_id).to eq(shift.id)
    expect(Spree::Pos::AuditEntry.where(action: 'workspace.rebind_collector', subject_id: order.workspace.id).count).to eq(1)
  end

  it 'leaves an order holding money on its shift and refuses another cashier’s tender' do
    order = seated(owner)
    take_tender(order, 'cash', 30_000)
    first_shift = order.workspace.reload.shift_id
    collected = take_over(order, collector)

    expect { take_tender(collected, 'cash', 70_000) }.to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('shift_has_funds') }
    expect(order.workspace.reload.shift_id).to eq(first_shift)
  end
end
