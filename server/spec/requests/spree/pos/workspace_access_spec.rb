# frozen_string_literal: true

require 'spree/api/testing_support/v3/base'

RSpec.describe 'POS workspace access and recovery', type: :request do
  let(:store) { Spree::Store.default }
  let(:password) { 'secret123' }
  let(:permissions) { %w[write_pos_orders read_pos_workspaces write_pos_workspaces write_pos_shifts read_pos_orders] }
  let(:cashier) { staff_with(permissions) }
  let(:editor_id) { SecureRandom.uuid }
  let!(:register) { drawer_for(cashier) }
  let(:branch) { register.branch }
  let(:cashier_token) { token_for(cashier) }

  def staff_with(list)
    user = create(:admin_user, :without_admin_role, password: password)
    role = create(:role, resource: store, permissions: list)
    create(:role_user, user: user, role: role)
    user
  end

  def token_for(user)
    post '/api/v3/admin/auth/login', params: { email: user.email, password: password }, as: :json
    response.parsed_body.fetch('token')
  end

  def drawer_for(user)
    location = create(:stock_location, store: store, backorderable_default: false)
    branch = Spree::Pos::Branch.create!(
      store: store, stock_location: location, name: 'Quan 1', code: "b#{user.id}",
      timezone: 'Asia/Ho_Chi_Minh', status: 'active'
    )
    register = Spree::Pos::Register.create!(store: store, branch: branch, name: 'Quay', code: "r#{user.id}", status: 'active')
    Spree::Pos::StaffMembership.create!(
      store: store, branch: branch, staff: user, capabilities: [Spree::Pos::Capabilities::OPEN_SHIFT], status: 'active'
    )
    Spree::Pos::Shifts::Open.call(store: store, staff: user, register: register, opening_float: '0')
    register
  end

  def member(user, branch, capabilities)
    Spree::Pos::StaffMembership.create!(store: store, branch: branch, staff: user, capabilities: capabilities, status: 'active')
  end

  def headers(token, key = SecureRandom.uuid)
    { 'Authorization' => "Bearer #{token}", 'Idempotency-Key' => key }
  end

  def open_draft
    Spree::Pos::Workspaces::Create.call(
      store: store, staff: cashier, register_id: register.prefixed_id, key: SecureRandom.uuid, editor_id: editor_id
    )
  end

  def audits
    Spree::Pos::AuditEntry.where(subject_type: Spree::Pos::Workspace.name)
  end

  def details
    response.parsed_body.dig('error', 'details')
  end

  it 'answers a cashier whose lease was taken over with a stale-lease conflict while replaying committed work' do
    draft = open_draft
    note = { expected_revision: 0, lease_generation: 1, editor_id: editor_id, note: 'giao sau 5 phut' }
    post "/api/v3/admin/pos/workspaces/#{draft['id']}/note", headers: headers(cashier_token, 'note-1'), params: note, as: :json
    expect(response).to have_http_status(:ok)
    committed = response.parsed_body.fetch('data')

    manager = staff_with(permissions)
    member(manager, branch, [Spree::Pos::Capabilities::OPEN_SHIFT, Spree::Pos::Capabilities::TAKEOVER])
    manager_token = token_for(manager)
    manager_editor = SecureRandom.uuid
    post "/api/v3/admin/pos/workspaces/#{draft['id']}/lease", headers: headers(manager_token),
                                                              params: { editor_id: manager_editor, takeover: true }, as: :json
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.dig('data', 'lease_generation')).to eq(2)

    # The cashier's lost response is retried with the same key after the takeover.
    post "/api/v3/admin/pos/workspaces/#{draft['id']}/note", headers: headers(cashier_token, 'note-1'), params: note, as: :json
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.fetch('data')).to eq(committed)

    post "/api/v3/admin/pos/workspaces/#{draft['id']}/note", headers: headers(cashier_token),
                                                             params: note.merge(expected_revision: 1, note: 'sau takeover'), as: :json
    expect(response).to have_http_status(:conflict)
    expect(details).to include('reason' => 'lease_stale', 'current_revision' => 1)

    patch "/api/v3/admin/pos/workspaces/#{draft['id']}/lease", headers: headers(cashier_token),
                                                               params: { editor_id: editor_id, lease_generation: 1 }, as: :json
    expect(response).to have_http_status(:conflict)
    expect(details['reason']).to eq('lease_stale')

    post "/api/v3/admin/pos/workspaces/#{draft['id']}/park",
         headers: headers(cashier_token),
         params: { expected_revision: 1, lease_generation: 1, editor_id: editor_id }, as: :json
    expect(response).to have_http_status(:conflict)
    expect(details['reason']).to eq('lease_stale')

    post "/api/v3/admin/pos/workspaces/#{draft['id']}/park",
         headers: headers(manager_token),
         params: { expected_revision: 1, lease_generation: 2, editor_id: manager_editor }, as: :json
    expect(response).to have_http_status(:ok)
    workspace = Spree::Pos::Workspace.find_by_prefix_id!(draft['id'])
    expect(workspace.note).to eq('giao sau 5 phut')
    expect(workspace.operational_status).to eq('parked')
    expect(audits.where(subject_id: workspace.id,
                        action: 'workspace.parked').pluck(:actor_id)).to eq([manager.id])
  end

  it 'hides drafts from a cashier whose branch membership was revoked' do
    draft = open_draft
    get '/api/v3/admin/pos/workspaces', headers: { 'Authorization' => "Bearer #{cashier_token}" }, as: :json
    expect(response.parsed_body.fetch('data').map { |row| row['id'] }).to eq([draft['id']])

    Spree::Pos::StaffMembership.find_by!(staff: cashier, branch: branch).update!(status: 'disabled')
    get '/api/v3/admin/pos/workspaces', headers: { 'Authorization' => "Bearer #{cashier_token}" }, as: :json
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.fetch('data')).to eq([])
    expect(response.parsed_body.dig('meta', 'count')).to eq(0)

    get "/api/v3/admin/pos/workspaces/#{draft['id']}", headers: { 'Authorization' => "Bearer #{cashier_token}" }, as: :json
    expect(response).to have_http_status(:not_found)
    expect(response.body).not_to include(draft['order_id'])

    post "/api/v3/admin/pos/workspaces/#{draft['id']}/lease", headers: headers(cashier_token), params: { editor_id: editor_id }, as: :json
    expect(response).to have_http_status(:not_found)
  end

  it 'limits takeover visibility to the branches where it was granted' do
    draft = open_draft
    other_branch = Spree::Pos::Branch.create!(
      store: store, stock_location: create(:stock_location, store: store), name: 'Quan 2', code: 'other',
      timezone: 'Asia/Ho_Chi_Minh', status: 'active'
    )
    manager = staff_with(permissions)
    member(manager, other_branch, [Spree::Pos::Capabilities::TAKEOVER])
    manager_token = token_for(manager)

    get '/api/v3/admin/pos/workspaces', headers: { 'Authorization' => "Bearer #{manager_token}" }, as: :json
    expect(response.parsed_body.fetch('data')).to eq([])
    get "/api/v3/admin/pos/workspaces/#{draft['id']}", headers: { 'Authorization' => "Bearer #{manager_token}" }, as: :json
    expect(response).to have_http_status(:not_found)

    member(manager, branch, [Spree::Pos::Capabilities::TAKEOVER])
    get "/api/v3/admin/pos/workspaces/#{draft['id']}", headers: { 'Authorization' => "Bearer #{manager_token}" }, as: :json
    expect(response).to have_http_status(:ok)
  end

  it 'refuses to cancel a draft while a tender still accounts for money' do
    draft = open_draft
    workspace = Spree::Pos::Workspace.find_by_prefix_id!(draft['id'])
    method = Spree::Pos::PosPaymentMethod.create!(store: store, code: 'cash', name: 'Tien mat', kind: 'cash', status: 'active')
    attempt = Spree::Pos::TenderAttempt.create!(
      store: store, workspace: workspace, branch: branch, register: register, shift: workspace.shift,
      pos_payment_method: method, actor: cashier, status: 'unknown', amount: 10_000,
      order_total_snapshot: 10_000, currency: 'VND', workspace_revision: 0
    )
    cancel = lambda do
      post "/api/v3/admin/pos/workspaces/#{draft['id']}/cancel",
           headers: headers(cashier_token),
           params: { expected_revision: 0, lease_generation: 1, editor_id: editor_id }, as: :json
    end

    cancel.call
    expect(response).to have_http_status(:conflict)
    expect(details['reason']).to eq('payments_recorded')
    expect(workspace.reload.operational_status).to eq('editing')
    expect(audits.where(subject_id: workspace.id, action: 'workspace.canceled')).not_to exist

    attempt.update!(status: 'failed')
    cancel.call
    expect(response).to have_http_status(:ok)
    expect(workspace.reload.operational_status).to eq('canceled')
    expect(workspace.order.reload).to be_present
  end

  it 'keeps the server draft when a view is parked, reopened and canceled' do
    draft = open_draft
    workspace = Spree::Pos::Workspace.find_by_prefix_id!(draft['id'])
    order_id = workspace.order_id
    %w[park reopen cancel].each_with_index do |action, revision|
      post "/api/v3/admin/pos/workspaces/#{draft['id']}/#{action}",
           headers: headers(cashier_token),
           params: { expected_revision: revision, lease_generation: 1, editor_id: editor_id }, as: :json
      expect(response).to have_http_status(:ok)
    end
    expect(Spree::Order.exists?(order_id)).to be(true)
    expect(audits.where(subject_id: workspace.id).order(:id).pluck(:action)).to eq(
      %w[workspace.create workspace.parked workspace.editing workspace.canceled]
    )

    post "/api/v3/admin/auth/logout", headers: { 'Authorization' => "Bearer #{cashier_token}" }, as: :json
    expect(Spree::Pos::Workspace.exists?(workspace.id)).to be(true)
  end
end
