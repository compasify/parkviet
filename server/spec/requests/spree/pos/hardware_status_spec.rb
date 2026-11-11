# frozen_string_literal: true

require 'spree/api/testing_support/v3/base'
require_relative '../../../support/pos_credit_helpers'

# The hardware checklist of a branch reads real state: a printer counts once
# its latest job printed, a station needs a kitchen screen or a printer, a
# print station must have been seen recently, a customer display must still
# be paired, and checks a branch does not use are `not_needed`.
RSpec.describe 'POS hardware status API', type: :request do
  include PosCreditHelpers

  let(:store) { create(:store, default_currency: 'VND', supported_currencies: 'VND') }
  let(:branch) { credit_branch(store) }
  let(:admin) { credit_staff(store, branch, [], extra_permissions: %w[read_pos_topology]) }
  let(:manager) { credit_staff(store, branch, [Spree::Pos::Capabilities::MANAGE]) }
  let(:cashier) { credit_staff(store, branch, PosCreditHelpers::CASHIER) }

  before { allow(Spree::Store).to receive(:default).and_return(store) }

  def status_for(user, at: branch)
    post '/api/v3/admin/auth/login', params: { email: user.email, password: 'secret123' }, as: :json
    get '/api/v3/admin/pos/hardware_status', params: { branch_id: at.prefixed_id },
                                             headers: { 'Authorization' => "Bearer #{response.parsed_body.fetch('token')}" }
    response.parsed_body['data']
  end

  def checks(data)
    data['checks'].to_h { |row| [row['key'], row['status']] }
  end

  # LAN printers print through the branch's print station, last seen 10 minutes ago.
  def printer(name, roles, connection: 'escpos_lan')
    lan = connection == 'escpos_lan'
    @station_device ||= device('print_station', seen_at: 10.minutes.ago) if lan
    Spree::Pos::Printer.create!(store: store, branch: branch, name: name, connection: connection, address: lan ? '192.168.1.50' : nil,
                                print_station_device: lan ? @station_device : nil, paper: '80mm', command_language: 'escpos',
                                roles: roles)
  end

  def print_job(target, status, at: Time.current)
    Spree::Pos::PrintJob.create!(store: store, branch: branch, printer: target, kind: 'test', document: { 'v' => 1 },
                                 status: status, idempotency_key: SecureRandom.uuid, created_at: at, updated_at: at,
                                 printed_at: status == 'printed' ? at : nil, last_error: status == 'failed' ? 'offline' : nil)
  end

  def device(mode, seen_at:, station: nil)
    Spree::Pos::Device.create!(store: store, branch: branch, name: mode, mode: mode, platform: 'android', kitchen_station: station,
                               token_digest: Spree::Pos::Device.digest(SecureRandom.hex(16)), last_seen_at: seen_at)
  end

  def turn_on(*keys)
    keys.each { |key| Spree::Pos::BranchModule.create!(store: store, branch: branch, module_key: key, enabled: true, reason: 'spec', changed_by: admin) }
  end

  it 'marks what a retail branch does not use as not needed and asks for a receipt printer' do
    data = status_for(admin)
    expect(response).to have_http_status(:ok)
    expect(response.headers['Cache-Control']).to include('no-store')
    expect(checks(data)).to include('receipt_printer' => 'attention', 'kitchen_printer' => 'not_needed',
                                    'cup_label_printer' => 'not_needed', 'kitchen_stations' => 'not_needed',
                                    'print_station' => 'not_needed', 'einvoice' => 'not_needed')
    expect(data['printers']).to eq([])
    expect(data['einvoice']).to include('type' => 'none', 'configured' => false)
  end

  it 'reads printers, stations, devices and displays of an F&B branch' do
    turn_on('fnb.menu', 'fnb.kitchen', 'fnb.cup_label')
    receipt = printer('Quầy', ['receipt'], connection: 'browser')
    kitchen = printer('Bếp', ['kitchen_ticket'])
    printer('Tem', ['cup_label'])
    print_job(receipt, 'failed', at: 2.hours.ago)
    print_job(receipt, 'printed', at: 1.hour.ago)
    print_job(kitchen, 'printed', at: 2.hours.ago)
    print_job(kitchen, 'failed', at: 1.minute.ago)
    prep = Spree::Pos::KitchenStation.create!(store: store, branch: branch, name: 'Bếp', kind: 'prep', printer: kitchen, kds_enabled: false)
    bar = Spree::Pos::KitchenStation.create!(store: store, branch: branch, name: 'Bar', kind: 'bar', position: 1)

    data = status_for(admin)
    expect(checks(data)).to include('receipt_printer' => 'ok', 'kitchen_printer' => 'attention',
                                    'cup_label_printer' => 'attention', 'kitchen_stations' => 'attention',
                                    'print_station' => 'attention')
    by_name = data['printers'].index_by { |row| row['name'] }
    expect(by_name['Bếp']).to include('last_job_status' => 'failed', 'last_error' => 'offline', 'via_print_station' => true)
    expect(by_name['Quầy']['via_print_station']).to be(false)
    expect(by_name['Quầy']).to include('last_job_status' => 'printed')
    expect(by_name['Tem']['last_job_status']).to be_nil
    expect(data['stations']).to eq([
      { 'id' => prep.prefixed_id, 'name' => 'Bếp', 'kind' => 'prep', 'printer_id' => kitchen.prefixed_id, 'kds_devices' => 0, 'ok' => true },
      { 'id' => bar.prefixed_id, 'name' => 'Bar', 'kind' => 'bar', 'printer_id' => nil, 'kds_devices' => 0, 'ok' => false }
    ])

    # A kitchen screen for the bar, the print station back online and the kitchen printer printing again.
    device('kds', seen_at: Time.current, station: bar)
    Spree::Pos::Device.where(branch: branch, mode: 'print_station').update_all(last_seen_at: Time.current)
    print_job(kitchen, 'printed')
    data = status_for(admin)
    expect(checks(data)).to include('kitchen_printer' => 'ok', 'kitchen_stations' => 'ok', 'print_station' => 'ok')
    expect(data['devices'].map { |row| [row['mode'], row['online']] }).to contain_exactly(['kds', true], ['print_station', true])
  end

  it 'counts a paired customer display only while it is live' do
    # Spec branches start with every feature on, the customer display included.
    expect(checks(status_for(admin))['customer_display']).to eq('attention')

    register = open_drawer(store, branch, cashier)
    shift = Spree::Pos::Shift.find_by!(register: register)
    session = Spree::Pos::DisplaySession.create!(store: store, branch: branch, register: register, shift: shift, staff: cashier,
                                                 token_digest: SecureRandom.hex(32), token_expires_at: 1.hour.from_now)
    data = status_for(admin)
    expect(checks(data)['customer_display']).to eq('ok')
    expect(data['customer_displays']).to eq('live' => 1)

    session.update_columns(token_expires_at: 1.minute.ago)
    expect(checks(status_for(admin))['customer_display']).to eq('attention')
  end

  it 'reports the server address, stuck outbound work and e-invoice settings' do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('POS_PUBLIC_BASE_URL').and_return('http://192.168.1.10')
    data = status_for(admin)
    expect(checks(data)['server']).to eq('ok')
    expect(data['server']).to include('public_base_url' => 'http://192.168.1.10', 'outbound_failed' => 0)

    Spree::Pos::OutboxEntry.record!(store: store, event_type: 'shift.closed', aggregate: branch)
    Spree::Pos::OutboxEntry.for_store(store).update_all(available_at: 1.hour.ago)
    expect(checks(status_for(admin))['server']).to eq('attention')

    Spree::Pos::StoreProfile.create!(store: store, profile_key: 'cafe_tra_sua', einvoice_type: 'coded', onboarded_at: Time.current)
    data = status_for(admin)
    expect(checks(data)['einvoice']).to eq('attention')
    expect(data['einvoice']).to include('type' => 'coded', 'provider' => nil, 'configured' => false)
  end

  it 'is for store administrators and branch managers only' do
    status_for(manager)
    expect(response).to have_http_status(:ok)
    status_for(cashier)
    expect(response).to have_http_status(:forbidden)
    other = credit_branch(create(:store, default_currency: 'VND', supported_currencies: 'VND'))
    status_for(admin, at: other)
    expect(response).to have_http_status(:not_found)
  end
end
