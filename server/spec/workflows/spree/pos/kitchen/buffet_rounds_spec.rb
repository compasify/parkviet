# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../../support/pos_table_helpers'

# A buffet table pays a ticket per guest; its dishes are free lines on that
# cover, only dishes of the tier qualify, and a round past the tier's limits
# reaches the kitchen only with a manager's approval.
RSpec.describe Spree::Pos::Kitchen::BuffetRounds do
  include PosTableHelpers

  let(:store) { menu_store }
  let(:branch) { table_branch(store) }
  let(:cashier) { credit_staff(store, branch, PosCreditHelpers::CASHIER) }
  let(:waiter) { credit_staff(store, branch, PosTableHelpers::WAITER) }
  let(:manager) { credit_staff(store, branch, [Spree::Pos::Capabilities::APPROVE, Spree::Pos::Capabilities::MANAGE_MENU]) }
  let(:table) { table!(area!(branch), name: 'Bàn 2') }
  let(:ticket) { menu_product!(store, branch, name: 'Vé buffet lẩu', price: 299_000) }
  let(:beef) { menu_product!(store, branch, name: 'Bò Mỹ', price: 120_000) }
  let(:shrimp) { menu_product!(store, branch, name: 'Tôm sú', price: 90_000) }
  let(:lobster) { menu_product!(store, branch, name: 'Tôm hùm', price: 900_000) }
  let!(:kitchen) { kitchen_station!(branch, name: 'Bếp', default: true) }
  let(:tier) do
    result = Spree::Pos::Buffet::SaveTier.call(
      store: store, staff: manager, key: SecureRandom.uuid, branch: branch,
      attributes: { 'name' => 'Lẩu 299', 'product_id' => ticket.product.prefixed_id, 'duration_minutes' => 90, 'round_item_limit' => 3,
                    'items' => [{ 'product_id' => beef.product.prefixed_id, 'max_per_round' => 1 },
                                { 'product_id' => shrimp.product.prefixed_id }] }
    )
    Spree::Pos::BuffetTier.find_by_prefix_id!(result.with_indifferent_access[:id])
  end

  before { table_register!(branch, cashier) }

  def append(order, rows)
    Spree::Pos::Workspaces::AppendItems.call(workspace: order.workspace.reload, staff: waiter, key: SecureRandom.uuid, items: rows)
  end

  def seat_two(order)
    append(order, [{ 'buffet_tier_id' => tier.prefixed_id, 'quantity' => 2 }])
    Spree::Pos::SaleLine.find_by!(workspace_id: order.workspace.id, kind: 'cover')
  end

  def send_now(order, approval_id: nil)
    Spree::Pos::Kitchen::Send.command(workspace: order.workspace.reload, staff: waiter, key: SecureRandom.uuid, approval_id: approval_id)
  end

  it 'charges the ticket per guest and serves the dishes of the tier for free' do
    order = open_table(waiter, table)
    cover = seat_two(order)
    append(order, [{ 'variant_id' => beef.prefixed_id, 'quantity' => 2, 'buffet_cover_line_id' => cover.prefixed_id }])

    expect(cover).to have_attributes(buffet_tier_id: tier.id, sale_quantity: 2)
    dish = Spree::Pos::SaleLine.find_by!(workspace_id: order.workspace.id, buffet_cover_line_id: cover.id)
    expect(dish.line_item.price).to eq(0)
    expect(order.workspace.reload.order.item_total).to eq(598_000)
    expect { append(order, [{ 'variant_id' => lobster.prefixed_id, 'quantity' => 1, 'buffet_cover_line_id' => cover.prefixed_id }]) }.
      to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('buffet_item_not_in_tier') }
  end

  it 'refuses a round over its limit without an approval and sends it with one' do
    order = open_table(waiter, table)
    cover = seat_two(order)
    append(order, [{ 'variant_id' => beef.prefixed_id, 'quantity' => 3, 'buffet_cover_line_id' => cover.prefixed_id },
                   { 'variant_id' => shrimp.prefixed_id, 'quantity' => 4, 'buffet_cover_line_id' => cover.prefixed_id }])

    expect { send_now(order) }.to raise_error(Spree::Pos::Conflict) { |error|
      expect(error.reason).to eq('buffet_round_limit')
      expect(error.details[:problems].map { |row| row[:kind] }).to contain_exactly('round_item_limit', 'max_per_round')
    }
    expect(Spree::Pos::KitchenTicket.where(workspace_id: order.workspace.id)).to be_empty

    workspace = order.workspace.reload
    approval = Spree::Pos::Approval.create!(store: store, branch: branch, approver: manager, requester: waiter,
                                            subject_type: 'Spree::Pos::Workspace', subject_id: workspace.id,
                                            action: Spree::Pos::Approval::BUFFET_OVERRIDE_ACTION, revision: workspace.revision.to_s,
                                            expires_at: 10.minutes.from_now, status: 'active')
    send_now(order, approval_id: approval.prefixed_id)

    sent = Spree::Pos::KitchenTicketItem.joins(:kitchen_ticket).where(spree_pos_kitchen_tickets: { workspace_id: workspace.id })
    expect(sent.where(name: ['Bò Mỹ', 'Tôm sú']).sum(:quantity)).to eq(7)
    expect(approval.reload.status).to eq('consumed')
  end

  it 'lets a round inside the limits through' do
    order = open_table(waiter, table)
    cover = seat_two(order)
    append(order, [{ 'variant_id' => beef.prefixed_id, 'quantity' => 2, 'buffet_cover_line_id' => cover.prefixed_id },
                   { 'variant_id' => shrimp.prefixed_id, 'quantity' => 4, 'buffet_cover_line_id' => cover.prefixed_id }])

    expect { send_now(order) }.not_to raise_error
  end
end
