# frozen_string_literal: true

require 'openssl'
require 'spree/api/testing_support/v3/base'
require_relative '../../../support/pos_credit_helpers'

# "Khách nợ" and "Nhắc nợ": the list of customers who owe at a branch, the
# reminder it carries (open orders and one pay-later QR for the total), and
# recording when a reminder was sent.
RSpec.describe 'POS debt reminders', type: :request do
  include PosCreditHelpers

  let(:store) { create(:store, default_currency: 'VND', supported_currencies: 'VND') }
  let(:branch) { credit_branch(store) }
  let(:manager) { credit_staff(store, branch, PosCreditHelpers::MANAGER) }
  let(:profile) do
    credit_customer(store, manager).tap { |customer| customer.update!(address: '1205 S1.02') }
  end
  let(:secret) { 'sepay-secret' }
  let!(:vietqr) { Spree::PaymentMethod::Vietqr.create!(store: store, name: 'Chuyển khoản VietQR', active: true) }
  let!(:bank_account) do
    vietqr.receiving_accounts.create!(provider: 'sepay', bank_bin: '970436', bank_name: 'Vietcombank',
                                      account_number: '0123456789', account_name: 'PARK VIET', webhook_secret: secret)
  end

  before do
    allow(Spree::Store).to receive(:default).and_return(store)
    configure_credit(store, manager, branch, profile, limit: 5_000_000, due_days: 7)
  end

  def token_for(user)
    @tokens ||= {}
    @tokens[user.id] ||= begin
      post '/api/v3/admin/auth/login', params: { email: user.email, password: 'secret123' }, as: :json
      response.parsed_body.fetch('token')
    end
  end

  def call(user, verb, path, body = {}, key: SecureRandom.uuid)
    send(verb, "/api/v3/admin/pos/#{path}", headers: { 'Authorization' => "Bearer #{token_for(user)}", 'Idempotency-Key' => key },
                                            params: verb == :get ? body : body.merge(idempotency_key: key), as: verb == :get ? nil : :json)
    response.parsed_body
  end

  def customers(user, **params)
    call(user, :get, 'receivables/customers', { branch_id: branch.prefixed_id }.merge(params))['data']
  end

  def sold(price, customer = profile)
    credit_order(store, branch, manager, customer, price: price).workspace.order.reload
  end

  def remind(user, account_id, key: SecureRandom.uuid, via: 'share')
    call(user, :post, "receivables/customers/#{account_id}/remind", { branch_id: branch.prefixed_id, via: via }, key: key)
  end

  def bank_webhook(content:, amount:)
    body = { id: SecureRandom.random_number(10**9), gateway: 'Vietcombank', transactionDate: Time.current.to_s,
             accountNumber: '0123456789', content: content, transferType: 'in', transferAmount: amount,
             referenceCode: "FT#{SecureRandom.hex(4).upcase}" }.to_json
    timestamp = Time.current.to_i.to_s
    signature = "sha256=#{OpenSSL::HMAC.hexdigest('SHA256', secret, "#{timestamp}.#{body}")}"
    post '/webhooks/payments/sepay', params: body,
                                     headers: { 'CONTENT_TYPE' => 'application/json', 'X-SePay-Signature' => signature,
                                                'X-SePay-Timestamp' => timestamp }
    SpreeVietqr::WebhookEvent.order(:id).last
  end

  it 'lists who owes with totals, oldest debt, overdue first and one QR for the whole balance' do
    older = sold(100_000)
    newer = sold(200_000)
    other = credit_customer(store, manager, name: 'Anh Minh')
    configure_credit(store, manager, branch, other, limit: 5_000_000, due_days: 7)
    late = sold(50_000, other)
    Spree::Pos::ReceivableEntry.where(order_id: late.id).update_all(due_on: Date.current - 3)

    rows = customers(manager)
    expect(response).to have_http_status(:ok)
    # Most overdue first, even with the smaller debt.
    expect(rows.map { |row| row.dig('customer', 'name') }).to eq(['Anh Minh', profile.name])
    expect(rows.first).to include('balance' => '50000.0', 'overdue' => '50000.0', 'orders' => 1)
    expect(rows.first['days_overdue']).to be >= 3

    row = rows.last
    expect(row).to include('balance' => '300000.0', 'overdue' => '0.0', 'orders' => 2, 'days_overdue' => 0, 'days_owed' => 0,
                           'last_reminded_at' => nil, 'oldest_placed_at' => older.completed_at.iso8601)
    expect(row['customer']).to include('phone' => profile.phone, 'address' => '1205 S1.02')
    expect(row['open_orders'].map { |order| [order['order_number'], order['balance']] }).
      to eq([[older.number, '100000.0'], [newer.number, '200000.0']])
    expect(row['oldest_due_on']).to eq(row['open_orders'].first['due_on'])
    expect(row['pay_later']).to include('amount' => '300000.0', 'transfer_content' => "TN#{older.number}",
                                        'account_number' => '0123456789')

    # Readers who cannot collect see neither the phone nor the address.
    reader = credit_staff(store, branch, [Spree::Pos::Capabilities::OPEN_SHIFT])
    masked = customers(reader).find { |item| item['credit_account_id'] == row['credit_account_id'] }
    expect(masked['customer']['phone']).to end_with(profile.phone[-3..])
    expect(masked['customer']['phone']).not_to eq(profile.phone)
    expect(masked['customer']['address']).to be_nil

    # Search by name; another branch sees nothing of this one.
    expect(customers(manager, q: 'Minh').map { |item| item['credit_account_id'] }).to eq([rows.first['credit_account_id']])
    outsider = credit_staff(store, credit_branch(store), PosCreditHelpers::MANAGER)
    call(outsider, :get, 'receivables/customers', { branch_id: branch.prefixed_id })
    expect(response).to have_http_status(:forbidden)
  end

  it 'settles every listed order oldest first from one transfer of the reminder QR' do
    older = sold(100_000)
    newer = sold(200_000)
    qr = customers(manager).sole['pay_later']

    event = bank_webhook(content: "CT #{qr['transfer_content']}", amount: 250_000)
    expect(event.reload.status).to eq('confirmed')
    expect(receivable_balance(older)).to eq(0)
    expect(receivable_balance(newer)).to eq(BigDecimal('50000'))

    # The next reminder anchors on what is still owed.
    row = customers(manager).sole
    expect(row['pay_later']).to include('amount' => '50000.0', 'transfer_content' => "TN#{newer.number}")
    # An order-level pay-later note keeps working alongside.
    expect(bank_webhook(content: "TN#{newer.number}", amount: 50_000).reload.status).to eq('confirmed')
    expect(receivable_balance(newer)).to eq(0)
  end

  it 'records a reminder once per key, audited, only for staff who may collect' do
    sold(100_000)
    account_id = Spree::Pos::CreditAccount.sole.prefixed_id
    key = SecureRandom.uuid

    reader = credit_staff(store, branch, [Spree::Pos::Capabilities::OPEN_SHIFT])
    remind(reader, account_id)
    expect(response).to have_http_status(:forbidden)
    outsider = credit_staff(store, credit_branch(store), PosCreditHelpers::MANAGER)
    remind(outsider, account_id)
    expect(response).to have_http_status(:forbidden)
    remind(manager, account_id, via: 'fax')
    expect(response).to have_http_status(:conflict)

    first = remind(manager, account_id, key: key)['data']
    expect(response).to have_http_status(:ok)
    expect(remind(manager, account_id, key: key)['data']).to eq(first)
    expect(Spree::Pos::AuditEntry.where(action: 'credit.remind').count).to eq(1)
    audit = Spree::Pos::AuditEntry.find_by!(action: 'credit.remind')
    expect(audit.metadata).to include('branch_id' => branch.prefixed_id, 'via' => 'share', 'balance' => '100000.0')
    expect(Spree::Pos::CreditAccount.sole.last_reminded_at).to be_present

    cashier = credit_staff(store, branch, PosCreditHelpers::CASHIER)
    remind(cashier, account_id, via: 'copy')
    expect(response).to have_http_status(:ok)
    expect(Spree::Pos::AuditEntry.where(action: 'credit.remind').count).to eq(2)

    expect(customers(manager).sole['last_reminded_at']).to eq(Spree::Pos::CreditAccount.sole.last_reminded_at.iso8601)
  end

  it 'refuses a reminder when nothing is owed at the branch' do
    order = sold(100_000)
    bank_webhook(content: "TN#{order.number}", amount: 100_000)
    remind(manager, Spree::Pos::CreditAccount.sole.prefixed_id)
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('reminder_nothing_owed')
  end
end
