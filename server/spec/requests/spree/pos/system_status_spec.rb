# frozen_string_literal: true

require 'spree/api/testing_support/v3/base'
require_relative '../../../support/pos_credit_helpers'

RSpec.describe 'POS system status API', type: :request do
  include PosCreditHelpers

  let(:store) { create(:store, default_currency: 'VND', supported_currencies: 'VND') }
  let(:branch) { credit_branch(store) }
  let(:admin) { credit_staff(store, branch, [], extra_permissions: %w[read_pos_topology]) }
  let(:manager) { credit_staff(store, branch, PosCreditHelpers::MANAGER + [Spree::Pos::Capabilities::DEVICE_MANAGE]) }

  before { allow(Spree::Store).to receive(:default).and_return(store) }

  def status_for(user)
    post '/api/v3/admin/auth/login', params: { email: user.email, password: 'secret123' }, as: :json
    get '/api/v3/admin/pos/system_status', headers: { 'Authorization' => "Bearer #{response.parsed_body.fetch('token')}" }
  end

  # Overrides a few variables for the code under test; every other read is real.
  def with_env(vars)
    allow(ENV).to receive(:[]).and_call_original
    vars.each { |key, value| allow(ENV).to receive(:[]).with(key).and_return(value) }
  end

  def printer
    @printer ||= Spree::Pos::Printer.create!(store: store, branch: branch, name: 'Bếp', connection: 'browser', paper: '80mm',
                                             command_language: 'escpos', roles: ['receipt'])
  end

  def print_job(status, at: Time.current)
    Spree::Pos::PrintJob.create!(store: store, branch: branch, printer: printer, kind: 'test', document: { 'v' => 1 },
                                 status: status, idempotency_key: SecureRandom.uuid, created_at: at, updated_at: at)
  end

  it 'reports the address, health and stuck work to a store administrator' do
    with_env('POS_PUBLIC_BASE_URL' => 'http://192.168.1.10', 'POS_TLS_MODE' => 'none', 'PARKVIET_VERSION' => 'v1.2.3')
    print_job('failed')
    print_job('failed', at: 2.days.ago)
    print_job('queued', at: 3.minutes.ago)
    print_job('printed')
    Spree::Pos::OutboxEntry.record!(store: store, event_type: 'shift.closed', aggregate: branch)

    status_for(admin)

    expect(response).to have_http_status(:ok)
    expect(response.headers['Cache-Control']).to include('no-store')
    expect_pos_schema!(response, 'SystemStatus')
    data = response.parsed_body.fetch('data')
    expect(data['version']).to include('app' => 'v1.2.3')
    expect(data['server']).to eq('public_base_url' => 'http://192.168.1.10', 'tls_mode' => 'none')
    expect(data['database']['ok']).to be(true)
    expect(data['printing']).to include('pending' => 1, 'failed_last_24h' => 1)
    expect(data['printing']['oldest_pending_age_seconds']).to be >= 180
    expect(data['outbound']).to include('pending' => 1, 'failed' => 0)
    expect(data['realtime']['ok']).to be(true)
    expect(data['realtime']['probe_ms']).to be_a(Numeric)
  end

  it 'counts only this store’s print jobs and outbound work' do
    other = create(:store, default_currency: 'VND', supported_currencies: 'VND')
    other_branch = credit_branch(other)
    other_printer = Spree::Pos::Printer.create!(store: other, branch: other_branch, name: 'Khác', connection: 'browser', paper: '80mm',
                                                command_language: 'escpos', roles: ['receipt'])
    Spree::Pos::PrintJob.create!(store: other, branch: other_branch, printer: other_printer, kind: 'test', document: { 'v' => 1 },
                                 status: 'failed', idempotency_key: SecureRandom.uuid)
    Spree::Pos::OutboxEntry.record!(store: other, event_type: 'shift.closed', aggregate: other_branch)

    status_for(admin)

    data = response.parsed_body.fetch('data')
    expect(data['printing']['failed_last_24h']).to eq(0)
    expect(data['outbound']['pending']).to eq(0)
  end

  it 'counts this store’s VietQR events and those no store claimed' do
    other = create(:store, default_currency: 'VND', supported_currencies: 'VND')
    own_method = Spree::PaymentMethod::Vietqr.create!(store: store, name: 'VietQR', active: true)
    other_method = Spree::PaymentMethod::Vietqr.create!(store: other, name: 'VietQR', active: true)
    SpreeVietqr::WebhookEvent.create!(provider: 'sepay', payment_method: own_method, status: 'unmatched')
    SpreeVietqr::WebhookEvent.create!(provider: 'sepay', payment_method: nil, status: 'unmatched')
    SpreeVietqr::WebhookEvent.create!(provider: 'sepay', payment_method: other_method, status: 'unmatched', created_at: 1.minute.from_now)

    status_for(admin)

    vietqr = response.parsed_body.dig('data', 'vietqr')
    expect(vietqr['unmatched']).to eq(2)
    expect(Time.zone.parse(vietqr['last_received_at'])).to be < 30.seconds.from_now
  end

  # Calls the service directly: a request would load controllers that capture
  # Rails.cache for their rate limits while it is stubbed here.
  it 'shares one realtime probe between status requests for a short while' do
    allow(Rails).to receive(:cache).and_return(ActiveSupport::Cache::MemoryStore.new)
    allow(ActionCable.server.pubsub).to receive(:subscribe).and_call_original

    first = Spree::Pos::SystemStatus.new(store: store).call[:realtime]
    second = Spree::Pos::SystemStatus.new(store: store, now: 10.seconds.from_now).call[:realtime]

    expect(first[:ok]).to be(true)
    expect(second).to eq(first)
    expect(ActionCable.server.pubsub).to have_received(:subscribe).once
  end

  it 'reads the newest backup from the backup folder' do
    Dir.mktmpdir do |dir|
      FileUtils.touch(File.join(dir, 'parkviet-20261110-023000.dump'), mtime: Time.utc(2026, 11, 10, 2, 30))
      FileUtils.touch(File.join(dir, 'parkviet-20261111-023000.dump'), mtime: Time.utc(2026, 11, 11, 2, 30))
      FileUtils.touch(File.join(dir, '.parkviet-20261112-023000.dump.partial'))
      with_env('POS_BACKUP_DIR' => dir)

      status_for(admin)

      expect(response.parsed_body.dig('data', 'backup')).to eq('configured' => true, 'last_at' => '2026-11-11T02:30:00Z', 'count' => 2)
    end
  end

  it 'says when no backup folder is mounted' do
    with_env('POS_BACKUP_DIR' => nil, 'POS_PUBLIC_BASE_URL' => nil, 'POS_TLS_MODE' => nil)

    status_for(admin)

    data = response.parsed_body.fetch('data')
    expect(data['backup']).to eq('configured' => false, 'last_at' => nil, 'count' => 0)
    expect(data['server']).to eq('public_base_url' => nil, 'tls_mode' => 'unset')
  end

  it 'refuses branch staff without store administration' do
    status_for(manager)

    expect(response).to have_http_status(:forbidden)
    expect(response.parsed_body.dig('error', 'details', 'required_permission')).to eq('read_pos_topology')
  end
end
