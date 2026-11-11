# frozen_string_literal: true

# The demo restaurant seed builds a branch a table-service shop can sell
# from, runs only when asked for in development, and leaves an existing
# demo alone.
RSpec.describe 'POS F&B demo seed', pos_modules: :default do
  let(:store) { create(:store, default_currency: 'VND', supported_currencies: 'VND') }
  let(:path) { Rails.root.join('db/seeds/pos_fnb_demo.rb') }

  before do
    allow(Spree::Store).to receive(:default).and_return(store)
    create(:admin_user)
  end

  def run(env: '1', development: true)
    allow(Rails.env).to receive(:development?).and_return(development)
    previous = ENV.fetch('POS_FNB_DEMO', nil)
    ENV['POS_FNB_DEMO'] = env
    expect { load path }.to output.to_stdout
  ensure
    ENV['POS_FNB_DEMO'] = previous
  end

  it 'creates a restaurant with tables, a menu with options, two stations and a fake LAN printer, once' do
    run
    branch = Spree::Pos::Branch.find_by!(store: store, code: 'demo-nha-hang')
    expect(branch).to have_attributes(profile_key: 'nha_hang', service_charge_rate: 5)
    expect(branch.table_register).to be_present
    expect(Spree::Pos::ModulePolicy.for_branch(branch)).to include('fnb.tables' => true, 'fnb.kitchen' => true, 'fnb.postpay' => true)
    expect(Spree::Pos::Area.where(branch: branch).count).to eq(2)
    expect(Spree::Pos::Resource.where(branch: branch).count).to eq(12)
    items = Spree::Pos::MenuItem.where(store: store)
    expect(items.count).to eq(30)
    expect(items.joins(:menu_item_modifier_groups).distinct.count).to be >= 20
    expect(Spree::Pos::KitchenStation.where(branch: branch).pluck(:name)).to contain_exactly('Bếp', 'Bar')
    expect(Spree::Pos::StationRoute.find_by!(branch: branch).kitchen_category).to eq('do_uong')
    expect(Spree::Pos::Printer.find_by!(branch: branch)).to have_attributes(connection: 'escpos_lan', address: '127.0.0.1:9100')

    run
    expect(Spree::Pos::Branch.for_store(store).where(code: 'demo-nha-hang').count).to eq(1)
    expect(Spree::Pos::MenuItem.where(store: store).count).to eq(30)
  end

  it 'does nothing unless asked for, and never outside development' do
    load path
    run(development: false)
    expect(Spree::Pos::Branch.for_store(store)).to be_empty
  end
end
