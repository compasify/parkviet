# frozen_string_literal: true

require 'spree/api/testing_support/v3/base'

# In-store EAN-13 scale labels: a branch format claims the barcode, the SKU's
# label code picks the variant, and the server alone turns the encoded weight
# or price into an exact measured quantity.
RSpec.describe 'POS scale labels and branch assortment', type: :request do
  let(:store) { create(:store, default_currency: 'VND', supported_currencies: 'VND') }
  let(:password) { 'secret123' }
  let(:editor_id) { SecureRandom.uuid }
  let(:suffix) { SecureRandom.hex(4) }
  let(:branch) do
    Spree::Pos::Branch.create!(store: store, stock_location: create(:stock_location, store: store), name: "B#{suffix}",
                               code: "b#{suffix}", timezone: 'Asia/Ho_Chi_Minh', status: 'active')
  end
  let(:register) { Spree::Pos::Register.create!(store: store, branch: branch, name: 'R', code: "r#{suffix}", status: 'active') }
  let(:capabilities) { [Spree::Pos::Capabilities::OPEN_SHIFT, Spree::Pos::Capabilities::MANAGE] }
  let(:user) do
    user = create(:admin_user, :without_admin_role, password: password)
    role = create(:role, resource: store, permissions: %w[write_pos_orders write_pos_workspaces write_pos_shifts write_pos_topology])
    create(:role_user, user: user, role: role)
    Spree::Pos::StaffMembership.create!(store: store, branch: branch, staff: user, capabilities: capabilities, status: 'active')
    user
  end
  let(:token) do
    post '/api/v3/admin/auth/login', params: { email: user.email, password: password }, as: :json
    response.parsed_body.fetch('token')
  end
  let(:pork) do
    product = create(:product, store: store, status: 'active', name: 'Thit heo')
    product.default_variant.set_price('VND', 100_000)
    Spree::Pos::BranchProduct.create!(branch: branch, product: product)
    product
  end

  before { allow(Spree::Store).to receive(:default).and_return(store) }

  def auth(key = nil)
    { 'Authorization' => "Bearer #{token}" }.merge(key ? { 'Idempotency-Key' => key } : {})
  end

  def ean(body)
    sum = body.chars.each_with_index.sum { |char, index| char.to_i * (index.even? ? 1 : 3) }
    "#{body}#{(10 - (sum % 10)) % 10}"
  end

  def create_format(**attrs)
    body = { name: 'Can dien tu', prefix: '21', kind: 'weight', item_code_length: 5, value_length: 5, value_decimals: 0,
             value_unit_code: 'g' }.merge(attrs)
    post "/api/v3/admin/pos/branches/#{branch.prefixed_id}/label_formats", headers: auth, params: body, as: :json
  end

  def configure(product, **attrs)
    body = { branch_id: branch.prefixed_id, variant_id: product.default_variant.prefixed_id, sale_unit: 'kg', base_unit: 'g',
             price_unit: 'kg', label_code: '12345' }.merge(attrs)
    put '/api/v3/admin/pos/units/variant', headers: auth, params: body, as: :json
  end

  def parse(barcode)
    post '/api/v3/admin/pos/measurement_barcodes/parse', headers: auth, params: { branch_id: branch.prefixed_id, barcode: barcode }, as: :json
  end

  def open_draft
    post '/api/v3/admin/pos/shifts', headers: auth, params: { register_id: register.prefixed_id, opening_float: '0' }, as: :json
    created = Spree::Pos::Workspaces::Create.call(store: store, staff: user, register_id: register.prefixed_id,
                                                  key: SecureRandom.uuid, editor_id: editor_id)
    Spree::Pos::Workspace.find_by_prefix_id!(created['id'])
  end

  def add_label(workspace, barcode, revision:, key: SecureRandom.uuid, **params)
    body = { expected_revision: revision, lease_generation: workspace.lease_generation, editor_id: editor_id,
             idempotency_key: key, label_barcode: barcode, measurement_event_id: SecureRandom.uuid }.merge(params)
    post "/api/v3/admin/pos/workspaces/#{workspace.prefixed_id}/items", headers: auth(key), params: body, as: :json
  end

  it 'reads a weight label into exact grams and keeps every package on its own line' do
    create_format
    expect(response).to have_http_status(:created)
    configure(pork)
    expect(response).to have_http_status(:ok)
    label = ean('211234501250')

    parse(label)
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body['data']).to include(
      'kind' => 'measured_label', 'variant_id' => pork.default_variant.prefixed_id, 'sale_quantity' => '1.25',
      'sale_unit' => 'kg', 'base_quantity' => 1250, 'line_amount' => '125000.0', 'format_version' => 1
    )

    workspace = open_draft
    key = SecureRandom.uuid
    event = SecureRandom.uuid
    add_label(workspace, label, revision: 0, key: key, measurement_event_id: event)
    expect(response).to have_http_status(:ok)
    line = response.parsed_body.dig('data', 'line_items', 0)
    expect(line).to include('sale_quantity' => '1.25', 'base_quantity' => 1250, 'label_barcode' => label, 'label_format_version' => 1)
    expect(response.parsed_body.dig('data', 'totals', 'total')).to eq('125000.0')

    add_label(workspace, label, revision: 0, key: key, measurement_event_id: event)
    expect(response).to have_http_status(:ok)
    expect(workspace.reload.revision).to eq(1)

    add_label(workspace, label, revision: 1, measurement_event_id: event)
    expect(response).to have_http_status(:conflict)

    add_label(workspace, label, revision: 1, merge: true)
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.dig('data', 'line_items').map { |row| row['base_quantity'] }).to eq([1250, 1250])
    audit = Spree::Pos::AuditEntry.where(action: 'workspace.item.add').last
    expect(audit.metadata).to include('label_barcode' => label, 'label_format_version' => 1)

    # The label fixes the package's weight; only removing the line changes it.
    sale_line_id = response.parsed_body.dig('data', 'line_items', 0, 'sale_line_id')
    update_key = SecureRandom.uuid
    body = { expected_revision: 2, lease_generation: workspace.lease_generation, editor_id: editor_id,
             idempotency_key: update_key, sale_quantity: '2' }
    post "/api/v3/admin/pos/workspaces/#{workspace.prefixed_id}/items/#{sale_line_id}/update", headers: auth(update_key), params: body, as: :json
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'message')).to eq('A scale label line keeps the labelled quantity.')
  end

  it 'never trusts the client for what a label says' do
    create_format
    configure(pork)
    workspace = open_draft
    other = create(:product, store: store, status: 'active')
    Spree::Pos::BranchProduct.create!(branch: branch, product: other)

    add_label(workspace, ean('211234501250'), revision: 0, variant_id: other.default_variant.prefixed_id)
    expect(response).to have_http_status(:conflict)
    add_label(workspace, ean('211234501250'), revision: 0, price_override: '1')
    expect(response).to have_http_status(:conflict)
    add_label(workspace, ean('211234501250'), revision: 0, sale_quantity: '9')
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.dig('data', 'line_items', 0, 'base_quantity')).to eq(1250)
  end

  it 'refuses broken or unknown labels and leaves ordinary barcodes alone' do
    create_format
    configure(pork)
    workspace = open_draft
    good = ean('211234501250')
    bad_check = good[0, 12] + ((good[-1].to_i + 1) % 10).to_s

    parse(bad_check)
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'message')).to eq('Label check digit is invalid.')

    parse(ean('219999901250'))
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'message')).to eq('Label item is not configured.')

    parse(ean('211234500000'))
    expect(response).to have_http_status(:conflict)

    parse('8934563123456')
    expect(response.parsed_body.dig('data', 'kind')).to eq('ordinary')
    add_label(workspace, '8934563123456', revision: 0)
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'message')).to eq('Barcode is not a scale label of this branch.')

    Spree::Pos::BranchProduct.where(product: pork).delete_all
    parse(ean('211234501250'))
    expect(response).to have_http_status(:not_found)
    expect(workspace.reload.revision).to eq(0)
  end

  it 'infers the weight from a price label only when the current price reproduces it' do
    create_format(prefix: '22', kind: 'price', value_unit_code: nil)
    expect(response).to have_http_status(:created)
    format_id = response.parsed_body.dig('data', 'id')
    configure(pork)

    parse(ean('221234512500'))
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body['data']).to include('base_quantity' => 125, 'sale_quantity' => '0.125', 'label_amount' => '12500.0')

    parse(ean('221234512550'))
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'message')).to eq('Label price does not match the current price.')

    patch "/api/v3/admin/pos/branches/#{branch.prefixed_id}/label_formats/#{format_id}", headers: auth, params: { price_tolerance: '100' }, as: :json
    expect(response.parsed_body.dig('data', 'version')).to eq(2)
    parse(ean('221234512550'))
    expect(response.parsed_body['data']).to include('base_quantity' => 126, 'line_amount' => '12600.0', 'format_version' => 2)

    patch "/api/v3/admin/pos/branches/#{branch.prefixed_id}/label_formats/#{format_id}", headers: auth, params: { price_tolerance: '0' }, as: :json
    pork.default_variant.set_price('VND', 120_000)
    parse(ean('221234512500'))
    expect(response).to have_http_status(:conflict)
  end

  it 'validates label layouts, keeps one active format per prefix and stops reading disabled ones' do
    create_format(item_code_length: 6)
    expect(response).to have_http_status(:unprocessable_content)
    create_format(kind: 'price')
    expect(response).to have_http_status(:unprocessable_content)
    create_format(value_unit_code: 'item')
    expect(response).to have_http_status(:unprocessable_content)

    create_format
    format_id = response.parsed_body.dig('data', 'id')
    create_format(name: 'Trung')
    expect(response).to have_http_status(:conflict)

    configure(pork)
    post "/api/v3/admin/pos/branches/#{branch.prefixed_id}/label_formats/#{format_id}/disable", headers: auth, as: :json
    expect(response.parsed_body.dig('data', 'status')).to eq('disabled')
    parse(ean('211234501250'))
    expect(response.parsed_body.dig('data', 'kind')).to eq('ordinary')
    create_format
    expect(response).to have_http_status(:created)

    get "/api/v3/admin/pos/branches/#{branch.prefixed_id}/label_formats", headers: auth, as: :json
    expect(response.parsed_body['data'].map { |row| row['status'] }).to contain_exactly('active', 'disabled')
    expect(Spree::Pos::AuditEntry.where(action: %w[label_format.create label_format.disable]).count).to eq(3)
  end

  it 'keeps label codes unique and lets them change after sales without touching the conversion' do
    create_format
    configure(pork)
    expect(response.parsed_body.dig('data', 'label_code')).to eq('12345')
    beef = create(:product, store: store, status: 'active', name: 'Thit bo')
    Spree::Pos::BranchProduct.create!(branch: branch, product: beef)
    configure(beef)
    expect(response).to have_http_status(:conflict)
    configure(beef, label_code: 'abc')
    expect(response).to have_http_status(:unprocessable_content)

    workspace = open_draft
    add_label(workspace, ean('211234501250'), revision: 0)
    expect(response).to have_http_status(:ok)

    configure(pork, label_code: '54321')
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body['data']).to include('label_code' => '54321', 'version' => 1)
    configure(pork, sale_unit: 'g', price_unit: 'g', label_code: '54321')
    expect(response).to have_http_status(:conflict)
  end

  it 'lists store products with their assignment for managing the branch assortment' do
    pork
    create(:product, store: store, status: 'active', name: 'Rau muong').default_variant.update!(sku: 'RAU-01')
    get "/api/v3/admin/pos/branches/#{branch.prefixed_id}/products", headers: auth, params: { q: 'rau-0' }, as: :json
    expect(response).to have_http_status(:ok)
    row = response.parsed_body['data'].sole
    expect(row).to include('name' => 'Rau muong', 'assigned' => false, 'skus' => ['RAU-01'])

    post "/api/v3/admin/pos/branches/#{branch.prefixed_id}/products", headers: auth, params: { product_id: row['id'] }, as: :json
    expect(response).to have_http_status(:created)
    get "/api/v3/admin/pos/branches/#{branch.prefixed_id}/products", headers: auth, params: { assigned: 'true' }, as: :json
    expect(response.parsed_body['data'].map { |item| item['name'] }).to eq(['Rau muong', 'Thit heo'])
    get "/api/v3/admin/pos/branches/#{branch.prefixed_id}/products", headers: auth, params: { assigned: 'false' }, as: :json
    expect(response.parsed_body['data']).to be_empty

    delete "/api/v3/admin/pos/branches/#{branch.prefixed_id}/products/#{row['id']}", headers: auth, as: :json
    expect(response).to have_http_status(:no_content)

    cashier = create(:admin_user, :without_admin_role, password: password)
    create(:role_user, user: cashier, role: create(:role, resource: store, permissions: %w[write_pos_orders]))
    post '/api/v3/admin/auth/login', params: { email: cashier.email, password: password }, as: :json
    cashier_auth = { 'Authorization' => "Bearer #{response.parsed_body.fetch('token')}" }
    get "/api/v3/admin/pos/branches/#{branch.prefixed_id}/products", headers: cashier_auth, as: :json
    expect(response).to have_http_status(:forbidden)
    get "/api/v3/admin/pos/branches/#{branch.prefixed_id}/label_formats", headers: cashier_auth, as: :json
    expect(response).to have_http_status(:forbidden)
  end
end
