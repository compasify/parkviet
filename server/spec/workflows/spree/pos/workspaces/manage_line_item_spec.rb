# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../../support/pos_menu_helpers'

# Adding menu lines: the server prices them, two option sets are two lines,
# the same set merges, sold-out items are refused, and a branch without the
# menu sells the same item as an ordinary line at its list price.
RSpec.describe Spree::Pos::Workspaces::ManageLineItem do
  include PosMenuHelpers
  include ActionCable::TestHelper
  include ActiveSupport::Testing::TimeHelpers

  let(:store) { menu_store }
  let(:branch) { menu_branch(store) }
  let(:item) { menu_item!(store, branch, name: 'Trà đào', price: 30_000, sizes: { 'M' => 30_000, 'L' => 36_000 }) }
  let!(:topping) do
    modifier_group!(store, item, name: 'Topping', options: { 'Trân châu' => 5_000, 'Thạch' => 4_000 }, max: 3, allow_quantity: true)
  end
  let(:sale) { menu_sale(store, branch) }

  def expect_conflict(reason, &block)
    expect(&block).to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq(reason) }
  end

  describe 'merge keys of lines without options' do
    # The key of a retail line is the digest of these exact parts (with
    # ActiveSupport a BigDecimal prints as 25000.0). A change here would
    # split lines that merged before the menu existed.
    it 'keeps the keys of ordinary, measured and tracked lines' do
      ordinary = Digest::SHA256.hexdigest('42|ordinary|25000.0|item|||none')
      measured = Digest::SHA256.hexdigest('42|measured|0.25|g|||none')
      tracked = Digest::SHA256.hexdigest('42|tracked|25000.0|item|L1|A1,B2|lot|2027-01-31')
      expect(Spree::Pos::SaleLine.build_merge_key(variant_id: 42, kind: 'ordinary', unit_price: BigDecimal('25000'), sale_unit_code: 'item')).
        to eq(ordinary)
      expect(Spree::Pos::SaleLine.build_merge_key(variant_id: 42, kind: 'measured', unit_price: BigDecimal('0.25'), sale_unit_code: 'g')).
        to eq(measured)
      expect(Spree::Pos::SaleLine.build_merge_key(variant_id: 42, kind: 'tracked', unit_price: BigDecimal('25000'), sale_unit_code: 'item',
                                                  lot_code: 'L1', serial_codes: %w[B2 A1], tracked_mode: 'lot', expiry_on: '2027-01-31')).
        to eq(tracked)
      expect(Spree::Pos::SaleLine.build_merge_key(variant_id: 42, kind: 'ordinary', unit_price: BigDecimal('25000'), sale_unit_code: 'item',
                                                  modifier_signature: 'abc')).not_to eq(ordinary)
    end
  end

  it 'prices a menu line on the server and keeps two option sets as two lines' do
    large = size(item, 1)
    add_menu(sale, large, modifiers: picks([option(topping, 'Trân châu'), 2]))
    data = add_menu(sale, large, modifiers: picks([option(topping, 'Thạch')]))
    lines = menu_lines(sale)
    expect(lines.size).to eq(2)
    expect(lines.map(&:kind)).to all(eq('menu'))
    expect(lines.map(&:unit_price)).to eq([46_000, 40_000])
    expect(lines.map { |line| line.line_item.price }).to eq([46_000, 40_000])
    rows = data['line_items']
    expect(rows.map { |row| row['modifiers'].map { |mod| [mod['name'], mod['quantity']] } }).to eq([[['Trân châu', 2]], [['Thạch', 1]]])
    expect(sale.workspace.reload.order.item_total).to eq(86_000)
    audit = Spree::Pos::AuditEntry.where(action: 'workspace.item.add').order(:id).last
    expect(audit.metadata['menu']).to include('menu_item_id' => item.prefixed_id, 'unit_price' => '40000.0')
  end

  it 'merges the same options and note into one line, quantity 2' do
    large = size(item, 1)
    add_menu(sale, large, modifiers: picks([option(topping, 'Thạch')]), note: 'Ít đá')
    add_menu(sale, large, modifiers: picks([option(topping, 'Thạch')]), note: 'ít  đá')
    line = menu_lines(sale).sole
    expect(line).to have_attributes(sale_quantity: 2, base_quantity: 2, note: 'Ít đá')
    expect(line.line_item.quantity).to eq(2)
    expect(line.line_modifiers.size).to eq(1)

    add_menu(sale, large, modifiers: picks([option(topping, 'Thạch')]), note: 'Nhiều đá')
    expect(menu_lines(sale).size).to eq(2)
  end

  it 'never takes a price from the client' do
    expect_conflict('menu_price_fixed') do
      Spree::Pos::Workspaces::ManageLineItem.add(**editing_args(sale), variant_id: size(item).prefixed_id, quantity: 1, price_override: '1')
    end
    expect(menu_lines(sale)).to be_empty
  end

  it 'shows what a combo contains in the order and keeps its price on its own line' do
    burger = menu_item!(store, branch, name: 'Burger', price: 45_000)
    fries = menu_item!(store, branch, name: 'Khoai tây', price: 20_000)
    combo = menu_item!(store, branch, name: 'Combo trưa', price: 55_000, kind: 'combo')
    combo.combo_components.create!(variant: size(burger), quantity: 1)
    combo.combo_components.create!(variant: size(fries), quantity: 2)

    data = add_menu(sale, size(combo))
    row = data['line_items'].sole
    expect(row['amount']).to eq('55000.0')
    expect(row['components'].map { |component| [component['name'], component['quantity']] }).to eq([['Burger', 1], ['Khoai tây', 2]])
    expect(sale.workspace.reload.order.line_items.count).to eq(1)

    # The receipt keeps the contents and prints them as rows under the combo.
    printed = Spree::Pos::ReceiptBuilder.new('sale', sale.workspace.reload).attributes[:payload]['lines'].sole
    expect(printed['components']).to eq([{ 'name' => 'Burger', 'quantity' => 1 }, { 'name' => 'Khoai tây', 'quantity' => 2 }])
    expect(Spree::Pos::PrintDocuments::TemplateData.sale_line(printed, 'VND')[:notes]).to eq(['- Burger', '- Khoai tây ×2'])
  end

  it 'refuses an item sold out today, and sells it again on the next business day' do
    staff = credit_staff(store, branch, [Spree::Pos::Capabilities::SET_SOLD_OUT])
    Spree::Pos::Menu::SetSoldOut.call(store: store, staff: staff, key: SecureRandom.uuid, branch: branch, menu_item: item, sold_out: true)
    expect(broadcasts(Spree::Pos::Realtime.stream_name(branch)).map { |raw| JSON.parse(raw)['event'] }).to include('menu.sold_out')
    expect_conflict('menu_item_sold_out') { add_menu(sale, size(item)) }

    travel_to(1.day.from_now) do
      add_menu(sale, size(item))
      expect(menu_lines(sale).size).to eq(1)
    end
  end

  it 'applies the time-of-day price at the moment of adding and keeps it afterwards' do
    zone = ActiveSupport::TimeZone[branch.timezone]
    schedule = Spree::Pos::MenuSchedule.create!(store: store, name: 'Giờ vàng', starts_at: '14:00', ends_at: '16:00')
    schedule.menu_schedule_items.create!(menu_item: item, price: 20_000)
    travel_to(zone.local(2026, 11, 11, 15, 0)) do
      add_menu(sale, size(item, 1))
    end
    travel_to(zone.local(2026, 11, 11, 17, 0)) do
      add_menu(sale, size(item, 1), quantity: 1)
      add_menu(sale, size(item, 1), quantity: 1)
    end
    expect(menu_lines(sale).map { |line| [line.unit_price, line.sale_quantity] }).to eq([[20_000, 1], [36_000, 2]])
  end

  context 'when the branch does not run the menu' do
    let(:branch) { menu_branch(store, enabled: false) }

    it 'sells the item as an ordinary line at its list price and refuses options' do
      add_menu(sale, size(item, 1))
      expect(menu_lines(sale).sole).to have_attributes(kind: 'ordinary', unit_price: 36_000, modifier_signature: nil)
      expect_conflict('module_disabled') { add_menu(sale, size(item, 1), modifiers: picks([option(topping, 'Thạch')])) }
      expect_conflict('module_disabled') { add_menu(sale, size(item, 1), note: 'Ít đá') }
    end
  end

  it 'refuses options for an item that is not on the menu' do
    product = create(:product, store: store, status: 'active', name: 'Nước suối')
    product.default_variant.set_price('VND', 10_000)
    branch.stock_location.restock(product.default_variant, 10)
    Spree::Pos::BranchProduct.create!(branch: branch, product: product)
    expect_conflict('modifier_unknown') { add_menu(sale, product.default_variant, modifiers: picks([option(topping, 'Thạch')])) }
    add_menu(sale, product.default_variant)
    expect(menu_lines(sale).sole.kind).to eq('ordinary')
  end
end
