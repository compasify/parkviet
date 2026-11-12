# frozen_string_literal: true

require 'spree/api/testing_support/v3/base'
require_relative '../../../support/pos_vehicle_helpers'
require_relative '../../../support/pos_schema_helpers'

# A rest stop over the API: opening a coach visit, putting orders on it,
# closing it, paying the commission in cash, a correction approved on the
# visit, drivers' phones masked by capability, and the commission report
# with its CSV export (which never holds a phone number).
RSpec.describe 'POS coach visits', type: :request do
  include PosVehicleHelpers
  include PosSchemaHelpers

  let(:store) { Spree::Store.default }
  let(:branch) { rest_stop_branch(store) }
  let(:cashier) { credit_staff(store, branch, PosVehicleHelpers::STOP_CASHIER) }
  let(:manager) { credit_staff(store, branch, PosVehicleHelpers::STOP_MANAGER, extra_permissions: %w[read_pos_shifts]) }
  let(:greeter) { credit_staff(store, branch, [PosVehicleHelpers::CAPS::VEHICLE_VISIT_OPERATE, PosVehicleHelpers::CAPS::OPEN_SHIFT]) }

  def headers(user = cashier)
    @tokens ||= {}
    @tokens[user.id] ||= begin
      post '/api/v3/admin/auth/login', params: { email: user.email, password: 'secret123' }, as: :json
      response.parsed_body.fetch('token')
    end
    { 'Authorization' => "Bearer #{@tokens[user.id]}", 'Idempotency-Key' => SecureRandom.uuid }
  end

  def editing_params(sale)
    workspace = sale.workspace.reload
    { expected_revision: workspace.revision, lease_generation: workspace.lease_generation, editor_id: sale.editor_id }
  end

  it 'opens a visit, sells orders on it, closes it and pays the commission in cash' do
    commission_rule!(store, manager, branch, per_vehicle_amounts: { 'seat_29' => '100000' }, per_guest_amount: '5000')
    post '/api/v3/admin/pos/vehicle_visits', headers: headers(greeter), as: :json,
                                             params: { branch_id: branch.prefixed_id, plate: '51b-123.45', vehicle_type: 'seat_29',
                                                       guest_count: 12, driver_name: 'Anh Tư', driver_phone: '0909123456' }
    expect(response).to have_http_status(:created), response.body
    expect_pos_schema!(response, 'VehicleVisit')
    visit = Spree::Pos::VehicleVisit.find_by_prefix_id!(response.parsed_body.dig('data', 'id'))
    expect(response.parsed_body['data']).to include('plate' => '51B12345', 'driver_phone' => '••••••3456', 'warnings' => [])

    post '/api/v3/admin/pos/vehicle_visits', headers: headers(greeter), as: :json,
                                             params: { branch_id: branch.prefixed_id, plate: '51B12345' }
    expect(response.parsed_body.dig('data', 'warnings')).to eq(['plate_open_today'])

    patch "/api/v3/admin/pos/vehicle_visits/#{visit.prefixed_id}", headers: headers(greeter), as: :json,
                                                                   params: { expected_revision: visit.revision, guest_count: 20 }
    expect(response).to have_http_status(:ok), response.body

    sales = Array.new(3) { stop_sale(store, branch, cashier, price: 100_000) }
    sales.each do |sale|
      put "/api/v3/admin/pos/workspaces/#{sale.workspace.prefixed_id}/vehicle_visit", headers: headers, as: :json,
                                                                                      params: editing_params(sale).merge(visit_id: visit.prefixed_id)
      expect(response).to have_http_status(:ok), response.body
      expect(response.parsed_body.dig('data', 'vehicle_visit_id')).to eq(visit.prefixed_id)
      expect_pos_schema!(response, 'Workspace')
      complete_in_cash(sale)
    end
    put "/api/v3/admin/pos/workspaces/#{sales.first.workspace.prefixed_id}/vehicle_visit", headers: headers, as: :json,
                                                                                           params: editing_params(sales.first).merge(visit_id: nil)
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('workspace_completed')

    post "/api/v3/admin/pos/vehicle_visits/#{visit.prefixed_id}/close", headers: headers(greeter), as: :json
    expect(response).to have_http_status(:ok), response.body
    expect(response.parsed_body['data']).to include('status' => 'closed', 'revenue_amount' => '300000.0', 'commission_amount' => '200000.0')
    expect_pos_schema!(response, 'VehicleVisit')

    # Greeting coaches is not paying them.
    post "/api/v3/admin/pos/vehicle_visits/#{visit.prefixed_id}/pay", headers: headers(greeter), as: :json, params: { payout_method: 'cash' }
    expect(response).to have_http_status(:forbidden)

    pay_key = SecureRandom.uuid
    2.times do
      post "/api/v3/admin/pos/vehicle_visits/#{visit.prefixed_id}/pay", headers: headers.merge('Idempotency-Key' => pay_key), as: :json,
                                                                        params: { payout_method: 'cash' }
      expect(response).to have_http_status(:ok), response.body
    end
    expect(response.parsed_body['data']).to include('status' => 'paid', 'payout_method' => 'cash', 'payout_status' => 'requested',
                                                    'driver_phone' => '0909123456')
    expect(Spree::Pos::CashMovementRequest.where(evidence_reference: visit.prefixed_id).count).to eq(1)

    get '/api/v3/admin/pos/vehicle_visits', headers: headers(greeter), params: { branch_id: branch.prefixed_id, status: 'paid' }
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body['data'].map { |row| row['id'] }).to eq([visit.prefixed_id])
    expect(response.parsed_body.dig('data', 0)).to include('driver_phone' => '••••••3456', 'workspaces_count' => 3)
    expect_pos_schema!(response, 'VehicleVisit')
  end

  it 'corrects a closed visit with an approval granted on the visit' do
    commission_rule!(store, manager, branch, per_vehicle_amounts: {}, per_guest_amount: '10000')
    visit = close_visit(open_visit!(store, cashier, branch, guest_count: 10), cashier)

    post "/api/v3/admin/pos/vehicle_visits/#{visit.prefixed_id}/adjust", headers: headers, as: :json,
                                                                         params: { expected_revision: visit.revision, guest_count: 15, note: 'Đếm lại' }
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'details')).to include('reason' => 'approval_required', 'action' => 'vehicle_visit.adjust')

    post '/api/v3/admin/pos/approvals', headers: headers(manager), as: :json,
                                        params: { branch_id: branch.prefixed_id, requester_id: cashier.prefixed_id,
                                                  vehicle_visit_id: visit.prefixed_id, action_name: 'vehicle_visit.adjust',
                                                  revision: visit.revision, expires_at: 10.minutes.from_now.iso8601 }
    expect(response).to have_http_status(:created), response.body
    approval_id = response.parsed_body.dig('data', 'id')

    post "/api/v3/admin/pos/vehicle_visits/#{visit.prefixed_id}/adjust", headers: headers, as: :json,
                                                                         params: { expected_revision: visit.revision, guest_count: 15, note: 'Đếm lại',
                                                                                   approval_id: approval_id }
    expect(response).to have_http_status(:ok), response.body
    expect(response.parsed_body['data']).to include('guest_count' => 15, 'commission_amount' => '150000.0')
  end

  it 'reports commission by operator and plate and exports it without phone numbers' do
    commission_rule!(store, manager, branch, per_vehicle_amounts: { 'seat_45' => '150000' }, per_guest_amount: '0')
    operator = bus_operator!(store, manager, branch, name: 'Phương Trang')
    visit = open_visit!(store, cashier, branch, plate: '51B-11111', vehicle_type: 'seat_45', bus_operator_id: operator.prefixed_id)
    sale = stop_sale(store, branch, cashier, price: 600_000)
    attach_visit(sale, visit)
    complete_in_cash(sale)
    close_visit(visit, cashier)
    pay_visit(visit.reload, cashier, payout_method: 'transfer', transfer_reference: 'FT0001')
    close_visit(open_visit!(store, cashier, branch, plate: '51B-22222', vehicle_type: 'seat_45'), cashier)
    day = visit.business_date.iso8601

    get '/api/v3/admin/pos/reports/vehicle_commissions', headers: headers(manager), params: { branch_id: branch.prefixed_id, from: day, to: day }
    expect(response).to have_http_status(:ok), response.body
    rows = response.parsed_body['data']
    expect(rows).to contain_exactly(
      include('bus_operator' => 'Phương Trang', 'plate' => '51B11111', 'visits' => 1, 'revenue' => '600000.0', 'commission_amount' => '150000.0',
              'paid' => '150000.0', 'unpaid' => '0.0', 'commission_rate' => '25.0'),
      include('bus_operator' => nil, 'plate' => '51B22222', 'commission_amount' => '150000.0', 'paid' => '0.0', 'unpaid' => '150000.0',
              'commission_rate' => nil)
    )
    expect(response.parsed_body.dig('meta', 'summary')).to include('visits' => 2, 'commission_amount' => '300000.0', 'unpaid' => '150000.0')

    post '/api/v3/admin/pos/exports', headers: headers(manager), as: :json,
                                      params: { branch_id: branch.prefixed_id, report_type: 'vehicle_commissions', filters: { from: day, to: day } }
    expect(response).to have_http_status(:accepted), response.body
    export = Spree::Pos::ExportRequest.order(:id).last
    Spree::Pos::GenerateExportJob.perform_now(export.id)
    expect(export.reload.status).to eq('ready')
    csv = export.file.download.force_encoding('UTF-8')
    expect(csv.lines.first).to include('business_date,bus_operator,plate,visits,guests,revenue,commission_amount,paid,unpaid,commission_rate')
    expect(csv).to include('51B11111')
    expect(csv).not_to include('0909123456')
    expect(csv).not_to include('Anh Tư')
  end
end
