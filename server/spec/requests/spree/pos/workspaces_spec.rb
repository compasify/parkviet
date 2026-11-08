# frozen_string_literal: true

require 'spree/api/testing_support/v3/base'

RSpec.describe 'POS workspaces', type: :request do
  include ActiveSupport::Testing::TimeHelpers

  let(:store) { Spree::Store.default }
  let(:password) { 'secret123' }
  let(:editor_id) { SecureRandom.uuid }

  it 'rejects conflicting idempotency keys before creating a draft' do
    user = staff_with(%w[write_pos_orders write_pos_workspaces write_pos_shifts])
    register, = drawer_for(user)
    headers = { 'Authorization' => "Bearer #{token_for(user)}", 'Idempotency-Key' => 'header-key' }
    expect {
      post '/api/v3/admin/pos/workspaces', headers: headers,
        params: { register_id: register.prefixed_id, editor_id: editor_id, idempotency_key: 'body-key' }, as: :json
    }.not_to change(Spree::Pos::Workspace, :count)
    expect(response).to have_http_status(:unprocessable_content)
  end

  def staff_with(permissions)
    user = create(:admin_user, :without_admin_role, password: password)
    role = create(:role, resource: store, permissions: permissions)
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
    register = Spree::Pos::Register.create!(
      store: store, branch: branch, name: 'Quay', code: "r#{user.id}", status: 'active'
    )
    Spree::Pos::StaffMembership.create!(
      store: store, branch: branch, staff: user,
      capabilities: [Spree::Pos::Capabilities::OPEN_SHIFT], status: 'active'
    )
    shift = Spree::Pos::Shifts::Open.call(store: store, staff: user, register: register, opening_float: '0')
    [register, shift]
  end

  it 'creates one draft for a repeated key and refuses handover' do
    user = staff_with(%w[write_pos_orders write_pos_workspaces write_pos_shifts])
    register, shift = drawer_for(user)
    headers = { 'Authorization' => "Bearer #{token_for(user)}", 'Idempotency-Key' => 'draft-1' }

    post '/api/v3/admin/pos/workspaces', headers: headers, params: { register_id: register.prefixed_id, editor_id: editor_id }, as: :json
    expect(response).to have_http_status(:created)
    body = response.parsed_body.fetch('data')
    expect(body['payments']).to be(false)
    expect(body['register_id']).to eq(register.prefixed_id)
    workspace = Spree::Pos::Workspace.find_by_prefix_id!(body['id'])
    expect(workspace.shift).to eq(shift)
    expect(workspace.order.email).to be_nil

    post '/api/v3/admin/pos/workspaces', headers: headers, params: { register_id: register.prefixed_id, editor_id: editor_id }, as: :json
    expect(response).to have_http_status(:created)
    expect(response.parsed_body.dig('data', 'id')).to eq(body['id'])
    expect(Spree::Pos::Workspace.count).to eq(1)

    get '/api/v3/admin/pos/command_receipts', headers: headers.dup, params: { idempotency_key: 'draft-1' }, as: :json
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.dig('data', 'id')).to eq(body['id'])

    post "/api/v3/admin/pos/workspaces/#{body['id']}/handover", headers: headers, as: :json
    expect(response).to have_http_status(:forbidden)
    expect(workspace.reload.register_id).to eq(register.id)

    other = staff_with(%w[write_pos_workspaces])
    get "/api/v3/admin/pos/workspaces/#{body['id']}", headers: {
      'Authorization' => "Bearer #{token_for(other)}"
    }, as: :json
    expect(response).to have_http_status(:not_found)
    expect(response.parsed_body.to_json).not_to include(body['order_id'])
  end

  it 'rejects a stale revision and a reused key with a different body' do
    user = staff_with(%w[write_pos_orders write_pos_workspaces write_pos_shifts])
    register, = drawer_for(user)
    headers = { 'Authorization' => "Bearer #{token_for(user)}" }
    created = Spree::Pos::Workspaces::Create.call(
      store: store, staff: user, register_id: register.prefixed_id, key: 'create-1', editor_id: editor_id
    )
    workspace = Spree::Pos::Workspace.find_by_prefix_id!(created['id'])

    post "/api/v3/admin/pos/workspaces/#{created['id']}/park", headers: headers.merge('Idempotency-Key' => 'park-1'), params: {
      expected_revision: workspace.revision + 1,
      lease_generation: workspace.lease_generation, editor_id: editor_id
    }, as: :json
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'code')).to eq('conflict')
    expect(response.parsed_body.dig('error', 'details', 'current_revision')).to eq(workspace.revision)
    expect(workspace.reload.operational_status).to eq('editing')

    post '/api/v3/admin/pos/workspaces', headers: headers.merge('Idempotency-Key' => 'create-1'), params: {
      register_id: 'pos_register_other', editor_id: editor_id
    }, as: :json
    expect(response).to have_http_status(:not_found)
    expect(Spree::Pos::Workspace.count).to eq(1)

  end

  it 'does not replay a create receipt after branch membership is revoked' do
    user = staff_with(%w[write_pos_orders write_pos_workspaces write_pos_shifts])
    register, = drawer_for(user)
    headers = { 'Authorization' => "Bearer #{token_for(user)}", 'Idempotency-Key' => 'revoke-create' }
    draft_params = { register_id: register.prefixed_id, editor_id: editor_id }
    post '/api/v3/admin/pos/workspaces', headers: headers, params: draft_params, as: :json
    expect(response).to have_http_status(:created)
    Spree::Pos::StaffMembership.find_by!(staff: user, branch: register.branch).update!(status: 'disabled')
    get '/api/v3/admin/pos/command_receipts', headers: headers.dup, params: { idempotency_key: 'revoke-create' }, as: :json
    expect(response).to have_http_status(:not_found)
    post '/api/v3/admin/pos/workspaces', headers: headers, params: draft_params, as: :json
    expect(response).to have_http_status(:forbidden)
  end

  it 'does not replay a command for a different workspace with the same key and body' do
    user = staff_with(%w[write_pos_orders write_pos_workspaces write_pos_shifts])
    register, = drawer_for(user)
    headers = { 'Authorization' => "Bearer #{token_for(user)}" }
    first = Spree::Pos::Workspaces::Create.call(store: store, staff: user, register_id: register.prefixed_id, key: 'ws-one', editor_id: editor_id)
    second = Spree::Pos::Workspaces::Create.call(store: store, staff: user, register_id: register.prefixed_id, key: 'ws-two', editor_id: editor_id)
    params = { expected_revision: 0, lease_generation: 1, editor_id: editor_id }
    post "/api/v3/admin/pos/workspaces/#{first['id']}/park", headers: headers.merge('Idempotency-Key' => 'same-park'), params: params, as: :json
    expect(response).to have_http_status(:ok)
    post "/api/v3/admin/pos/workspaces/#{second['id']}/park", headers: headers.merge('Idempotency-Key' => 'same-park'), params: params, as: :json
    expect(response).to have_http_status(:conflict)
    expect(Spree::Pos::Workspace.find_by_prefix_id!(second['id']).operational_status).to eq('editing')
  end

  it 'reopens a parked workspace but never reopens a canceled one' do
    user = staff_with(%w[write_pos_orders write_pos_workspaces write_pos_shifts])
    register, = drawer_for(user)
    headers = { 'Authorization' => "Bearer #{token_for(user)}" }
    workspace = Spree::Pos::Workspaces::Create.call(store: store, staff: user, register_id: register.prefixed_id, key: 'reopen-create', editor_id: editor_id)
    %w[park reopen cancel reopen].each_with_index do |action, index|
      post "/api/v3/admin/pos/workspaces/#{workspace['id']}/#{action}",
           headers: headers.merge('Idempotency-Key' => "transition-#{index}"),
           params: { expected_revision: [index, 3].min, lease_generation: 1, editor_id: editor_id }, as: :json
      expect(response).to have_http_status(index == 3 ? :conflict : :ok)
    end
    expect(Spree::Pos::Workspace.find_by_prefix_id!(workspace['id']).operational_status).to eq('canceled')
  end

  it 'lets another browser take editing over without strict editing locks (the product default)' do
    user = staff_with(%w[write_pos_orders write_pos_workspaces write_pos_shifts])
    register, = drawer_for(user)
    # Specs switch every feature on; this one runs with strict locks off.
    Spree::Pos::FeatureFlag.where(store: store, branch_id: nil, feature: 'edit_lease').update_all(enabled: false)
    headers = { 'Authorization' => "Bearer #{token_for(user)}" }
    workspace = Spree::Pos::Workspaces::Create.call(store: store, staff: user, register_id: register.prefixed_id, key: 'simple-create', editor_id: editor_id)
    other_editor = SecureRandom.uuid
    post "/api/v3/admin/pos/workspaces/#{workspace['id']}/lease", headers: headers.merge('Idempotency-Key' => 'simple-claim'),
                                                                params: { editor_id: other_editor, takeover: true }, as: :json
    expect(response).to have_http_status(:ok)
    generation = response.parsed_body.dig('data', 'lease_generation')
    expect(generation).to eq(2)
    # The page that lost editing still cannot write with its old lease.
    post "/api/v3/admin/pos/workspaces/#{workspace['id']}/park", headers: headers.merge('Idempotency-Key' => 'simple-old'), params: {
      editor_id: editor_id, expected_revision: 0, lease_generation: 1
    }, as: :json
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('lease_stale')
    expect(Spree::Pos::AuditEntry.where(action: 'workspace.takeover', subject_type: 'Spree::Pos::Workspace')).to exist
  end

  it 'requires an explicit authorized takeover for a different browser of the same staff' do
    user = staff_with(%w[write_pos_orders write_pos_workspaces write_pos_shifts])
    register, = drawer_for(user)
    membership = Spree::Pos::StaffMembership.find_by!(staff: user, branch: register.branch)
    headers = { 'Authorization' => "Bearer #{token_for(user)}" }
    workspace = Spree::Pos::Workspaces::Create.call(store: store, staff: user, register_id: register.prefixed_id, key: 'editor-create', editor_id: editor_id)
    other_editor = SecureRandom.uuid
    path = "/api/v3/admin/pos/workspaces/#{workspace['id']}/lease"
    post path, headers: headers.merge('Idempotency-Key' => 'claim-other'), params: { editor_id: other_editor }, as: :json
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('lease_busy')
    expect(response.parsed_body.dig('error', 'details', 'retry_after_seconds')).to be_between(1, 120)
    post path, headers: headers.merge('Idempotency-Key' => 'takeover-no-permission'), params: { editor_id: other_editor, takeover: true }, as: :json
    expect(response).to have_http_status(:conflict)
    membership.update!(capabilities: [Spree::Pos::Capabilities::OPEN_SHIFT, Spree::Pos::Capabilities::TAKEOVER])
    post path, headers: headers.merge('Idempotency-Key' => 'claim-with-takeover-permission'), params: { editor_id: other_editor, takeover: false }, as: :json
    expect(response).to have_http_status(:conflict)
    expect(Spree::Pos::Workspace.find_by_prefix_id!(workspace['id']).lease_generation).to eq(1)
    post path, headers: headers.merge('Idempotency-Key' => 'takeover-approved'), params: { editor_id: other_editor, takeover: true }, as: :json
    expect(response).to have_http_status(:ok)
    generation = response.parsed_body.dig('data', 'lease_generation')
    post "/api/v3/admin/pos/workspaces/#{workspace['id']}/park", headers: headers.merge('Idempotency-Key' => 'old-editor'), params: {
      editor_id: editor_id, expected_revision: 0, lease_generation: generation
    }, as: :json
    expect(response).to have_http_status(:conflict)
    expect(Spree::Pos::AuditEntry.where(action: 'workspace.takeover', subject_type: 'Spree::Pos::Workspace')).to exist
  end

  it 'allows a new editor to claim an expired lease and invalidates the old editor' do
    user = staff_with(%w[write_pos_orders write_pos_workspaces write_pos_shifts])
    register, = drawer_for(user)
    headers = { 'Authorization' => "Bearer #{token_for(user)}" }
    created = Spree::Pos::Workspaces::Create.call(store: store, staff: user, register_id: register.prefixed_id, key: 'expired-create', editor_id: editor_id)
    workspace = Spree::Pos::Workspace.find_by_prefix_id!(created['id'])
    workspace.update!(lease_expires_at: Spree::Pos::Workspace.database_now - 1.second)
    other_editor = SecureRandom.uuid
    post "/api/v3/admin/pos/workspaces/#{created['id']}/lease", headers: headers.merge('Idempotency-Key' => 'claim-expired'), params: { editor_id: other_editor }, as: :json
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.dig('data', 'lease_generation')).to eq(2)
    expect(workspace.reload.lease_current?(user, editor_id)).to be(false)
    expect(workspace.lease_current?(user, other_editor)).to be(true)
    patch "/api/v3/admin/pos/workspaces/#{created['id']}/lease", headers: headers.merge('Idempotency-Key' => 'refresh-new-editor'),
      params: { editor_id: other_editor, lease_generation: 2 }, as: :json
    expect(response).to have_http_status(:ok)
    patch "/api/v3/admin/pos/workspaces/#{created['id']}/lease", headers: headers.merge('Idempotency-Key' => 'refresh-old-editor'),
      params: { editor_id: editor_id, lease_generation: 1 }, as: :json
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('lease_stale')
  end

  it 'refreshes one lease across two browsers and reloads the persisted draft' do
    user = staff_with(%w[write_pos_orders write_pos_workspaces write_pos_shifts])
    register, = drawer_for(user)
    browser_a = { 'Authorization' => "Bearer #{token_for(user)}" }
    browser_b = { 'Authorization' => "Bearer #{token_for(user)}" }

    post '/api/v3/admin/pos/workspaces', headers: browser_a.merge('Idempotency-Key' => 'live-create'), params: {
      register_id: register.prefixed_id, editor_id: editor_id
    }, as: :json
    expect(response).to have_http_status(:created)
    opened = response.parsed_body.fetch('data')
    original_generation = opened.fetch('lease_generation')

    get '/api/v3/admin/pos/workspaces', headers: browser_b, as: :json
    expect(response).to have_http_status(:ok)
    listed = response.parsed_body.fetch('data').find { |row| row['id'] == opened['id'] }
    expect(listed).to include('order_id' => opened['order_id'], 'operational_status' => 'editing')

    post "/api/v3/admin/pos/workspaces/#{opened['id']}/lease", headers: browser_a.merge('Idempotency-Key' => 'live-claim'), params: { editor_id: editor_id }, as: :json
    expect(response).to have_http_status(:ok)
    claimed = response.parsed_body.fetch('data')
    expect(claimed.fetch('lease_generation')).to be > original_generation
    expires_before_refresh = Spree::Pos::Workspace.find_by_prefix_id!(opened['id']).lease_expires_at

    travel 30.seconds do
      patch "/api/v3/admin/pos/workspaces/#{opened['id']}/lease", headers: browser_a.merge('Idempotency-Key' => 'live-refresh'), params: {
        lease_generation: claimed.fetch('lease_generation'), editor_id: editor_id
      }, as: :json
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.dig('data', 'lease_generation')).to eq(claimed.fetch('lease_generation'))
      expect(response.parsed_body.dig('data', 'order_id')).to eq(opened['order_id'])
    end
    expect(Spree::Pos::Workspace.find_by_prefix_id!(opened['id']).lease_expires_at).to be > expires_before_refresh

    post "/api/v3/admin/pos/workspaces/#{opened['id']}/park", headers: browser_b.merge('Idempotency-Key' => 'live-stale'), params: {
      expected_revision: opened.fetch('revision'),
      lease_generation: original_generation, editor_id: SecureRandom.uuid
    }, as: :json
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'details', 'current_revision')).to eq(opened.fetch('revision'))

    get "/api/v3/admin/pos/workspaces/#{opened['id']}", headers: browser_b, as: :json
    expect(response).to have_http_status(:ok)
    reloaded = response.parsed_body.fetch('data')
    expect(reloaded).to include(
      'order_id' => opened['order_id'],
      'operational_status' => 'editing',
      'lease_generation' => claimed.fetch('lease_generation'),
      'revision' => opened.fetch('revision')
    )
    expect(Spree::Pos::Workspace.count).to eq(1)
    expect(reloaded['line_items']).to eq([])
  end

  it 'pages 20 live and 200 parked workspaces without returning every row at once' do
    user = staff_with(%w[write_pos_orders write_pos_workspaces write_pos_shifts])
    register, shift = drawer_for(user)
    20.times { persist_workspace(user, shift, register, 'editing') }
    200.times { persist_workspace(user, shift, register, 'parked') }
    headers = { 'Authorization' => "Bearer #{token_for(user)}" }

    expect(Spree::Pos::Workspace.where(operational_status: 'editing').count).to eq(20)
    expect(Spree::Pos::Workspace.where(operational_status: 'parked').count).to eq(200)

    get '/api/v3/admin/pos/workspaces', headers: headers, params: { limit: 1000 }, as: :json
    expect(response).to have_http_status(:ok)
    capped = response.parsed_body
    expect(capped.dig('meta', 'limit')).to eq(100)
    expect(capped.dig('meta', 'count')).to eq(220)
    expect(capped.fetch('data').size).to eq(100)
    expect(capped.fetch('data').first.keys).not_to include('line_items')

    seen = []
    page = 1
    loop do
      get '/api/v3/admin/pos/workspaces', headers: headers, params: { page: page, limit: 25 }, as: :json
      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body.dig('meta', 'limit')).to eq(25)
      expect(body.fetch('data').size).to be <= 25
      seen.concat(body.fetch('data'))
      page = body.dig('meta', 'next')
      break if page.nil?
    end

    expect(seen.size).to eq(220)
    expect(seen.map { |row| row.fetch('id') }.uniq.size).to eq(220)
    expect(seen.map { |row| row.fetch('order_id') }.uniq.size).to eq(220)
    expect(seen.count { |row| row.fetch('operational_status') == 'editing' }).to eq(20)
    expect(seen.count { |row| row.fetch('operational_status') == 'parked' }).to eq(200)

    live = seen.find { |row| row.fetch('operational_status') == 'editing' }
    parked = seen.find { |row| row.fetch('operational_status') == 'parked' }
    [live, parked].each do |row|
      get "/api/v3/admin/pos/workspaces/#{row.fetch('id')}", headers: headers, as: :json
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.fetch('data')).to include(
        'id' => row.fetch('id'),
        'order_id' => row.fetch('order_id'),
        'operational_status' => row.fetch('operational_status')
      )
    end
  end

  def persist_workspace(user, shift, register, status)
    draft = Pos::CreateWalkInDraft.call(store: store, staff: user)
    Spree::Pos::Workspace.create!(
      store: store,
      branch: register.branch,
      register: register,
      shift: shift,
      order: draft.value,
      revision: 0,
      lease_generation: 1,
      lease_holder: user,
      lease_expires_at: 2.minutes.from_now,
      operational_status: status
    )
  end
end
