# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../support/pos_timed_helpers'

# A karaoke shop end to end on the server: set up with the karaoke profile,
# the VIP room's clock started at 21:30, beer added, the guests moved to a
# normal room at 22:40, the clock stopped at 23:55 and the bill paid. The
# singing is billed in two price segments, rounded once on the total, and
# both the singing and the beer carry their 10 % VAT on the order.
RSpec.describe 'Karaoke room from setup to payment', pos_modules: :default do
  include PosTimedHelpers

  let(:store) { menu_store }
  let(:location) do
    Spree::StockLocation.create!(store: store, name: 'Kho karaoke', address1: '1 Lê Lợi', city: 'HCM', zipcode: '70000', country_code: 'VN',
                                 active: true, backorderable_default: false, propagate_all_variants: false)
  end
  let(:owner) do
    user = create(:admin_user, :without_admin_role, password: 'secret123')
    create(:role_user, user: user, role: create(:role, resource: store, permissions: %w[write_pos_topology]))
    user
  end

  before do
    allow(Spree::Store).to receive(:default).and_return(store)
    Spree::Market.where(store_id: store.id).find_each { |market| market.update!(country_codes: ['VN']) }
    create(:check_payment_method, store: store, name: 'Bank transfer', active: true)
  end

  after { travel_back }

  # The owner picks the karaoke / billiard profile: rooms on a board, a
  # table register, play time on.
  def onboard!(name, code)
    result = Spree::Pos::Onboarding::Setup.call(
      store: store, actor: owner, key: SecureRandom.uuid, profile_key: 'karaoke_bida', grant_self: true,
      branch: { 'name' => name, 'code' => code, 'timezone' => 'Asia/Ho_Chi_Minh', 'stock_location_id' => location.prefixed_id },
      register: { 'name' => 'Quầy 1' },
      fnb_setup: { 'stations' => [{ 'name' => 'Bar', 'kind' => 'bar' }],
                   'tax_categories' => { 'food' => 'vat_food', 'alcohol' => 'vat_special' } }
    ).with_indifferent_access
    [Spree::Pos::Branch.find_by_prefix_id!(result.dig(:branch, :id)), Spree::Pos::Register.find_by_prefix_id!(result.dig(:register, :id))]
  end

  it 'bills the singing in two price segments and the beer, each with its tax' do
    # 1. The karaoke shop is set up.
    clock_at('2026-11-12 20:00')
    branch, register = onboard!('Karaoke Q1', 'kr-q1')
    expect(branch.table_register).to eq(register)
    expect(Spree::Pos::ModulePolicy.for_branch(branch)).to include('timed_billing' => true, 'fnb.tables' => true, 'resources' => true)

    # 2. The manager prices the rooms; the singing and the beer are taxed at 10 %.
    special = Spree::Pos::StoreProfile.find_by!(store: store).alcohol_tax_category
    singing = time_service!(store, branch, name: 'Giờ hát', tax_category: special)
    rate_plan!(branch, variant: singing, type: 'vip', day: 200_000, evening: 300_000)
    rate_plan!(branch, variant: singing, type: 'room', day: 100_000, evening: 150_000)
    area = area!(branch)
    vip = room!(area, name: 'VIP 1', type: 'vip')
    normal = room!(area, name: 'P3', type: 'room', x: 4)
    beer = size(menu_item!(store, branch, name: 'Bia Tiger', price: 30_000))
    beer.product.update!(tax_category: special)

    cashier = credit_staff(store, branch, PosTimedHelpers::OPERATOR)
    Spree::Pos::Shifts::Open.call(store: store, staff: cashier, register: register, opening_float: '0')

    # 3. 21:30: the VIP room's clock starts; the room shows playing.
    clock_at('2026-11-12 21:30')
    session = session_of(start_clock(cashier, vip, guest_count: 6))
    workspace = session.workspace
    tile = Spree::Pos::ResourceState.for(branch)[:resources].find { |row| row[:id] == vip.prefixed_id }
    expect(tile[:state]).to eq('playing')
    expect(tile.dig(:timed, :status)).to eq('running')

    # 4. Two beers on the room's order.
    clock_at('2026-11-12 21:45')
    Spree::Pos::Workspaces::AppendItems.call(workspace: workspace.reload, staff: cashier, key: SecureRandom.uuid,
                                             items: [{ variant_id: beer.prefixed_id, quantity: 2 }])

    # 5. 22:40: the guests move to a normal room; the clock follows them.
    clock_at('2026-11-12 22:40')
    Spree::Pos::Timed::MoveResource.call(session: session.reload, staff: cashier, key: SecureRandom.uuid, resource_id: normal.prefixed_id)
    expect(workspace.reload.resource).to eq(normal)

    # 6. 23:55: stopped. 145 minutes played round up to 150; the 5 minutes go on the last room.
    clock_at('2026-11-12 23:55')
    stop_clock(session, cashier)
    session.reload
    expect(session).to have_attributes(played_minutes: 145, billed_minutes: 150)
    expect(session.timed_quote_lines.map { |row| [row.price_per_hour.to_i, row.minutes, row.amount.to_i] }).
      to eq([[300_000, 70, 350_000], [150_000, 80, 200_000]])

    # 7. Paid in cash: 550 000 of singing and 60 000 of beer.
    order = order_of(session, cashier)
    spree_order = workspace.reload.order
    expect(spree_order.item_total).to eq(610_000)
    take_tender(order, 'cash', spree_order.total.to_i)
    Spree::Pos::Workspaces::Complete.call(**editing_args(order))

    spree_order.reload
    expect(spree_order).to be_complete
    # 10 % on each line, added to the order: 55 000 on the singing, 6 000 on the beer.
    expect(spree_order.additional_tax_total).to eq(61_000)
    expect(spree_order.total).to eq(671_000)
    taxes = Spree::TaxLine.where(line_item_id: spree_order.line_items.select(:id)).includes(:tax_rate).to_a
    expect(taxes.map(&:line_item_id).uniq.size).to eq(2)
    expect(taxes.map { |row| row.tax_rate.amount }.uniq).to eq([BigDecimal('0.1')])


    receipt = Spree::Pos::ReceiptSnapshot.find_by!(source_type: 'sale', source_id: workspace.id).payload
    singing_line = receipt['lines'].find { |line| line['timed'] }
    expect(singing_line['timed']).to include('resource' => 'P3', 'billed_minutes' => 150, 'hours' => '2.5')
    expect(singing_line['timed']['bands'].map { |band| band['minutes'] }).to eq([70, 80])
    tile = Spree::Pos::ResourceState.for(branch)[:resources].find { |row| row[:id] == normal.prefixed_id }
    expect(tile[:state]).to eq('available')
  end

  # Billiard time is an ordinary service: it takes the general rate (8 %
  # until the end of 2026) from its own tax category, while the beer on the
  # same table keeps 10 %.
  it 'taxes billiard time at the general rate and the beer at 10 %' do
    clock_at('2026-11-12 13:00')
    branch, register = onboard!('Bida Q3', 'bd-q3')
    profile = Spree::Pos::StoreProfile.find_by!(store: store)
    play = time_service!(store, branch, name: 'Giờ bida', tax_category: profile.food_tax_category)
    rate_plan!(branch, variant: play, type: 'billiard', day: 60_000, evening: 80_000)
    table = room!(area!(branch), name: 'Bàn bida 1', type: 'billiard', kind: 'billiard')
    beer = size(menu_item!(store, branch, name: 'Bia Tiger', price: 30_000))
    beer.product.update!(tax_category: profile.alcohol_tax_category)
    cashier = credit_staff(store, branch, PosTimedHelpers::OPERATOR)
    Spree::Pos::Shifts::Open.call(store: store, staff: cashier, register: register, opening_float: '0')

    # 14:00 to 15:30 on a Thursday: 90 minutes at 60 000 an hour, and two beers.
    clock_at('2026-11-12 14:00')
    session = session_of(start_clock(cashier, table, guest_count: 2))
    workspace = session.workspace
    clock_at('2026-11-12 14:10')
    Spree::Pos::Workspaces::AppendItems.call(workspace: workspace.reload, staff: cashier, key: SecureRandom.uuid,
                                             items: [{ variant_id: beer.prefixed_id, quantity: 2 }])
    clock_at('2026-11-12 15:30')
    stop_clock(session, cashier)
    expect(session.reload).to have_attributes(billed_minutes: 90, amount: 90_000)

    order = order_of(session, cashier)
    spree_order = workspace.reload.order
    expect(spree_order.item_total).to eq(150_000)
    take_tender(order, 'cash', spree_order.total.to_i)
    Spree::Pos::Workspaces::Complete.call(**editing_args(order))

    spree_order.reload
    expect(spree_order).to be_complete
    rates = Spree::TaxLine.where(line_item_id: spree_order.line_items.select(:id)).includes(:tax_rate, :line_item).
            to_h { |row| [row.line_item.variant_id, row.tax_rate.amount] }
    expect(rates).to eq(play.id => BigDecimal('0.08'), beer.id => BigDecimal('0.1'))
    # 8 % of 90 000 on the play time, 10 % of 60 000 on the beer.
    expect(spree_order.additional_tax_total).to eq(13_200)
    expect(spree_order.total).to eq(163_200)
  end
end
