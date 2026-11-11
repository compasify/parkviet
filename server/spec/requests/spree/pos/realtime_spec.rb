# frozen_string_literal: true

require 'spree/api/testing_support/v3/base'
require_relative '../../../support/pos_credit_helpers'

RSpec.describe 'POS realtime events', type: :request do
  include ActionCable::TestHelper
  include PosCreditHelpers

  let(:store) { create(:store, default_currency: 'VND', supported_currencies: 'VND') }
  let(:branch) { credit_branch(store) }
  let(:cashier) { credit_staff(store, branch, PosCreditHelpers::CASHIER) }
  let(:editor_id) { SecureRandom.uuid }
  let(:stream) { Spree::Pos::Realtime.stream_name(branch) }
  let(:register) { open_drawer(store, branch, cashier) }
  let(:workspace) do
    created = Spree::Pos::Workspaces::Create.call(store: store, staff: cashier, register_id: register.prefixed_id,
                                                  key: SecureRandom.uuid, editor_id: editor_id)
    Spree::Pos::Workspace.find_by_prefix_id!(created['id'])
  end

  before { allow(Spree::Store).to receive(:default).and_return(store) }

  def bearer(user)
    post '/api/v3/admin/auth/login', params: { email: user.email, password: 'secret123' }, as: :json
    response.parsed_body.fetch('token')
  end

  def messages
    broadcasts(stream).map { |raw| JSON.parse(raw) }
  end

  def post_note(token, revision:, key: SecureRandom.uuid, generation: workspace.lease_generation)
    post "/api/v3/admin/pos/workspaces/#{workspace.prefixed_id}/note",
         headers: { 'Authorization' => "Bearer #{token}", 'Idempotency-Key' => key },
         params: { expected_revision: revision, lease_generation: generation, editor_id: editor_id, note: 'Giao nhanh', idempotency_key: key },
         as: :json
  end

  it 'broadcasts exactly one workspace.updated carrying the committed revision' do
    workspace
    token = bearer(cashier)
    before = messages.size

    post_note(token, revision: 0)

    expect(response).to have_http_status(:ok)
    fresh = messages.drop(before)
    expect(fresh.size).to eq(1)
    expect(fresh.sole).to include('event' => 'workspace.updated', 'id' => workspace.prefixed_id, 'branch_id' => branch.prefixed_id, 'revision' => 1)
    expect(fresh.sole.keys).to match_array(%w[event id branch_id revision lease_generation at refs])
  end

  it 'broadcasts nothing for a replay of the same key' do
    workspace
    token = bearer(cashier)
    key = SecureRandom.uuid
    post_note(token, revision: 0, key: key)
    before = messages.size

    post_note(token, revision: 0, key: key)

    expect(response).to have_http_status(:ok)
    expect(messages.size).to eq(before)
  end

  it 'broadcasts nothing when the command is refused' do
    workspace
    token = bearer(cashier)
    before = messages.size

    post_note(token, revision: 99)

    expect(response).to have_http_status(:conflict)
    expect(messages.size).to eq(before)
  end

  it 'broadcasts nothing when the command rolls back after its workflow ran' do
    workspace
    token = bearer(cashier)
    allow(Spree::Pos::CommandReceipt).to receive(:create!).and_raise(ActiveRecord::StatementInvalid, 'write failed')
    before = messages.size

    expect { post_note(token, revision: 0) }.to raise_error(ActiveRecord::StatementInvalid)

    expect(workspace.reload.revision).to eq(0)
    expect(messages.size).to eq(before)
  end

  it 'broadcasts for a draft created through the API' do
    register
    token = bearer(cashier)
    key = SecureRandom.uuid

    post '/api/v3/admin/pos/workspaces', headers: { 'Authorization' => "Bearer #{token}", 'Idempotency-Key' => key },
                                         params: { register_id: register.prefixed_id, editor_id: editor_id, idempotency_key: key }, as: :json

    expect(response).to have_http_status(:created)
    expect(messages.map { |message| message['id'] }).to eq([response.parsed_body.dig('data', 'id')])
  end

  it 'stays silent for a lease renewal' do
    workspace
    token = bearer(cashier)
    key = SecureRandom.uuid
    before = messages.size

    patch "/api/v3/admin/pos/workspaces/#{workspace.prefixed_id}/lease",
          headers: { 'Authorization' => "Bearer #{token}", 'Idempotency-Key' => key },
          params: { lease_generation: workspace.lease_generation, editor_id: editor_id, idempotency_key: key }, as: :json

    expect(response).to have_http_status(:ok)
    expect(messages.size).to eq(before)
  end

  it 'broadcasts approval.requested when an approval is granted' do
    workspace
    manager = credit_staff(store, branch, PosCreditHelpers::MANAGER, extra_permissions: %w[write_pos_topology read_pos_topology])
    token = bearer(manager)
    before = messages.size

    post '/api/v3/admin/pos/approvals', headers: { 'Authorization' => "Bearer #{token}" },
                                        params: { branch_id: branch.prefixed_id, requester_id: cashier.prefixed_id,
                                                  workspace_id: workspace.prefixed_id, revision: workspace.revision.to_s,
                                                  action_name: 'discount', expires_at: 10.minutes.from_now.iso8601 }, as: :json

    expect(response).to have_http_status(:created)
    message = messages.drop(before).sole
    expect(message).to include('event' => 'approval.requested', 'id' => response.parsed_body.dig('data', 'id'),
                               'refs' => { 'workspace_id' => workspace.prefixed_id })
  end
end
