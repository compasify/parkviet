# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../../support/pos_table_helpers'

RSpec.describe Spree::Pos::Kitchen::VoidSent do
  include PosTableHelpers

  let(:store) { menu_store }
  let(:branch) { table_branch(store) }
  let(:cashier) { credit_staff(store, branch, PosCreditHelpers::CASHIER) }
  let(:waiter) { credit_staff(store, branch, PosTableHelpers::WAITER) }
  let(:voider) { credit_staff(store, branch, PosTableHelpers::WAITER + [Spree::Pos::Capabilities::KITCHEN_VOID]) }
  let(:manager) { credit_staff(store, branch, [Spree::Pos::Capabilities::APPROVE]) }
  let(:printer) { kitchen_printer!(branch) }
  let!(:station) { kitchen_station!(branch, name: 'Bếp', default: true, printer: printer) }
  let(:area) { area!(branch) }
  let(:dish) { menu_product!(store, branch, name: 'Phở bò', price: 50_000) }
  let(:order) { open_table(cashier, table!(area, name: 'Bàn 1')) }
  let(:workspace) { order.workspace.reload }

  before { table_register!(branch, cashier) }

  def sent_line(quantity)
    result = Spree::Pos::Workspaces::AppendItems.call(workspace: order.workspace, staff: waiter, key: SecureRandom.uuid,
                                                     items: [{ variant_id: dish.prefixed_id, quantity: quantity }])
    Spree::Pos::Kitchen::Send.command(workspace: order.workspace.reload, staff: waiter, key: SecureRandom.uuid)
    Spree::Pos::SaleLine.find_by_prefix_id!(result['sale_line_ids'].first)
  end

  def void(staff, line, quantity, reason: 'khach_doi_y', note: nil, approval_id: nil, key: SecureRandom.uuid)
    described_class.call(workspace: workspace, staff: staff, key: key, sale_line_id: line.prefixed_id, quantity: quantity,
                         reason_code: reason, note: note, approval_id: approval_id)
  end

  def approval_for(staff, revision = workspace.revision)
    Spree::Pos::Approval.create!(store: store, branch: branch, approver: manager, requester: staff, subject_type: 'Spree::Pos::Workspace',
                                 subject_id: workspace.id, action: described_class::ACTION, revision: revision.to_s,
                                 expires_at: 10.minutes.from_now, status: 'active')
  end

  it 'needs an approval from people who may not void' do
    line = sent_line(2)
    expect { void(waiter, line, 1) }.to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('approval_required') }
    expect(line.reload).to have_attributes(sale_quantity: 2, kitchen_sent_quantity: 2)

    approval = approval_for(waiter)
    result = void(waiter, line, 1, approval_id: approval.prefixed_id)

    expect(line.reload).to have_attributes(sale_quantity: 1, kitchen_sent_quantity: 1)
    expect(workspace.order.reload.item_total).to eq(50_000)
    expect(approval.reload.status).to eq('consumed')
    expect(result['kitchen_void']).to include('quantity' => '1.0', 'reason_code' => 'khach_doi_y', 'approval_id' => approval.prefixed_id,
                                              'wasted' => false)
    audit = Spree::Pos::AuditEntry.find_by!(action: 'kitchen.void_sent', subject_id: workspace.id)
    expect(audit.metadata).to include('quantity' => '1.0', 'reason_code' => 'khach_doi_y', 'approver_id' => manager.prefixed_id)
  end

  it 'prints a void ticket at the station and leaves the fired ticket as it was' do
    line = sent_line(2)
    void(voider, line, 1)

    tickets = Spree::Pos::KitchenTicket.where(workspace_id: workspace.id).order(:sequence).to_a
    expect(tickets.map(&:kind)).to eq(%w[fire void])
    expect(tickets.first.items.sole).to have_attributes(quantity: 2, status: 'new')
    expect(tickets.last).to have_attributes(kitchen_station_id: station.id, kitchen_send_id: nil)
    expect(tickets.last.items.sole).to have_attributes(quantity: 1, status: 'voided', note: 'Khách đổi ý')
    job = Spree::Pos::PrintJob.find_by!(kind: 'void_ticket', source_id: tickets.last.id)
    expect(job.document['kind']).to eq('void_ticket')
    lines = job.document['header'].flat_map { |block| Array(block['lines']) }
    expect(lines).to include('HỦY MÓN', '-1 x Phở bò', 'Lý do: Khách đổi ý')
  end

  it 'voids a whole line off the order and marks what the kitchen had made as waste' do
    line = sent_line(2)
    item = Spree::Pos::KitchenTicketItem.find_by!(sale_line_id: line.id)
    item.update!(status: 'ready', ready_at: Time.current)

    result = void(voider, line, 2, reason: 'khac', note: 'Khách về sớm')

    expect(Spree::Pos::SaleLine.exists?(line.id)).to be(false)
    expect(workspace.order.reload.line_items).to be_empty
    expect(item.reload).to have_attributes(status: 'voided', sale_line_id: nil)
    expect(result['kitchen_void']).to include('wasted' => true, 'note' => 'Khách về sớm', 'sale_line_id' => line.prefixed_id)
    expect(Spree::Pos::KitchenVoid.sole).to have_attributes(sale_line_id: nil, name: 'Phở bò', quantity: 2)
  end

  it 'refuses a reason off the list, "other" without a note and more than was sent' do
    line = sent_line(1)
    expect { void(voider, line, 1, reason: 'boc_phet') }.
      to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('void_reason_invalid') }
    expect { void(voider, line, 1, reason: 'khac') }.
      to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('void_note_required') }
    expect { void(voider, line, 2) }.
      to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('void_quantity_invalid') }
  end

  it 'lists every send and void in the kitchen history' do
    line = sent_line(2)
    void(voider, line, 1, reason: 'het_mon')

    entries = Spree::Pos::Kitchen::History.for(workspace)[:entries]
    expect(entries.map { |entry| entry[:kind] }).to eq(%w[send void])
    expect(entries.first).to include(sequence: 1, staff_name: Spree::Pos::KitchenSend.staff_name(waiter))
    expect(entries.first[:items].sole).to include(name: 'Phở bò', quantity: '2.0', station_name: 'Bếp')
    expect(entries.last).to include(reason_code: 'het_mon', wasted: false)
    expect(entries.last[:items].sole).to include(quantity: '-1.0')
  end
end
