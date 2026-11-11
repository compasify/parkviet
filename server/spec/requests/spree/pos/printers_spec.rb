# frozen_string_literal: true

require 'spree/api/testing_support/v3/base'
require_relative '../../../support/pos_credit_helpers'

RSpec.describe 'POS printers API', type: :request do
  include PosCreditHelpers

  let(:store) { create(:store, default_currency: 'VND', supported_currencies: 'VND') }
  let(:branch) { credit_branch(store) }
  let(:manager) { credit_staff(store, branch, [Spree::Pos::Capabilities::PRINTER_MANAGE]) }
  let(:cashier) { credit_staff(store, branch, [Spree::Pos::Capabilities::OPEN_SHIFT]) }
  let(:device) { station(branch) }

  before { allow(Spree::Store).to receive(:default).and_return(store) }

  def station(at, mode: 'print_station')
    Spree::Pos::Device.create!(store: at.store, branch: at, name: 'Trạm in', mode: mode, platform: 'android',
                               token_digest: Spree::Pos::Device.digest(Spree::Pos::Device.new_token))
  end

  def auth(user, key = SecureRandom.uuid)
    post '/api/v3/admin/auth/login', params: { email: user.email, password: 'secret123' }, as: :json
    { 'Authorization' => "Bearer #{response.parsed_body.fetch('token')}", 'Idempotency-Key' => key }
  end

  def create_printer(user, **attributes)
    post '/api/v3/admin/pos/printers', headers: auth(user), as: :json, params: {
      branch_id: branch.prefixed_id, name: 'Quầy', connection: 'browser', paper: '80mm', command_language: 'escpos', roles: ['receipt']
    }.merge(attributes)
  end

  def errors
    response.parsed_body.dig('error', 'details')&.to_s.to_s + response.parsed_body.dig('error', 'message').to_s
  end

  it 'exposes the capability for assignment' do
    expect(Spree::Pos::Capabilities::ASSIGNABLE).to include('pos.printer.manage')
  end

  it 'creates and lists a printer for a manager' do
    create_printer(manager, connection: 'epson_epos', address: '192.168.1.20:8008')
    expect(response).to have_http_status(:created)
    expect_pos_schema!(response, 'Printer')

    get '/api/v3/admin/pos/printers', headers: auth(cashier), params: { branch_id: branch.prefixed_id }
    expect(response).to have_http_status(:ok)
    expect_pos_schema!(response, 'Printer')
    expect(response.parsed_body['data'].map { |row| row['address'] }).to eq(['192.168.1.20:8008'])
  end

  it 'refuses a cashier without the capability' do
    create_printer(cashier)
    expect(response).to have_http_status(:forbidden)
  end

  it 'replays a create with the same key' do
    key = SecureRandom.uuid
    params = { branch_id: branch.prefixed_id, name: 'Quầy', connection: 'browser', paper: '80mm', command_language: 'escpos', roles: [] }
    headers = auth(manager, key)
    2.times { post '/api/v3/admin/pos/printers', headers: headers, params: params, as: :json }

    expect(response).to have_http_status(:created)
    expect(Spree::Pos::Printer.where(branch: branch).count).to eq(1)
  end

  it 'hides a branch the staff member does not work at' do
    other = credit_branch(store)
    get '/api/v3/admin/pos/printers', headers: auth(cashier), params: { branch_id: other.prefixed_id }
    expect(response).to have_http_status(:not_found)
  end

  it 'hides another store\'s printer' do
    foreign_store = create(:store, default_currency: 'VND', supported_currencies: 'VND')
    foreign = Spree::Pos::Printer.create!(store: foreign_store, branch: credit_branch(foreign_store), name: 'X', connection: 'browser',
                                          paper: '80mm', command_language: 'escpos', roles: [])
    patch "/api/v3/admin/pos/printers/#{foreign.prefixed_id}", headers: auth(manager), params: { name: 'Y' }, as: :json
    expect(response).to have_http_status(:not_found)
  end

  it 'lists the branch print stations to a manager and refuses a cashier' do
    device
    station(branch, mode: 'kds')
    get '/api/v3/admin/pos/printers/stations', headers: auth(manager), params: { branch_id: branch.prefixed_id }
    expect(response.parsed_body['data']).to eq([{ 'id' => device.prefixed_id, 'name' => device.name }])

    get '/api/v3/admin/pos/printers/stations', headers: auth(cashier), params: { branch_id: branch.prefixed_id }
    expect(response).to have_http_status(:forbidden)
  end

  describe 'connection fields' do
    %w[http://192.168.1.20 192.168.1.20/path user@192.168.1.20 192.168.1.20:99999].each do |address|
      it "refuses the address #{address}" do
        create_printer(manager, connection: 'star_webprnt', address: address)
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    it 'requires an address for a direct printer' do
      create_printer(manager, connection: 'epson_epos')
      expect(response).to have_http_status(:unprocessable_content)
    end

    it 'requires a station device for a station connection' do
      create_printer(manager, connection: 'sunmi_builtin')
      expect(response).to have_http_status(:unprocessable_content)
    end

    it 'refuses a device that is not a print station' do
      create_printer(manager, connection: 'sunmi_builtin', print_station_device_id: station(branch, mode: 'kds').prefixed_id)
      expect(response).to have_http_status(:unprocessable_content)
    end

    it 'refuses a device of another branch' do
      create_printer(manager, connection: 'sunmi_builtin', print_station_device_id: station(credit_branch(store)).prefixed_id)
      expect(response).to have_http_status(:not_found)
    end

    it 'accepts a print station of the branch' do
      create_printer(manager, connection: 'sunmi_builtin', print_station_device_id: device.prefixed_id)
      expect(response).to have_http_status(:created)
    end
  end

  describe 'disabling and deleting' do
    let(:printer) do
      Spree::Pos::Printer.create!(store: store, branch: branch, name: 'Quầy', connection: 'sunmi_builtin', paper: '58mm', command_language: 'escpos',
                                  roles: [], print_station_device: device)
    end

    it 'deletes a printer that never had a job' do
      delete "/api/v3/admin/pos/printers/#{printer.prefixed_id}", headers: auth(manager), as: :json
      expect(response).to have_http_status(:ok)
      expect(Spree::Pos::Printer.exists?(printer.id)).to be(false)
    end

    it 'refuses to delete a printer with jobs' do
      Spree::Pos::PrintJobs::Enqueue.call(store: store, printer: printer, kind: 'test', document: { 'version' => 1 }, key: SecureRandom.uuid)
      delete "/api/v3/admin/pos/printers/#{printer.prefixed_id}", headers: auth(manager), as: :json
      expect(response).to have_http_status(:conflict)
      expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('printer_in_use')
    end

    it 'can still disable a printer whose station was revoked, but not re-enable it' do
      printer
      device.update!(status: 'revoked')

      patch "/api/v3/admin/pos/printers/#{printer.prefixed_id}", headers: auth(manager), params: { status: 'disabled' }, as: :json
      expect(response).to have_http_status(:ok)

      patch "/api/v3/admin/pos/printers/#{printer.prefixed_id}", headers: auth(manager), params: { status: 'active' }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end

    it 'disables a printer' do
      patch "/api/v3/admin/pos/printers/#{printer.prefixed_id}", headers: auth(manager), params: { status: 'disabled' }, as: :json
      expect(response).to have_http_status(:ok)
      expect(printer.reload).to be_disabled
    end
  end

  describe 'test print' do
    it 'queues a test job for a station printer' do
      printer = Spree::Pos::Printer.create!(store: store, branch: branch, name: 'Quầy', connection: 'sunmi_builtin', paper: '58mm',
                                            command_language: 'escpos', roles: [], print_station_device: device)
      post "/api/v3/admin/pos/printers/#{printer.prefixed_id}/test", headers: auth(manager), as: :json
      expect(response).to have_http_status(:created)
      expect(response.parsed_body.dig('data', 'print_job', 'kind')).to eq('test')
      expect(Spree::Pos::PrintJob.where(printer: printer).count).to eq(1)
    end

    it 'returns the document for a printer the browser drives, queueing nothing' do
      printer = Spree::Pos::Printer.create!(store: store, branch: branch, name: 'Quầy', connection: 'epson_epos', address: '10.0.0.5', paper: '80mm',
                                            command_language: 'escpos', roles: [])
      post "/api/v3/admin/pos/printers/#{printer.prefixed_id}/test", headers: auth(manager), as: :json
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.dig('data', 'document', 'kind')).to eq('test')
      expect(Spree::Pos::PrintJob.where(printer: printer)).to be_empty
    end

    it 'refuses a cashier' do
      printer = Spree::Pos::Printer.create!(store: store, branch: branch, name: 'Quầy', connection: 'browser', paper: '80mm',
                                            command_language: 'escpos', roles: [])
      post "/api/v3/admin/pos/printers/#{printer.prefixed_id}/test", headers: auth(cashier), as: :json
      expect(response).to have_http_status(:forbidden)
    end
  end
end
