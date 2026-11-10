# frozen_string_literal: true

require 'spree/api/testing_support/v3/base'

RSpec.describe 'POS catalog', type: :request do
  let(:store) { Spree::Store.default }
  let(:password) { 'secret123' }
  let(:location) { create(:stock_location, store: store) }
  let(:branch) do
    Spree::Pos::Branch.create!(store: store, stock_location: location, name: 'Branch A', code: 'branch-a', timezone: 'Asia/Ho_Chi_Minh', status: 'active')
  end
  let(:product) { create(:product, store: store, name: 'Shirt', status: 'active') }

  def staff_with(permissions)
    staff = create(:admin_user, :without_admin_role, password: password)
    role = create(:role, resource: store, permissions: permissions)
    create(:role_user, user: staff, role: role)
    staff
  end

  def headers_for(staff)
    post '/api/v3/admin/auth/login', params: { email: staff.email, password: password }, as: :json
    { 'Authorization' => "Bearer #{response.parsed_body.fetch('token')}" }
  end

  def catalog(headers, branch_id: branch.prefixed_id, query: 'Shirt')
    get '/api/v3/admin/pos/catalog', headers: headers, params: { branch_id: branch_id, q: query }, as: :json
  end

  it 'requires an active branch membership and only returns products explicitly assigned there' do
    cashier = staff_with(%w[read_pos_orders])
    headers = headers_for(cashier)
    catalog(headers)
    expect(response).to have_http_status(:not_found)
    membership = Spree::Pos::StaffMembership.create!(store: store, branch: branch, staff: cashier, capabilities: [], status: 'active')
    catalog(headers)
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.fetch('data')).to be_empty
    Spree::Pos::BranchProduct.create!(branch: branch, product: product)
    location.restock(product.default_variant, 3)
    other_location = create(:stock_location, store: store)
    other_location.restock(product.default_variant, 17)
    catalog(headers)
    expect(response.parsed_body.fetch('data').map { |item| item['product_id'] }).to include(product.prefixed_id)
    product.default_variant.set_price(store.default_currency, 100)
    catalog(headers)
    expect(response.parsed_body.fetch('data').find { |item| item['product_id'] == product.prefixed_id }['stock_on_hand']).to eq(3)
    expect(response.parsed_body.fetch('data').find { |item| item['product_id'] == product.prefixed_id }['price']).to eq('100.0')
    expect_pos_schema!(response, 'CatalogItem')
    expect(response.parsed_body.to_json).not_to include('cost_price', 'metadata', 'stock_location')
    membership.update!(status: 'disabled')
    catalog(headers)
    expect(response).to have_http_status(:not_found)
  end

  it 'only permits topology writers to configure same-store assortment' do
    cashier = staff_with(%w[read_pos_orders])
    cashier_headers = headers_for(cashier)
    path = "/api/v3/admin/pos/branches/#{branch.prefixed_id}/products"
    post path, headers: cashier_headers, params: { product_id: product.prefixed_id }, as: :json
    expect(response).to have_http_status(:forbidden)

    manager = staff_with(%w[write_pos_topology])
    manager_headers = headers_for(manager)
    foreign = create(:product, store: create(:store), status: 'active')
    post path, headers: manager_headers, params: { product_id: foreign.prefixed_id }, as: :json
    expect(response).to have_http_status(:not_found)
    Spree::ProductPublication.create!(product: product, channel: PosChannelHelpers.channel_for(store))
    post path, headers: manager_headers, params: { product_id: product.prefixed_id }, as: :json
    expect(response).to have_http_status(:created)
    expect(Spree::Pos::BranchProduct.where(branch: branch, product: product)).to exist
    post path, headers: manager_headers, params: { product_id: product.prefixed_id }, as: :json
    expect(response).to have_http_status(:created)
    expect(Spree::Pos::BranchProduct.where(branch: branch, product: product).count).to eq(1)
    delete "#{path}/#{product.prefixed_id}", headers: manager_headers, as: :json
    expect(response).to have_http_status(:no_content)
    expect(Spree::Pos::BranchProduct.where(branch: branch, product: product)).not_to exist
  end

  it 'browses only the assigned assortment and refuses malformed searches and disabled branches' do
    cashier = staff_with(%w[read_pos_orders])
    Spree::Pos::StaffMembership.create!(store: store, branch: branch, staff: cashier, capabilities: [], status: 'active')
    headers = headers_for(cashier)
    catalog(headers, query: '')
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.fetch('data')).to be_empty
    Spree::Pos::BranchProduct.create!(branch: branch, product: product)
    catalog(headers, query: '')
    expect(response.parsed_body.fetch('data').map { |item| item['product_id'] }).to eq([product.prefixed_id])
    catalog(headers, query: 'x' * 201)
    expect(response).to have_http_status(:unprocessable_content)
    branch.update!(status: 'disabled')
    catalog(headers)
    expect(response).to have_http_status(:not_found)
  end

  it 'exposes exact unit defaults and the unconfigured variant as item/item' do
    cashier = staff_with(%w[read_pos_orders read_pos_topology])
    Spree::Pos::StaffMembership.create!(store: store, branch: branch, staff: cashier, capabilities: [], status: 'active')
    Spree::Pos::BranchProduct.create!(branch: branch, product: product)
    headers = headers_for(cashier)

    get '/api/v3/admin/pos/units', headers: headers, params: { branch_id: branch.prefixed_id }, as: :json
    expect(response).to have_http_status(:ok)
    codes = response.parsed_body.fetch('data').map { |unit| unit['code'] }
    expect(codes).to include('item', 'g', 'kg', 'ml', 'l', 'chai', 'pack', 'case')

    get '/api/v3/admin/pos/units/variant', headers: headers,
      params: { branch_id: branch.prefixed_id, variant_id: product.default_variant.prefixed_id }, as: :json
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.dig('data', 'sale_unit')).to eq('item')
    expect(response.parsed_body.dig('data', 'tracked_mode')).to eq('none')
  end

  it 'configures a measured variant only for topology managers and locks it after a sale line exists' do
    cashier = staff_with(%w[read_pos_orders write_pos_orders])
    Spree::Pos::StaffMembership.create!(store: store, branch: branch, staff: cashier, capabilities: [], status: 'active')
    manager = staff_with(%w[write_pos_topology])
    Spree::Pos::StaffMembership.create!(store: store, branch: branch, staff: manager,
                                        capabilities: [Spree::Pos::Capabilities::MANAGE], status: 'active')
    Spree::Pos::BranchProduct.create!(branch: branch, product: product)
    cashier_headers = headers_for(cashier)
    manager_headers = headers_for(manager)
    path = '/api/v3/admin/pos/units/variant'
    body = { branch_id: branch.prefixed_id, variant_id: product.default_variant.prefixed_id,
             sale_unit: 'kg', base_unit: 'g', price_unit: 'kg' }

    put path, headers: cashier_headers, params: body, as: :json
    expect(response).to have_http_status(:forbidden)

    put path, headers: manager_headers, params: body, as: :json
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.dig('data', 'sale_unit')).to eq('kg')
    expect(response.parsed_body.dig('data', 'base_unit')).to eq('g')

    # Once a SaleLine exists the conversion snapshot must be immutable.
    Spree::Pos::UnitDefinition.ensure_defaults!(store)
    order = create(:order, store: store, currency: store.default_currency)
    workspace = instance_double(Spree::Pos::Workspace)
    register = Spree::Pos::Register.create!(store: store, branch: branch, name: 'R1', code: "r#{SecureRandom.hex(3)}", status: 'active')
    shift = Spree::Pos::Shift.create!(store: store, branch: branch, register: register, owner: cashier,
                                      opening_float: 0, currency: store.default_currency, status: 'open', opened_at: Time.current)
    ws = Spree::Pos::Workspace.create!(store: store, branch: branch, register: register, shift: shift,
                                       order: order, revision: 0, operational_status: 'editing')
    line = create(:line_item, order: order, variant: product.default_variant, quantity: 1, price: 100)
    Spree::Pos::SaleLine.create!(workspace: ws, order: order, line_item: line, variant: product.default_variant,
                                 kind: 'measured', merge_key: 'k', sale_quantity: 1, base_quantity: 1000,
                                 sale_unit_code: 'kg', base_unit_code: 'g', unit_price: 100, line_price: '0.1')

    put path, headers: manager_headers, params: body.merge(sale_unit: 'g', base_unit: 'g', price_unit: 'g'), as: :json
    expect(response).to have_http_status(:conflict)
    expect(Spree::Pos::VariantUnit.find_by!(variant: product.default_variant).sale_unit.code).to eq('kg')
  end

  it 'reports a shared barcode as ambiguous rather than choosing a variant' do
    cashier = staff_with(%w[read_pos_orders])
    Spree::Pos::StaffMembership.create!(store: store, branch: branch, staff: cashier, capabilities: [], status: 'active')
    Spree::Pos::BranchProduct.create!(branch: branch, product: product)
    product.default_variant.update!(barcode: 'shared-code')
    create(:variant, product: product, barcode: 'shared-code')
    headers = headers_for(cashier)
    get '/api/v3/admin/pos/catalog', headers: headers, params: { branch_id: branch.prefixed_id, q: 'shared-code', barcode: 'true', limit: 1 }, as: :json
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.fetch('meta')).to include('count' => 2, 'ambiguous' => true)
    expect(response.parsed_body.fetch('data').size).to eq(1)
  end
end
