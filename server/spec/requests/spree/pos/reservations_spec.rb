# frozen_string_literal: true

require 'spree/api/testing_support/v3/base'
require_relative '../../../support/pos_table_helpers'
require_relative '../../../support/pos_schema_helpers'

# Booking tables: a table is held for the booking's time and never twice,
# the free tables for a time follow capacity and status, and seating the
# party opens the order at the booked table.
RSpec.describe 'POS reservations', type: :request do
  include PosTableHelpers
  include PosSchemaHelpers

  let(:store) { menu_store }
  let(:branch) { table_branch(store).tap { |row| set_pos_module(row, 'fnb.reservations', true) } }
  let(:cashier) { credit_staff(store, branch, PosCreditHelpers::CASHIER) }
  let(:host) do
    credit_staff(store, branch, [Spree::Pos::Capabilities::RESERVATION_MANAGE, Spree::Pos::Capabilities::TABLE_SERVE])
  end
  let(:area) { area!(branch) }
  let!(:small) { table!(area, name: 'Bàn 2', capacity: 2) }
  let!(:large) { table!(area, name: 'Bàn 8', capacity: 8, x: 4) }
  let(:starts_at) { 1.day.from_now.change(min: 0, sec: 0) }

  before { allow(Spree::Store).to receive(:default).and_return(store) }

  def headers(user = host)
    @tokens ||= {}
    @tokens[user.id] ||= begin
      post '/api/v3/admin/auth/login', params: { email: user.email, password: 'secret123' }, as: :json
      response.parsed_body.fetch('token')
    end
    { 'Authorization' => "Bearer #{@tokens[user.id]}", 'Idempotency-Key' => SecureRandom.uuid }
  end

  def book(resource, at: starts_at, party: 2, name: 'Chị Lan')
    post '/api/v3/admin/pos/reservations', headers: headers, as: :json, params: {
      branch_id: branch.prefixed_id, resource_ids: [resource.prefixed_id], guest_name: name, phone: '0901234567',
      party_size: party, starts_at: at.iso8601
    }
    response.parsed_body
  end

  it 'holds a table for the booking and refuses an overlapping one' do
    body = book(small)
    expect(response).to have_http_status(:created), response.body
    expect_pos_schema!(response, 'Reservation')
    expect(body['data']).to include('status' => 'booked', 'party_size' => 2, 'deposit_held' => '0.0')
    expect(body.dig('data', 'resources').map { |row| row['id'] }).to eq([small.prefixed_id])
    expect(Time.iso8601(body.dig('data', 'ends_at')) - Time.iso8601(body.dig('data', 'starts_at'))).to eq(120.minutes)

    body = book(small, at: starts_at + 1.hour, name: 'Anh Minh')
    expect(response).to have_http_status(:conflict)
    expect(body.dig('error', 'details')).to include('reason' => 'reservation_overlap')

    book(small, at: starts_at + 2.hours, name: 'Anh Minh')
    expect(response).to have_http_status(:created), response.body
  end

  it 'refuses a party larger than the tables' do
    body = book(small, party: 5)
    expect(response).to have_http_status(:conflict)
    expect(body.dig('error', 'details')).to include('reason' => 'reservation_capacity')
  end

  it 'offers the free tables that seat the party, smallest first' do
    out = table!(area, name: 'Bàn 9', capacity: 4, x: 8, manual_status: 'out_of_service')
    book(small)

    get '/api/v3/admin/pos/reservations/availability', headers: headers, params: {
      branch_id: branch.prefixed_id, starts_at: (starts_at + 30.minutes).iso8601, party_size: 2
    }
    expect(response).to have_http_status(:ok), response.body
    expect_pos_schema!(response, 'AvailableResource')
    ids = response.parsed_body['data'].map { |row| row['id'] }
    expect(ids).to eq([large.prefixed_id])
    expect(ids).not_to include(out.prefixed_id)

    get '/api/v3/admin/pos/reservations/availability', headers: headers, params: {
      branch_id: branch.prefixed_id, starts_at: (starts_at + 3.hours).iso8601, party_size: 2
    }
    expect(response.parsed_body['data'].map { |row| row['id'] }).to eq([small.prefixed_id, large.prefixed_id])
  end

  it 'lists the day of the branch and seats the party at its table' do
    table_register!(branch, cashier)
    booked = book(large, at: 30.minutes.from_now.change(sec: 0), party: 6)['data']

    get '/api/v3/admin/pos/reservations', headers: headers, params: { branch_id: branch.prefixed_id,
                                                                      from: 1.hour.ago.iso8601, to: 3.hours.from_now.iso8601 }
    expect(response.parsed_body['data'].map { |row| row['id'] }).to eq([booked['id']])
    tile = Spree::Pos::ResourceState.for(branch)[:resources].find { |row| row[:id] == large.prefixed_id }
    expect(tile).to include(state: 'reserved')
    expect(tile[:next_reservation]).to include(id: booked['id'], guest_name: 'Chị Lan')

    post "/api/v3/admin/pos/reservations/#{booked['id']}/seat", headers: headers, as: :json, params: { editor_id: SecureRandom.uuid }
    expect(response).to have_http_status(:created), response.body
    body = response.parsed_body['data']
    expect(body['reservation']).to include('status' => 'seated')
    workspace = Spree::Pos::Workspace.find_by_prefix_id!(body.dig('workspace', 'id'))
    expect(workspace).to have_attributes(resource_id: large.id, guest_count: 6)
    expect(workspace.to_pos[:reservation]).to include(id: booked['id'], party_size: 6)

    post "/api/v3/admin/pos/reservations/#{booked['id']}/seat", headers: headers, as: :json, params: { editor_id: SecureRandom.uuid }
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'details')).to include('reason' => 'reservation_not_booked')
  end

  it 'cancels a booking and lets its table go' do
    booked = book(small)['data']
    post "/api/v3/admin/pos/reservations/#{booked['id']}/cancel", headers: headers, as: :json, params: {}
    expect(response).to have_http_status(:ok), response.body
    expect(response.parsed_body.dig('data', 'status')).to eq('canceled')

    book(small, name: 'Anh Minh')
    expect(response).to have_http_status(:created), response.body
  end

  it 'confirms a waiting booking once, keeping its revision, and only for those who book' do
    booked = book(small)['data']
    expect(booked['confirmed_at']).to be_nil

    post "/api/v3/admin/pos/reservations/#{booked['id']}/confirm", headers: headers(cashier), as: :json
    expect(response).to have_http_status(:forbidden)

    post "/api/v3/admin/pos/reservations/#{booked['id']}/confirm", headers: headers, as: :json
    expect(response).to have_http_status(:ok), response.body
    expect_pos_schema!(response, 'Reservation')
    confirmed = response.parsed_body['data']
    expect(confirmed).to include('status' => 'booked', 'revision' => booked['revision'], 'confirmed_at' => be_present)

    post "/api/v3/admin/pos/reservations/#{booked['id']}/confirm", headers: headers, as: :json
    expect(response.parsed_body.dig('data', 'confirmed_at')).to eq(confirmed['confirmed_at'])
    expect(Spree::Pos::AuditEntry.where(action: 'reservation.confirm').count).to eq(1)

    post "/api/v3/admin/pos/reservations/#{booked['id']}/cancel", headers: headers, as: :json, params: {}
    post "/api/v3/admin/pos/reservations/#{booked['id']}/confirm", headers: headers, as: :json
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'details')).to include('reason' => 'reservation_not_booked')
  end

  it 'is closed to a branch without bookings and to staff who do not book' do
    set_pos_module(branch, 'fnb.reservations', false)
    body = book(small)
    expect(response).to have_http_status(:conflict).or have_http_status(:forbidden).or have_http_status(:unprocessable_content)
    expect(body.to_s).to include('module')

    set_pos_module(branch, 'fnb.reservations', true)
    post '/api/v3/admin/pos/reservations', headers: headers(cashier), as: :json, params: {
      branch_id: branch.prefixed_id, resource_ids: [small.prefixed_id], guest_name: 'Chị Lan', party_size: 2, starts_at: starts_at.iso8601
    }
    expect(response).to have_http_status(:forbidden)
  end
end
