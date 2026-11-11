# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../../support/pos_platform_helpers'

# Entering a platform order makes one delivery sale from the platform, with
# the platform's prices, sends it to the kitchen at once and never makes a
# second order for the same platform code.
RSpec.describe Spree::Pos::PlatformOrders::Enter do
  include PosPlatformHelpers

  let(:store) { menu_store }
  let(:branch) { platform_branch(store, rate: 25, trigger: 'manual') }
  let(:counter) { platform_counter(store, branch) }
  let(:milk_tea) { menu_item!(store, branch, name: 'Trà sữa', price: 30_000) }
  let(:pearls) { modifier_group!(store, milk_tea, name: 'Topping', options: { 'Trân châu' => 5_000 }) }
  let!(:kitchen) { kitchen_station!(branch, name: 'Bar', kind: 'bar', default: true) }

  it 'makes a delivery sale from the platform and sends it to the kitchen with the pickup code' do
    order = enter_platform(store, counter, ref: 'GF-1001', pickup: 'A12',
                                           lines: [platform_line(size(milk_tea), quantity: 2, price: 39_000,
                                                                                 modifiers: picks([option(pearls, 'Trân châu')]), note: 'Ít ngọt')])

    workspace = order.workspace
    expect(workspace).to have_attributes(order_source: 'grabfood', service_mode: 'delivery', operational_status: 'editing')
    expect(workspace.order_number).to eq(1)
    line = Spree::Pos::SaleLine.where(workspace_id: workspace.id).sole
    expect(line).to have_attributes(kind: 'menu', unit_price: 39_000, note: 'Ít ngọt')
    expect(line.line_modifiers.map(&:name)).to eq(['Trân châu'])
    expect(workspace.order.reload.total).to eq(78_000)
    expect(order).to have_attributes(status: 'accepted', gross_amount: 78_000, commission_rate: 25, commission_amount: 19_500,
                                     net_amount: 58_500, currency: 'VND', pickup_code: 'A12', entered_by: counter.cashier)

    # A manual-send branch still sends: the customer has paid the platform.
    ticket = Spree::Pos::KitchenTicket.where(workspace_id: workspace.id).sole
    expect(ticket.header).to include('order_source' => 'grabfood', 'platform_order_ref' => 'GF-1001', 'pickup_code' => 'A12',
                                     'order_number' => 1, 'service_mode' => 'delivery')
    expect(ticket.items.sole).to have_attributes(quantity: 2, status: 'new')
    document = Spree::Pos::Kitchen::TicketDocument.build(ticket)
    expect(document['header'].flat_map { |block| block['lines'] || [] }).to include('GRABFOOD · Mã lấy: A12')

    override = Spree::Pos::AuditEntry.find_by!(action: 'workspace.price.override', subject_id: workspace.id)
    expect(override.metadata).to include('reason' => 'platform_price', 'before' => '35000.0', 'after' => '39000.0',
                                         'platform' => 'grabfood')
    expect(Spree::Pos::AuditEntry.where(action: 'platform_order.enter', subject_id: workspace.id).count).to eq(1)
  end

  it 'keeps the menu price when the platform price is the same or missing, without an override' do
    order = enter_platform(store, counter, lines: [platform_line(size(milk_tea), price: 30_000), platform_line(size(milk_tea))])

    expect(order.gross_amount).to eq(60_000)
    expect(Spree::Pos::AuditEntry.where(action: 'workspace.price.override', subject_id: order.workspace_id)).to be_empty
  end

  it 'answers the same order for the same key and refuses the same platform code twice' do
    key = SecureRandom.uuid
    lines = [platform_line(size(milk_tea))]
    first = enter_platform(store, counter, ref: 'GF-2002', key: key, lines: lines)
    expect(enter_platform(store, counter, ref: 'GF-2002', key: key, lines: lines)).to eq(first)

    expect { enter_platform(store, counter, ref: 'GF-2002', lines: lines) }.to raise_error(Spree::Pos::Conflict) { |error|
      expect(error.reason).to eq('platform_order_duplicate')
      expect(error.details).to eq(platform_order_id: first.prefixed_id)
    }
    expect(Spree::Pos::PlatformOrder.where(branch_id: branch.id).count).to eq(1)
    expect(Spree::Pos::Workspace.where(branch_id: branch.id, order_source: 'grabfood').count).to eq(1)

    # The same code on another platform is another order.
    Spree::Pos::PlatformSetting.create!(store: store, branch: branch, platform: 'shopeefood', commission_rate: 20, status: 'active')
    expect(enter_platform(store, counter, ref: 'GF-2002', platform: 'shopeefood', lines: lines).platform).to eq('shopeefood')
  end

  it 'refuses a platform the branch has not turned on, and a branch without the module' do
    expect { enter_platform(store, counter, platform: 'shopeefood', lines: [platform_line(size(milk_tea))]) }.
      to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('platform_disabled') }

    set_pos_module(branch, 'fnb.delivery_platforms', false)
    expect { enter_platform(store, counter, lines: [platform_line(size(milk_tea))]) }.
      to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('module_disabled') }
    expect(Spree::Pos::Workspace.where(branch_id: branch.id)).to be_empty
  end

  it 'takes menu items only, and rolls the whole entry back when one line is refused' do
    plain = create(:product, store: store, status: 'active', name: 'Khăn giấy')
    plain.default_variant.set_price('VND', 2_000)
    Spree::Pos::BranchProduct.create!(branch: branch, product: plain)
    branch.stock_location.restock(plain.default_variant, 10)

    expect { enter_platform(store, counter, lines: [platform_line(size(milk_tea)), platform_line(plain.default_variant)]) }.
      to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('platform_item_not_menu') }
    expect(Spree::Pos::Workspace.where(branch_id: branch.id)).to be_empty
    expect(Spree::Pos::PlatformOrder.count).to eq(0)
  end

  it 'refuses an empty order, a bad code and a bad price' do
    expect { enter_platform(store, counter, lines: []) }.
      to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('platform_order_empty') }
    expect { enter_platform(store, counter, ref: 'GF 1', lines: [platform_line(size(milk_tea))]) }.
      to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('platform_order_ref_invalid') }
    expect { enter_platform(store, counter, lines: [platform_line(size(milk_tea), price: '-1')]) }.
      to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('platform_price_invalid') }
    expect { enter_platform(store, counter, lines: [platform_line(size(milk_tea), price: '1.5')]) }.
      to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('platform_price_invalid') }
  end

  it 'keeps a platform order on its platform and the platform off other sales' do
    order = enter_platform(store, counter, lines: [platform_line(size(milk_tea))])
    sale = PosCreditHelpers::Sale.new(workspace: order.workspace, cashier: counter.cashier, editor_id: counter.editor_id)

    expect { Spree::Pos::Workspaces::SetOrderSource.call(**editing_args(sale), order_source: 'counter') }.
      to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('order_source_invalid') }
    expect { take_tender(sale, 'cash', 30_000) }.
      to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('platform_tender') }

    counter_sale = menu_sale(store, branch)
    add_menu(counter_sale, size(milk_tea))
    expect { Spree::Pos::Workspaces::SetOrderSource.call(**editing_args(counter_sale), order_source: 'grabfood') }.
      to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('order_source_invalid') }
    method = Spree::Pos::PaymentMethodResolver.new(store: store).platform_method!
    expect do
      Spree::Pos::Tenders::Prepare.call(**editing_args(counter_sale), payment_method_id: method.prefixed_id, amount: '30000')
    end.to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('platform_tender') }
    # The counter never offers it, and the store's payment method list leaves it out.
    resolver = Spree::Pos::PaymentMethodResolver.new(store: store)
    expect(resolver.available(branch: branch).map(&:kind)).not_to include('platform_receivable')
    expect(resolver.materialize!.map(&:kind)).not_to include('platform_receivable')
  end
end
