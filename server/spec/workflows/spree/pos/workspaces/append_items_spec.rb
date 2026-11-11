# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../../support/pos_table_helpers'

RSpec.describe Spree::Pos::Workspaces::AppendItems do
  include PosTableHelpers

  let(:store) { menu_store }
  let(:branch) { table_branch(store) }
  let(:cashier) { credit_staff(store, branch, PosCreditHelpers::CASHIER) }
  let(:waiter) { credit_staff(store, branch, PosTableHelpers::WAITER) }
  let(:area) { area!(branch) }
  let(:dish) { menu_product!(store, branch, name: 'Phở bò', price: 50_000) }
  let(:drink) { menu_product!(store, branch, name: 'Trà đá', price: 5_000) }
  let(:order) { open_table(cashier, table!(area, name: 'Bàn 1')) }

  before do
    table_register!(branch, cashier)
    kitchen_station!(branch, name: 'Bếp', default: true)
  end

  def append(staff, items, batch: SecureRandom.uuid, key: SecureRandom.uuid, workspace: order.workspace)
    described_class.call(workspace: workspace, staff: staff, key: key, items: items, append_batch_id: batch)
  end

  def item(variant, quantity = 1, **rest)
    { variant_id: variant.prefixed_id, quantity: quantity, **rest }
  end

  it 'adds a batch without a lease or a revision and says who added it' do
    revision = order.workspace.reload.revision
    result = append(waiter, [item(dish, 2), item(drink)])

    lines = Spree::Pos::SaleLine.where(workspace_id: order.workspace.id).order(:id)
    expect(lines.map(&:sale_quantity)).to eq([2, 1])
    expect(lines.map(&:added_by_id).uniq).to eq([waiter.id])
    expect(result['sale_line_ids']).to eq(lines.map(&:prefixed_id))
    expect(order.workspace.reload.revision).to eq(revision + 1)
    expect(order.workspace.order.reload.item_total).to eq(105_000)
    line = result['workspace']['line_items'].first
    expect(line).to include('pending_kitchen_quantity' => '2.0', 'kitchen_sent_quantity' => '0.0', 'row_version' => 0)
    expect(line['added_by']).to include('id' => waiter.prefixed_id)
    expect(Spree::Pos::AuditEntry.where(action: 'workspace.items.append', subject_id: order.workspace.id).count).to eq(1)
  end

  it 'merges only within its own batch and never into a sent line' do
    batch = SecureRandom.uuid
    append(waiter, [item(dish), item(dish)], batch: batch)
    expect(Spree::Pos::SaleLine.where(workspace_id: order.workspace.id).sole.sale_quantity).to eq(2)

    append(cashier, [item(dish)])
    expect(Spree::Pos::SaleLine.where(workspace_id: order.workspace.id).count).to eq(2)

    Spree::Pos::Kitchen::Send.command(workspace: order.workspace, staff: waiter, key: SecureRandom.uuid)
    append(waiter, [item(dish)], batch: batch)
    expect(Spree::Pos::SaleLine.where(workspace_id: order.workspace.id).map(&:sale_quantity).sort).to eq([1, 1, 2])
  end

  it 'replays the same key with the same answer' do
    key = SecureRandom.uuid
    batch = SecureRandom.uuid
    first = append(waiter, [item(dish)], key: key, batch: batch)
    second = append(waiter, [item(dish)], key: key, batch: batch)
    expect(second).to eq(first)
    expect(Spree::Pos::SaleLine.where(workspace_id: order.workspace.id).count).to eq(1)
  end

  it 'refuses a counter order' do
    sale = menu_sale(store, branch)
    expect { append(sale.cashier, [item(dish)], workspace: sale.workspace) }.
      to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('not_table_order') }
  end

  it 'refuses when the branch has tables turned off' do
    workspace = order.workspace
    set_pos_module(branch, 'fnb.tables', false)
    expect { append(cashier, [item(dish)], workspace: workspace.reload) }.
      to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('module_disabled') }
  end

  it 'refuses once a payment locked the order; more items go to another order of the table' do
    append(cashier, [item(dish)])
    prepare_cash(order, 10_000)
    expect { append(waiter, [item(drink)]) }.
      to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('snapshot_locked') }
    # Sending changes no money: what was added before the payment still reaches the kitchen.
    sent = Spree::Pos::Kitchen::Send.command(workspace: order.workspace.reload, staff: waiter, key: SecureRandom.uuid)
    expect(sent['ticket_count']).to eq(1)

    extra = open_table(waiter, order.workspace.resource, add_order: true)
    append(waiter, [item(drink)], workspace: extra.workspace)
    expect(extra.workspace.reload.table_label).to eq('B')
    expect(extra.workspace.order.reload.item_total).to eq(5_000)
  end

  it 'refuses people who may not edit the order' do
    stranger = credit_staff(store, branch, [Spree::Pos::Capabilities::DISCOUNT])
    expect { append(stranger, [item(dish)]) }.to raise_error(CanCan::AccessDenied)
  end

  describe 'unsent lines' do
    let!(:line_id) { append(waiter, [item(dish, 2)])['sale_line_ids'].first }

    def line
      Spree::Pos::SaleLine.find_by_prefix_id!(line_id)
    end

    it 'changes and removes a line by its own version' do
      append(cashier, [item(drink)])
      version = line.row_version
      Spree::Pos::Workspaces::EditUnsentLine.call(workspace: order.workspace, staff: cashier, key: SecureRandom.uuid,
                                                  sale_line_id: line_id, row_version: version, quantity: 3)
      expect(line).to have_attributes(sale_quantity: 3, row_version: version + 1)

      expect do
        Spree::Pos::Workspaces::EditUnsentLine.call(workspace: order.workspace, staff: waiter, key: SecureRandom.uuid,
                                                    sale_line_id: line_id, row_version: version, quantity: 1)
      end.to raise_error(Spree::Pos::Conflict) { |error|
        expect(error.reason).to eq('line_changed')
        expect(error.details[:sale_line]).to include(row_version: version + 1, sale_quantity: '3.0')
      }

      Spree::Pos::Workspaces::RemoveUnsentLine.call(workspace: order.workspace, staff: waiter, key: SecureRandom.uuid,
                                                    sale_line_id: line_id, row_version: version + 1)
      expect(Spree::Pos::SaleLine.where(workspace_id: order.workspace.id).count).to eq(1)
      expect(order.workspace.order.reload.item_total).to eq(5_000)
    end

    it 'refuses a line already sent to the kitchen' do
      Spree::Pos::Kitchen::Send.command(workspace: order.workspace, staff: waiter, key: SecureRandom.uuid)
      expect do
        Spree::Pos::Workspaces::EditUnsentLine.call(workspace: order.workspace, staff: waiter, key: SecureRandom.uuid,
                                                    sale_line_id: line_id, row_version: line.row_version, quantity: 1)
      end.to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('line_sent') }
      expect do
        Spree::Pos::Workspaces::RemoveUnsentLine.call(workspace: order.workspace, staff: waiter, key: SecureRandom.uuid,
                                                      sale_line_id: line_id, row_version: line.row_version)
      end.to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('line_sent') }
    end
  end
end
