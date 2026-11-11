# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../../support/pos_kitchen_helpers'

# Every menu line reaches a station: the most specific route first, the
# branch's default station last, and a missing route is never an error.
RSpec.describe Spree::Pos::Kitchen::Router do
  include PosKitchenHelpers

  let(:store) { menu_store }
  let(:branch) { kitchen_branch(store) }
  let(:item) { menu_item!(store, branch, name: 'Bia Sài Gòn', price: 20_000).tap { |row| row.update!(kitchen_category: 'drinks') } }
  let(:line) { Spree::Pos::SaleLine.new(variant: size(item)) }
  let!(:kitchen) { kitchen_station!(branch, name: 'Bếp', default: true) }
  let!(:bar) { kitchen_station!(branch, name: 'Bar', kind: 'bar', position: 1) }
  let!(:cooler) { kitchen_station!(branch, name: 'Tủ mát', position: 2) }
  let!(:pass) { kitchen_station!(branch, name: 'Ra món', kind: 'expo', position: 3) }

  def station(mode = 'takeaway')
    described_class.station_for(branch, line, mode)
  end

  it 'takes a product route for the service mode before every other route' do
    station_route!(pass, product: item.product, mode: 'takeaway')
    station_route!(cooler, product: item.product)
    station_route!(bar, category: 'drinks', mode: 'takeaway')
    station_route!(bar, category: 'drinks')

    expect(station('takeaway')).to eq(pass)
    expect(station('dine_in')).to eq(cooler)
  end

  it 'takes a product route for every mode before category routes' do
    station_route!(cooler, product: item.product)
    station_route!(bar, category: 'drinks', mode: 'takeaway')

    expect(station('takeaway')).to eq(cooler)
  end

  it 'takes a category route for the service mode before one for every mode' do
    station_route!(pass, category: 'drinks', mode: 'takeaway')
    station_route!(bar, category: 'drinks')

    expect(station('takeaway')).to eq(pass)
    expect(station('counter')).to eq(bar)
  end

  it 'falls back to the default station, then to the first active one, and to nothing without stations' do
    station_route!(bar, category: 'food')
    expect(station).to eq(kitchen)

    kitchen.update!(is_default: false)
    expect(station).to eq(kitchen)

    kitchen.update!(active: false)
    bar.update!(active: false)
    station_route!(bar, product: item.product)
    expect(station).to eq(cooler)

    Spree::Pos::KitchenStation.where(branch_id: branch.id).update_all(active: false)
    expect(station).to be_nil
  end

  it 'reads the routes once for one send' do
    station_route!(bar, category: 'drinks')
    router = described_class.new(branch)
    router.station_for(line, 'counter')

    queries = 0
    counter = ->(*, payload) { queries += 1 unless payload[:name] == 'SCHEMA' || payload[:sql].start_with?('SAVEPOINT', 'RELEASE') }
    ActiveSupport::Notifications.subscribed(counter, 'sql.active_record') do
      3.times { expect(router.station_for(line, 'counter')).to eq(bar) }
    end
    expect(queries).to eq(0)
  end
end
