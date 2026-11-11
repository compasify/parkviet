# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../../support/pos_table_helpers'

# A held course stays off the prep stations and waits at the pass until it
# is fired; a fire sends only the part of the course the kitchen was not
# told yet, and the same key fires once.
RSpec.describe Spree::Pos::Kitchen::FireCourse do
  include PosTableHelpers

  let(:store) { menu_store }
  let(:branch) { table_branch(store) }
  let(:cashier) { credit_staff(store, branch, PosCreditHelpers::CASHIER) }
  let(:waiter) { credit_staff(store, branch, PosTableHelpers::WAITER) }
  let(:table) { table!(area!(branch), name: 'Bàn 5') }
  let(:soup) { menu_product!(store, branch, name: 'Súp', price: 40_000) }
  let(:steak) { menu_product!(store, branch, name: 'Bò bít tết', price: 180_000) }
  let(:cake) { menu_product!(store, branch, name: 'Bánh flan', price: 25_000) }
  let!(:kitchen) { kitchen_station!(branch, name: 'Bếp', default: true) }
  let!(:pass) { kitchen_station!(branch, name: 'Ra món', kind: 'expo') }

  before { table_register!(branch, cashier) }

  def append(order, rows)
    Spree::Pos::Workspaces::AppendItems.call(workspace: order.workspace.reload, staff: waiter, key: SecureRandom.uuid, items: rows)
  end

  def send_now(order, key: SecureRandom.uuid)
    Spree::Pos::Kitchen::Send.command(workspace: order.workspace.reload, staff: waiter, key: key)
  end

  def ticket_lines(order)
    Spree::Pos::KitchenTicketItem.joins(:kitchen_ticket).where(spree_pos_kitchen_tickets: { workspace_id: order.workspace.id }).
      pluck(:name, :quantity).map { |name, quantity| [name, quantity.to_i] }
  end

  it 'sends no held line and shows it at the pass, waiting for its fire' do
    order = open_table(waiter, table)
    append(order, [{ 'variant_id' => soup.prefixed_id, 'quantity' => 2, 'course' => 1 },
                   { 'variant_id' => steak.prefixed_id, 'quantity' => 2, 'course' => 2, 'hold' => true }])

    result = send_now(order)

    expect(ticket_lines(order)).to eq([['Súp', 2]])
    expect(result['workspace']['line_items'].find { |row| row['name'] == 'Bò bít tết' }).
      to include('course' => 2, 'course_status' => 'held', 'pending_kitchen_quantity' => '0.0')
    board = Spree::Pos::Kitchen::Board.call(branch: branch)
    expect(board[:held]).to contain_exactly(include(workspace_id: order.workspace.prefixed_id, course: 2, course_name: 'Món chính',
                                                    lines: [include(name: 'Bò bít tết', quantity: '2.0')]))
    expect(Spree::Pos::Kitchen::Board.call(branch: branch, station: kitchen)[:held]).to eq([])
  end

  it 'fires only the held course, and the same key fires it once' do
    order = open_table(waiter, table)
    append(order, [{ 'variant_id' => soup.prefixed_id, 'quantity' => 2, 'course' => 1 },
                   { 'variant_id' => steak.prefixed_id, 'quantity' => 2, 'course' => 2, 'hold' => true },
                   { 'variant_id' => cake.prefixed_id, 'quantity' => 2, 'course' => 3, 'hold' => true }])
    send_now(order)
    key = SecureRandom.uuid

    first = described_class.call(workspace: order.workspace.reload, actor: waiter, course: 2, key: key)
    again = described_class.call(workspace: order.workspace.reload, actor: waiter, course: 2, key: key)

    expect(first['ticket_count']).to eq(1)
    expect(again['tickets'].map { |row| row['id'] }).to eq(first['tickets'].map { |row| row['id'] })
    expect(ticket_lines(order)).to contain_exactly(['Súp', 2], ['Bò bít tết', 2])
    expect(Spree::Pos::SaleLine.where(workspace_id: order.workspace.id).pluck(:course, :course_status)).
      to contain_exactly([1, 'none'], [2, 'fired'], [3, 'held'])
    expect { described_class.call(workspace: order.workspace.reload, actor: waiter, course: 2, key: SecureRandom.uuid) }.
      to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('course_not_held') }
  end

  it 'is fired by a pass screen of the branch' do
    order = open_table(waiter, table)
    append(order, [{ 'variant_id' => steak.prefixed_id, 'quantity' => 1, 'course' => 2, 'hold' => true }])
    screen = kitchen_screen!(branch, Spree::Pos::Device.new_token, mode: 'expo', station: pass)

    result = described_class.call(workspace: order.workspace.reload, actor: screen, course: 2, key: 'tap-1')
    replay = described_class.call(workspace: order.workspace.reload, actor: screen, course: 2, key: 'tap-1')

    expect(result['ticket_count']).to eq(1)
    expect(replay['tickets'].size).to eq(1)
    expect(Spree::Pos::KitchenSend.where(workspace_id: order.workspace.id).pluck(:device_id)).to eq([screen.id])
  end

  it 'holds an unsent dish later and moves a sent dish to another seat only' do
    order = open_table(waiter, table)
    append(order, [{ 'variant_id' => soup.prefixed_id, 'quantity' => 1, 'seat' => 1 },
                   { 'variant_id' => steak.prefixed_id, 'quantity' => 1 }])
    soup_line, steak_line = Spree::Pos::SaleLine.where(workspace_id: order.workspace.id).order(:id).to_a
    edit = lambda do |line, **changes|
      Spree::Pos::Workspaces::EditUnsentLine.call(workspace: order.workspace.reload, staff: waiter, key: SecureRandom.uuid,
                                                  sale_line_id: line.prefixed_id, row_version: line.reload.row_version, **changes)
    end

    edit.call(steak_line, placement: { 'course' => 2, 'hold' => true })
    expect(steak_line.reload).to have_attributes(course: 2, course_status: 'held')
    send_now(order)
    expect(ticket_lines(order)).to eq([['Súp', 1]])

    edit.call(soup_line, placement: { 'seat' => 3 })
    expect(soup_line.reload.seat).to eq(3)
    expect { edit.call(soup_line, placement: { 'course' => 1 }) }.
      to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('line_sent') }
    expect { edit.call(soup_line) }.to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('line_change_empty') }
  end

  it 'hands a ready dish out once and announces the order' do
    order = open_table(waiter, table)
    append(order, [{ 'variant_id' => soup.prefixed_id, 'quantity' => 1 }])
    send_now(order)
    item = Spree::Pos::KitchenTicketItem.joins(:kitchen_ticket).find_by!(spree_pos_kitchen_tickets: { workspace_id: order.workspace.id })
    expect { Spree::Pos::Kitchen::MarkServed.call(item: item, actor: cashier) }.
      to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('kitchen_status_invalid') }

    Spree::Pos::Kitchen::ChangeItemStatus.call(item: item, action: 'ready', actor: cashier)
    allow(Spree::Pos::Realtime).to receive(:announce_workspaces).and_call_original
    Spree::Pos::Kitchen::MarkServed.call(item: item.reload, actor: cashier)
    Spree::Pos::Kitchen::MarkServed.call(item: item.reload, actor: cashier)

    expect(item.reload.status).to eq('served')
    expect(Spree::Pos::Realtime).to have_received(:announce_workspaces).with([order.workspace.id]).once
  end
end
