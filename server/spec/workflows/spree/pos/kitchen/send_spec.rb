# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../../support/pos_kitchen_helpers'

# A send tells each station only what it has not heard yet, once per key,
# copies what the line was sold with, and leaves printing to after commit.
RSpec.describe Spree::Pos::Kitchen::Send do
  include PosKitchenHelpers

  let(:store) { menu_store }
  let(:branch) { kitchen_branch(store, trigger: 'manual') }
  let(:milk_tea) { menu_item!(store, branch, name: 'Trà sữa', price: 30_000, sizes: { 'M' => 30_000, 'L' => 36_000 }) }
  let(:beer) { menu_item!(store, branch, name: 'Bia', price: 20_000).tap { |row| row.update!(kitchen_category: 'drinks') } }
  let(:ice) { modifier_group!(store, milk_tea, name: 'Đá', options: { 'Ít đá' => 0 }) }
  let!(:kitchen) { kitchen_station!(branch, name: 'Bếp', default: true) }
  let!(:bar) { kitchen_station!(branch, name: 'Bar', kind: 'bar', position: 1) }
  let(:sale) { menu_sale(store, branch) }

  before { station_route!(bar, category: 'drinks') }

  it 'makes one ticket per station with a copy of every line' do
    add_menu(sale, size(milk_tea, 1), quantity: 2, modifiers: picks([option(ice, 'Ít đá')]), note: 'Không đường')
    add_menu(sale, size(beer))
    result = kitchen_send(sale)

    tickets = tickets_of(sale)
    expect(tickets.map(&:kitchen_station)).to eq([kitchen, bar])
    expect(tickets.map(&:sequence)).to eq([1, 2])
    expect(result['tickets'].map { |row| row['station_name'] }).to eq(%w[Bếp Bar])
    tea = tickets.first.items.sole
    expect(tea).to have_attributes(name: 'Trà sữa (L)', quantity: 2, note: 'Không đường', status: 'new')
    expect(tea.modifiers).to eq([{ 'name' => 'Ít đá', 'group_name' => 'Đá', 'quantity' => 1 }])
    expect(tickets.first).to have_attributes(service_mode: 'counter', business_date: sale.workspace.reload.business_date, kind: 'fire')
    expect(menu_lines(sale).map(&:kitchen_sent_quantity)).to eq([2, 1])
    expect(Spree::Pos::AuditEntry.where(action: 'kitchen.send', subject_id: sale.workspace.id).count).to eq(1)
    expect(result['workspace']['line_items'].map { |row| row['kitchen_sent_quantity'] }).to eq(%w[2.0 1.0])
  end

  it 'answers the same tickets for the same key and sends only the unsent part later' do
    add_menu(sale, size(milk_tea))
    args = editing_args(sale)
    first = described_class.command(**args)
    expect(described_class.command(**args)).to eq(first)
    expect(tickets_of(sale).size).to eq(1)

    add_menu(sale, size(milk_tea))
    kitchen_send(sale)
    tickets = tickets_of(sale)
    expect(tickets.map { |ticket| ticket.items.map(&:quantity) }).to eq([[1], [1]])
    expect(menu_lines(sale).sole.kitchen_sent_quantity).to eq(2)

    # Nothing left to send: no empty ticket, no new revision.
    revision = sale.workspace.reload.revision
    expect(kitchen_send(sale)['tickets']).to eq([])
    expect(sale.workspace.reload.revision).to eq(revision)
  end

  it 'lists the parts of a combo only when the combo shows them' do
    fries = menu_item!(store, branch, name: 'Khoai tây', price: 15_000)
    combo = menu_item!(store, branch, name: 'Combo trưa', price: 60_000, kind: 'combo')
    combo.combo_components.create!(variant: size(fries), quantity: 2)
    combo.update!(show_components_on_kds: false)
    add_menu(sale, size(combo))
    kitchen_send(sale)
    expect(tickets_of(sale).sole.items.sole.components).to eq([])

    combo.update!(show_components_on_kds: true)
    add_menu(sale, size(combo))
    kitchen_send(sale)
    expect(tickets_of(sale).last.items.sole.components).to eq([{ 'name' => 'Khoai tây', 'quantity' => '2' }])
  end

  it 'keeps a sent line from going down or changing its options' do
    add_menu(sale, size(milk_tea), quantity: 2)
    kitchen_send(sale)
    line = menu_lines(sale).sole

    expect do
      Spree::Pos::Workspaces::ManageLineItem.update_quantity(**editing_args(sale), sale_line_id: line.prefixed_id, quantity: 1)
    end.to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('kitchen_sent') }
    expect do
      Spree::Pos::Workspaces::ManageLineItem.remove(**editing_args(sale), sale_line_id: line.prefixed_id)
    end.to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('kitchen_sent') }
    expect do
      Spree::Pos::Workspaces::UpdateLineModifiers.call(**editing_args(sale), sale_line_id: line.prefixed_id,
                                                                             modifiers: picks([option(ice, 'Ít đá')]))
    end.to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('kitchen_sent') }

    Spree::Pos::Workspaces::ManageLineItem.update_quantity(**editing_args(sale), sale_line_id: line.prefixed_id, quantity: 3)
    expect(line.reload.sale_quantity).to eq(3)
  end

  it 'sends nothing when the kitchen is off at the branch, and refuses the button' do
    set_pos_module(branch, 'fnb.kitchen', false)
    add_menu(sale, size(milk_tea))

    expect(described_class.call(workspace: sale.workspace.reload, actor: sale.cashier, send_key: 'k')).to eq([])
    expect { kitchen_send(sale) }.to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('module_disabled') }
    expect(tickets_of(sale)).to be_empty
  end

  it 'queues a kitchen ticket for a station printer after commit, and a printer that refuses changes nothing' do
    printer = kitchen_printer!(branch)
    kitchen.update!(printer: printer)
    add_menu(sale, size(milk_tea), note: 'Nóng')
    kitchen_send(sale)

    job = Spree::Pos::PrintJob.find_by!(source_type: 'Spree::Pos::KitchenTicket', source_id: tickets_of(sale).first.id)
    expect(job).to have_attributes(kind: 'kitchen_ticket', printer_id: printer.id, status: 'queued')
    texts = job.document['header'].flat_map { |block| block['lines'] || [block['title']] }
    expect(texts).to include('BẾP', '1 x Trà sữa (M)', 'Ghi chú: Nóng')
    expect(job.document['header'].find { |block| block['lines']&.include?('Ghi chú: Nóng') }).to include('invert' => true)

    printer.update!(status: 'disabled')
    add_menu(sale, size(milk_tea))
    expect { kitchen_send(sale) }.not_to raise_error
    expect(tickets_of(sale).size).to eq(2)
    expect(Spree::Pos::PrintJob.where(source_type: 'Spree::Pos::KitchenTicket').count).to eq(1)
  end

  it 'never changes a ticket once written' do
    add_menu(sale, size(milk_tea))
    kitchen_send(sale)
    ticket = tickets_of(sale).sole

    expect { ticket.update!(service_mode: 'takeaway') }.to raise_error(ActiveRecord::ReadOnlyRecord)
    expect { ticket.items.first.update!(quantity: 5) }.to raise_error(ActiveRecord::RecordInvalid)
    expect(ticket.items.first.update!(status: 'preparing')).to be(true)
  end
end
