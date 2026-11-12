# frozen_string_literal: true

require 'spree/api/testing_support/v3/base'
require_relative '../../../support/pos_return_helpers'
require_relative '../../../support/pos_owner_helpers'
require_relative '../../../support/pos_schema_helpers'

RSpec.describe 'POS approval requests', type: :request do
  include PosReturnHelpers
  include PosOwnerHelpers
  include PosSchemaHelpers

  let(:store) { create(:store, default_currency: 'VND', supported_currencies: 'VND') }
  let(:branch) { credit_branch(store) }
  let(:cashier) { credit_staff(store, branch, [Spree::Pos::Capabilities::OPEN_SHIFT, Spree::Pos::Capabilities::PAYMENT]) }
  let(:manager) { credit_staff(store, branch, [Spree::Pos::Capabilities::APPROVE, Spree::Pos::Capabilities::REPORT_READ]) }
  let(:product) { stocked_product(store, branch, price: 100_000) }
  let(:sale) { open_sale(store, branch, cashier: cashier, product: product) }

  before { allow(Spree::Store).to receive(:default).and_return(store) }

  def headers_for(user, key: SecureRandom.uuid)
    post '/api/v3/admin/auth/login', params: { email: user.email, password: 'secret123' }, as: :json
    { 'Authorization' => "Bearer #{response.parsed_body.fetch('token')}", 'Idempotency-Key' => key }
  end

  def discount(approval_id: nil)
    workspace = sale.workspace.reload
    Spree::Pos::Workspaces::ApplyDiscount.call(workspace: workspace, staff: cashier, revision: workspace.revision,
                                               lease_generation: workspace.lease_generation, editor_id: sale.editor_id,
                                               key: SecureRandom.uuid, value_type: 'percent', value: '10', reason: 'Khách quen',
                                               approval_id: approval_id)
  end

  # The cashier's discount answers `approval_required` with what to ask for.
  def needed
    discount
    raise 'expected an approval to be required'
  rescue Spree::Pos::Conflict => e
    e
  end

  def submit(conflict, user: cashier, reason: 'Khách quen 10%')
    post '/api/v3/admin/pos/approval_requests', headers: headers_for(user), params: {
      branch_id: branch.prefixed_id, workspace_id: sale.workspace.prefixed_id, action_name: conflict.details[:action],
      revision: conflict.revision, amount: conflict.details[:amount], reason: reason
    }, as: :json
  end

  it 'lets a manager grant from another device and the cashier then spends the approval' do
    conflict = needed
    expect(conflict.reason).to eq('approval_required')
    expect(conflict.details).to include(action: 'workspace.apply_discount', amount: '10000.0')

    events = []
    allow(Spree::Pos::Realtime).to receive(:publish).and_wrap_original do |original, *args, **kwargs|
      events << args[1]
      original.call(*args, **kwargs)
    end
    submit(conflict)
    expect(response).to have_http_status(:created)
    expect_pos_schema!(response, 'ApprovalRequest')
    request_id = response.parsed_body.dig('data', 'id')
    expect(response.parsed_body['data']).to include('status' => 'pending', 'requester_name' => be_present, 'amount' => '10000.0')
    expect(events).to include('approval_request.created')

    get '/api/v3/admin/pos/approval_requests', headers: headers_for(manager), params: { branch_id: branch.prefixed_id }
    expect(response.parsed_body['data'].pluck('id')).to eq([request_id])

    key = SecureRandom.uuid
    post "/api/v3/admin/pos/approval_requests/#{request_id}/grant", headers: headers_for(manager, key: key), as: :json
    expect(response).to have_http_status(:ok)
    expect_pos_schema!(response, 'ApprovalRequest')
    granted = response.parsed_body['data']
    expect(granted['status']).to eq('granted')
    approval = Spree::Pos::Approval.find_by_prefix_id!(granted['approval_id'])
    expect([approval.approver, approval.requester, approval.action]).to eq([manager, cashier, 'workspace.apply_discount'])
    expect(events).to include('approval.requested', 'approval_request.updated')
    expect(Spree::Pos::AuditEntry.where(action: %w[approval_request.submit approval_request.granted approval.grant]).count).to eq(3)

    # Replayed with the same key, and granted again: one approval.
    post "/api/v3/admin/pos/approval_requests/#{request_id}/grant", headers: headers_for(manager, key: key), as: :json
    expect(response.parsed_body.dig('data', 'approval_id')).to eq(approval.prefixed_id)
    post "/api/v3/admin/pos/approval_requests/#{request_id}/grant", headers: headers_for(manager), as: :json
    expect(response.parsed_body.dig('data', 'approval_id')).to eq(approval.prefixed_id)
    expect(Spree::Pos::Approval.count).to eq(1)

    discount(approval_id: approval.prefixed_id)
    expect(sale.workspace.reload.order.total).to eq(90_000)
    expect(approval.reload.status).to eq('consumed')
  end

  it 'answers the pending request when the same thing is asked again' do
    conflict = needed
    submit(conflict)
    first = response.parsed_body.dig('data', 'id')
    submit(conflict)
    expect(response.parsed_body.dig('data', 'id')).to eq(first)
    expect(Spree::Pos::ApprovalRequest.count).to eq(1)
  end

  it 'refuses deciders without the approve capability, other branches and the requester' do
    conflict = needed
    submit(conflict)
    request_id = response.parsed_body.dig('data', 'id')

    post "/api/v3/admin/pos/approval_requests/#{request_id}/grant", headers: headers_for(cashier), as: :json
    expect(response).to have_http_status(:forbidden)

    other_branch = credit_branch(store)
    elsewhere = credit_staff(store, other_branch, [Spree::Pos::Capabilities::APPROVE])
    get '/api/v3/admin/pos/approval_requests', headers: headers_for(elsewhere)
    expect(response.parsed_body['data']).to be_empty
    get "/api/v3/admin/pos/approval_requests/#{request_id}", headers: headers_for(elsewhere)
    expect(response).to have_http_status(:not_found)
    post "/api/v3/admin/pos/approval_requests/#{request_id}/grant", headers: headers_for(elsewhere), as: :json
    expect(response).to have_http_status(:not_found)

    # A manager asking for themself cannot grant their own request.
    boss = credit_staff(store, branch, [Spree::Pos::Capabilities::OPEN_SHIFT, Spree::Pos::Capabilities::APPROVE])
    own = open_sale(store, branch, cashier: boss, product: product)
    post '/api/v3/admin/pos/approval_requests', headers: headers_for(boss), params: {
      branch_id: branch.prefixed_id, workspace_id: own.workspace.prefixed_id, action_name: 'kitchen.void_sent',
      revision: own.workspace.reload.revision
    }, as: :json
    expect(response).to have_http_status(:created)
    post "/api/v3/admin/pos/approval_requests/#{response.parsed_body.dig('data', 'id')}/grant", headers: headers_for(boss), as: :json
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('approver_is_requester')
    expect(Spree::Pos::Approval.count).to eq(0)
  end

  it 'refuses a request from someone who may not work the order, and actions that are approved elsewhere' do
    conflict = needed
    stranger = credit_staff(store, branch, [Spree::Pos::Capabilities::OPEN_SHIFT])
    submit(conflict, user: stranger)
    expect(response).to have_http_status(:forbidden)

    post '/api/v3/admin/pos/approval_requests', headers: headers_for(cashier), params: {
      branch_id: branch.prefixed_id, workspace_id: sale.workspace.prefixed_id, action_name: 'credit.sale', revision: conflict.revision
    }, as: :json
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('approval_action_invalid')
  end

  it 'expires a request once its order changed, or after its time' do
    conflict = needed
    submit(conflict)
    request_id = response.parsed_body.dig('data', 'id')
    sale.workspace.update!(revision: sale.workspace.revision + 1)

    post "/api/v3/admin/pos/approval_requests/#{request_id}/grant", headers: headers_for(manager), as: :json
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.dig('data', 'status')).to eq('expired')
    expect(Spree::Pos::Approval.count).to eq(0)

    fresh = needed
    submit(fresh)
    late_id = response.parsed_body.dig('data', 'id')
    # Waiting is measured on the database clock.
    Spree::Pos::ApprovalRequest.find_by_prefix_id!(late_id).update_columns(expires_at: Spree::Pos::Workspace.database_now - 1.second)
    get '/api/v3/admin/pos/approval_requests', headers: headers_for(manager), params: { status: 'expired' }
    expect(response.parsed_body['data'].pluck('id')).to include(late_id)
    post "/api/v3/admin/pos/approval_requests/#{late_id}/grant", headers: headers_for(manager), as: :json
    expect(response.parsed_body.dig('data', 'status')).to eq('expired')
  end

  it 'declines with a reason and lets the requester cancel' do
    conflict = needed
    submit(conflict)
    request_id = response.parsed_body.dig('data', 'id')
    post "/api/v3/admin/pos/approval_requests/#{request_id}/decline", headers: headers_for(manager), params: { reason: 'Không' }, as: :json
    expect(response.parsed_body.dig('data', 'status')).to eq('declined')
    post "/api/v3/admin/pos/approval_requests/#{request_id}/grant", headers: headers_for(manager), as: :json
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('approval_request_decided')

    sale.workspace.update!(revision: sale.workspace.revision + 1)
    submit(needed)
    other_id = response.parsed_body.dig('data', 'id')
    post "/api/v3/admin/pos/approval_requests/#{other_id}/cancel", headers: headers_for(manager), as: :json
    expect(response).to have_http_status(:forbidden)
    post "/api/v3/admin/pos/approval_requests/#{other_id}/cancel", headers: headers_for(cashier), as: :json
    expect(response.parsed_body.dig('data', 'status')).to eq('canceled')

    get '/api/v3/admin/pos/approval_requests', headers: headers_for(cashier), params: { mine: 'true', status: 'all' }
    expect(response.parsed_body['data'].pluck('status')).to contain_exactly('declined', 'canceled')
  end

  it 'wakes the approvers phones through the relay only when one is set up' do
    owner_device, = pair_owner_device!(branch)
    Spree::Pos::PushRegistration.create!(store: store, device: owner_device, staff: manager, platform: 'apns', token: 'apns-token')
    conflict = needed

    allow(Spree::Pos::PushDeliveryJob).to receive(:perform_later)
    submit(conflict)
    expect(Spree::Pos::PushDeliveryJob).not_to have_received(:perform_later)

    Spree::Pos::PushRelaySetting.create!(store: store, url: 'https://relay.example.test/push', relay_key: 'k' * 40)
    sale.workspace.update!(revision: sale.workspace.revision + 1)
    submit(needed)
    registration = Spree::Pos::PushRegistration.find_by!(device: owner_device)
    expect(Spree::Pos::PushDeliveryJob).to have_received(:perform_later).
      with(registration.id, 'approval_request.created', response.parsed_body.dig('data', 'id')).once
  end
end
