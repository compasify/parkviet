# frozen_string_literal: true

require 'spree/api/testing_support/v3/base'
require_relative '../../../support/pos_recipe_helpers'
require_relative '../../../support/pos_schema_helpers'

# Recipes, low-stock thresholds and the two recipe reports over HTTP, every
# response matching pos-staff.yaml.
RSpec.describe 'POS recipes API', type: :request do
  include PosRecipeHelpers
  include PosSchemaHelpers

  let(:store) { menu_store }
  let(:branch) { recipe_branch(store) }
  let(:manager) do
    credit_staff(store, branch, [Spree::Pos::Capabilities::INVENTORY_MANAGE, Spree::Pos::Capabilities::REPORT_READ,
                                 Spree::Pos::Capabilities::REPORT_EXPORT])
  end
  let(:item) { menu_item!(store, branch, name: 'Trà sữa', price: 30_000, sizes: { 'M' => 30_000, 'L' => 36_000 }) }
  let(:milk) { ingredient!(store, branch, name: 'Sữa tươi', base: 'ml', stock: 1_000, cost: 40) }

  before { allow(Spree::Store).to receive(:default).and_return(store) }

  def token_for(user)
    @tokens ||= {}
    @tokens[user.id] ||= begin
      post '/api/v3/admin/auth/login', params: { email: user.email, password: 'secret123' }, as: :json
      response.parsed_body.fetch('token')
    end
  end

  def call(user, verb, path, body = {})
    key = SecureRandom.uuid
    send(verb, "/api/v3/admin/pos/#{path}", headers: { 'Authorization' => "Bearer #{token_for(user)}", 'Idempotency-Key' => key },
                                            params: verb == :get ? body : body.merge(idempotency_key: key), as: verb == :get ? nil : :json)
    response.parsed_body
  end

  def business_today
    Spree::Pos::BusinessDay.for(branch, Spree::Pos::Workspace.business_now).iso8601
  end

  it 'saves a recipe version, warns before writing stock off, and reads the history' do
    variant = size(item, 1)
    body = { variant_id: variant.prefixed_id, ingredients: [{ variant_id: milk.prefixed_id, quantity: '0.2', unit_code: 'l' }] }

    call(manager, :put, 'recipes', body)
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('recipe_variant_has_stock')

    call(manager, :put, 'recipes', body.merge(confirm_stock_write_off: true))
    expect(response).to have_http_status(:ok)
    expect_pos_schema!(response, 'RecipeOwner')
    expect(response.parsed_body.dig('data', 'active', 'ingredients', 0)).to include('base_quantity' => 200, 'base_unit' => 'ml',
                                                                                    'cost' => '8000.0')

    data = call(manager, :get, 'recipes', variant_id: variant.prefixed_id)
    expect(response).to have_http_status(:ok)
    expect_pos_schema!(response, 'RecipeOwner')
    expect(data.dig('data', 'track_inventory')).to be(false)
    expect(data.dig('data', 'versions').map { |row| row['version'] }).to eq([1])

    cashier = credit_staff(store, branch, PosCreditHelpers::CASHIER)
    call(cashier, :put, 'recipes', body.merge(confirm_stock_write_off: true))
    expect(response).to have_http_status(:forbidden)
  end

  it 'sets thresholds, lists low ones first and removes one' do
    sugar = ingredient!(store, branch, name: 'Đường', base: 'g', stock: 5_000)
    call(manager, :put, 'stock_alerts', branch_id: branch.prefixed_id, variant_id: sugar.prefixed_id, min_quantity: 1_000)
    data = call(manager, :put, 'stock_alerts', branch_id: branch.prefixed_id, variant_id: milk.prefixed_id, min_quantity: 2_000)
    expect(response).to have_http_status(:ok)
    expect_pos_schema!(response, 'StockAlert')
    expect(data['data'].map { |row| [row['name'], row['low'], row['on_hand']] }).to eq([['Sữa tươi', true, 1_000], ['Đường', false, 5_000]])

    call(manager, :put, 'stock_alerts', branch_id: branch.prefixed_id, variant_id: milk.prefixed_id, min_quantity: nil)
    expect(call(manager, :get, 'stock_alerts', branch_id: branch.prefixed_id)['data'].map { |row| row['name'] }).to eq(['Đường'])
    expect(Spree::Pos::AuditEntry.where(action: 'stock_alert.change').count).to eq(3)

    set_pos_module(branch, 'fnb.recipes', false)
    call(manager, :put, 'stock_alerts', branch_id: branch.prefixed_id, variant_id: milk.prefixed_id, min_quantity: 10)
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('module_disabled')
  end

  describe 'reports' do
    before do
      recipe!(store, manager, size(item, 0), [[milk, 150, 'ml']])
      recipe!(store, manager, size(item, 1), [[milk, 200, 'ml']])
      sale = menu_sale(store, branch)
      add_menu(sale, size(item, 1), quantity: 2)
      add_menu(sale, size(item, 0))
      pay_and_complete(sale)
    end

    it 'reports ingredient usage by day, ingredient and item' do
      data = call(manager, :get, 'reports/ingredient_usage', branch_id: branch.prefixed_id, from: business_today, to: business_today)
      expect(response).to have_http_status(:ok)
      expect_pos_schema!(response, 'IngredientUsageRow')
      expect(data['data'].map { |row| [row['menu_item'], row['quantity'], row['unit'], row['cost']] }).
        to contain_exactly(['Trà sữa · Size: L', 400, 'ml', '16000.0'], ['Trà sữa · Size: M', 150, 'ml', '6000.0'])
      expect(data.dig('meta', 'summary')).to include('total_cost' => '22000.0', 'shortages' => 0)
      expect(data.dig('meta', 'summary', 'ingredients').sole).to include('quantity' => 550, 'unit' => 'ml')
    end

    it 'reports the margin of each size, and exports it' do
      data = call(manager, :get, 'reports/menu_margin', branch_id: branch.prefixed_id, from: business_today, to: business_today)
      expect(response).to have_http_status(:ok)
      expect_pos_schema!(response, 'MenuMarginRow')
      expect(data['data'].map { |row| [row['menu_item'], row['quantity'], row['revenue'], row['cost'], row['margin']] }).
        to eq([['Trà sữa · Size: L', 2, '72000.0', '16000.0', '56000.0'], ['Trà sữa · Size: M', 1, '30000.0', '6000.0', '24000.0']])
      expect(data.dig('meta', 'summary')).to include('revenue' => '102000.0', 'cost' => '22000.0', 'margin' => '80000.0')

      created = call(manager, :post, 'exports', branch_id: branch.prefixed_id, report_type: 'menu_margin',
                                                filters: { from: business_today, to: business_today })
      expect(response).to have_http_status(:accepted)
      export = Spree::Pos::ExportRequest.find_by_prefix_id!(created.dig('data', 'id'))
      Spree::Pos::GenerateExportJob.perform_now(export.id)
      expect(export.reload).to have_attributes(status: 'ready', row_count: 2)
    end
  end
end
