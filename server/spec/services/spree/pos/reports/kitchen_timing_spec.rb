# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../../support/pos_kitchen_helpers'

# Kitchen timing of a branch: average and 90th percentile from send to
# ready, and late items, by station, dish and local hour.
RSpec.describe Spree::Pos::Reports::KitchenTiming do
  include PosKitchenHelpers

  let(:store) { menu_store }
  let(:branch) { kitchen_branch(store, trigger: 'manual') }
  let!(:kitchen) { kitchen_station!(branch, name: 'Bếp', default: true) }
  let(:soup) { size(menu_item!(store, branch, name: 'Phở bò', price: 50_000)) }
  let(:screen) { kitchen_screen!(branch, Spree::Pos::Device.new_token) }

  def ready_after(minutes)
    sale = menu_sale(store, branch)
    add_menu(sale, soup)
    kitchen_send(sale)
    item = tickets_of(sale).sole.items.sole
    allow(Spree::Pos::Workspace).to receive(:database_now).and_return(item.kitchen_ticket.sent_at + minutes.minutes)
    Spree::Pos::Kitchen::ChangeItemStatus.call(item: item, action: 'ready', actor: screen)
    item.reload
  end

  it 'adds up preparation times and late items by station, dish and hour' do
    items = [ready_after(4), ready_after(6), ready_after(20)]
    report = described_class.call(branch: branch, from: 1.day.ago, to: 1.day.from_now)

    expect(report['summary']).to include('items' => 3, 'average_seconds' => 600, 'late_items' => 1)
    expect(report['summary']['p90_seconds']).to be_between(840, 1200)
    expect(report['station'].sole).to include('key' => 'Bếp', 'items' => 3)
    expect(report['dish'].sole).to include('key' => items.first.name, 'late_items' => 1)
    hour = items.first.ready_at.in_time_zone(branch.timezone).hour
    expect(report['hour'].map { |row| row['key'] }).to include(hour)

    expect(described_class.call(branch: branch, from: 2.days.ago, to: 1.day.ago)['summary']['items']).to eq(0)
  end
end
