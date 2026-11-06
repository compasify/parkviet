# frozen_string_literal: true

require 'spree/api/testing_support/v3/base'

RSpec.describe 'POS topology', type: :request do
  let(:store) { Spree::Store.default }
  let(:password) { 'secret123' }

  def login_as(user)
    post '/api/v3/admin/auth/login', params: { email: user.email, password: password }, as: :json
    response.parsed_body.fetch('token')
  end

  def staff_with(permissions, target_store = store)
    user = create(:admin_user, :without_admin_role, password: password)
    role = create(:role, resource: target_store, permissions: permissions)
    create(:role_user, user: user, role: role)
    user
  end

  def auth_headers(permissions)
    { 'Authorization' => "Bearer #{login_as(staff_with(permissions))}" }
  end

  def location_for(target_store)
    create(:stock_location, store: target_store, backorderable_default: false)
  end

  it 'offers readable store-scoped configuration options only to topology staff' do
    manager = staff_with(%w[write_pos_topology])
    coworker = staff_with(%w[read_pos_orders])
    other = create(:store)
    outsider = staff_with(%w[read_pos_orders], other)
    location = location_for(store)
    foreign_location = location_for(other)
    headers = { 'Authorization' => "Bearer #{login_as(manager)}" }

    get '/api/v3/admin/pos/context', headers: headers, as: :json
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body['administration']).to eq('read' => true, 'write' => true)
    expect(response.parsed_body['capabilities']).not_to include('pos.discount.apply', 'pos.price.override')

    get '/api/v3/admin/pos/configuration/staff', headers: headers, params: { limit: 1 }, as: :json
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.dig('meta', 'next')).to eq(2)
    get '/api/v3/admin/pos/configuration/staff', headers: headers, params: { q: coworker.email }, as: :json
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body['data']).to include(include('id' => coworker.prefixed_id, 'email' => coworker.email))
    expect(response.parsed_body.to_json).not_to include(outsider.email)

    get '/api/v3/admin/pos/configuration/locations', headers: headers, as: :json
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body['data']).to include(include('id' => location.prefixed_id, 'name' => location.name))
    expect(response.parsed_body.to_json).not_to include(foreign_location.prefixed_id)

    cashier_headers = { 'Authorization' => "Bearer #{login_as(coworker)}" }
    get '/api/v3/admin/pos/configuration/staff', headers: cashier_headers, as: :json
    expect(response).to have_http_status(:forbidden)
    get '/api/v3/admin/pos/configuration/locations', headers: cashier_headers, as: :json
    expect(response).to have_http_status(:forbidden)
    get '/api/v3/admin/pos/context', headers: cashier_headers, as: :json
    expect(response.parsed_body['administration']).to eq('read' => false, 'write' => false)
  end

  it 'edits every assignable capability without granting store roles or duplicating a membership' do
    manager = staff_with(%w[write_pos_topology])
    coworker = staff_with(%w[read_pos_orders])
    branch = Spree::Pos::Branch.create!(store: store, stock_location: location_for(store), name: 'Main', code: 'main', timezone: 'Asia/Ho_Chi_Minh', status: 'active')
    membership = Spree::Pos::StaffMembership.create!(store: store, branch: branch, staff: coworker, capabilities: ['pos.shift.open'], status: 'active')
    headers = { 'Authorization' => "Bearer #{login_as(manager)}" }
    patch "/api/v3/admin/pos/memberships/#{membership.prefixed_id}", headers: headers, params: { capabilities: Spree::Pos::Capabilities::ASSIGNABLE }, as: :json
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.dig('data', 'staff', 'email')).to eq(coworker.email)
    expect(membership.reload.capabilities).to match_array(Spree::Pos::Capabilities::ASSIGNABLE)
    expect(Spree::Pos::AccessPolicy.new(store: store, staff: coworker).permission?('write_pos_topology')).to be(false)
    expect(Spree::Pos::StaffMembership.where(staff: coworker, branch: branch).count).to eq(1)
    reader = staff_with(%w[read_pos_topology])
    patch "/api/v3/admin/pos/memberships/#{membership.prefixed_id}", headers: { 'Authorization' => "Bearer #{login_as(reader)}" }, params: { capabilities: [] }, as: :json
    expect(response).to have_http_status(:forbidden)
    expect(membership.reload.capabilities).to match_array(Spree::Pos::Capabilities::ASSIGNABLE)
  end

  it 'does not let a POS reader configure a branch or write core orders' do
    headers = auth_headers(%w[read_pos_orders])

    post '/api/v3/admin/pos/branches', headers: headers, params: { name: 'Quan 1' }, as: :json
    expect(response).to have_http_status(:forbidden)
    expect(response.parsed_body.dig('error', 'details', 'required_permission')).to eq('write_pos_topology')

    post '/api/v3/admin/orders', headers: headers, params: { order: {} }, as: :json
    expect(response).to have_http_status(:forbidden)
    expect(response.parsed_body.dig('error', 'details', 'required_permission')).to eq('write_orders')
  end

  it 'rejects a channel and a stock location from another store' do
    headers = auth_headers(%w[write_pos_topology])
    other = create(:store)
    foreign_location = location_for(other)

    post '/api/v3/admin/pos/branches', headers: headers, params: {
      channel_id: 'pos',
      name: 'Quan 1',
      code: 'q1',
      timezone: 'Asia/Ho_Chi_Minh',
      stock_location_id: foreign_location.prefixed_id
    }, as: :json

    expect(response).to have_http_status(:unprocessable_content)
    expect(Spree::Pos::Branch.count).to eq(0)

    post '/api/v3/admin/pos/branches', headers: headers, params: {
      name: 'Quan 1',
      code: 'q1',
      timezone: 'Asia/Ho_Chi_Minh',
      stock_location_id: foreign_location.prefixed_id
    }, as: :json

    expect(response).to have_http_status(:not_found)
    expect(response.parsed_body.to_json).not_to include(other.name.to_s)
    expect(Spree::Pos::Branch.count).to eq(0)
  end

  it 'keeps a disabled branch and does not reveal one outside the staff membership' do
    manager = staff_with(%w[write_pos_topology read_pos_orders])
    headers = { 'Authorization' => "Bearer #{login_as(manager)}" }
    location = location_for(store)
    post '/api/v3/admin/pos/branches', headers: headers, params: {
      name: 'Quan 1',
      code: 'q1',
      timezone: 'Asia/Ho_Chi_Minh',
      stock_location_id: location.prefixed_id,
      receiving_note: 'Cua sau'
    }, as: :json
    expect(response).to have_http_status(:created)
    branch_id = response.parsed_body.dig('data', 'id')
    record = Spree::Pos::Branch.find_by_prefix_id!(branch_id)

    post "/api/v3/admin/pos/branches/#{branch_id}/disable", headers: headers, as: :json
    expect(response).to have_http_status(:ok)
    expect(record.reload.status).to eq('disabled')
    expect(Spree::Pos::AuditEntry.where(subject_type: record.class.name, subject_id: record.id, action: 'disable')).to exist

    cashier = staff_with(%w[read_pos_orders])
    get '/api/v3/admin/pos/context', headers: {
      'Authorization' => "Bearer #{login_as(cashier)}"
    }, params: { branch_id: branch_id }, as: :json
    expect(response).to have_http_status(:not_found)
    expect(response.parsed_body.to_json).not_to include(branch_id)
  end

  it 'binds an approval to the original action and does not offer a consume route' do
    manager = staff_with(%w[write_pos_topology])
    requester = staff_with(%w[read_pos_orders write_pos_orders write_pos_workspaces write_pos_shifts])
    location = location_for(store)
    branch = Spree::Pos::Branch.create!(
      store: store,
      stock_location: location,
      name: 'Quan 1',
      code: 'q1',
      timezone: 'Asia/Ho_Chi_Minh',
      status: 'active'
    )
    Spree::Pos::StaffMembership.create!(
      store: store,
      branch: branch,
      staff: manager,
      capabilities: [Spree::Pos::Capabilities::APPROVE, Spree::Pos::Capabilities::RECOVER],
      status: 'active'
    )
    Spree::Pos::StaffMembership.create!(
      store: store, branch: branch, staff: requester,
      capabilities: [Spree::Pos::Capabilities::OPEN_SHIFT], status: 'active'
    )
    register = Spree::Pos::Register.create!(store: store, branch: branch, name: 'Quay', code: 'q1', status: 'active')
    Spree::Pos::Shifts::Open.call(store: store, staff: requester, register: register, opening_float: '0')
    result = Spree::Pos::Workspaces::Create.call(store: store, staff: requester, register_id: register.prefixed_id, key: 'approval-workspace', editor_id: SecureRandom.uuid)
    workspace = Spree::Pos::Workspace.find_by_prefix_id!(result['id'])
    headers = { 'Authorization' => "Bearer #{login_as(manager)}" }

    post '/api/v3/admin/pos/approvals', headers: headers, params: {
      branch_id: branch.prefixed_id,
      workspace_id: workspace.prefixed_id,
      requester_id: requester.prefixed_id,
      action_name: 'pos.discount',
      amount: '10.5',
      revision: '0',
      expires_at: 1.hour.from_now.iso8601
    }, as: :json
    expect(response).to have_http_status(:created)
    approval = Spree::Pos::Approval.find_by_prefix_id!(response.parsed_body.dig('data', 'id'))
    second_result = Spree::Pos::Workspaces::Create.call(store: store, staff: requester, register_id: register.prefixed_id, key: 'approval-other', editor_id: SecureRandom.uuid)
    other_workspace = Spree::Pos::Workspace.find_by_prefix_id!(second_result['id'])
    expect {
      approval.consume!(action: 'pos.discount', amount: BigDecimal('10.5'), currency: store.default_currency, revision: '0', subject: other_workspace, requester: requester)
    }.to raise_error(Spree::Pos::Conflict)
    expect {
      approval.consume!(action: 'pos.other', amount: BigDecimal('10.5'), currency: store.default_currency, revision: '0', subject: workspace, requester: requester)
    }.to raise_error(Spree::Pos::Conflict)
    expect {
      approval.consume!(action: 'pos.discount', amount: BigDecimal('10.5'), currency: store.default_currency, revision: '0', subject: workspace, requester: manager)
    }.to raise_error(Spree::Pos::Conflict)
    approval.consume!(action: 'pos.discount', amount: BigDecimal('10.5'), currency: store.default_currency, revision: '0', subject: workspace, requester: requester)
    expect {
      approval.consume!(action: 'pos.discount', amount: BigDecimal('10.5'), currency: store.default_currency, revision: '0', subject: workspace, requester: requester)
    }.to raise_error(Spree::Pos::Conflict)

    expect {
      Rails.application.routes.recognize_path(
        "/api/v3/admin/pos/approvals/#{approval.prefixed_id}/consume",
        method: :post
      )
    }.to raise_error(ActionController::RoutingError)
    expect(approval.reload.status).to eq('consumed')
  end
end
