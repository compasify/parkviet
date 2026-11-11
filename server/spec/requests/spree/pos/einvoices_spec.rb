# frozen_string_literal: true

require 'spree/api/testing_support/v3/base'
require_relative '../../../support/pos_einvoice_helpers'
require_relative '../../../support/pos_schema_helpers'

# E-invoice settings and the invoice list over HTTP, every response matching
# pos-staff.yaml: credentials are write-only, a store picks only registered
# providers, the list shows invoices still waiting, and a manager retries,
# cancels, sets buyer details or requests a replacement.
RSpec.describe 'POS e-invoices API', type: :request do
  include PosEinvoiceHelpers
  include PosSchemaHelpers
  include ActiveSupport::Testing::TimeHelpers

  let(:store) { einvoice_store }
  let(:branch) { credit_branch(store) }
  let(:manager) { einvoice_manager(store, branch) }
  let(:admin) { credit_staff(store, branch, [], extra_permissions: %w[read_pos_topology write_pos_topology]) }

  before { allow(Spree::Store).to receive(:default).and_return(store) }

  def token_for(user)
    @tokens ||= {}
    @tokens[user.id] ||= begin
      post '/api/v3/admin/auth/login', params: { email: user.email, password: 'secret123' }, as: :json
      response.parsed_body.fetch('token')
    end
  end

  def call(user, verb, path, body = {})
    key = SecureRandom.uuid
    send(verb, "/api/v3/admin/pos/#{path}", headers: { 'Authorization' => "Bearer #{token_for(user)}", 'Idempotency-Key' => key },
                                            params: verb == :get ? body : body.merge(idempotency_key: key), as: verb == :get ? nil : :json)
    response.parsed_body
  end

  it 'saves settings with write-only credentials and offers only registered providers' do
    data = call(admin, :put, 'einvoice_settings', einvoice_type: 'coded',
                                                  setting: { provider: 'sandbox', symbol: 'c26tab', seller_tax_code: '0101234567',
                                                             credentials: { username: 'shop', password: 'Top-Secret-1' } })
    expect(response).to have_http_status(:ok)
    expect_pos_schema!(response, 'EinvoiceSettings')
    expect(response.body).not_to include('Top-Secret-1')
    expect(data.dig('data', 'einvoice_type')).to eq('coded')
    expect(data.dig('data', 'providers').map { |row| row['key'] }).to eq(['sandbox'])
    expect(data.dig('data', 'settings', 0)).to include('symbol' => 'C26TAB', 'credential_fields' => %w[password username])
    expect(Spree::Pos::EinvoiceSetting.find_by(store_id: store.id, branch_id: nil).credential_values).
      to eq('username' => 'shop', 'password' => 'Top-Secret-1')

    # Saving other fields keeps the stored credentials.
    call(admin, :put, 'einvoice_settings', setting: { seller_name: 'Tên mới' })
    expect(Spree::Pos::EinvoiceSetting.find_by(store_id: store.id, branch_id: nil).credential_values.keys).to eq(%w[username password])
    entry = Spree::Pos::AuditEntry.where(action: 'einvoice_settings.change').order(:id).first
    expect(entry.metadata.to_json).not_to include('Top-Secret-1')

    call(admin, :put, 'einvoice_settings', setting: { provider: 'viettel' })
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('einvoice_provider_unknown')

    call(admin, :get, 'einvoice_settings')
    expect_pos_schema!(response, 'EinvoiceSettings')
    expect(response.body).not_to include('Top-Secret-1')

    call(manager, :get, 'einvoice_settings')
    expect(response).to have_http_status(:forbidden)
  end

  it 'issues a sandbox test invoice without saving one' do
    data = call(admin, :post, 'einvoice_settings/test')
    expect(response).to have_http_status(:ok)
    expect_pos_schema!(response, 'EinvoiceSample')
    expect(data.dig('data', 'symbol')).to eq('C26MAA')
    expect(Spree::Pos::Einvoice.count).to eq(0)
  end

  it 'lists invoices still waiting, retries them and shows the year against the mark' do
    allow(Spree::Pos::Einvoices::SandboxProvider).to receive(:new).
      and_raise(Spree::Pos::Einvoices::Provider::Error.new('Down', code: 'timeout'))
    # Core caps one order below 100 million, so the mark is scaled down.
    stub_const('Spree::Pos::Einvoices::MANDATORY_REVENUE', BigDecimal('100000'))
    sale = completed_sale(store, branch, price: 85_000)
    einvoice = einvoice_of(sale)
    drain_outbox

    data = call(manager, :get, 'einvoices', branch_id: branch.prefixed_id, status: 'outstanding')
    expect(response).to have_http_status(:ok)
    expect_pos_schema!(response, 'Einvoice')
    expect(data['data'].map { |row| row['id'] }).to eq([einvoice.prefixed_id])
    expect(data.dig('data', 0)).to include('status' => 'failed', 'order_number' => sale.workspace.order.number)

    summary = call(manager, :get, 'einvoices/summary', branch_id: branch.prefixed_id)
    expect_pos_schema!(response, 'EinvoiceSummary')
    expect(summary['data']).to include('outstanding' => 1)
    expect(summary.dig('data', 'revenue')).to include('total' => '85000.0', 'share' => '0.85', 'level' => 'warning')

    allow(Spree::Pos::Einvoices::SandboxProvider).to receive(:new).and_call_original
    result = call(manager, :post, 'einvoices/retry', branch_id: branch.prefixed_id)
    expect(result['data']).to eq('queued' => [einvoice.prefixed_id], 'skipped' => 0)
    drain_outbox

    data = call(manager, :get, "einvoices/#{einvoice.prefixed_id}")
    expect_pos_schema!(response, 'Einvoice')
    expect(data.dig('data', 'status')).to eq('issued')
    expect(call(manager, :get, 'einvoices', status: 'outstanding')['data']).to be_empty

    other = credit_staff(store, branch, PosCreditHelpers::CASHIER)
    call(other, :get, 'einvoices')
    expect(response).to have_http_status(:forbidden)
  end

  it 'takes buyer details until issued, then only a replacement' do
    allow(Spree::Pos::Einvoices::SandboxProvider).to receive(:new).
      and_raise(Spree::Pos::Einvoices::Provider::Error.new('Down', code: 'timeout'))
    einvoice = einvoice_of(completed_sale(store, branch))
    drain_outbox

    buyer = { tax_code: '0312345678', name: 'Công ty TNHH ABC', address: '2 Hai Bà Trưng' }
    call(manager, :put, "einvoices/#{einvoice.prefixed_id}/buyer", buyer: { tax_code: '0312345678' })
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'details')).to include('reason' => 'einvoice_buyer_invalid', 'field' => 'name')

    call(manager, :put, "einvoices/#{einvoice.prefixed_id}/buyer", buyer: buyer)
    expect(response).to have_http_status(:ok)
    expect_pos_schema!(response, 'Einvoice')
    allow(Spree::Pos::Einvoices::SandboxProvider).to receive(:new).and_call_original
    drain_outbox
    expect(einvoice.reload).to have_attributes(status: 'issued', buyer: buyer.transform_keys(&:to_s))

    call(manager, :put, "einvoices/#{einvoice.prefixed_id}/buyer", buyer: { name: 'Khác' })
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('einvoice_already_issued')
    call(manager, :post, "einvoices/#{einvoice.prefixed_id}/cancel", reason: 'Nhầm')
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('einvoice_already_issued')

    company = { tax_code: '0109876543', name: 'Công ty CP XYZ', address: '5 Nguyễn Huệ' }
    data = call(manager, :post, "einvoices/#{einvoice.prefixed_id}/replace", buyer: company, reason: 'Khách xin hóa đơn công ty')
    expect(response).to have_http_status(:created)
    expect_pos_schema!(response, 'Einvoice')
    expect(data['data']).to include('relation' => 'replacement', 'original_einvoice_id' => einvoice.prefixed_id, 'status' => 'pending')
    call(manager, :post, "einvoices/#{einvoice.prefixed_id}/replace", buyer: company, reason: 'Lần hai')
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('einvoice_replacement_pending')

    drain_outbox
    replacement = Spree::Pos::Einvoice.find_by_prefix_id!(data.dig('data', 'id'))
    expect(replacement.reload).to have_attributes(status: 'issued', buyer: company.transform_keys(&:to_s),
                                                  lines_snapshot: einvoice.lines_snapshot)
    expect(einvoice.reload.status).to eq('replaced')
  end

  it 'cancels an invoice that never reached the provider' do
    allow(Spree::Pos::Einvoices::SandboxProvider).to receive(:new).
      and_raise(Spree::Pos::Einvoices::Provider::Error.new('Down', code: 'timeout'))
    einvoice = einvoice_of(completed_sale(store, branch))
    drain_outbox

    call(manager, :post, "einvoices/#{einvoice.prefixed_id}/cancel", reason: '')
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('einvoice_reason_required')
    data = call(manager, :post, "einvoices/#{einvoice.prefixed_id}/cancel", reason: 'Đơn thử')
    expect(response).to have_http_status(:ok)
    expect(data.dig('data', 'status')).to eq('canceled')

    allow(Spree::Pos::Einvoices::SandboxProvider).to receive(:new).and_call_original
    drain_outbox(at: 2.hours.from_now)
    expect(einvoice.reload.status).to eq('canceled')
  end

  it 'tells the counter which e-invoice the store issues' do
    get '/api/v3/admin/pos/context', headers: { 'Authorization' => "Bearer #{token_for(manager)}" },
                                     params: { branch_id: branch.prefixed_id }
    expect_pos_schema!(response, 'Context')
    expect(response.parsed_body['einvoice_type']).to eq('cash_register')
  end
end
