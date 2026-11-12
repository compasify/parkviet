# frozen_string_literal: true

require 'spree/api/testing_support/v3/base'
require_relative '../../../support/pos_timed_helpers'

# A branch's prices of play time over the staff API: rate plans with their
# time bands, a new version once a clock was priced on one, a priced
# preview, holidays and weekend days.
RSpec.describe 'POS rate plans API', type: :request do
  include PosTimedHelpers

  let(:store) { menu_store }
  let(:branch) { timed_branch(store) }
  let(:manager) { credit_staff(store, branch, [Spree::Pos::Capabilities::RATE_PLAN_MANAGE]) }
  let(:operator) { credit_staff(store, branch, PosTimedHelpers::OPERATOR) }
  let(:service) { time_service!(store, branch) }

  before { allow(Spree::Store).to receive(:default).and_return(store) }

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

  def rules(day: '100000', evening: '150000')
    [{ day_type: 'weekday', start_minute: 0, end_minute: 1080, price_per_hour: day, label: 'Ngày' },
     { day_type: 'weekday', start_minute: 1080, end_minute: 1440, price_per_hour: evening, label: 'Tối' },
     { day_type: 'weekend', start_minute: 0, end_minute: 1440, price_per_hour: '200000', label: 'Cuối tuần' }]
  end

  def plan_params(**overrides)
    { branch_id: branch.prefixed_id, name: 'Phòng thường', resource_type_code: 'room', variant_id: service.prefixed_id,
      block_minutes: 15, grace_minutes: 5, minimum_minutes: 60, rules: rules }.merge(overrides)
  end

  it 'adds a plan, lists it and previews a stay' do
    body = call(manager, :post, 'rate_plans', plan_params)
    expect(response).to have_http_status(:created), response.body
    expect(body['data']).to include('resource_type_code' => 'room', 'version' => 1, 'minimum_minutes' => 60)
    expect(body.dig('data', 'rules').size).to eq(3)
    id = body.dig('data', 'id')

    list = call(manager, :get, "rate_plans?branch_id=#{branch.prefixed_id}")
    expect(list['data'].map { |row| row['id'] }).to eq([id])
    expect(list.dig('meta', 'weekend_days')).to eq([6, 0])

    get "/api/v3/admin/pos/rate_plans/#{id}/preview", headers: bearer(manager),
                                                      params: { branch_id: branch.prefixed_id, started_at: local('2026-11-12 17:30').iso8601,
                                                                ended_at: local('2026-11-12 18:30').iso8601 }
    expect(response).to have_http_status(:ok), response.body
    expect(response.parsed_body['data']).to include('billed_minutes' => 60, 'amount' => '125000.0')
  end

  it 'refuses rules that leave hours unpriced, and a second plan for the same rooms' do
    call(manager, :post, 'rate_plans', plan_params(rules: rules.first(1) + rules.last(1)))
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('rate_plan_invalid')

    call(manager, :post, 'rate_plans', plan_params)
    call(manager, :post, 'rate_plans', plan_params)
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('rate_plan_duplicate')
  end

  it 'keeps the version a clock was priced on and writes the next one' do
    table_register!(branch, operator)
    id = call(manager, :post, 'rate_plans', plan_params(minimum_minutes: 0)).dig('data', 'id')
    room = room!(area!(branch), name: 'P1', type: 'room')
    server_clock_at('2026-11-12 10:00')
    session = session_of(start_clock(operator, room))
    server_clock_at('2026-11-12 11:00')
    stop_clock(session, operator)

    body = call(manager, :patch, "rate_plans/#{id}", branch_id: branch.prefixed_id, rules: rules(day: '120000'))
    expect(response).to have_http_status(:ok), response.body
    expect(body['data']).to include('version' => 2, 'status' => 'active')
    expect(body['data']['id']).not_to eq(id)
    expect(Spree::Pos::RatePlan.find_by_prefix_id!(id).status).to eq('archived')
    expect(session.reload.amount).to eq(100_000)
  end

  it 'keeps holidays and weekend days, managers only' do
    call(operator, :post, 'rate_plans/special_days', branch_id: branch.prefixed_id, date: '2027-04-30', name: 'Giải phóng')
    expect(response).to have_http_status(:forbidden)

    body = call(manager, :post, 'rate_plans/special_days', branch_id: branch.prefixed_id, date: '2027-04-30', name: 'Giải phóng',
                                                            holiday_surcharge_percent: '20')
    expect(response).to have_http_status(:created), response.body
    expect(body['data']).to include('date' => '2027-04-30', 'holiday_surcharge_percent' => '20.0')
    call(manager, :post, 'rate_plans/special_days', branch_id: branch.prefixed_id, date: '2027-04-30', name: 'Lặp')
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('special_day_duplicate')

    list = call(manager, :get, "rate_plans/special_days?branch_id=#{branch.prefixed_id}")
    expect(list['data'].map { |row| row['name'] }).to eq(['Giải phóng'])
    call(manager, :delete, "rate_plans/special_days/#{body.dig('data', 'id')}", branch_id: branch.prefixed_id)
    expect(response).to have_http_status(:ok)

    call(manager, :patch, 'rate_plans/weekend_days', branch_id: branch.prefixed_id, weekend_days: [0])
    expect(response).to have_http_status(:ok), response.body
    expect(branch.reload.weekend_days).to eq([0])
  end
end
