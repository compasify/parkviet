# frozen_string_literal: true

require 'spree/api/testing_support/v3/base'

RSpec.describe 'POS workspace note', type: :request do
  let(:store) { create(:store, default_currency: 'VND', supported_currencies: 'VND') }
  let(:password) { 'secret123' }
  let(:editor_id) { SecureRandom.uuid }

  before { allow(Spree::Store).to receive(:default).and_return(store) }

  def setup_workspace
    user = create(:admin_user, :without_admin_role, password: password)
    role = create(:role, resource: store, permissions: %w[write_pos_orders write_pos_workspaces write_pos_shifts])
    create(:role_user, user: user, role: role)
    location = create(:stock_location, store: store)
    suffix = SecureRandom.hex(4)
    branch = Spree::Pos::Branch.create!(store: store, stock_location: location, name: "B#{suffix}", code: "b#{suffix}", timezone: 'Asia/Ho_Chi_Minh', status: 'active')
    register = Spree::Pos::Register.create!(store: store, branch: branch, name: 'R', code: "r#{suffix}", status: 'active')
    Spree::Pos::StaffMembership.create!(store: store, branch: branch, staff: user, capabilities: [Spree::Pos::Capabilities::OPEN_SHIFT], status: 'active')
    post '/api/v3/admin/auth/login', params: { email: user.email, password: password }, as: :json
    token = response.parsed_body.fetch('token')
    post '/api/v3/admin/pos/shifts', headers: { 'Authorization' => "Bearer #{token}" }, params: { register_id: register.prefixed_id, opening_float: '0' }, as: :json
    created = Spree::Pos::Workspaces::Create.call(store: store, staff: user, register_id: register.prefixed_id, key: SecureRandom.uuid, editor_id: editor_id)
    workspace = Spree::Pos::Workspace.find_by_prefix_id!(created['id'])
    [workspace, token]
  end

  def post_note(workspace, token, note:, revision:, key: SecureRandom.uuid)
    post "/api/v3/admin/pos/workspaces/#{workspace.prefixed_id}/note",
      headers: { 'Authorization' => "Bearer #{token}", 'Idempotency-Key' => key },
      params: { expected_revision: revision, lease_generation: workspace.lease_generation, editor_id: editor_id, note: note, idempotency_key: key }, as: :json
  end

  it 'updates, replays, clears with blank text and never writes the core order note' do
    workspace, token = setup_workspace
    key = SecureRandom.uuid
    post_note(workspace, token, note: '  Giao nhanh  ', revision: 0, key: key)
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.dig('data', 'note')).to eq('Giao nhanh')
    expect(workspace.reload.note).to eq('Giao nhanh')
    expect(workspace.order.customer_note).to be_blank
    expect(workspace.order.internal_note).to be_blank

    post_note(workspace, token, note: '  Giao nhanh  ', revision: 0, key: key)
    expect(response).to have_http_status(:ok)
    expect(workspace.reload.revision).to eq(1)

    post_note(workspace, token, note: ' ', revision: 1)
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.dig('data', 'note')).to be_nil
    expect(workspace.reload.note).to be_nil
    expect(workspace.reload.revision).to eq(2)
  end

  it 'rejects an overlong note and a stale revision without changing the draft' do
    workspace, token = setup_workspace
    post_note(workspace, token, note: 'a' * 1001, revision: 0)
    expect(response).to have_http_status(:conflict)
    expect(workspace.reload.note).to be_nil
    expect(workspace.reload.revision).to eq(0)

    post_note(workspace, token, note: 'ok', revision: 9)
    expect(response).to have_http_status(:conflict)
    expect(workspace.reload.note).to be_nil
  end

  it 'rejects a note when the workspace is not editing' do
    workspace, token = setup_workspace
    workspace.update!(operational_status: 'parked')
    post_note(workspace, token, note: 'ok', revision: 0)
    expect(response).to have_http_status(:conflict)
    expect(workspace.reload.note).to be_nil
  end
end
