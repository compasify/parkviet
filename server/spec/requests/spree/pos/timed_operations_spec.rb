# frozen_string_literal: true

require 'spree/api/testing_support/v3/base'
require_relative '../../../support/pos_timed_helpers'

# The staff API around a room's clock: pausing and resuming (a long pause
# needs an approval), the attendants book and its report, prepaid cards,
# timed promotions and the branch's operating hours.
RSpec.describe 'POS timed operations API', type: :request do
  include PosTimedHelpers

  let(:store) { menu_store }
  let(:branch) { timed_branch(store) }
  let(:operator) { credit_staff(store, branch, PosTimedHelpers::OPERATOR) }
  let(:manager) { credit_staff(store, branch, PosCreditHelpers::MANAGER + [Spree::Pos::Capabilities::RATE_PLAN_MANAGE]) }
  let(:attendant) { credit_staff(store, branch, PosTableHelpers::WAITER) }
  let(:area) { area!(branch) }
  let(:service) { time_service!(store, branch) }
  let(:room) { room!(area, name: 'P1', type: 'room') }

  before do
    allow(Spree::Store).to receive(:default).and_return(store)
    table_register!(branch, operator)
    rate_plan!(branch, variant: service, type: 'room')
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
    call(user, :post, "resources/#{resource.prefixed_id}/timed_sessions",
         { branch_id: branch.prefixed_id, editor_id: SecureRandom.uuid }.merge(params))
  end

  it 'pauses and resumes a clock, and asks for an approval after a long pause' do
    bearer(operator)
    bearer(manager)
    server_clock_at('2026-11-12 19:00')
    id = start(operator, room).dig('data', 'timed_session', 'id')

    server_clock_at('2026-11-12 20:00')
    body = call(operator, :post, "timed_sessions/#{id}/pause")
    expect(response).to have_http_status(:ok), response.body
    expect(body.dig('data', 'timed_session')).to include('status' => 'paused', 'paused_at' => local('2026-11-12 20:00').utc.iso8601)
    expect_pos_schema!(response, 'TimedSessionCommand')

    server_clock_at('2026-11-12 20:30')
    call(operator, :post, "timed_sessions/#{id}/resume")
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'details')).to include('reason' => 'approval_required', 'action' => 'timed.long_pause',
                                                                    'paused_minutes' => 30, 'max_pause_minutes' => 15)

    workspace = Spree::Pos::TimedSession.find_by_prefix_id!(id).workspace
    approval = call(manager, :post, 'approvals', branch_id: branch.prefixed_id, requester_id: operator.prefixed_id,
                                                 workspace_id: workspace.prefixed_id, action_name: Spree::Pos::Approval::TIMED_LONG_PAUSE_ACTION,
                                                 revision: workspace.reload.revision, expires_at: 10.minutes.from_now.iso8601)
    expect(response).to have_http_status(:created), response.body
    Spree::Pos::Approval.find_by_prefix_id!(approval.dig('data', 'id')).update_column(:expires_at, local('2026-11-12 20:40'))

    body = call(operator, :post, "timed_sessions/#{id}/resume", approval_id: approval.dig('data', 'id'))
    expect(response).to have_http_status(:ok), response.body
    expect(body.dig('data', 'timed_session', 'status')).to eq('running')
    expect(body.dig('data', 'timed_session', 'segments').map { |row| row['ended_reason'] }).to eq(['pause', 'resume', nil])
    expect_pos_schema!(response, 'TimedSessionCommand')
  end

  it 'keeps the attendants book and reports its hours' do
    bearer(operator)
    server_clock_at('2026-11-12 19:00')
    id = start(operator, room).dig('data', 'timed_session', 'id')

    body = call(operator, :post, 'attendant_assignments', branch_id: branch.prefixed_id, resource_id: room.prefixed_id,
                                                          staff_id: attendant.prefixed_id, note: 'Phục vụ phòng')
    expect(response).to have_http_status(:created), response.body
    expect(body['data']).to include('timed_session_id' => id, 'resource_name' => 'P1')
    expect_pos_schema!(response, 'AttendantAssignment')
    other = room!(area, name: 'P2', type: 'room', x: 4)
    call(operator, :post, 'attendant_assignments', branch_id: branch.prefixed_id, resource_id: other.prefixed_id, staff_id: attendant.prefixed_id)
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('attendant_busy')

    candidates = call(operator, :get, "attendant_assignments/candidates?branch_id=#{branch.prefixed_id}")
    expect(candidates['data'].map { |row| row['id'] }).to include(attendant.prefixed_id, operator.prefixed_id)
    expect(candidates['data'].first.keys).to eq(%w[id name])

    list = call(operator, :get, "attendant_assignments?branch_id=#{branch.prefixed_id}")
    expect(list['data'].map { |row| row['id'] }).to eq([body.dig('data', 'id')])
    expect_pos_schema!(response, 'AttendantAssignment')

    # Stopping the clock ends the turn on it.
    server_clock_at('2026-11-12 20:30')
    call(operator, :post, "timed_sessions/#{id}/stop")
    expect(response).to have_http_status(:ok), response.body
    turn = Spree::Pos::AttendantAssignment.find_by_prefix_id!(body.dig('data', 'id'))
    expect(turn.ended_at).to eq(local('2026-11-12 20:30'))
    expect(call(operator, :get, "attendant_assignments?branch_id=#{branch.prefixed_id}")['data']).to eq([])

    reader = credit_staff(store, branch, PosCreditHelpers::MANAGER + [Spree::Pos::Capabilities::REPORT_READ])
    date = turn.business_date.iso8601
    report = call(reader, :get, "reports/attendants?branch_id=#{branch.prefixed_id}&from=#{date}&to=#{date}")
    expect(response).to have_http_status(:ok), response.body
    expect(report['data'].sole).to include('staff_id' => attendant.prefixed_id, 'rooms' => 1, 'assignments' => 1, 'minutes' => 90,
                                           'hours' => '1.5')
  end

  it 'sells, finds and tops up a card without its code in any URL' do
    bearer(operator)
    body = call(operator, :post, 'stored_value_accounts', branch_id: branch.prefixed_id, card_kind: 'minutes', card_token: 'THE-004242',
                                                          minutes: 300, kind: 'cash', amount: '250000', holder_name: 'Chị Hoa')
    expect(response).to have_http_status(:created), response.body
    card_id = body.dig('data', 'card', 'id')
    expect(body.dig('data', 'card')).to include('kind' => 'minutes', 'card_hint' => '4242', 'minutes_balance' => 300, 'balance' => '250000.0')

    found = call(operator, :post, 'stored_value_accounts/lookup', branch_id: branch.prefixed_id, card_token: 'THE-004242')
    expect(found.dig('data', 'id')).to eq(card_id)
    expect(call(operator, :post, 'stored_value_accounts/lookup', branch_id: branch.prefixed_id, card_token: 'NOPE-1234')['data']).to be_nil

    call(operator, :post, "stored_value_accounts/#{card_id}/top_ups", branch_id: branch.prefixed_id, minutes: 60, kind: 'cash', amount: '60000')
    expect(response).to have_http_status(:created), response.body
    entries = call(operator, :get, "stored_value_accounts/#{card_id}/entries?branch_id=#{branch.prefixed_id}")
    expect(entries['data'].map { |row| row['minutes'] }).to eq([60, 300])

    call(operator, :post, "stored_value_accounts/#{card_id}/refund", branch_id: branch.prefixed_id)
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('approval_required')

    bearer(manager)
    call(manager, :post, 'approvals', branch_id: branch.prefixed_id, requester_id: operator.prefixed_id, stored_value_account_id: card_id,
                                      action_name: Spree::Pos::Approval::STORED_VALUE_REFUND_ACTION, amount: '310000',
                                      revision: Spree::Pos::StoredValueAccount.find_by_prefix_id!(card_id).revision,
                                      expires_at: 10.minutes.from_now.iso8601)
    expect(response).to have_http_status(:created), response.body
    approval_id = response.parsed_body.dig('data', 'id')
    refund = call(operator, :post, "stored_value_accounts/#{card_id}/refund", branch_id: branch.prefixed_id, approval_id: approval_id)
    expect(response).to have_http_status(:ok), response.body
    expect(refund.dig('data', 'card')).to include('balance' => '0.0', 'minutes_balance' => 0)
  end

  it 'pays an order from a money card at the counter' do
    bearer(operator)
    call(operator, :post, 'stored_value_accounts', branch_id: branch.prefixed_id, card_kind: 'money', card_token: 'MONEY-7777',
                                                   kind: 'cash', amount: '200000')
    server_clock_at('2026-11-12 10:00')
    session = Spree::Pos::TimedSession.find_by_prefix_id!(start(operator, room).dig('data', 'timed_session', 'id'))
    server_clock_at('2026-11-12 11:00')
    call(operator, :post, "timed_sessions/#{session.prefixed_id}/stop")
    order = order_of(session, operator)
    workspace = order.workspace.reload

    body = call(operator, :post, "workspaces/#{workspace.prefixed_id}/stored_value_payments",
                expected_revision: workspace.revision, lease_generation: workspace.lease_generation, editor_id: order.editor_id,
                card_token: 'MONEY-7777')
    expect(response).to have_http_status(:ok), response.body
    expect(body['data']).to be_present
    expect(Spree::Pos::StoredValueAccount.find_card(store, 'MONEY-7777').balance).to eq(100_000)
  end

  it 'saves timed promotions and the branch operating hours for managers only' do
    bearer(manager)
    body = call(manager, :post, 'timed_promotions', branch_id: branch.prefixed_id, name: 'Hát 2 tặng 15', kind: 'bonus_after',
                                                    threshold_minutes: 120, bonus_minutes: 15, resource_kinds: ['room'],
                                                    active_windows: [{ days: [1, 2, 3, 4, 5], from: '13:00', to: '17:00' }])
    expect(response).to have_http_status(:created), response.body
    id = body.dig('data', 'id')
    call(manager, :patch, "timed_promotions/#{id}", branch_id: branch.prefixed_id, status: 'archived')
    expect(response).to have_http_status(:ok), response.body
    list = call(operator, :get, "timed_promotions?branch_id=#{branch.prefixed_id}")
    expect(list['data'].sole).to include('id' => id, 'status' => 'archived', 'resource_kinds' => ['room'])

    call(operator, :post, 'timed_promotions', branch_id: branch.prefixed_id, name: 'X', kind: 'bonus_after', bonus_minutes: 10)
    expect(response).to have_http_status(:forbidden)

    call(manager, :patch, 'rate_plans/timed_settings', branch_id: branch.prefixed_id, max_pause_minutes: 20,
                                                       operating_windows: [{ days: [0, 1, 2, 3, 4, 5, 6], from: '08:00', to: '24:00' }])
    expect(response).to have_http_status(:ok), response.body
    meta = call(operator, :get, "rate_plans?branch_id=#{branch.prefixed_id}")['meta']
    expect(meta).to include('max_pause_minutes' => 20,
                            'operating_windows' => [{ 'days' => [0, 1, 2, 3, 4, 5, 6], 'from' => '08:00', 'to' => '24:00' }])
  end
end
