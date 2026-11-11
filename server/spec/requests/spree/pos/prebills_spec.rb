# frozen_string_literal: true

require 'spree/api/testing_support/v3/base'
require_relative '../../../support/pos_table_helpers'
require_relative '../../../support/pos_schema_helpers'

# A pre-bill hands the table its bill before it pays: recorded, free the
# first time, a reprint or a take-back only with a manager's approval.
RSpec.describe 'POS pre-bills', type: :request do
  include PosTableHelpers
  include PosSchemaHelpers

  let(:store) { menu_store }
  let(:branch) { table_branch(store) }
  let(:cashier) { credit_staff(store, branch, PosCreditHelpers::CASHIER) }
  let(:manager) { credit_staff(store, branch, PosCreditHelpers::MANAGER) }
  let(:table) { table!(area!(branch), name: 'Bàn 7') }
  let(:order) do
    table_register!(branch, cashier)
    seated = open_table(cashier, table)
    add_dish(seated, menu_product!(store, branch, name: 'Lẩu thái', price: 250_000))
    seated
  end

  before { allow(Spree::Store).to receive(:default).and_return(store) }

  def bearer(user)
    post '/api/v3/admin/auth/login', params: { email: user.email, password: 'secret123' }, as: :json
    { 'Authorization' => "Bearer #{response.parsed_body.fetch('token')}" }
  end

  def prebill(path = 'prebill', **params)
    post "/api/v3/admin/pos/workspaces/#{order.workspace.prefixed_id}/#{path}",
         headers: bearer(cashier).merge('Idempotency-Key' => SecureRandom.uuid), params: params, as: :json
    response.parsed_body
  end

  def approval(action)
    workspace = order.workspace.reload
    Spree::Pos::Approval.create!(store: store, branch: branch, approver: manager, requester: cashier, action: action, revision: workspace.revision,
                                 subject_type: workspace.class.name, subject_id: workspace.id, status: 'active', expires_at: 10.minutes.from_now)
  end

  it 'records the first pre-bill with its document and takes no money' do
    body = prebill
    expect(response).to have_http_status(:created), response.body
    expect_pos_schema!(response, 'PrebillOutcome')
    expect(body.dig('data', 'prebill')).to include('sequence' => 1, 'status' => 'current', 'total' => '250000.0')
    expect(body.dig('data', 'document')).to be_present
    workspace = order.workspace.reload
    expect(workspace.order.payments).to be_empty
    expect(workspace.snapshot_locked?).to be(false)
    expect(workspace.to_pos[:prebill]).to include(sequence: 1, stale: false)
  end

  it 'refuses a reprint without an approval and takes one bound to the order' do
    prebill
    body = prebill
    expect(response).to have_http_status(:conflict)
    expect(body.dig('error', 'details')).to include('reason' => 'approval_required', 'action' => 'workspace.reprint_prebill')
    expect(Spree::Pos::PrebillPrint.where(workspace_id: order.workspace.id).count).to eq(1)

    granted = approval(Spree::Pos::PrebillPrint::REPRINT_ACTION)
    body = prebill(approval_id: granted.prefixed_id)
    expect(response).to have_http_status(:created), response.body
    expect(body.dig('data', 'prebill')).to include('sequence' => 2, 'approval_id' => granted.prefixed_id)
    expect(granted.reload.status).to eq('consumed')
    expect(Spree::Pos::PrebillPrint.where(workspace_id: order.workspace.id).pluck(:status)).to contain_exactly('superseded', 'current')
    expect(Spree::Pos::AuditEntry.where(action: 'workspace.prebill', subject_id: order.workspace.id).count).to eq(2)
  end

  it 'takes a pre-bill back with an approval' do
    prebill
    prebill('prebill/cancel')
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('approval_required')

    body = prebill('prebill/cancel', approval_id: approval(Spree::Pos::PrebillPrint::CANCEL_ACTION).prefixed_id)
    expect(response).to have_http_status(:ok), response.body
    expect(body.dig('data', 'prebill', 'status')).to eq('canceled')

    # With nothing standing the next pre-bill is free again.
    prebill
    expect(response).to have_http_status(:created), response.body
  end

  it 'marks the pre-bill stale when the order changes' do
    prebill
    add_dish(order, menu_product!(store, branch, price: 30_000))
    expect(order.workspace.reload.to_pos[:prebill]).to include(stale: true)
  end

  it 'needs fnb.postpay' do
    order
    set_pos_module(branch, 'fnb.postpay', false)
    prebill
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('module_disabled')
  end
end
