# frozen_string_literal: true

require 'spree/api/testing_support/v3/base'

# Server-side guards around what a cashier can put on a draft: counts, packages,
# serials, unit configuration, sellable variants and the frozen tender snapshot.
RSpec.describe 'POS sale guards', type: :request do
  let(:store) { create(:store, default_currency: 'VND', supported_currencies: 'VND') }
  let(:password) { 'secret123' }
  let(:editor_id) { SecureRandom.uuid }
  let(:all_capabilities) do
    [Spree::Pos::Capabilities::OPEN_SHIFT, Spree::Pos::Capabilities::PRICE_OVERRIDE,
     Spree::Pos::Capabilities::DISCOUNT, Spree::Pos::Capabilities::MANAGE, Spree::Pos::Capabilities::CUSTOMER]
  end

  before { allow(Spree::Store).to receive(:default).and_return(store) }

  def staff(capabilities, branch: nil)
    user = create(:admin_user, :without_admin_role, password: password)
    role = create(:role, resource: store, permissions: %w[write_pos_orders write_pos_workspaces write_pos_shifts write_pos_topology])
    create(:role_user, user: user, role: role)
    Spree::Pos::StaffMembership.create!(store: store, branch: branch, staff: user, capabilities: capabilities, status: 'active') if branch
    user
  end

  def token_for(user)
    post '/api/v3/admin/auth/login', params: { email: user.email, password: password }, as: :json
    response.parsed_body.fetch('token')
  end

  def open_sale(capabilities: all_capabilities)
    suffix = SecureRandom.hex(4)
    branch = Spree::Pos::Branch.create!(store: store, stock_location: create(:stock_location, store: store), name: "B#{suffix}",
                                        code: "b#{suffix}", timezone: 'Asia/Ho_Chi_Minh', status: 'active')
    register = Spree::Pos::Register.create!(store: store, branch: branch, name: 'R', code: "r#{suffix}", status: 'active')
    user = staff(capabilities, branch: branch)
    token = token_for(user)
    post '/api/v3/admin/pos/shifts', headers: auth(token), params: { register_id: register.prefixed_id, opening_float: '0' }, as: :json
    created = Spree::Pos::Workspaces::Create.call(store: store, staff: user, register_id: register.prefixed_id,
                                                  key: SecureRandom.uuid, editor_id: editor_id)
    workspace = Spree::Pos::Workspace.find_by_prefix_id!(created['id'])
    product = sellable_product(branch)
    { user: user, branch: branch, register: register, workspace: workspace, product: product, token: token }
  end

  def sellable_product(branch, **attrs)
    product = create(:product, store: store, status: 'active', name: 'Gao', **attrs)
    product.default_variant.set_price('VND', 100)
    Spree::Pos::BranchProduct.create!(branch: branch, product: product)
    product
  end

  def auth(token, key = nil)
    { 'Authorization' => "Bearer #{token}" }.merge(key ? { 'Idempotency-Key' => key } : {})
  end

  def command(sale, path, revision:, key: SecureRandom.uuid, **params)
    workspace = sale[:workspace]
    body = { expected_revision: revision, lease_generation: workspace.lease_generation, editor_id: editor_id,
             idempotency_key: key }.merge(params)
    post "/api/v3/admin/pos/workspaces/#{workspace.prefixed_id}/#{path}", headers: auth(sale[:token], key), params: body, as: :json
  end

  def add(sale, revision:, **params)
    command(sale, 'items', revision: revision, variant_id: sale[:product].default_variant.prefixed_id, **params)
  end

  def configure_unit(sale, **attrs)
    body = { branch_id: sale[:branch].prefixed_id, variant_id: sale[:product].default_variant.prefixed_id }.merge(attrs)
    put '/api/v3/admin/pos/units/variant', headers: auth(sale[:token]), params: body, as: :json
  end

  def lines
    response.parsed_body.dig('data', 'line_items')
  end

  def error
    response.parsed_body['error']
  end

  it 'rejects counts that are not whole numbers instead of truncating them' do
    sale = open_sale
    [1.9, '1.5', 0, '-1', '1e3', 10_001].each do |quantity|
      add(sale, revision: 0, quantity: quantity)
      expect(response).to have_http_status(:conflict), "quantity #{quantity.inspect} was accepted"
    end
    expect(sale[:workspace].reload.revision).to eq(0)

    add(sale, revision: 0, quantity: '010')
    expect(response).to have_http_status(:ok)
    expect(lines.first['quantity']).to eq(10)
  end

  it 'never merges weighed packages, even when merge is requested' do
    sale = open_sale
    configure_unit(sale, sale_unit: 'kg', base_unit: 'g', price_unit: 'kg')
    expect(response).to have_http_status(:ok)

    add(sale, revision: 0, sale_quantity: '0.5', merge: true)
    add(sale, revision: 1, sale_quantity: '0.5', merge: true)
    expect(response).to have_http_status(:ok)
    expect(lines.map { |line| line['base_quantity'] }).to eq([500, 500])

    event = SecureRandom.uuid
    add(sale, revision: 2, sale_quantity: '0.7', measurement_event_id: event)
    expect(response).to have_http_status(:ok)
    add(sale, revision: 3, sale_quantity: '0.7', measurement_event_id: event)
    expect(response).to have_http_status(:conflict)
    expect(error['message']).to eq('This measurement was already added.')
  end

  it 'requires one distinct serial per unit and never sells a serial twice' do
    sale = open_sale
    configure_unit(sale, sale_unit: 'item', base_unit: 'item', price_unit: 'item', tracked_mode: 'serial')
    expect(response).to have_http_status(:ok)

    add(sale, revision: 0, quantity: 1)
    expect(response).to have_http_status(:conflict)
    add(sale, revision: 0, quantity: 2, serial_codes: ['SN-1'])
    expect(response).to have_http_status(:conflict)
    add(sale, revision: 0, quantity: 2, serial_codes: %w[SN-1 SN-1])
    expect(response).to have_http_status(:conflict)

    add(sale, revision: 0, quantity: 2, serial_codes: %w[SN-1 SN-2], merge: true)
    expect(response).to have_http_status(:ok)
    sale_line_id = lines.first['sale_line_id']
    add(sale, revision: 1, quantity: 1, serial_codes: ['SN-2'], merge: true)
    expect(response).to have_http_status(:conflict)
    expect(error['message']).to eq('A serial number is already on this order.')

    command(sale, "items/#{sale_line_id}/update", revision: 1, quantity: 3)
    expect(response).to have_http_status(:conflict)
    expect(Spree::Pos::SaleLine.where(workspace: sale[:workspace]).sum(:base_quantity)).to eq(2)
  end

  it 'keeps the same lot with a different expiry on its own line and rejects a bad date' do
    sale = open_sale
    add(sale, revision: 0, quantity: 1, lot_code: 'LOT-1', expiry_on: '2027-01-31', merge: true)
    add(sale, revision: 1, quantity: 1, lot_code: 'LOT-1', expiry_on: '2027-02-28', merge: true)
    expect(lines.size).to eq(2)
    add(sale, revision: 2, quantity: 1, lot_code: 'LOT-1', expiry_on: '2027-01-31', merge: true)
    expect(lines.size).to eq(2)
    expect(lines.map { |line| line['quantity'] }).to contain_exactly(2, 1)

    add(sale, revision: 3, quantity: 1, lot_code: 'LOT-1', expiry_on: '2027-02-30')
    expect(response).to have_http_status(:conflict)
    expect(error['message']).to eq('Expiry date is invalid.')
  end

  it 'only accepts the canonical base unit and products in the branch assortment' do
    sale = open_sale
    configure_unit(sale, sale_unit: 'kg', base_unit: 'kg', price_unit: 'kg')
    expect(response).to have_http_status(:conflict)
    expect(Spree::Pos::VariantUnit.count).to eq(0)

    elsewhere = create(:product, store: store, status: 'active')
    body = { branch_id: sale[:branch].prefixed_id, variant_id: elsewhere.default_variant.prefixed_id, sale_unit: 'kg',
             base_unit: 'g', price_unit: 'kg' }
    put '/api/v3/admin/pos/units/variant', headers: auth(sale[:token]), params: body, as: :json
    expect(response).to have_http_status(:not_found)
  end

  it 'sells option variants, never a legacy master, and hides products outside their selling window' do
    sale = open_sale
    product = sale[:product]
    # Data created before masters were phased out still carries one next to option variants.
    master = product.default_variant
    option = create(:variant, product: product, sku: 'GAO-5KG')
    option.set_price('VND', 120)
    master.update_column(:is_master, true)

    get '/api/v3/admin/pos/catalog', headers: auth(sale[:token]), params: { branch_id: sale[:branch].prefixed_id, q: 'Gao' }, as: :json
    expect(response.parsed_body['data'].map { |row| row['id'] }).to eq([option.prefixed_id])

    command(sale, 'items', revision: 0, variant_id: master.prefixed_id, quantity: 1)
    expect(response).to have_http_status(:not_found)
    command(sale, 'items', revision: 0, variant_id: option.prefixed_id, quantity: 1)
    expect(response).to have_http_status(:ok)

    upcoming = sellable_product(sale[:branch], available_on: 1.day.from_now)
    retired = sellable_product(sale[:branch], discontinue_on: 1.day.ago)
    [upcoming, retired].each do |product_out_of_window|
      command(sale, 'items', revision: 1, variant_id: product_out_of_window.default_variant.prefixed_id, quantity: 1)
      expect(response).to have_http_status(:not_found)
    end
  end

  it 'freezes items, prices, discounts, customer and note while a tender holds the snapshot' do
    sale = open_sale
    add(sale, revision: 0, quantity: 1)
    sale_line_id = lines.first['sale_line_id']
    workspace = sale[:workspace]
    method = Spree::Pos::PosPaymentMethod.create!(store: store, code: 'cash', name: 'Tien mat', kind: 'cash', status: 'active')
    attempt = Spree::Pos::TenderAttempt.create!(
      store: store, workspace: workspace, branch: sale[:branch], register: sale[:register], shift: workspace.shift,
      pos_payment_method: method, actor: sale[:user], status: 'prepared', amount: 100,
      order_total_snapshot: 100, currency: 'VND', workspace_revision: 1
    )

    attempts = {
      'items' => { variant_id: sale[:product].default_variant.prefixed_id, quantity: 1 },
      "items/#{sale_line_id}/update" => { quantity: 2 },
      "items/#{sale_line_id}/remove" => {},
      "items/#{sale_line_id}/line_discount" => { value_type: 'percent', value: '10', reason: 'Khach quen' },
      "items/#{sale_line_id}/price_override" => { price: '90', reason: 'Gia khuyen mai' },
      'discount' => { value_type: 'percent', value: '10', reason: 'Khach quen' },
      'customer/clear' => {},
      'note' => { note: 'giao sau' }
    }
    %w[prepared unknown confirmed].each do |status|
      attempt.update!(status: status)
      attempts.each do |path, params|
        command(sale, path, revision: 1, **params)
        expect(response).to have_http_status(:conflict), "#{path} was allowed while a tender was #{status}"
        expect(error.dig('details', 'reason')).to eq('snapshot_locked')
      end
    end
    expect(workspace.reload.revision).to eq(1)
    expect(workspace.order.reload.total).to eq(100)

    attempt.update!(status: 'canceled')
    command(sale, 'note', revision: 1, note: 'giao sau')
    expect(response).to have_http_status(:ok)
  end

  it 'keeps price override a separate authority and whole VND at add time' do
    sale = open_sale(capabilities: [Spree::Pos::Capabilities::OPEN_SHIFT, Spree::Pos::Capabilities::DISCOUNT])
    add(sale, revision: 0, quantity: 1)
    sale_line_id = lines.first['sale_line_id']
    command(sale, "items/#{sale_line_id}/price_override", revision: 1, price: '50', reason: 'Gia moi')
    expect(response).to have_http_status(:conflict)
    expect(error['message']).to eq('Price override approval is required.')
    add(sale, revision: 1, quantity: 1, price_override: '50')
    expect(response).to have_http_status(:conflict)

    owner = open_sale
    add(owner, revision: 0, quantity: 1, price_override: '90.5')
    expect(response).to have_http_status(:conflict)
    add(owner, revision: 0, quantity: 1, price_override: '90')
    expect(response).to have_http_status(:ok)
    audit = Spree::Pos::AuditEntry.where(action: 'workspace.item.add').last
    expect(audit.metadata['price_override']).to eq('before' => '100.0', 'after' => '90.0')

    key = SecureRandom.uuid
    sale_line_id = lines.first['sale_line_id']
    command(owner, "items/#{sale_line_id}/price_override", revision: 1, key: key, price: '80', reason: 'Gia moi')
    expect(response).to have_http_status(:ok)
    command(owner, "items/#{sale_line_id}/price_override", revision: 1, key: key, price: '80', reason: 'Ly do khac')
    expect(response).to have_http_status(:conflict)
  end

  it 'binds an order discount approval to the amount actually applied and audits the approver' do
    sale = open_sale(capabilities: [Spree::Pos::Capabilities::OPEN_SHIFT, Spree::Pos::Capabilities::DISCOUNT])
    add(sale, revision: 0, quantity: 1, merge: true)
    command(sale, "items/#{lines.first['sale_line_id']}/line_discount", revision: 1, value_type: 'percent', value: '10', reason: 'Dong')
    expect(response).to have_http_status(:ok)

    workspace = sale[:workspace]
    Spree::Pos::StaffMembership.find_by!(staff: sale[:user]).update!(capabilities: [Spree::Pos::Capabilities::OPEN_SHIFT])
    manager = staff([Spree::Pos::Capabilities::APPROVE], branch: sale[:branch])
    grant = lambda do |amount|
      body = { branch_id: sale[:branch].prefixed_id, requester_id: sale[:user].prefixed_id, workspace_id: workspace.prefixed_id,
               action_name: 'workspace.apply_discount', amount: amount, revision: 2, expires_at: 5.minutes.from_now }
      post '/api/v3/admin/pos/approvals', headers: auth(token_for(manager)), params: body, as: :json
      expect(response).to have_http_status(:created)
      response.parsed_body.dig('data', 'id')
    end

    # The invoice discount is taken before the flat/percent line discount, so
    # 10% of the order is 10 here, not 9 from the already reduced line.
    wrong = grant.call('9')
    command(sale, 'discount', revision: 2, value_type: 'percent', value: '10', reason: 'Hoa don', approval_id: wrong)
    expect(response).to have_http_status(:conflict)
    expect(Spree::Pos::DiscountIntent.where(workspace: workspace)).not_to exist
    expect(Spree::Pos::Approval.find_by_prefix_id!(wrong).status).to eq('active')

    right = grant.call('10')
    command(sale, 'discount', revision: 2, value_type: 'percent', value: '10', reason: 'Hoa don', approval_id: right)
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.dig('data', 'discount', 'amount')).to eq('-10.0')
    audit = Spree::Pos::AuditEntry.where(action: 'workspace.discount.apply').last
    expect(audit.metadata).to include('approval_id' => right, 'approver_id' => manager.prefixed_id, 'amount' => '10.0')
    expect(Spree::Pos::AuditEntry.where(action: 'approval.consume', subject_type: Spree::Pos::Approval.name)).to exist
  end

  it 'uses an approval once, for its own action and draft only, and never after revocation' do
    sale = open_sale(capabilities: [Spree::Pos::Capabilities::OPEN_SHIFT])
    add(sale, revision: 0, quantity: 1)
    sale_line_id = lines.first['sale_line_id']
    other_id = Spree::Pos::Workspaces::Create.call(store: store, staff: sale[:user], register_id: sale[:register].prefixed_id,
                                                   key: SecureRandom.uuid, editor_id: editor_id)['id']
    other = sale.merge(workspace: Spree::Pos::Workspace.find_by_prefix_id!(other_id))
    add(other, revision: 0, quantity: 1)
    expect(response).to have_http_status(:ok)

    manager = staff([Spree::Pos::Capabilities::APPROVE], branch: sale[:branch])
    manager_token = token_for(manager)
    grant = lambda do |action, revision, amount = '10'|
      body = { branch_id: sale[:branch].prefixed_id, requester_id: sale[:user].prefixed_id,
               workspace_id: sale[:workspace].prefixed_id, action_name: action, amount: amount, revision: revision,
               expires_at: 5.minutes.from_now }
      post '/api/v3/admin/pos/approvals', headers: auth(manager_token), params: body, as: :json
      expect(response).to have_http_status(:created)
      response.parsed_body.dig('data', 'id')
    end
    discount = { value_type: 'percent', value: '10', reason: 'Hoa don' }

    approval = grant.call('workspace.apply_discount', 1)
    command(sale, "items/#{sale_line_id}/line_discount", revision: 1, approval_id: approval, **discount)
    expect(response).to have_http_status(:conflict)
    command(other, 'discount', revision: 1, approval_id: approval, **discount)
    expect(response).to have_http_status(:conflict)
    expect(Spree::Pos::Approval.find_by_prefix_id!(approval).status).to eq('active')

    command(sale, 'discount', revision: 1, approval_id: approval, **discount)
    expect(response).to have_http_status(:ok)
    command(sale, 'discount', revision: 2, approval_id: approval, **discount, value: '5')
    expect(response).to have_http_status(:conflict)
    expect(error['message']).to eq('Approval cannot be reused.')

    revoked = grant.call('workspace.clear_discount', 2)
    post "/api/v3/admin/pos/approvals/#{revoked}/revoke", headers: auth(manager_token), as: :json
    expect(response).to have_http_status(:ok)
    command(sale, 'discount/clear', revision: 2, approval_id: revoked)
    expect(response).to have_http_status(:conflict)

    # Clearing is approved for the amount this discount currently takes off.
    command(sale, 'discount/clear', revision: 2, approval_id: grant.call('workspace.clear_discount', 2, '10'))
    expect(response).to have_http_status(:ok)
    expect(sale[:workspace].order.reload.total).to eq(100)
  end

  it 'clears the customer even when a profile is sent with the clear request' do
    sale = open_sale
    profile = Spree::Pos::CustomerProfile.create!(store: store, name: 'Lan', phone: '0901234567', created_by: sale[:user])
    command(sale, 'customer', revision: 0, profile_id: profile.prefixed_id)
    expect(response).to have_http_status(:ok)
    command(sale, 'customer/clear', revision: 1, profile_id: profile.prefixed_id)
    expect(response).to have_http_status(:ok)
    expect(sale[:workspace].reload.pos_customer).to be_nil
  end

  it 'refuses customer lookup on a disabled branch and keeps phone numbers out of the audit' do
    sale = open_sale
    key = SecureRandom.uuid
    body = { branch_id: sale[:branch].prefixed_id, name: 'Lan', phone: '0901234567', idempotency_key: key }
    post '/api/v3/admin/pos/customers', headers: auth(sale[:token], key), params: body, as: :json
    expect(response).to have_http_status(:created)
    audit = Spree::Pos::AuditEntry.where(action: 'customer.create').last
    expect(audit.metadata.to_json).not_to include('0901234567')

    sale[:branch].update!(status: 'disabled')
    get '/api/v3/admin/pos/customers', headers: auth(sale[:token]), params: { branch_id: sale[:branch].prefixed_id, q: 'Lan' }, as: :json
    expect(response).to have_http_status(:forbidden)
  end
end
