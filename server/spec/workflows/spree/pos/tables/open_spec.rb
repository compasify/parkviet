# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../../support/pos_table_helpers'

# Seating guests: a dine-in order at the table, booked on the table
# register's open shift whoever opens it, editable by the people serving
# tables and by nobody else's counter orders.
RSpec.describe Spree::Pos::Tables::Open do
  include PosTableHelpers

  let(:store) { menu_store }
  let(:branch) { table_branch(store) }
  let(:cashier) { credit_staff(store, branch, PosCreditHelpers::CASHIER) }
  let(:waiter) { credit_staff(store, branch, PosTableHelpers::WAITER) }
  let(:area) { area!(branch) }
  let(:table) { table!(area, name: 'Bàn 5') }
  let!(:register) { table_register!(branch, cashier) }

  it 'opens a dine-in order on the table register shift, whoever seats the guests' do
    order = open_table(waiter, table, guest_count: 4)
    workspace = order.workspace
    shift = Spree::Pos::Shift.find_by!(register_id: register.id)
    expect(workspace).to have_attributes(service_mode: 'dine_in', resource_id: table.id, guest_count: 4, table_label: 'A',
                                         shift_id: shift.id, lease_holder_id: waiter.id)
    expect(workspace.to_pos[:resource]).to include(id: table.prefixed_id, name: 'Bàn 5')
    expect(Spree::Pos::AuditEntry.where(action: 'table.open', subject_id: workspace.id).count).to eq(1)
  end

  it 'refuses a second order unless asked, then letters them A, B' do
    first = open_table(cashier, table)
    expect { open_table(cashier, table) }.to raise_error(Spree::Pos::Conflict) { |error|
      expect(error.reason).to eq('table_occupied')
      expect(error.details[:workspace_ids]).to eq([first.workspace.prefixed_id])
    }
    second = open_table(cashier, table, add_order: true)
    expect(second.workspace.table_label).to eq('B')
  end

  it 'answers the same order for the same key' do
    key = SecureRandom.uuid
    editor = SecureRandom.uuid
    first = open_table(cashier, table, key: key, editor_id: editor)
    expect(open_table(cashier, table, key: key, editor_id: editor).workspace).to eq(first.workspace)
  end

  it 'needs the table register and its open shift' do
    branch.update!(table_register: nil)
    expect { open_table(cashier, table) }.to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('table_register_missing') }

    branch.update!(table_register: register)
    Spree::Pos::Shift.where(register_id: register.id).update_all(status: 'closed', closed_at: Time.current)
    expect { open_table(cashier, table) }.to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('no_open_shift') }
  end

  it 'refuses tables being cleaned or out of service, and branches without the module' do
    table.update!(manual_status: 'cleaning')
    expect { open_table(cashier, table) }.to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('table_unavailable') }

    table.update!(manual_status: 'available')
    set_pos_module(branch, 'fnb.tables', false)
    expect { open_table(cashier, table) }.to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('module_disabled') }
  end

  it 'refuses people who neither serve tables nor sell' do
    stranger = credit_staff(store, branch, [Spree::Pos::Capabilities::REPORT_READ])
    expect { open_table(stranger, table) }.to raise_error(CanCan::AccessDenied)
  end

  describe 'who edits the order' do
    let(:dish) { menu_product!(store, branch, price: 50_000) }

    it 'lets a waiter with only table service edit a table order' do
      order = open_table(waiter, table)
      add_dish(order, dish, quantity: 2)
      expect(order.workspace.reload.order.item_total).to eq(100_000)
    end

    it 'keeps the counter orders of another cashier out of a waiter’s reach' do
      counter = credit_sale(store, branch, price: 10_000)
      expect do
        Spree::Pos::Workspaces::ManageLineItem.add(workspace: counter.workspace.reload, staff: waiter, revision: counter.workspace.revision,
                                                   lease_generation: counter.workspace.lease_generation, editor_id: SecureRandom.uuid,
                                                   key: SecureRandom.uuid, variant_id: counter.product.default_variant.prefixed_id, quantity: 1)
      end.to raise_error(CanCan::AccessDenied)
      expect do
        Spree::Pos::Workspaces::ClaimLease.call(workspace: counter.workspace, staff: waiter, key: SecureRandom.uuid, editor_id: SecureRandom.uuid)
      end.to raise_error(CanCan::AccessDenied)
    end

    it 'keeps a table order out of reach of staff without table service' do
      order = open_table(cashier, table)
      seller = credit_staff(store, branch, [Spree::Pos::Capabilities::OPEN_SHIFT])
      expect do
        Spree::Pos::Workspaces::ManageLineItem.add(workspace: order.workspace.reload, staff: seller, revision: 0,
                                                   lease_generation: order.workspace.lease_generation, editor_id: order.editor_id,
                                                   key: SecureRandom.uuid, variant_id: dish.prefixed_id, quantity: 1)
      end.to raise_error(CanCan::AccessDenied)
    end
  end
end
