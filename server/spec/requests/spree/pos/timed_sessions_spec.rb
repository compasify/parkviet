# frozen_string_literal: true

require 'spree/api/testing_support/v3/base'
require_relative '../../../support/pos_timed_helpers'

# Clocks of rooms and billiard tables over the staff API: start on a room,
# read the running quote, move, correct a stretch and stop; the room board
# shows the clock; times sent by the client are never used for billing.
RSpec.describe 'POS timed sessions API', type: :request do
  include PosTimedHelpers

  let(:store) { menu_store }
  let(:branch) { timed_branch(store) }
  let(:operator) { credit_staff(store, branch, PosTimedHelpers::OPERATOR) }
  let(:waiter) { credit_staff(store, branch, PosTableHelpers::WAITER) }
  let(:area) { area!(branch) }
  let(:service) { time_service!(store, branch) }
  let(:room) { room!(area, name: 'P1', type: 'room') }
  let(:vip) { room!(area, name: 'VIP 1', type: 'vip', x: 4) }

  before do
    allow(Spree::Store).to receive(:default).and_return(store)
    table_register!(branch, operator)
    rate_plan!(branch, variant: service, type: 'room')
    rate_plan!(branch, variant: service, type: 'vip', day: 200_000, evening: 300_000, weekend: 400_000)
  end

  def bearer(user)
    @tokens ||= {}
    @tokens[user.id] ||= begin
      post '/api/v3/admin/auth/login', params: { email: user.email, password: 'secret123' }, as: :json
      response.parsed_body.fetch('token')
    end
    { 'Authorization' => "Bearer #{@tokens[user.id]}" }
  end

  def call(user, verb, path, params = {})
    send(verb, "/api/v3/admin/pos/#{path}", headers: bearer(user).merge('Idempotency-Key' => SecureRandom.uuid), params: params, as: :json)
    response.parsed_body
  end

  def start(user, resource, **params)
    call(user, :post, "resources/#{resource.prefixed_id}/timed_sessions", { branch_id: branch.prefixed_id, editor_id: SecureRandom.uuid }.merge(params))
  end

  it 'runs a clock from start to stop on the server time' do
    bearer(operator)
    server_clock_at('2026-11-12 10:00')
    # A time from the client is not a start time.
    body = start(operator, room, started_at: '2026-11-12T01:00:00Z')
    expect(response).to have_http_status(:created), response.body
    id = body.dig('data', 'timed_session', 'id')
    expect(Time.iso8601(body.dig('data', 'timed_session', 'started_at'))).to eq(local('2026-11-12 10:00'))
    expect(body.dig('data', 'workspace', 'service_mode')).to eq('timed')

    server_clock_at('2026-11-12 10:40')
    get "/api/v3/admin/pos/timed_sessions/#{id}/quote", headers: bearer(operator)
    expect(response).to have_http_status(:ok), response.body
    expect(response.parsed_body.dig('data', 'quote')).to include('played_minutes' => 40, 'billed_minutes' => 45, 'final' => false)

    board = call(operator, :get, "resource_board?branch_id=#{branch.prefixed_id}")
    tile = board['data']['resources'].find { |row| row['id'] == room.prefixed_id }
    expect(tile).to include('state' => 'playing')
    expect(tile['timed']).to include('id' => id, 'status' => 'running', 'workspace_id' => body.dig('data', 'workspace', 'id'))

    moved = call(operator, :post, "timed_sessions/#{id}/move", resource_id: vip.prefixed_id)
    expect(response).to have_http_status(:ok), response.body
    expect(moved.dig('data', 'timed_session', 'resource_id')).to eq(vip.prefixed_id)

    server_clock_at('2026-11-12 11:00')
    stopped = call(operator, :post, "timed_sessions/#{id}/stop")
    expect(response).to have_http_status(:ok), response.body
    # 40 minutes at 100 000 an hour, 20 at 200 000.
    expect(stopped.dig('data', 'timed_session')).to include('status' => 'stopped', 'billed_minutes' => 60, 'amount' => '133334.0')
    expect(stopped.dig('data', 'timed_session', 'quote', 'lines').map { |line| line['minutes'] }).to eq([40, 20])
  end

  it 'corrects a stretch with a manager approval only' do
    manager = credit_staff(store, branch, [Spree::Pos::Capabilities::APPROVE])
    bearer(operator)
    server_clock_at('2026-11-12 10:00')
    id = start(operator, room).dig('data', 'timed_session', 'id')
    server_clock_at('2026-11-12 11:00')
    call(operator, :post, "timed_sessions/#{id}/stop")
    session = Spree::Pos::TimedSession.find_by_prefix_id!(id)
    segment = session.timed_segments.first.prefixed_id
    change = { started_at: local('2026-11-12 09:45').iso8601, reason: 'Bật giờ trễ' }

    call(operator, :patch, "timed_sessions/#{id}/segments/#{segment}", change)
    expect(response).to have_http_status(:conflict), response.body

    workspace = session.workspace.reload
    approval = Spree::Pos::Approval.create!(store: store, branch: branch, approver: manager, requester: operator,
                                            subject_type: 'Spree::Pos::Workspace', subject_id: workspace.id,
                                            action: Spree::Pos::Approval::TIMED_EDIT_ACTION, revision: workspace.revision.to_s,
                                            expires_at: 10.minutes.from_now, status: 'active')
    # Valid for ten minutes on the server clock of this example.
    approval.update_column(:expires_at, local('2026-11-12 11:10'))
    body = call(operator, :patch, "timed_sessions/#{id}/segments/#{segment}", change.merge(approval_id: approval.prefixed_id))
    expect(response).to have_http_status(:ok), response.body
    expect(body.dig('data', 'timed_session')).to include('billed_minutes' => 75, 'amount' => '125000.0')
  end

  it 'refuses people who do not run play time and a second clock on a room' do
    server_clock_at('2026-11-12 10:00')
    start(waiter, room)
    expect(response).to have_http_status(:forbidden)

    start(operator, room)
    expect(response).to have_http_status(:created)
    start(operator, room)
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('timed_session_running')
  end
end
