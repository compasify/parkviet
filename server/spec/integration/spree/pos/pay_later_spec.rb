# frozen_string_literal: true

require 'openssl'
require_relative '../../../support/pos_credit_helpers'

# Pay later by VietQR: the receipt of a credit sale prints a bank QR for the
# debt with `TN<order number>` as the note, and a bank webhook reporting that
# note books a debt collection through the regular collection path, once per
# bank transaction, without touching counter-QR matching.
RSpec.describe 'POS pay-later VietQR', type: :request do
  include PosCreditHelpers

  let(:store) { create(:store, default_currency: 'VND', supported_currencies: 'VND') }
  let(:branch) { credit_branch(store) }
  let(:manager) { credit_staff(store, branch, PosCreditHelpers::MANAGER) }
  let(:profile) { credit_customer(store, manager) }
  let(:secret) { 'sepay-secret' }
  let!(:vietqr) { Spree::PaymentMethod::Vietqr.create!(store: store, name: 'Chuyển khoản VietQR', active: true) }
  let!(:bank_account) do
    vietqr.receiving_accounts.create!(provider: 'sepay', bank_bin: '970436', bank_name: 'Vietcombank',
                                      account_number: '0123456789', account_name: 'PARK VIET', webhook_secret: secret)
  end

  before { configure_credit(store, manager, branch, profile, limit: 5_000_000, due_days: 7) }

  def sold_on_credit(price, paid: 0)
    sale = credit_sale(store, branch, price: price)
    assign(sale, profile)
    take_tender(sale, 'cash', paid) if paid.positive?
    approval = approve_credit(sale, manager, price - paid)
    complete_on_credit(sale, approval['approval_id'])
    sale.workspace.reload
  end

  def receipt(workspace)
    Spree::Pos::ReceiptBuilder.for_source!(workspace, actor: manager)
  end

  def bank_webhook(content:, amount:, id: SecureRandom.random_number(10**9), reference: "FT#{SecureRandom.hex(4).upcase}")
    body = { id: id, gateway: 'Vietcombank', transactionDate: Time.current.to_s, accountNumber: '0123456789',
             content: content, transferType: 'in', transferAmount: amount, referenceCode: reference }.to_json
    timestamp = Time.current.to_i.to_s
    signature = "sha256=#{OpenSSL::HMAC.hexdigest('SHA256', secret, "#{timestamp}.#{body}")}"
    post '/webhooks/payments/sepay', params: body,
                                     headers: { 'CONTENT_TYPE' => 'application/json', 'X-SePay-Signature' => signature,
                                                'X-SePay-Timestamp' => timestamp }
    SpreeVietqr::WebhookEvent.order(:id).last
  end

  describe 'the receipt' do
    it 'carries a non-expiring QR for the debt with the order code in the note' do
      workspace = sold_on_credit(300_000, paid: 100_000)
      order = workspace.order
      qr = receipt(workspace).payload.dig('credit', 'pay_qr')

      expect(qr).to include('amount' => '200000.0', 'currency' => 'VND', 'order_number' => order.number,
                            'transfer_content' => "TN#{order.number}", 'bank_bin' => '970436', 'bank_name' => 'Vietcombank',
                            'account_number' => '0123456789', 'account_name' => 'PARK VIET')
      note = Spree::Pos::PayLater.tlv('08', "TN#{order.number}")
      expect(qr['payload']).to start_with('000201010212').and include('0010A000000727', '0006970436', '01100123456789', note,
                                                                      '5406200000', '5303704')
      expect(qr['payload'][-4..]).to eq(Spree::Pos::PayLater.crc16(qr['payload'][0...-4]))
      expect(qr['image_url']).to include('img.vietqr.io/image/970436-0123456789', 'amount=200000', "addInfo=TN#{order.number}")
      expect(qr).not_to have_key('expires_at')
      expect(SpreeVietqr::PaymentAllocation.count).to eq(0)
    end

    it 'has no QR without a debt, or while VietQR is off at the branch' do
      paid = credit_sale(store, branch, price: 50_000)
      take_tender(paid, 'cash', 50_000)
      Spree::Pos::Workspaces::Complete.call(**editing_args(paid))
      expect(receipt(paid.workspace.reload).payload['credit']).to be_nil

      Spree::Pos::FeatureFlag.create!(store: store, branch: branch, feature: 'vietqr', enabled: false,
                                      changed_by: manager, reason: 'Tắt VietQR')
      workspace = sold_on_credit(80_000)
      credit = receipt(workspace).payload['credit']
      expect(credit).to include('debt' => '80000.0')
      expect(credit).not_to have_key('pay_qr')
    end
  end

  describe 'the bank webhook' do
    it 'books the transfer as a collection and lowers the debt, audited' do
      order = sold_on_credit(300_000).order
      event = bank_webhook(content: "CT TU 0901 TN#{order.number} chuyen khoan", amount: 300_000, reference: 'FT-PAYLATER-1')

      expect(response).to have_http_status(:ok)
      expect(event.reload).to have_attributes(status: 'confirmed', matched_order_number: order.number)
      expect(receivable_balance(order)).to eq(0)
      collection = Spree::Pos::Collection.sole
      expect(collection.received_funds).to have_attributes(kind: 'bank_manual', reference: 'FT-PAYLATER-1',
                                                           receiving_account: '0123456789', received_net: 300_000)
      expect(collection.received_funds.balance.available).to eq(0)
      expect(order.reload.payment_status).to eq('paid')
      audit = Spree::Pos::AuditEntry.find_by!(action: 'collection.receive', subject_type: collection.class.name, subject_id: collection.id)
      expect(audit.metadata).to include('source' => 'vietqr_webhook', 'webhook_event_id' => event.prefixed_id,
                                        'order_number' => order.number)
    end

    it 'lowers the debt by a partial transfer' do
      order = sold_on_credit(300_000).order
      bank_webhook(content: "TN #{order.number}", amount: 120_000)

      expect(receivable_balance(order)).to eq(BigDecimal('180000'))
      expect(order.reload.payment_status).to eq('partially_paid')
    end

    it 'spends an overpayment on older debts and keeps the rest available' do
      older = sold_on_credit(100_000).order
      order = sold_on_credit(200_000).order
      bank_webhook(content: "TN#{order.number}", amount: 350_000)

      expect(receivable_balance(order)).to eq(0)
      expect(receivable_balance(older)).to eq(0)
      expect(Spree::Pos::Collection.sole.received_funds.balance.available).to eq(BigDecimal('50000'))
    end

    it 'books one bank transaction once, however often it is delivered' do
      order = sold_on_credit(300_000).order
      first = bank_webhook(content: "TN#{order.number}", amount: 100_000, id: 4242)
      second = bank_webhook(content: "TN#{order.number}", amount: 100_000, id: 4242)

      expect(response).to have_http_status(:ok)
      expect([first.reload.status, second.reload.status]).to eq(%w[confirmed duplicate])
      expect(Spree::Pos::Collection.count).to eq(1)
      expect(receivable_balance(order)).to eq(BigDecimal('200000'))

      # A replay of the handler itself (e.g. staff retrying the event) books nothing either.
      transaction = SpreeVietqr::NormalizedTransaction.new(provider: 'sepay', provider_transaction_id: '4242', amount_cents: 100_000,
                                                           raw_content: "TN#{order.number}")
      expect(Spree::Pos::Collections::ReceiveTransfer.call(transaction: transaction, webhook_event: second, payment_method: vietqr)).to be(true)
      expect(Spree::Pos::Collection.count).to eq(1)
    end

    it 'leaves other transfers alone' do
      order = sold_on_credit(300_000).order

      expect(bank_webhook(content: 'chuyen tien an trua', amount: 300_000).reload.status).to eq('unmatched')
      expect(bank_webhook(content: 'TNR000000001', amount: 300_000).reload.status).to eq('unmatched')
      # The counter prefix of the same order is not a pay-later note.
      expect(bank_webhook(content: "MMO#{order.number}", amount: 300_000).reload.status).to eq('unmatched')
      expect(Spree::Pos::Collection.count).to eq(0)

      bank_webhook(content: "TN#{order.number}", amount: 300_000)
      # Paid off: a second transfer is not obviously for a debt, so staff decide.
      expect(bank_webhook(content: "TN#{order.number}", amount: 300_000).reload.status).to eq('unmatched')
      expect(Spree::Pos::Collection.count).to eq(1)
    end

    it 'leaves a transfer whose bank reference was already recorded by hand to staff' do
      order = sold_on_credit(300_000).order
      open_drawer(store, branch, manager)
      Spree::Pos::Collections::Receive.call(
        store: store, staff: manager, key: SecureRandom.uuid, branch_id: branch.prefixed_id,
        credit_account_id: Spree::Pos::CreditAccount.sole.prefixed_id, kind: 'bank_manual', amount: '100000',
        allocations: [{ 'order_id' => order.prefixed_id, 'amount' => '100000' }], reference: 'FT-HAND', receiving_account: '0123456789'
      )
      expect(bank_webhook(content: "TN#{order.number}", amount: 100_000, reference: 'FT-HAND').reload.status).to eq('unmatched')
      expect(receivable_balance(order)).to eq(BigDecimal('200000'))
    end

    it 'still settles a counter QR the usual way' do
      sale = credit_sale(store, branch, price: 100_000)
      method = Spree::Pos::PaymentMethodResolver.new(store: store).available(branch: branch).find { |row| row.kind == 'vietqr' }
      Spree::Pos::Tenders::Prepare.call(**editing_args(sale), payment_method_id: method.prefixed_id || 'posmethod-vietqr', amount: '100000')
      attempt = Spree::Pos::TenderAttempt.where(workspace: sale.workspace).order(:id).last
      content = Spree::Pos::VietqrTender.summary(attempt)[:transfer_content]

      event = bank_webhook(content: content, amount: 100_000)
      expect(event.reload.status).to eq('confirmed')
      expect(event.payment_allocation).to be_present
      expect(Spree::Pos::VietqrTender.payment_for(attempt).reload.status).to eq('completed')
      expect(Spree::Pos::Collection.count).to eq(0)
    end
  end

  it 'gives each open debt in the receivables API a QR for what is still owed' do
    allow(Spree::Store).to receive(:default).and_return(store)
    order = sold_on_credit(300_000).order
    bank_webhook(content: "TN#{order.number}", amount: 100_000)

    post '/api/v3/admin/auth/login', params: { email: manager.email, password: 'secret123' }, as: :json
    token = response.parsed_body.fetch('token')
    get '/api/v3/admin/pos/receivables', params: { branch_id: branch.prefixed_id }, headers: { 'Authorization' => "Bearer #{token}" }

    expect(response).to have_http_status(:ok)
    row = response.parsed_body['data'].sole
    expect(row['pay_later']).to include('amount' => '200000.0', 'transfer_content' => "TN#{order.number}",
                                        'account_number' => '0123456789')
  end

  it 'computes the EMVCo CRC-16/CCITT-FALSE check value' do
    expect(Spree::Pos::PayLater.crc16('123456789')).to eq('29B1')
    expect(Spree::Pos::PayLater.order_number('MBVCB.1.tn r123456789.CT')).to eq('R123456789')
    expect(Spree::Pos::PayLater.order_number('MMOR123456789')).to be_nil
  end
end
