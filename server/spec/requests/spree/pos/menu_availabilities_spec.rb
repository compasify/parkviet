# frozen_string_literal: true

require 'spree/api/testing_support/v3/base'
require_relative '../../../support/pos_menu_helpers'
require_relative '../../../support/pos_schema_helpers'

# Sold out holds for the business day it was set on: the counter refuses
# the item, screens hear `menu.sold_out`, and the next business day sells it again.
RSpec.describe 'POS menu availabilities API', type: :request do
  include PosMenuHelpers
  include PosSchemaHelpers
  include ActionCable::TestHelper
  include ActiveSupport::Testing::TimeHelpers

  let(:store) { menu_store }
  let(:branch) { menu_branch(store) }
  let(:item) { menu_item!(store, branch, name: 'Bánh flan', price: 15_000) }
  let(:zone) { ActiveSupport::TimeZone['Asia/Ho_Chi_Minh'] }

  before { allow(Spree::Store).to receive(:default).and_return(store) }

  def token_for(user)
    post '/api/v3/admin/auth/login', params: { email: user.email, password: 'secret123' }, as: :json
    response.parsed_body.fetch('token')
  end

  def sold_out(user, value, target: item)
    put '/api/v3/admin/pos/menu_availabilities',
        headers: { 'Authorization' => "Bearer #{token_for(user)}", 'Idempotency-Key' => SecureRandom.uuid },
        params: { branch_id: branch.prefixed_id, menu_item_id: target.prefixed_id, sold_out: value }, as: :json
    response.parsed_body
  end

  def menu_row(user)
    get '/api/v3/admin/pos/menu', headers: { 'Authorization' => "Bearer #{token_for(user)}" }, params: { branch_id: branch.prefixed_id }
    response.parsed_body.dig('data', 'items').find { |row| row['id'] == item.prefixed_id }
  end

  it 'marks an item sold out for the business day, refuses it at the counter and lapses the next day' do
    lead = credit_staff(store, branch, [Spree::Pos::Capabilities::SET_SOLD_OUT])
    sale = menu_sale(store, branch)
    travel_to(zone.local(2026, 11, 11, 20, 0)) do
      body = sold_out(lead, true)
      expect(response).to have_http_status(:ok), response.body
      expect_pos_schema!(response, 'MenuAvailability')
      expect(body['data']).to include('sold_out' => true, 'business_date' => '2026-11-11')
      event = broadcasts(Spree::Pos::Realtime.stream_name(branch)).map { |raw| JSON.parse(raw) }.find { |row| row['event'] == 'menu.sold_out' }
      expect(event).to include('id' => item.prefixed_id, 'refs' => { 'menu_item_id' => item.prefixed_id })
      expect(Spree::Pos::AuditEntry.where(action: 'menu.sold_out').sole.metadata).to include('sold_out' => true)

      expect(menu_row(sale.cashier)['sold_out']).to be(true)
      expect { add_menu(sale, size(item)) }.to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('menu_item_sold_out') }

      # The same mark again changes and announces nothing.
      sold_out(lead, true)
      expect(Spree::Pos::AuditEntry.where(action: 'menu.sold_out').count).to eq(1)
    end

    # 03:59 still belongs to 11 November (cutoff 04:00); 04:00 starts the next day.
    travel_to(zone.local(2026, 11, 12, 3, 59)) { expect(menu_row(sale.cashier)['sold_out']).to be(true) }
    travel_to(zone.local(2026, 11, 12, 4, 0)) do
      expect(menu_row(sale.cashier)['sold_out']).to be(false)
      add_menu(sale, size(item))
      expect(menu_lines(sale).size).to eq(1)
    end
  end

  it 'puts an item back on sale' do
    lead = credit_staff(store, branch, [Spree::Pos::Capabilities::SET_SOLD_OUT])
    sold_out(lead, true)
    body = sold_out(lead, false)
    expect(body['data']).to include('sold_out' => false)
    expect(Spree::Pos::AuditEntry.where(action: 'menu.sold_out').count).to eq(2)
    expect(menu_row(lead)['sold_out']).to be(false)
  end

  it 'needs the sold-out or menu capability at the branch, or a kitchen screen there' do
    cashier = credit_staff(store, branch, PosCreditHelpers::CASHIER)
    sold_out(cashier, true)
    expect(response).to have_http_status(:forbidden)
    expect(Spree::Pos::MenuAvailability.count).to eq(0)

    guard = Spree::Pos::Menu::Guard
    kitchen = Spree::Pos::Device.new(store: store, branch: branch, mode: 'kds')
    waiter = Spree::Pos::Device.new(store: store, branch: branch, mode: 'waiter')
    expect { guard.sold_out!(store, cashier, branch, device: kitchen) }.not_to raise_error
    expect { guard.sold_out!(store, cashier, branch, device: waiter) }.to raise_error(CanCan::AccessDenied)
    other = Spree::Pos::Device.new(store: store, branch: credit_branch(store), mode: 'kds')
    expect { guard.sold_out!(store, cashier, branch, device: other) }.to raise_error(CanCan::AccessDenied)
  end

  it 'refuses at a branch that does not run the menu' do
    set_pos_module(branch, 'fnb.menu', false)
    sold_out(credit_staff(store, branch, [Spree::Pos::Capabilities::SET_SOLD_OUT]), true)
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('module_disabled')
  end
end
