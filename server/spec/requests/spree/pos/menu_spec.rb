# frozen_string_literal: true

require 'spree/api/testing_support/v3/base'
require_relative '../../../support/pos_menu_helpers'
require_relative '../../../support/pos_schema_helpers'

# The menu over HTTP: one read for the counter with an etag, store-wide
# changes for menu managers (audited), and menu lines added and changed
# through the item endpoints, every response matching pos-staff.yaml.
RSpec.describe 'POS menu API', type: :request do
  include PosMenuHelpers
  include PosSchemaHelpers
  include ActiveSupport::Testing::TimeHelpers

  let(:store) { menu_store }
  let(:branch) { menu_branch(store) }
  let(:manager) { credit_staff(store, branch, [Spree::Pos::Capabilities::MANAGE_MENU]) }

  before { allow(Spree::Store).to receive(:default).and_return(store) }

  def token_for(user)
    @tokens ||= {}
    @tokens[user.id] ||= begin
      post '/api/v3/admin/auth/login', params: { email: user.email, password: 'secret123' }, as: :json
      response.parsed_body.fetch('token')
    end
  end

  def auth(user, key: nil)
    headers = { 'Authorization' => "Bearer #{token_for(user)}" }
    headers['Idempotency-Key'] = key if key
    headers
  end

  def write(verb, user, path, body = {})
    send(verb, "/api/v3/admin/pos/#{path}", headers: auth(user, key: SecureRandom.uuid), params: body, as: :json)
    response.parsed_body
  end

  def read_menu(user, etag: nil)
    headers = auth(user)
    headers['If-None-Match'] = %("#{etag}") if etag
    get '/api/v3/admin/pos/menu', headers: headers, params: { branch_id: branch.prefixed_id }
    response
  end

  # Noon at the branch, well inside the all-day window below.
  around { |example| travel_to(Time.zone.parse('2026-11-11T05:00:00Z')) { example.run } }

  it 'reads the menu of a branch with sizes, options, favourites and an etag' do
    category = Spree::Pos::MenuCategory.create!(store: store, name: 'Trà sữa', position: 1)
    item = menu_item!(store, branch, name: 'Trà sữa', price: 30_000, sizes: { 'M' => 30_000, 'L' => 36_000 }, category: category)
    group = modifier_group!(store, item, name: 'Đường', options: { '50%' => 0, '100%' => 0 }, min: 1, defaults: ['100%'])
    hidden = menu_item!(store, branch, name: 'Bánh mì', price: 20_000)
    menu_item!(store, credit_branch(store), name: 'Ở chi nhánh khác', price: 10_000)
    schedule = Spree::Pos::MenuSchedule.create!(store: store, name: 'Cả ngày', starts_at: '00:00', ends_at: '23:59')
    schedule.menu_schedule_items.create!(menu_item: hidden, hidden: true)
    Spree::Pos::MenuFavorite.create!(branch: branch, menu_item: item, position: 0)
    cashier = credit_staff(store, branch, PosCreditHelpers::CASHIER)

    expect(read_menu(cashier)).to have_http_status(:ok)
    expect_pos_schema!(response, 'Menu')
    data = response.parsed_body['data']
    expect(data['module_enabled']).to be(true)
    expect(data['items'].map { |row| row['name'] }).to eq(['Trà sữa'])
    row = data['items'].sole
    expect(row).to include('menu_category_id' => category.prefixed_id, 'sold_out' => false, 'modifier_group_ids' => [group.prefixed_id])
    expect(row['variants'].map { |variant| variant['price'] }).to eq(%w[30000.0 36000.0])
    expect(data['modifier_groups'].sole['options'].map { |option| [option['name'], option['default_selected']] }).
      to eq([['50%', false], ['100%', true]])
    expect(data['favorites']).to eq([item.prefixed_id])

    etag = data['etag']
    expect(response.headers['ETag']).to eq(%("#{etag}"))
    expect(read_menu(cashier, etag: etag)).to have_http_status(:not_modified)
    Spree::Pos::MenuFavorite.delete_all
    expect(read_menu(cashier, etag: etag)).to have_http_status(:ok)

    outsider = credit_staff(store, credit_branch(store), PosCreditHelpers::CASHIER)
    expect(read_menu(outsider)).to have_http_status(:not_found)
  end

  it 'lets a menu manager build the menu, audited, and nobody else' do
    product = create(:product, store: store, status: 'active', name: 'Cà phê sữa')
    product.default_variant.set_price('VND', 25_000)

    category = write(:post, manager, 'menu_categories', name: 'Cà phê', position: 1, color: '#7b4a2e')['data']
    expect(response).to have_http_status(:created)
    group = write(:post, manager, 'modifier_groups', name: 'Đá', min_select: 0, max_select: 1,
                                                     options: [{ name: 'Ít đá', price_delta: '0' }, { name: 'Không đá', price_delta: '0' }])['data']
    expect(response).to have_http_status(:created)
    expect(group['options'].map { |row| row['name'] }).to eq(['Ít đá', 'Không đá'])

    item = write(:post, manager, 'menu_items', product_id: product.prefixed_id, menu_category_id: category['id'],
                                               kitchen_category: 'bar', modifier_group_ids: [group['id']])['data']
    expect(response).to have_http_status(:created)
    expect(item).to include('name' => 'Cà phê sữa', 'kitchen_category' => 'bar', 'modifier_group_ids' => [group['id']])
    # A new item joins the assortment of every branch running the menu.
    expect(Spree::Pos::BranchProduct.exists?(branch: branch, product: product)).to be(true)

    kept = group['options'].first
    group = write(:patch, manager, "modifier_groups/#{group['id']}", options: [{ id: kept['id'], name: 'Ít đá', price_delta: '0' },
                                                                               { name: 'Nhiều đá', price_delta: '0' }])['data']
    expect(group['options'].map { |row| row['name'] }).to eq(['Ít đá', 'Nhiều đá'])
    expect(group['options'].first['id']).to eq(kept['id'])

    get '/api/v3/admin/pos/menu_items', headers: auth(manager)
    expect(response).to have_http_status(:ok)
    expect_pos_schema!(response, 'MenuItemConfig')
    get '/api/v3/admin/pos/modifier_groups', headers: auth(manager)
    expect_pos_schema!(response, 'ModifierGroup')
    get '/api/v3/admin/pos/menu_categories', headers: auth(manager)
    expect_pos_schema!(response, 'MenuCategory')

    expect(Spree::Pos::AuditEntry.where(action: %w[menu_category.change modifier_group.change menu_item.change]).count).to eq(4)

    write(:post, manager, 'menu_items', product_id: product.prefixed_id)
    expect(response).to have_http_status(:unprocessable_content)
    write(:post, manager, 'menu_items', product_id: create(:product, store: store).prefixed_id, kind: 'combo')
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('combo_empty')

    cashier = credit_staff(store, branch, PosCreditHelpers::CASHIER)
    write(:post, cashier, 'menu_categories', name: 'Trà')
    expect(response).to have_http_status(:forbidden)

    write(:delete, manager, "menu_categories/#{category['id']}")
    expect(response).to have_http_status(:ok)
    expect(Spree::Pos::MenuItem.find_by_prefix_id!(item['id']).menu_category_id).to be_nil
  end

  it 'refuses menu changes while no branch of the store runs the menu' do
    set_pos_module(branch, 'fnb.menu', false)
    write(:post, manager, 'menu_categories', name: 'Cà phê')
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('module_disabled')
  end

  it 'saves time-of-day menus and favourites' do
    item = menu_item!(store, branch, name: 'Trà đào', price: 30_000)
    schedule = write(:post, manager, 'menu_schedules', name: 'Giờ vàng', starts_at: '14:00', ends_at: '16:00', days_of_week: [1, 2],
                                                       items: [{ menu_item_id: item.prefixed_id, price: '20000' }])['data']
    expect(response).to have_http_status(:created)
    expect(schedule).to include('starts_at' => '14:00', 'ends_at' => '16:00', 'days_of_week' => [1, 2])
    expect(schedule['items'].sole).to include('menu_item_id' => item.prefixed_id, 'price' => '20000.0')
    write(:post, manager, 'menu_schedules', name: 'Sai', starts_at: '14:00', ends_at: '16:00', days_of_week: [9])
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('menu_schedule_days_invalid')

    lead = credit_staff(store, branch, [Spree::Pos::Capabilities::MANAGE_MENU])
    body = write(:put, lead, 'menu_favorites', branch_id: branch.prefixed_id, menu_item_ids: [item.prefixed_id])
    expect(response).to have_http_status(:ok)
    expect(body['data']).to eq('branch_id' => branch.prefixed_id, 'menu_item_ids' => [item.prefixed_id])
    expect(Spree::Pos::AuditEntry.where(action: 'menu_favorite.change').count).to eq(1)
  end

  it 'adds menu lines with options over HTTP and changes their options' do
    item = menu_item!(store, branch, name: 'Trà sữa', price: 30_000)
    group = modifier_group!(store, item, name: 'Topping', options: { 'Trân châu' => 5_000, 'Thạch' => 4_000 }, max: 2)
    sale = menu_sale(store, branch)

    add = lambda do |modifiers|
      workspace = sale.workspace.reload
      post "/api/v3/admin/pos/workspaces/#{workspace.prefixed_id}/items", headers: auth(sale.cashier, key: SecureRandom.uuid),
                                                                          params: { expected_revision: workspace.revision, lease_generation: workspace.lease_generation,
                                                                                    editor_id: sale.editor_id, variant_id: size(item).prefixed_id,
                                                                                    quantity: 1, merge: true, modifiers: modifiers, note: 'Ít ngọt' }, as: :json
    end
    add.call([{ option_id: option(group, 'Trân châu').prefixed_id }])
    expect(response).to have_http_status(:ok), response.body
    expect_pos_schema!(response, 'Workspace')
    line = response.parsed_body.dig('data', 'line_items').sole
    expect(line).to include('kind' => 'menu', 'unit_price' => '35000.0', 'note' => 'Ít ngọt')

    add.call([{ option_id: 'posmodopt_nope' }])
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('modifier_unknown')

    workspace = sale.workspace.reload
    patch "/api/v3/admin/pos/workspaces/#{workspace.prefixed_id}/items/#{line['sale_line_id']}/modifiers",
          headers: auth(sale.cashier, key: SecureRandom.uuid),
          params: { expected_revision: workspace.revision, lease_generation: workspace.lease_generation, editor_id: sale.editor_id,
                    modifiers: [{ option_id: option(group, 'Thạch').prefixed_id }] }, as: :json
    expect(response).to have_http_status(:ok), response.body
    expect_pos_schema!(response, 'Workspace')
    expect(response.parsed_body.dig('data', 'line_items').sole).to include('unit_price' => '34000.0', 'note' => nil)
  end
end
