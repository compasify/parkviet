# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../../support/pos_kitchen_helpers'

# The kitchen board for one, several or every station: late tickets first,
# the open items by dish, the ready items at the pass, and one way of
# serving at a time.
RSpec.describe Spree::Pos::Kitchen::Board do
  include PosKitchenHelpers

  let(:store) { menu_store }
  let(:branch) { kitchen_branch(store, trigger: 'manual') }
  let(:pass) { kitchen_station!(branch, name: 'Ra món', kind: 'expo', position: 2) }
  let!(:kitchen) { kitchen_station!(branch, name: 'Bếp', default: true) }
  let!(:bar) { kitchen_station!(branch, name: 'Bar', kind: 'bar', position: 1) }
  let(:soup) { size(menu_item!(store, branch, name: 'Phở bò', price: 50_000)) }
  let(:tea) { menu_item!(store, branch, name: 'Trà đá', price: 5_000) }
  let(:screen) { kitchen_screen!(branch, Spree::Pos::Device.new_token) }

  before { station_route!(bar, product: tea.product) }

  def sent_sale(*variants)
    sale = menu_sale(store, branch)
    variants.each { |variant| add_menu(sale, variant) }
    kitchen_send(sale)
    sale
  end

  it 'puts a late ticket first and adds up the open items by dish, oldest first' do
    first = sent_sale(soup, soup)
    second = sent_sale(soup)
    late = tickets_of(second).sole
    late.class.where(id: late.id).update_all(sent_at: 20.minutes.ago)

    board = described_class.call(branch: branch, station: kitchen)
    expect(board[:open].map { |row| row[:id] }).to eq([late.prefixed_id, tickets_of(first).sole.prefixed_id])
    dish = board[:all_day].sole
    expect(dish).to include(name: late.items.sole.name, quantity: '3.0')
    # Two adds of one dish on the first order merged into one line.
    expect(dish[:item_ids]).to eq([late.items.sole.prefixed_id, tickets_of(first).sole.items.sole.prefixed_id])
    expect(dish[:key]).to eq(described_class.all_day_key(late.items.sole))
  end

  it 'shows several stations at once and narrows to one way of serving' do
    sale = sent_sale(soup, size(tea))
    board = described_class.call(branch: branch, stations: [kitchen, bar])
    expect(board[:station]).to be_nil
    expect(board[:stations].map { |row| row[:id] }).to eq([kitchen.prefixed_id, bar.prefixed_id])
    expect(board[:open].map { |row| row[:station_name] }).to contain_exactly('Bếp', 'Bar')

    expect(described_class.call(branch: branch, stations: [kitchen, bar], service_mode: 'takeaway')[:open]).to eq([])
    expect(described_class.call(branch: branch, stations: [kitchen, bar], service_mode: sale.workspace.service_mode)[:open].size).to eq(2)
  end

  it 'shows a pass what the stations handing to it finished, until it is served' do
    kitchen.update!(expo_station: pass)
    sale = sent_sale(soup, size(tea))
    ticket = tickets_of(sale).find { |row| row.kitchen_station_id == kitchen.id }
    Spree::Pos::Kitchen::ChangeItemStatus.bump(ticket: ticket, actor: screen)
    Spree::Pos::Kitchen::ChangeItemStatus.bump(ticket: tickets_of(sale).find { |row| row.kitchen_station_id == bar.id }, actor: screen)

    board = described_class.call(branch: branch, station: pass)
    order = board[:expo].sole
    expect(order[:workspace_id]).to eq(sale.workspace.prefixed_id)
    # The bar hands to no pass, so only the kitchen's dish waits here.
    expect(order[:items].map { |row| row[:station_name] }).to eq(['Bếp'])
    expect(board[:open]).to eq([])

    item = Spree::Pos::KitchenTicketItem.find_by_prefix_id(order[:items].sole[:item][:id])
    Spree::Pos::Kitchen::ChangeItemStatus.call(item: item, action: 'serve', actor: screen)
    expect(described_class.call(branch: branch, station: pass)[:expo]).to eq([])
  end

  it 'refuses a pass that is not an expo station of the branch' do
    expect(kitchen.update(expo_station: bar)).to be(false)
    other = kitchen_station!(kitchen_branch(store), name: 'Ra món', kind: 'expo')
    expect(kitchen.update(expo_station: other)).to be(false)
  end
end
