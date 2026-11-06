# frozen_string_literal: true

require 'spree/api/testing_support/v3/base'

RSpec.describe 'POS workspace discount', type: :request do
  let(:store) { create(:store, default_currency: 'VND', supported_currencies: 'VND') }
  let(:password) { 'secret123' }
  let(:editor_id) { SecureRandom.uuid }

  before { allow(Spree::Store).to receive(:default).and_return(store) }

  def make_staff(permissions, capabilities)
    user = create(:admin_user, :without_admin_role, password: password)
    role = create(:role, resource: store, permissions: permissions)
    create(:role_user, user: user, role: role)
    location = create(:stock_location, store: store)
    suffix = SecureRandom.hex(4)
    branch = Spree::Pos::Branch.create!(store: store, stock_location: location, name: "B#{suffix}", code: "b#{suffix}", timezone: 'Asia/Ho_Chi_Minh', status: 'active')
    register = Spree::Pos::Register.create!(store: store, branch: branch, name: 'R', code: "r#{suffix}", status: 'active')
    Spree::Pos::StaffMembership.create!(store: store, branch: branch, staff: user, capabilities: capabilities, status: 'active')
    [user, branch, register]
  end

  def token_for(user)
    post '/api/v3/admin/auth/login', params: { email: user.email, password: password }, as: :json
    response.parsed_body.fetch('token')
  end

  def workspace_for(user, branch, register, capabilities)
    post '/api/v3/admin/pos/shifts', headers: { 'Authorization' => "Bearer #{token_for(user)}" },
      params: { register_id: register.prefixed_id, opening_float: '0' }, as: :json
    expect(response).to have_http_status(:created)
    shift = Spree::Pos::Shift.find_by!(register: register)
    created = Spree::Pos::Workspaces::Create.call(store: store, staff: user, register_id: register.prefixed_id, key: SecureRandom.uuid, editor_id: editor_id)
    workspace = Spree::Pos::Workspace.find_by_prefix_id!(created['id'])
    order = workspace.order
    item = create(:line_item, order: order, quantity: 1, price: 100)
    item.variant.set_price(order.currency, 100)
    [workspace, order, item, shift]
  end

  it 'applies, replays, clears and recalculates only with discount capability' do
    user, branch, register = make_staff(%w[write_pos_orders write_pos_workspaces write_pos_shifts], [Spree::Pos::Capabilities::OPEN_SHIFT, Spree::Pos::Capabilities::DISCOUNT])
    workspace, order, item, _shift = workspace_for(user, branch, register, nil)
    headers = { 'Authorization' => "Bearer #{token_for(user)}" }
    key = SecureRandom.uuid
    body = { expected_revision: workspace.revision, lease_generation: workspace.lease_generation, editor_id: editor_id,
             value_type: 'percent', value: '10', reason: 'Khach than thiet', idempotency_key: key }
    post "/api/v3/admin/pos/workspaces/#{workspace.prefixed_id}/discount", headers: headers.merge('Idempotency-Key' => key), params: body, as: :json
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.dig('data', 'totals', 'total')).to eq('90.0')
    expect(response.parsed_body.dig('data', 'discount', 'amount')).to eq('-10.0')

    post "/api/v3/admin/pos/workspaces/#{workspace.prefixed_id}/discount", headers: headers.merge('Idempotency-Key' => key), params: body, as: :json
    expect(response).to have_http_status(:ok)
    expect(Spree::Pos::DiscountIntent.where(workspace: workspace).count).to eq(1)
    expect(workspace.reload.revision).to eq(1)

    item.update!(quantity: 2)
    Spree.order_recalculate_totals_workflow.call(order: order)
    expect(order.reload.total).to eq(180)

    clear_key = SecureRandom.uuid
    post "/api/v3/admin/pos/workspaces/#{workspace.prefixed_id}/discount/clear", headers: headers.merge('Idempotency-Key' => clear_key),
      params: { expected_revision: workspace.reload.revision, lease_generation: workspace.lease_generation,
                editor_id: editor_id, idempotency_key: clear_key }, as: :json
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.dig('data', 'totals', 'total')).to eq('200.0')
  end

  it 'requires an action-bound approval with the server amount when capability is absent' do
    user, branch, register = make_staff(%w[write_pos_orders write_pos_workspaces write_pos_shifts], [Spree::Pos::Capabilities::OPEN_SHIFT])
    workspace, order, _item, _shift = workspace_for(user, branch, register, nil)
    manager, = make_staff(%w[write_pos_topology], [Spree::Pos::Capabilities::APPROVE])
    # Manager must be a member of same branch for approval capability to be usable.
    Spree::Pos::StaffMembership.create!(store: store, branch: branch, staff: manager, capabilities: [Spree::Pos::Capabilities::APPROVE], status: 'active')
    headers = { 'Authorization' => "Bearer #{token_for(user)}" }
    body = { expected_revision: workspace.revision, lease_generation: workspace.lease_generation, editor_id: editor_id,
             value_type: 'percent', value: '10', reason: 'Can duyet' }
    post "/api/v3/admin/pos/workspaces/#{workspace.prefixed_id}/discount", headers: headers.merge('Idempotency-Key' => SecureRandom.uuid), params: body, as: :json
    expect(response).to have_http_status(:conflict)

    manager_headers = { 'Authorization' => "Bearer #{token_for(manager)}" }
    post '/api/v3/admin/pos/approvals', headers: manager_headers,
      params: { branch_id: branch.prefixed_id, requester_id: user.prefixed_id, workspace_id: workspace.prefixed_id,
                action_name: 'workspace.apply_discount', amount: '10', revision: workspace.revision, expires_at: 5.minutes.from_now }, as: :json
    expect(response).to have_http_status(:created)
    approval_id = response.parsed_body.dig('data', 'id')

    post "/api/v3/admin/pos/workspaces/#{workspace.prefixed_id}/discount", headers: headers.merge('Idempotency-Key' => SecureRandom.uuid),
      params: body.merge(approval_id: approval_id), as: :json
    expect(response).to have_http_status(:ok)
    expect(order.reload.total).to eq(90)
    expect(Spree::Pos::Approval.find_by_prefix_id!(approval_id).status).to eq('consumed')
  end

  it 'invalidates a discount approval when assigning a customer changes the revision' do
    user, branch, register = make_staff(%w[write_pos_orders write_pos_workspaces write_pos_shifts], [Spree::Pos::Capabilities::OPEN_SHIFT])
    workspace, order, _item, _shift = workspace_for(user, branch, register, nil)
    manager, = make_staff(%w[write_pos_topology], [Spree::Pos::Capabilities::APPROVE])
    Spree::Pos::StaffMembership.create!(store: store, branch: branch, staff: manager, capabilities: [Spree::Pos::Capabilities::APPROVE], status: 'active')
    headers = { 'Authorization' => "Bearer #{token_for(user)}" }
    manager_headers = { 'Authorization' => "Bearer #{token_for(manager)}" }

    post '/api/v3/admin/pos/approvals', headers: manager_headers,
      params: { branch_id: branch.prefixed_id, requester_id: user.prefixed_id, workspace_id: workspace.prefixed_id,
                action_name: 'workspace.apply_discount', amount: '10', revision: workspace.revision, expires_at: 5.minutes.from_now }, as: :json
    expect(response).to have_http_status(:created)
    stale_approval_id = response.parsed_body.dig('data', 'id')

    profile = Spree::Pos::CustomerProfile.create!(store: store, created_by: user, name: 'Lan', phone: '0901234567')
    post "/api/v3/admin/pos/workspaces/#{workspace.prefixed_id}/customer", headers: headers.merge('Idempotency-Key' => SecureRandom.uuid),
      params: { expected_revision: workspace.revision, lease_generation: workspace.lease_generation, editor_id: editor_id, profile_id: profile.prefixed_id }, as: :json
    expect(response).to have_http_status(:ok)
    expect(workspace.reload.revision).to eq(1)

    body = { expected_revision: 1, lease_generation: workspace.lease_generation, editor_id: editor_id,
             value_type: 'percent', value: '10', reason: 'Can duyet', approval_id: stale_approval_id }
    post "/api/v3/admin/pos/workspaces/#{workspace.prefixed_id}/discount", headers: headers.merge('Idempotency-Key' => SecureRandom.uuid), params: body, as: :json
    expect(response).to have_http_status(:conflict)
    expect(Spree::Pos::Approval.find_by_prefix_id!(stale_approval_id).status).to eq('active')
    expect(Spree::Pos::DiscountIntent.where(workspace: workspace)).to be_empty
    Spree.order_recalculate_totals_workflow.call(order: order)
    expect(order.reload.total).to eq(100)

    post '/api/v3/admin/pos/approvals', headers: manager_headers,
      params: { branch_id: branch.prefixed_id, requester_id: user.prefixed_id, workspace_id: workspace.prefixed_id,
                action_name: 'workspace.apply_discount', amount: '10', revision: 1, expires_at: 5.minutes.from_now }, as: :json
    expect(response).to have_http_status(:created)
    fresh_approval_id = response.parsed_body.dig('data', 'id')

    post "/api/v3/admin/pos/workspaces/#{workspace.prefixed_id}/discount", headers: headers.merge('Idempotency-Key' => SecureRandom.uuid),
      params: body.merge(approval_id: fresh_approval_id), as: :json
    expect(response).to have_http_status(:ok)
    expect(order.reload.total).to eq(90)
    expect(Spree::Pos::Approval.find_by_prefix_id!(fresh_approval_id).status).to eq('consumed')
  end
end
