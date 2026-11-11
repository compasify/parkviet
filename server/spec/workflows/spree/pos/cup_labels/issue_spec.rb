# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../../support/pos_counter_service_helpers'

# One label per cup of every item that prints cup labels, "n/N", after the
# send or the sale commits; a send followed by the completion never prints a
# cup twice, and a reprint is its own command with an audit entry.
RSpec.describe Spree::Pos::CupLabels::Issue do
  include PosCounterServiceHelpers

  let(:store) { menu_store }
  let(:branch) { counter_branch(store, trigger: 'manual') }
  let(:tea) { cup_item!(store, branch, name: 'Trà sữa', price: 30_000, sizes: { 'M' => 30_000, 'L' => 36_000 }) }
  let(:coffee) { cup_item!(store, branch, name: 'Cà phê', price: 20_000) }
  let(:cake) { menu_item!(store, branch, name: 'Bánh', price: 15_000) }
  let(:ice) { modifier_group!(store, tea, name: 'Đá', options: { 'Ít đá' => 0 }) }
  let!(:printer) { cup_printer!(branch) }
  let(:sale) { menu_sale(store, branch) }

  before { kitchen_station!(branch, name: 'Bar', default: true) }

  it 'prints one label per cup of the items that print labels, numbered n/N' do
    add_menu(sale, size(tea, 1), quantity: 3, modifiers: picks([option(ice, 'Ít đá')]), note: 'Ít ngọt')
    add_menu(sale, size(coffee))
    add_menu(sale, size(cake), quantity: 2)
    Spree::Pos::Workspaces::SetGuestName.call(**editing_args(sale), guest_name: 'Lan')
    kitchen_send(sale)

    expect(cup_jobs(sale).count).to eq(4)
    expect(cup_counts(sale)).to eq(%w[1/3 2/3 3/3 1/1])
    expect(cup_jobs(sale).map(&:printer_id).uniq).to eq([printer.id])
    label = cup_jobs(sale).first.document
    texts = label['header'].flat_map { |block| block['lines'] }
    expect(texts.first).to eq('Số 1 · 1/3')
    expect(texts).to include('Trà sữa (L)', '+ Ít đá', 'Ghi chú: Ít ngọt', 'Lan')
    expect(label['page']['label']).to eq('width_mm' => 50, 'height_mm' => 30)
    expect(label['kind']).to eq('cup_label')
  end

  it 'prints only the cups the send added, and nothing again at completion' do
    add_menu(sale, size(coffee), quantity: 2)
    kitchen_send(sale)
    add_menu(sale, size(tea))
    kitchen_send(sale)
    expect(cup_counts(sale)).to eq(%w[1/2 2/2 1/1])

    pay_and_complete(sale)
    expect(cup_jobs(sale).count).to eq(3)
  end

  it 'prints at completion the cups a manual branch never sent' do
    add_menu(sale, size(coffee), quantity: 2)
    pay_and_complete(sale)
    expect(cup_counts(sale)).to eq(%w[1/2 2/2])
  end

  it 'prints at completion where the branch has no kitchen' do
    set_pos_module(branch, 'fnb.kitchen', false)
    add_menu(sale, size(coffee))
    pay_and_complete(sale)
    expect(cup_jobs(sale).count).to eq(1)
    expect(Spree::Pos::KitchenTicket.where(workspace_id: sale.workspace.id)).to be_empty
  end

  it 'prints nothing where the branch is not on cup labels or has no label printer, and the sale still completes' do
    set_pos_module(branch, 'fnb.cup_label', false)
    add_menu(sale, size(coffee))
    kitchen_send(sale)
    expect(cup_jobs(sale)).to be_empty

    set_pos_module(branch, 'fnb.cup_label', true)
    branch.update!(cup_label_printer: nil)
    pay_and_complete(sale)
    expect(cup_jobs(sale)).to be_empty
    expect(sale.workspace.reload.operational_status).to eq('completed')
  end

  it 'completes the sale when the label printer refuses' do
    printer.update!(status: 'disabled')
    add_menu(sale, size(coffee))
    pay_and_complete(sale)
    expect(sale.workspace.reload.operational_status).to eq('completed')
    expect(cup_jobs(sale)).to be_empty
  end

  describe 'reprint' do
    let(:reprint) { Spree::Pos::CupLabels::Reprint }

    before do
      add_menu(sale, size(coffee), quantity: 2)
      add_menu(sale, size(tea))
    end

    it 'prints a line or the whole order again, once per key, with an audit entry' do
      kitchen_send(sale)
      line = menu_lines(sale).first
      key = SecureRandom.uuid
      first = reprint.call(workspace: sale.workspace.reload, staff: sale.cashier, key: key, sale_line_id: line.prefixed_id)
      expect(reprint.call(workspace: sale.workspace.reload, staff: sale.cashier, key: key, sale_line_id: line.prefixed_id)).to eq(first)
      expect(first['jobs'].size).to eq(2)

      whole = reprint.call(workspace: sale.workspace.reload, staff: sale.cashier, key: SecureRandom.uuid)
      expect(whole['jobs'].size).to eq(3)
      expect(cup_jobs(sale).count).to eq(3 + 2 + 3)
      audits = Spree::Pos::AuditEntry.where(action: 'cup_label.reprint', subject_id: sale.workspace.id)
      expect(audits.count).to eq(2)
      expect(audits.map { |row| row.metadata['sale_line_id'] }).to contain_exactly(line.prefixed_id, nil)
    end

    it 'refuses before anything was sent, without a printer, and without the collect capability' do
      expect { reprint.call(workspace: sale.workspace.reload, staff: sale.cashier, key: SecureRandom.uuid) }.
        to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('cup_label_nothing') }

      kitchen_send(sale)
      waiter = credit_staff(store, branch, %w[pos.shift.open])
      expect { reprint.call(workspace: sale.workspace.reload, staff: waiter, key: SecureRandom.uuid) }.to raise_error(CanCan::AccessDenied)

      branch.update!(cup_label_printer: nil)
      expect { reprint.call(workspace: sale.workspace.reload, staff: sale.cashier, key: SecureRandom.uuid) }.
        to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('cup_label_printer_missing') }
      expect(Spree::Pos::AuditEntry.where(action: 'cup_label.reprint')).to be_empty
    end
  end
end
