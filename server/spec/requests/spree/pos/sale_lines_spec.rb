# frozen_string_literal: true

require 'spree/api/testing_support/v3/base'
require_relative '../../../support/pos_trace_helpers'

# I08: packages of the same variant stay independent by SaleLine, while an
# explicit `merge: true` with an identical merge key still merges.
RSpec.describe 'POS SaleLine identity (I08)', type: :request do
  include PosTraceHelpers

  let(:store) { create(:store, default_currency: 'VND', supported_currencies: 'VND') }
  let(:password) { 'secret123' }
  let(:editor_id) { SecureRandom.uuid }

  before { allow(Spree::Store).to receive(:default).and_return(store) }

  def setup_workspace(capabilities: [Spree::Pos::Capabilities::OPEN_SHIFT, Spree::Pos::Capabilities::PRICE_OVERRIDE,
                                     Spree::Pos::Capabilities::DISCOUNT, Spree::Pos::Capabilities::MANAGE])
    user = create(:admin_user, :without_admin_role, password: password)
    role = create(:role, resource: store, permissions: %w[write_pos_orders write_pos_workspaces write_pos_shifts write_pos_topology])
    create(:role_user, user: user, role: role)
    location = create(:stock_location, store: store)
    suffix = SecureRandom.hex(4)
    branch = Spree::Pos::Branch.create!(store: store, stock_location: location, name: "B#{suffix}", code: "b#{suffix}", timezone: 'Asia/Ho_Chi_Minh', status: 'active')
    register = Spree::Pos::Register.create!(store: store, branch: branch, name: 'R', code: "r#{suffix}", status: 'active')
    Spree::Pos::StaffMembership.create!(store: store, branch: branch, staff: user, capabilities: capabilities, status: 'active')
    post '/api/v3/admin/auth/login', params: { email: user.email, password: password }, as: :json
    token = response.parsed_body.fetch('token')
    post '/api/v3/admin/pos/shifts', headers: { 'Authorization' => "Bearer #{token}" }, params: { register_id: register.prefixed_id, opening_float: '0' }, as: :json
    created = Spree::Pos::Workspaces::Create.call(store: store, staff: user, register_id: register.prefixed_id, key: SecureRandom.uuid, editor_id: editor_id)
    workspace = Spree::Pos::Workspace.find_by_prefix_id!(created['id'])
    product = create(:product, store: store, status: 'active', name: 'Ao')
    product.default_variant.set_price('VND', 100)
    Spree::Pos::BranchProduct.create!(branch: branch, product: product)
    [user, branch, workspace, product, token]
  end

  def configure_variant_unit(branch, product, token, attrs)
    headers = { 'Authorization' => "Bearer #{token}" }
    put '/api/v3/admin/pos/units/variant', headers: headers,
      params: { branch_id: branch.prefixed_id, variant_id: product.default_variant.prefixed_id }.merge(attrs), as: :json
    expect(response).to have_http_status(:ok)
  end

  def post_item(workspace, token, key: SecureRandom.uuid, **params)
    headers = { 'Authorization' => "Bearer #{token}", 'Idempotency-Key' => key }
    post "/api/v3/admin/pos/workspaces/#{workspace.prefixed_id}/items", headers: headers,
      params: { lease_generation: workspace.lease_generation, editor_id: editor_id, idempotency_key: key }.merge(params), as: :json
  end

  def line_command(workspace, token, path, revision:, key: SecureRandom.uuid, **params)
    post "/api/v3/admin/pos/workspaces/#{workspace.prefixed_id}/#{path}",
      headers: { 'Authorization' => "Bearer #{token}", 'Idempotency-Key' => key },
      params: { expected_revision: revision, lease_generation: workspace.lease_generation, editor_id: editor_id, idempotency_key: key }.merge(params), as: :json
  end

  it 'records target-price reductions, scales quantities and stacks invoice discounts on the reduced base' do
    _user, _branch, workspace, product, token = setup_workspace
    post_item(workspace, token, expected_revision: 0, variant_id: product.default_variant.prefixed_id, quantity: 2, merge: true)
    expect(response).to have_http_status(:ok)
    line_id = response.parsed_body.dig('data', 'line_items', 0, 'sale_line_id')
    key = SecureRandom.uuid
    line_command(workspace, token, "items/#{line_id}/line_discount", revision: 1, key: key, value_type: 'unit_price', value: '80', reason: 'Price match')
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.dig('data', 'totals')).to include('item_total' => '200.0', 'discount_total' => '-40.0', 'manual_discount_total' => '-40.0', 'total' => '160.0')
    expect(response.parsed_body.dig('data', 'line_items', 0)).to include('price' => '100.0', 'net_amount' => '160.0')
    # Exact replay returns the original receipt, never a second allocation.
    line_command(workspace, token, "items/#{line_id}/line_discount", revision: 1, key: key, value_type: 'unit_price', value: '80', reason: 'Price match')
    expect(response).to have_http_status(:ok)
    expect(workspace.reload.revision).to eq(2)
    line_command(workspace, token, 'discount', revision: 2, value_type: 'percent', value: '10', reason: 'Invoice')
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.dig('data', 'totals')).to include('discount_total' => '-56.0', 'total' => '144.0')
    expect(response.parsed_body.dig('data', 'discount', 'amount')).to eq('-16.0')
    expect(response.parsed_body.dig('data', 'line_items', 0, 'line_discount', 'amount')).to eq('-40.0')
    line_command(workspace, token, "items/#{line_id}/update", revision: 3, quantity: 3)
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.dig('data', 'totals')).to include('item_total' => '300.0', 'discount_total' => '-84.0', 'total' => '216.0')
    # A fixed invoice discount still works, independently of the line target.
    line_command(workspace, token, 'discount', revision: 4, value_type: 'flat', value: '30', reason: 'Invoice fixed')
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.dig('data', 'totals', 'total')).to eq('210.0')
    delete_key = SecureRandom.uuid
    delete "/api/v3/admin/pos/workspaces/#{workspace.prefixed_id}/items/#{line_id}/line_discount",
      headers: { 'Authorization' => "Bearer #{token}", 'Idempotency-Key' => delete_key },
      params: { expected_revision: 5, lease_generation: workspace.lease_generation, editor_id: editor_id, idempotency_key: delete_key }, as: :json
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.dig('data', 'totals')).to include('discount_total' => '-30.0', 'total' => '270.0')
  end

  it 'rejects invalid targets and stale revisions without changing price or discount evidence' do
    _user, _branch, workspace, product, token = setup_workspace
    post_item(workspace, token, expected_revision: 0, variant_id: product.default_variant.prefixed_id, quantity: 1)
    line_id = response.parsed_body.dig('data', 'line_items', 0, 'sale_line_id')
    %w[101 -1 1.5 NaN].each do |value|
      line_command(workspace, token, "items/#{line_id}/line_discount", revision: 1, value_type: 'unit_price', value: value, reason: 'Invalid')
      expect(response).to have_http_status(:conflict)
      expect(workspace.reload.revision).to eq(1)
      expect(Spree::Pos::LineDiscountIntent.where(workspace: workspace)).to be_empty
    end
    line_command(workspace, token, "items/#{line_id}/line_discount", revision: 0, value_type: 'unit_price', value: '80', reason: 'Stale')
    expect(response).to have_http_status(:conflict)
    line_command(workspace, token, "items/#{line_id}/line_discount", revision: 1, value_type: 'unit_price', value: '0', reason: 'Free item')
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.dig('data', 'totals')).to include('discount_total' => '-100.0', 'total' => '0.0')
  end

  it 'requires discount permission or revision-bound approval for a price reduction' do
    _user, _branch, workspace, product, token = setup_workspace(capabilities: [Spree::Pos::Capabilities::OPEN_SHIFT, Spree::Pos::Capabilities::PRICE_OVERRIDE])
    post_item(workspace, token, expected_revision: 0, variant_id: product.default_variant.prefixed_id, quantity: 1)
    line_id = response.parsed_body.dig('data', 'line_items', 0, 'sale_line_id')
    line_command(workspace, token, "items/#{line_id}/line_discount", revision: 1, value_type: 'unit_price', value: '80', reason: 'No discount authority')
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.to_s).to include('Discount approval is required.')
    expect(workspace.reload.revision).to eq(1)
    expect(Spree::Pos::LineDiscountIntent.where(workspace: workspace)).to be_empty
  end

  it 'uses sale quantities for measured targets with whole-VND rounding' do
    _user, branch, workspace, product, token = setup_workspace
    configure_variant_unit(branch, product, token, sale_unit: 'kg', base_unit: 'g', price_unit: 'kg')
    post_item(workspace, token, expected_revision: 0, variant_id: product.default_variant.prefixed_id, sale_quantity: '1.25')
    line_id = response.parsed_body.dig('data', 'line_items', 0, 'sale_line_id')
    line_command(workspace, token, "items/#{line_id}/line_discount", revision: 1, value_type: 'unit_price', value: '90', reason: 'Per kg')
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.dig('data', 'totals')).to include('discount_total' => '-12.0', 'total' => '113.0')
    line_command(workspace, token, "items/#{line_id}/update", revision: 2, sale_quantity: '0.5')
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.dig('data', 'totals')).to include('discount_total' => '-5.0', 'total' => '45.0')
  end

  it 'keeps two packages of one variant with different override prices independent' do
    _user, branch, workspace, product, token = setup_workspace
    configure_variant_unit(branch, product, token, sale_unit: 'item', base_unit: 'item', price_unit: 'item')
    variant_id = product.default_variant.prefixed_id

    post_item(workspace, token, expected_revision: 0, variant_id: variant_id, quantity: 1, price_override: '120')
    expect(response).to have_http_status(:ok)
    first_id = response.parsed_body.dig('data', 'line_items', 0, 'sale_line_id')
    expect(first_id).to be_present

    post_item(workspace, token, expected_revision: 1, variant_id: variant_id, quantity: 2, price_override: '150')
    expect(response).to have_http_status(:ok)
    lines = response.parsed_body.dig('data', 'line_items')
    expect(lines.size).to eq(2)

    by_sale_id = lines.index_by { |line| line['sale_line_id'] }
    expect(by_sale_id.fetch(first_id)).to include('quantity' => 1, 'price' => '120.0')
    second = lines.find { |line| line['sale_line_id'] != first_id }
    expect(second).to include('quantity' => 2, 'price' => '150.0')
    expect(response.parsed_body.dig('data', 'totals', 'total')).to eq('420.0')

    # Updating the second package must not touch the first.
    headers = { 'Authorization' => "Bearer #{token}" }
    key = SecureRandom.uuid
    post "/api/v3/admin/pos/workspaces/#{workspace.prefixed_id}/items/#{second['sale_line_id']}/update",
      headers: headers.merge('Idempotency-Key' => key),
      params: { expected_revision: 2, lease_generation: workspace.lease_generation, editor_id: editor_id,
                quantity: 1, idempotency_key: key }, as: :json
    expect(response).to have_http_status(:ok)
    lines = response.parsed_body.dig('data', 'line_items')
    expect(lines.find { |line| line['sale_line_id'] == first_id }['quantity']).to eq(1)
    expect(lines.find { |line| line['sale_line_id'] == second['sale_line_id'] }['quantity']).to eq(1)
    # Each package keeps its own override price (120 and 150), so the total is
    # 270 — proof the update did not re-price or merge the other package.
    expect(response.parsed_body.dig('data', 'totals', 'total')).to eq('270.0')
  end

  it 'shows an item campaign and replaces its discount up or down without stacking, then restores automatic pricing' do
    _user, _branch, workspace, product, token = setup_workspace
    promotion = create(:promotion, store: store, code: nil, kind: 'automatic', name: 'Item campaign')
    calculator = Spree::Calculator::PercentOnLineItem.new(preferred_percent: 20)
    Spree::Promotion::Actions::CreateItemAdjustments.create!(promotion: promotion, calculator: calculator)
    post_item(workspace, token, expected_revision: 0, variant_id: product.default_variant.prefixed_id, quantity: 2)
    first_id = response.parsed_body.dig('data', 'line_items', 0, 'sale_line_id')
    post_item(workspace, token, expected_revision: 1, variant_id: product.default_variant.prefixed_id, quantity: 1)
    expect(response).to have_http_status(:ok)
    data = workspace.reload.to_pos.deep_stringify_keys
    first = data['line_items'].find { |line| line['sale_line_id'] == first_id }
    expect(first['item_discount']).to include('source' => 'promotion', 'value_type' => 'percent')
    expect(BigDecimal(first['item_discount']['value'])).to eq(20)
    expect(first['item_discount']['amount']).to eq('-40.0')
    expect(data.dig('totals', 'total')).to eq('240.0')

    key = SecureRandom.uuid
    line_command(workspace, token, "items/#{first_id}/line_discount", revision: 2, key: key, value_type: 'item_percent', value: '10', reason: 'Replace item campaign')
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.dig('data', 'totals', 'total')).to eq('260.0')
    first = response.parsed_body.dig('data', 'line_items').find { |line| line['sale_line_id'] == first_id }
    expect(first['item_discount']).to include('source' => 'manual', 'value' => '10', 'amount' => '-20.0')
    expect(first['discounts'].none? { |row| row['kind'] == 'promotion' }).to be(true)
    line_command(workspace, token, "items/#{first_id}/line_discount", revision: 2, key: key, value_type: 'item_percent', value: '10', reason: 'Replace item campaign')
    expect(response).to have_http_status(:ok)
    expect(workspace.reload.revision).to eq(3)

    line_command(workspace, token, 'discount', revision: 3, value_type: 'percent', value: '10', reason: 'Invoice')
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.dig('data', 'totals', 'total')).to eq('234.0')
    first = response.parsed_body.dig('data', 'line_items').find { |line| line['sale_line_id'] == first_id }
    expect(first['item_net_amount']).to eq('180.0')
    expect(first['net_amount']).to eq('162.0')
    line_command(workspace, token, "items/#{first_id}/line_discount", revision: 4, value_type: 'item_percent', value: '25', reason: 'Larger reduction')
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.dig('data', 'totals', 'total')).to eq('207.0')
    line_command(workspace, token, "items/#{first_id}/line_discount", revision: 5, value_type: 'item_flat', value: '0', reason: 'No item discount')
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.dig('data', 'totals', 'total')).to eq('252.0')
    delete_key = SecureRandom.uuid
    delete "/api/v3/admin/pos/workspaces/#{workspace.prefixed_id}/items/#{first_id}/line_discount",
      headers: { 'Authorization' => "Bearer #{token}", 'Idempotency-Key' => delete_key },
      params: { expected_revision: 6, lease_generation: workspace.lease_generation, editor_id: editor_id, idempotency_key: delete_key }, as: :json
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.dig('data', 'totals', 'total')).to eq('216.0')
    line_command(workspace, token, "items/#{first_id}/update", revision: 7, quantity: 3)
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.dig('data', 'totals', 'total')).to eq('288.0')
    first = response.parsed_body.dig('data', 'line_items').find { |line| line['sale_line_id'] == first_id }
    expect(first['item_discount']).to include('source' => 'promotion', 'amount' => '-60.0', 'value' => '20.0')
  end

  it 'rejects invalid explicit item discounts and requires discount authority, not price-override authority' do
    _user, _branch, workspace, product, token = setup_workspace(capabilities: [Spree::Pos::Capabilities::OPEN_SHIFT, Spree::Pos::Capabilities::PRICE_OVERRIDE])
    post_item(workspace, token, expected_revision: 0, variant_id: product.default_variant.prefixed_id, quantity: 1)
    line_id = response.parsed_body.dig('data', 'line_items', 0, 'sale_line_id')
    [['item_percent', '101'], ['item_flat', '101'], ['item_flat', '1.5'], ['item_percent', '-1']].each do |type, value|
      line_command(workspace, token, "items/#{line_id}/line_discount", revision: 1, value_type: type, value: value, reason: 'Invalid override')
      expect(response).to have_http_status(:conflict)
      expect(workspace.reload.revision).to eq(1)
    end
    line_command(workspace, token, "items/#{line_id}/line_discount", revision: 1, value_type: 'item_percent', value: '10', reason: 'Requires approval')
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.to_s).to include('Discount approval is required.')
    expect(Spree::Pos::LineDiscountIntent.where(workspace: workspace)).to be_empty
  end

  it 'merges only on explicit merge with an identical key and keeps divergent packages separate' do
    _user, branch, workspace, product, token = setup_workspace
    configure_variant_unit(branch, product, token, sale_unit: 'item', base_unit: 'item', price_unit: 'item')
    variant_id = product.default_variant.prefixed_id

    post_item(workspace, token, expected_revision: 0, variant_id: variant_id, quantity: 1, lot_code: 'LOT-A', merge: true)
    expect(response).to have_http_status(:ok)
    first = response.parsed_body.dig('data', 'line_items', 0)
    expect(first['lot_code']).to eq('LOT-A')

    # Same lot, no explicit merge: a new package line, not a merge.
    post_item(workspace, token, expected_revision: 1, variant_id: variant_id, quantity: 1, lot_code: 'LOT-A')
    expect(response.parsed_body.dig('data', 'line_items').size).to eq(2)

    # Different lot, explicit merge: key differs, so still its own line.
    post_item(workspace, token, expected_revision: 2, variant_id: variant_id, quantity: 1, lot_code: 'LOT-B', merge: true)
    expect(response.parsed_body.dig('data', 'line_items').size).to eq(3)

    # Identical key + explicit merge: merges into package 1 (quantity 2).
    post_item(workspace, token, expected_revision: 3, variant_id: variant_id, quantity: 1, lot_code: 'LOT-A', merge: true)
    lines = response.parsed_body.dig('data', 'line_items')
    expect(lines.size).to eq(3)
    merged = lines.find { |line| line['sale_line_id'] == first['sale_line_id'] }
    expect(merged['quantity']).to eq(2)
    expect(lines.sum { |line| line['quantity'] }).to eq(4)
    expect(Spree::Pos::SaleLine.where(workspace: workspace).count).to eq(3)
  end

  it 'sells measured kg exactly in grams and edits/removes by sale_line_id only' do
    _user, branch, workspace, product, token = setup_workspace
    configure_variant_unit(branch, product, token, sale_unit: 'kg', base_unit: 'g', price_unit: 'kg')
    variant_id = product.default_variant.prefixed_id
    headers = { 'Authorization' => "Bearer #{token}" }

    post_item(workspace, token, expected_revision: 0, variant_id: variant_id, sale_quantity: '1.25')
    expect(response).to have_http_status(:ok)
    line = response.parsed_body.dig('data', 'line_items', 0)
    expect(line).to include('sale_quantity' => '1.25', 'base_quantity' => 1250, 'quantity' => 1250,
                            'sale_unit' => 'kg', 'base_unit' => 'g', 'kind' => 'measured')
    expect(line['price']).to eq('0.1')
    sale_line_id = line['sale_line_id']

    # 1.25 kg of a 100/kg item = 125 total.
    expect(response.parsed_body.dig('data', 'totals', 'total')).to eq('125.0')

    # Line discount of 10% applies to this package only.
    key = SecureRandom.uuid
    post "/api/v3/admin/pos/workspaces/#{workspace.prefixed_id}/items/#{sale_line_id}/line_discount",
      headers: headers.merge('Idempotency-Key' => key),
      params: { expected_revision: 1, lease_generation: workspace.lease_generation, editor_id: editor_id,
                value_type: 'percent', value: '10', reason: 'Test', idempotency_key: key }, as: :json
    expect(response).to have_http_status(:ok)
    # VND is a zero-decimal currency: 10% of 125 rounds to a whole-VND 13, so
    # the discounted total is 112. Fractional totals are not representable.
    expect(response.parsed_body.dig('data', 'totals', 'total')).to eq('112.0')
    discounted = response.parsed_body.dig('data', 'line_items', 0)
    expect(discounted.dig('line_discount', 'value')).to eq('10')

    # Edit to 0.5 kg by sale_line_id: 500 g, discount recomputes to 5.
    update_key = SecureRandom.uuid
    post "/api/v3/admin/pos/workspaces/#{workspace.prefixed_id}/items/#{sale_line_id}/update",
      headers: headers.merge('Idempotency-Key' => update_key),
      params: { expected_revision: 2, lease_generation: workspace.lease_generation, editor_id: editor_id,
                sale_quantity: '0.5', idempotency_key: update_key }, as: :json
    expect(response).to have_http_status(:ok)
    updated = response.parsed_body.dig('data', 'line_items', 0)
    expect(updated).to include('sale_quantity' => '0.5', 'base_quantity' => 500, 'quantity' => 500)
    # 0.5 kg = 50; 10% is 5, so the total is 45.
    expect(response.parsed_body.dig('data', 'totals', 'total')).to eq('45.0')

    # Remove by sale_line_id clears the line and its line discount only.
    remove_key = SecureRandom.uuid
    post "/api/v3/admin/pos/workspaces/#{workspace.prefixed_id}/items/#{sale_line_id}/remove",
      headers: headers.merge('Idempotency-Key' => remove_key),
      params: { expected_revision: 3, lease_generation: workspace.lease_generation, editor_id: editor_id,
                idempotency_key: remove_key }, as: :json
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.dig('data', 'line_items')).to eq([])
    expect(response.parsed_body.dig('data', 'totals', 'total')).to eq('0.0')
    expect(Spree::Pos::SaleLine.where(workspace: workspace)).to be_empty
    expect(Spree::Pos::LineDiscountIntent.where(workspace: workspace)).to be_empty
  end

  it 'keeps tracked packages distinct even when the same package is scanned twice' do
    user, branch, workspace, product, token = setup_workspace
    configure_variant_unit(branch, product, token, sale_unit: 'item', base_unit: 'item', price_unit: 'item', tracked_mode: 'serial')
    enroll_serials!(branch, product.default_variant, %w[SN-1 SN-2], opened_by: user)
    variant_id = product.default_variant.prefixed_id

    post_item(workspace, token, expected_revision: 0, variant_id: variant_id, quantity: 1, serial_codes: ['SN-1'], merge: true)
    expect(response).to have_http_status(:ok)
    post_item(workspace, token, expected_revision: 1, variant_id: variant_id, quantity: 1, serial_codes: ['SN-2'], merge: true)
    expect(response).to have_http_status(:ok)

    lines = response.parsed_body.dig('data', 'line_items')
    expect(lines.size).to eq(2)
    expect(lines.map { |line| line['serial_codes'] }).to contain_exactly(['SN-1'], ['SN-2'])
    expect(lines.map { |line| line['kind'] }).to all(eq('tracked'))
    expect(lines.map { |line| line['tracked_mode'] }).to all(eq('serial'))
  end

  it 'allows overriding unit price up or down independently of item discounts' do
    _user, _branch, workspace, product, token = setup_workspace
    product.default_variant.set_price('VND', 10_000)
    post_item(workspace, token, expected_revision: 0, variant_id: product.default_variant.prefixed_id, quantity: 1)
    expect(response).to have_http_status(:ok)
    line_id = response.parsed_body.dig('data', 'line_items', 0, 'sale_line_id')

    line_command(workspace, token, "items/#{line_id}/price_override", revision: 1, price: '11000', reason: 'Nhu cau thuc te')
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.dig('data', 'line_items', 0)).to include(
      'price' => '11000.0', 'unit_price' => '11000.0', 'list_price' => '10000.0', 'item_net_amount' => '11000.0'
    )
    expect(response.parsed_body.dig('data', 'totals')).to include(
      'item_total' => '11000.0', 'discount_total' => '0.0', 'total' => '11000.0'
    )

    line_command(workspace, token, "items/#{line_id}/line_discount", revision: 2, value_type: 'item_flat', value: '2000', reason: 'Giam 2k')
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.dig('data', 'line_items', 0)).to include(
      'price' => '11000.0', 'unit_price' => '11000.0', 'list_price' => '10000.0', 'item_net_amount' => '9000.0'
    )
    expect(response.parsed_body.dig('data', 'line_items', 0, 'item_discount')).to include(
      'amount' => '-2000.0', 'source' => 'manual', 'value_type' => 'flat', 'value' => '2000'
    )
    expect(response.parsed_body.dig('data', 'totals')).to include(
      'item_total' => '11000.0', 'discount_total' => '-2000.0', 'total' => '9000.0'
    )
  end
end
