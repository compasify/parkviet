# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../support/pos_table_helpers'

# A restaurant end to end on the server, as the cashier (S1), a waiter's
# phone (S2) and the kitchen and bar screens (S3) drive it: set up with
# tables, open table 5 for four, two rounds where the second sends only what
# is new, a void with a manager's approval, the bill asked for, a pre-bill,
# payment, and the table free again with the service charge and each dish's
# tax on the order.
RSpec.describe 'F&B restaurant with tables, waiter and kitchen screens', pos_modules: :default do
  include PosTableHelpers

  let(:store) { menu_store }
  let(:location) do
    Spree::StockLocation.create!(store: store, name: 'Kho nhà hàng', address1: '1 Lê Lợi', city: 'HCM', zipcode: '70000', country_code: 'VN',
                                 active: true, backorderable_default: false, propagate_all_variants: false)
  end
  let(:owner) do
    user = create(:admin_user, :without_admin_role, password: 'secret123')
    create(:role_user, user: user, role: create(:role, resource: store, permissions: %w[write_pos_topology]))
    user
  end

  before do
    allow(Spree::Store).to receive(:default).and_return(store)
    # Vietnamese VAT, matched on the market's country.
    Spree::Market.where(store_id: store.id).find_each { |market| market.update!(country_codes: ['VN']) }
    create(:check_payment_method, store: store, name: 'Bank transfer', active: true)
  end

  def setup_restaurant!
    Spree::Pos::Onboarding::Setup.call(
      store: store, actor: owner, key: SecureRandom.uuid, profile_key: 'nha_hang', grant_self: true,
      branch: { 'name' => 'Nhà hàng Q1', 'code' => 'nh-q1', 'timezone' => 'Asia/Ho_Chi_Minh', 'stock_location_id' => location.prefixed_id },
      register: { 'name' => 'Quầy 1' },
      fnb_setup: { 'stations' => [{ 'name' => 'Bếp', 'kind' => 'prep' }, { 'name' => 'Bar', 'kind' => 'bar' }],
                   'tax_categories' => { 'food' => 'vat_food', 'alcohol' => 'vat_special' } }
    )
  end

  def screen_for(branch, station)
    Spree::Pos::Device.create!(store: store, branch: branch, name: "KDS #{station.name}", mode: 'kds', platform: 'android',
                               kitchen_station: station, token_digest: Spree::Pos::Device.digest(Spree::Pos::Device.new_token))
  end

  # What a station's screen shows still to make, as [name, quantity].
  def open_items(branch, station)
    Spree::Pos::Kitchen::Board.call(branch: branch, station: station)[:open].flat_map { |ticket| ticket[:items] }.
      select { |item| %w[new preparing].include?(item[:status]) }.map { |item| [item[:name], item[:quantity]] }
  end

  it 'runs a table from setup to a free table again' do
    # 1. The manager picks the restaurant profile; it serves tables, so the register is the table register.
    result = setup_restaurant!.with_indifferent_access
    branch = Spree::Pos::Branch.find_by_prefix_id!(result.dig(:branch, :id))
    register = Spree::Pos::Register.find_by_prefix_id!(result.dig(:register, :id))
    expect(branch.table_register).to eq(register)
    expect(branch.service_charge_rate).to eq(5)
    expect(Spree::Pos::ModulePolicy.for_branch(branch)).to include('fnb.tables' => true, 'fnb.postpay' => true, 'fnb.service_charge' => true)
    kitchen, bar = Spree::Pos::KitchenStation.where(branch: branch).order(:position).to_a
    expect([kitchen.name, bar.name]).to eq(%w[Bếp Bar])
    expect(Spree::Pos::StationRoute.find_by!(branch: branch, kitchen_category: 'do_uong').kitchen_station).to eq(bar)

    profile = Spree::Pos::StoreProfile.find_by!(store: store)
    pho = size(menu_item!(store, branch, name: 'Phở bò', price: 60_000))
    tra_da = menu_item!(store, branch, name: 'Trà đá', price: 5_000).tap { |item| item.update!(kitchen_category: 'do_uong') }
    tra_da = size(tra_da)
    pho.product.update!(tax_category: profile.food_tax_category)
    tra_da.product.update!(tax_category: profile.alcohol_tax_category)
    table = table!(area!(branch), name: 'Bàn 5')

    # 2. The cashier opens the shift; the waiter seats four at table 5 and orders round one.
    cashier = credit_staff(store, branch, PosCreditHelpers::CASHIER)
    waiter = credit_staff(store, branch, PosTableHelpers::WAITER)
    manager = credit_staff(store, branch, [Spree::Pos::Capabilities::APPROVE])
    Spree::Pos::Shifts::Open.call(store: store, staff: cashier, register: register, opening_float: '0')
    phone = Spree::Pos::Device.create!(store: store, branch: branch, name: 'Phục vụ 1', mode: 'waiter', platform: 'android',
                                       token_digest: Spree::Pos::Device.digest(Spree::Pos::Device.new_token))
    order = open_table(waiter, table, guest_count: 4)
    workspace = order.workspace
    expect(workspace.shift.register).to eq(register)
    append = lambda do |items|
      Spree::Pos::Workspaces::AppendItems.call(workspace: workspace.reload, staff: waiter, key: SecureRandom.uuid, device: phone,
                                               append_batch_id: SecureRandom.uuid,
                                               items: items.map { |variant, quantity| { variant_id: variant.prefixed_id, quantity: quantity } })
    end
    send_kitchen = -> { Spree::Pos::Kitchen::Send.command(workspace: workspace.reload, staff: waiter, key: SecureRandom.uuid) }
    append.call([[pho, 2], [tra_da, 4]])
    send_kitchen.call

    # 3. Each screen gets its own dishes; both bump, and the phone hears the table is ready.
    expect(open_items(branch, kitchen)).to eq([['Phở bò', '2.0']])
    expect(open_items(branch, bar)).to eq([['Trà đá', '4.0']])
    screens = { kitchen.id => screen_for(branch, kitchen), bar.id => screen_for(branch, bar) }
    Spree::Pos::KitchenTicket.where(workspace_id: workspace.id).find_each do |ticket|
      Spree::Pos::Kitchen::ChangeItemStatus.bump(ticket: ticket, actor: screens.fetch(ticket.kitchen_station_id))
    end
    expect(open_items(branch, kitchen) + open_items(branch, bar)).to be_empty
    feed = Spree::Pos::Kitchen::ReadyFeed.call(device: phone, staff: waiter)
    expect(feed[:items].map { |item| [item[:table_name], item[:status]] }.uniq).to eq([['Bàn 5', 'ready']])

    # 4. Round two sends only the new bowl; voiding it needs the manager, and the kitchen gets a void ticket.
    tickets_before = Spree::Pos::KitchenTicket.where(workspace_id: workspace.id).count
    append.call([[pho, 1]])
    send_kitchen.call
    added = Spree::Pos::KitchenTicket.where(workspace_id: workspace.id).order(:id).offset(tickets_before).to_a
    expect(added.map(&:kitchen_station)).to eq([kitchen])
    expect(added.flat_map(&:items).map(&:quantity)).to eq([1])
    expect(open_items(branch, kitchen)).to eq([['Phở bò', '1.0']])
    line = Spree::Pos::SaleLine.where(workspace_id: workspace.id).order(:id).last
    void = lambda do |approval_id = nil|
      Spree::Pos::Kitchen::VoidSent.call(workspace: workspace.reload, staff: waiter, key: SecureRandom.uuid, sale_line_id: line.prefixed_id,
                                         quantity: 1, reason_code: 'khach_doi_y', approval_id: approval_id, device: phone)
    end
    expect { void.call }.to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('approval_required') }
    approval = Spree::Pos::Approval.create!(store: store, branch: branch, approver: manager, requester: waiter,
                                            subject_type: 'Spree::Pos::Workspace', subject_id: workspace.id,
                                            action: Spree::Pos::Kitchen::VoidSent::ACTION, revision: workspace.reload.revision.to_s,
                                            expires_at: 10.minutes.from_now, status: 'active')
    void.call(approval.prefixed_id)
    voided = Spree::Pos::KitchenTicket.where(workspace_id: workspace.id, kitchen_station_id: kitchen.id).order(:id).last
    expect(voided.kind).to eq('void')
    expect(Spree::Pos::KitchenVoid.where(workspace_id: workspace.id).sole).to have_attributes(reason_code: 'khach_doi_y', wasted: false)
    expect(approval.reload.status).to eq('consumed')

    # 5. The waiter asks for the bill; the cashier sees it, prints the pre-bill and takes cash.
    Spree::Pos::Tables::RequestPayment.call(workspace: workspace.reload, staff: waiter, key: SecureRandom.uuid, device: phone)
    tile = Spree::Pos::ResourceState.for(branch)[:resources].find { |row| row[:id] == table.prefixed_id }
    expect(tile[:state]).to eq('payment_requested')
    editor = SecureRandom.uuid
    workspace.update_column(:lease_expires_at, 1.minute.ago)
    Spree::Pos::Workspaces::ClaimLease.call(workspace: workspace.reload, staff: cashier, key: SecureRandom.uuid, editor_id: editor)
    collected = PosTableHelpers::TableOrder.new(workspace: workspace.reload, cashier: cashier, editor_id: editor)
    prebill = Spree::Pos::Workspaces::Prebill.call(workspace: workspace.reload, staff: cashier, key: SecureRandom.uuid).with_indifferent_access
    expect(prebill.dig(:prebill, :sequence)).to eq(1)

    spree_order = workspace.reload.order
    # 2 bowls × 60 000 + 4 teas × 5 000 = 140 000; the service charge is 5 % of it.
    expect(spree_order.item_total).to eq(140_000)
    fee = spree_order.fees.find_by!(kind: 'service_charge')
    expect(fee.amount).to eq(7_000)
    take_tender(collected, 'cash', spree_order.reload.total.to_i)
    Spree::Pos::Workspaces::Complete.call(**editing_args(collected))

    # 6. The order is complete, the table is free, and the order carries the charge and each dish's own tax.
    spree_order.reload
    expect(spree_order).to be_complete
    expect(Spree::Pos::PaymentRequest.find_by!(workspace_id: workspace.id).status).not_to eq('open')
    tile = Spree::Pos::ResourceState.for(branch)[:resources].find { |row| row[:id] == table.prefixed_id }
    expect(tile[:state]).to eq('available')
    taxed = Spree::TaxLine.where(line_item_id: spree_order.line_items.select(:id)).includes(tax_rate: :tax_category).to_a
    expect(taxed.map { |row| row.tax_rate.tax_category }.uniq).to contain_exactly(profile.food_tax_category, profile.alcohol_tax_category)
    expect(spree_order.fees.find_by!(kind: 'service_charge').amount).to eq(7_000)
    expect(spree_order.total).to eq(spree_order.item_total + spree_order.fee_total + spree_order.additional_tax_total)
  end
end
