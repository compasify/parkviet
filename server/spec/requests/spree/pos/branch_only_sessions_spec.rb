# frozen_string_literal: true

require 'spree/api/testing_support/v3/base'

RSpec.describe 'POS without configured registers', type: :request do
  let(:store) { Spree::Store.default }
  let(:password) { 'secret123' }
  let(:editor_id) { SecureRandom.uuid }
  let(:staff) do
    user = create(:admin_user, :without_admin_role, password: password)
    role = create(:role, resource: store, permissions: %w[read_pos_orders write_pos_orders read_pos_workspaces write_pos_workspaces write_pos_shifts])
    create(:role_user, user: user, role: role)
    user
  end
  let(:branch) do
    Spree::Pos::Branch.create!(store: store, stock_location: create(:stock_location, store: store),
      name: 'No registers', code: 'branch-only', timezone: 'Asia/Ho_Chi_Minh', status: 'active')
  end
  let!(:membership) do
    Spree::Pos::StaffMembership.create!(store: store, branch: branch, staff: staff,
      capabilities: [Spree::Pos::Capabilities::OPEN_SHIFT], status: 'active')
  end
  let(:headers) do
    post '/api/v3/admin/auth/login', params: { email: staff.email, password: password }, as: :json
    { 'Authorization' => "Bearer #{response.parsed_body.fetch('token')}" }
  end

  def open_branch_shift(user = staff)
    Spree::Pos::Shifts::Open.call(store: store, staff: user, branch: branch, opening_float: '0')
  end

  it 'opens a branch-owned cashier shift through the API without inventing a register' do
    expect {
      post '/api/v3/admin/pos/shifts', headers: headers, params: { branch_id: branch.prefixed_id, opening_float: '10000' }, as: :json
    }.not_to change(Spree::Pos::Register, :count)
    expect(response).to have_http_status(:created)
    expect(response.parsed_body.dig('data', 'register_id')).to be_nil
    expect(response.parsed_body.dig('data', 'branch_id')).to eq(branch.prefixed_id)

    get '/api/v3/admin/pos/context', headers: headers, params: { branch_id: branch.prefixed_id }, as: :json
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body['registers']).to eq([])
    expect(response.parsed_body.dig('shift', 'owner_id')).to eq(staff.prefixed_id)
    expect(response.parsed_body.dig('shift', 'register_id')).to be_nil
  end

  it 'enforces one open branch-only shift per staff while allowing a different cashier' do
    first = open_branch_shift
    expect { open_branch_shift }.to raise_error(Spree::Pos::Conflict)
    other = create(:admin_user, :without_admin_role)
    Spree::Pos::StaffMembership.create!(store: store, branch: branch, staff: other,
      capabilities: [Spree::Pos::Capabilities::OPEN_SHIFT], status: 'active')
    second = open_branch_shift(other)
    expect(second.owner).to eq(other)
    duplicate = Spree::Pos::Shift.new(first.attributes.except('id', 'created_at', 'updated_at'))
    expect { duplicate.save!(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
  end

  it 'cannot bypass an existing or disabled register by omitting its ID' do
    register = Spree::Pos::Register.create!(store: store, branch: branch, name: 'Counter', code: 'counter', status: 'active')
    expect { open_branch_shift }.to raise_error(CanCan::AccessDenied)
    register.update!(status: 'disabled')
    expect { open_branch_shift }.to raise_error(CanCan::AccessDenied)
  end

  it 'creates and replays a branch-only draft, preserves leases and rejects revoked membership' do
    shift = open_branch_shift
    request_headers = headers.merge('Idempotency-Key' => 'branch-draft')
    params = { branch_id: branch.prefixed_id, editor_id: editor_id }
    post '/api/v3/admin/pos/workspaces', headers: request_headers, params: params, as: :json
    expect(response).to have_http_status(:created)
    body = response.parsed_body.fetch('data')
    workspace = Spree::Pos::Workspace.find_by_prefix_id!(body['id'])
    expect(workspace.register_id).to be_nil
    expect(workspace.shift).to eq(shift)
    expect(body['register_id']).to be_nil

    expect {
      post '/api/v3/admin/pos/workspaces', headers: request_headers, params: params, as: :json
    }.not_to change(Spree::Pos::Workspace, :count)
    expect(response.parsed_body.dig('data', 'id')).to eq(body['id'])
    get '/api/v3/admin/pos/command_receipts', headers: headers.dup, params: { idempotency_key: 'branch-draft' }, as: :json
    expect(response).to have_http_status(:ok)

    post "/api/v3/admin/pos/workspaces/#{workspace.prefixed_id}/park", headers: headers.merge('Idempotency-Key' => 'branch-park'),
      params: { expected_revision: 0, lease_generation: 1, editor_id: editor_id }, as: :json
    expect(response).to have_http_status(:ok)
    expect(workspace.reload.operational_status).to eq('parked')
    membership.update!(status: 'disabled')
    post '/api/v3/admin/pos/workspaces', headers: request_headers, params: params, as: :json
    expect(response).to have_http_status(:forbidden)
  end

  it 'does not expose another staff shift or allow missing/foreign branch sessions' do
    open_branch_shift
    other = create(:admin_user, :without_admin_role)
    resolved = Spree::Pos::ContextResolver.new(store: store, staff: other)
    expect { resolved.call(branch_id: branch.prefixed_id) }.to raise_error(ActiveRecord::RecordNotFound)
    foreign = create(:store)
    expect {
      Spree::Pos::Shifts::Open.call(store: foreign, staff: staff, branch: branch, opening_float: '0')
    }.to raise_error(CanCan::AccessDenied)
    post '/api/v3/admin/pos/shifts', headers: headers, params: { opening_float: '0' }, as: :json
    expect(response).to have_http_status(:forbidden)
  end
end
