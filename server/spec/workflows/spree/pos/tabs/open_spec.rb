# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../../support/pos_table_helpers'

# Bar tabs: an order named after its guest, which every counter and waiter
# of the branch adds to, booked on the business day it was opened.
RSpec.describe Spree::Pos::Tabs::Open do
  include ActiveSupport::Testing::TimeHelpers
  include PosTableHelpers

  let(:store) { menu_store }
  let(:branch) { table_branch(store) }
  let(:cashier) { credit_staff(store, branch, PosCreditHelpers::CASHIER) }
  let(:waiter) { credit_staff(store, branch, PosTableHelpers::WAITER) }
  let(:beer) { menu_product!(store, branch, name: 'Bia', price: 40_000) }
  let(:zone) { ActiveSupport::TimeZone['Asia/Ho_Chi_Minh'] }

  before { table_register!(branch, cashier) }

  def open_tab(staff, name, editor_id: SecureRandom.uuid)
    result = described_class.call(store: store, staff: staff, key: SecureRandom.uuid, editor_id: editor_id,
                                  branch_id: branch.prefixed_id, tab_name: name)
    PosTableHelpers::TableOrder.new(workspace: Spree::Pos::Workspace.find_by_prefix_id!(result['id']), cashier: staff, editor_id: editor_id)
  end

  def append(staff, tab, variant, quantity: 1)
    Spree::Pos::Workspaces::AppendItems.call(workspace: tab.workspace.reload, staff: staff, key: SecureRandom.uuid,
                                             items: [{ 'variant_id' => variant.prefixed_id, 'quantity' => quantity }])
  end

  it 'opens a tab with only a name, on the opener’s own shift, and refuses a second open tab of that name' do
    tab = open_tab(cashier, 'Anh Tuấn áo xanh')

    expect(tab.workspace).to have_attributes(service_mode: 'tab', tab_name: 'Anh Tuấn áo xanh', resource_id: nil)
    expect(tab.workspace.shift.owner_id).to eq(cashier.id)
    expect(tab.workspace.summary).to include(tab_name: 'Anh Tuấn áo xanh')
    expect { open_tab(waiter, 'anh tuấn ÁO XANH') }.
      to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('tab_name_taken') }
    expect { open_tab(cashier, ' ') }.to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('tab_name_invalid') }
  end

  it 'lets a waiter open a tab on the table register’s shift and anyone add to it without a lease' do
    tab = open_tab(waiter, 'Bàn quầy 3')
    expect(tab.workspace.shift.owner_id).to eq(cashier.id)

    append(waiter, tab, beer, quantity: 2)
    append(cashier, tab, beer)

    expect(tab.workspace.reload.order.line_items.sum(:quantity)).to eq(3)
    expect(tab.workspace.order.total).to eq(120_000)
  end

  it 'finds open tabs by name or call number' do
    first = open_tab(cashier, 'Chị Mai')
    open_tab(cashier, 'Nhóm sinh nhật')
    scope = described_class.open_tabs(branch)

    expect(described_class.search(scope, 'mai').pluck(:id)).to eq([first.workspace.id])
    expect(described_class.search(scope, '').count).to eq(2)
  end

  it 'is refused where pay-later is off' do
    set_pos_module(branch, 'fnb.postpay', false)
    expect { open_tab(cashier, 'Khách lẻ') }.to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('module_disabled') }
  end

  it 'counts a tab opened at 23:30 and paid at 01:30 once, on the day it was opened' do
    tab = travel_to(zone.local(2026, 11, 10, 23, 30)) do
      open_tab(cashier, 'Đêm muộn').tap { |opened| append(cashier, opened, beer) }
    end
    travel_to(zone.local(2026, 11, 11, 1, 30)) do
      append(waiter, tab, beer)
      pay_and_complete(tab)
    end

    workspace = tab.workspace.reload
    expect(workspace.operational_status).to eq('completed')
    expect(workspace.business_date).to eq(Date.new(2026, 11, 10))

    manager = credit_staff(store, branch, [Spree::Pos::Capabilities::REPORT_READ])
    scope = Spree::Pos::Reports::Scope.new(store: store, staff: manager, branch: branch)
    report = Spree::Pos::Reports.build('bar', scope: scope, values: { 'from' => '2026-11-10', 'to' => '2026-11-11' })
    rows, = report.page(1, 25)
    expect(rows).to contain_exactly(include(business_date: '2026-11-10', orders: 1, tabs: 1, revenue: '80000.0'))
    expect(report.summary).to include(orders: 1, tabs: 1, revenue: '80000.0')
  end

  def pay_and_complete(tab)
    take_tender(tab, 'cash', tab.workspace.reload.order.total.to_i)
    Spree::Pos::Workspaces::Complete.call(**editing_args(tab))
  end
end
