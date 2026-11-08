# frozen_string_literal: true

require 'openssl'
require_relative '../../../support/pos_credit_helpers'
require_relative '../../../support/pos_feature_helpers'

# A VietQR tender at the counter: preparing it reserves a receiving account
# and shows a QR; the bank webhook (SePay here) completes the core payment;
# the cashier then confirms the tender with that webhook as evidence, or by
# hand when no webhook arrives. Canceling gives the QR back and voids the
# payment, but never money the bank already reported.
RSpec.describe 'POS VietQR tender', type: :request do
  include PosCreditHelpers

  let(:store) { create(:store, default_currency: 'VND', supported_currencies: 'VND') }
  let(:branch) { credit_branch(store) }
  let(:secret) { 'sepay-secret' }
  let!(:vietqr) { Spree::PaymentMethod::Vietqr.create!(store: store, name: 'Chuyển khoản VietQR', active: true) }
  let!(:account) do
    vietqr.receiving_accounts.create!(provider: 'sepay', bank_bin: '970436', bank_name: 'Vietcombank',
                                      account_number: '0123456789', account_name: 'PARK VIET', webhook_secret: secret)
  end
  let(:sale) { credit_sale(store, branch, price: 100_000) }

  def method_id(kind)
    row = Spree::Pos::PaymentMethodResolver.new(store: store).available(branch: branch).find { |item| item.kind == kind }
    row && (row.prefixed_id || "posmethod-#{kind}")
  end

  def prepare(kind, amount)
    Spree::Pos::Tenders::Prepare.call(**editing_args(sale), payment_method_id: method_id(kind), amount: amount.to_s)
    Spree::Pos::TenderAttempt.where(workspace: sale.workspace).order(:id).last
  end

  def confirm(attempt, **evidence)
    Spree::Pos::Tenders::Confirm.call(**editing_args(sale), attempt_id: attempt.prefixed_id, **evidence)
  end

  def bank_webhook(content:, amount:, reference: "FT#{SecureRandom.hex(4).upcase}")
    body = { id: SecureRandom.random_number(10**9), gateway: 'Vietcombank', transactionDate: Time.current.to_s,
             accountNumber: '0123456789', content: content, transferType: 'in', transferAmount: amount,
             referenceCode: reference }.to_json
    timestamp = Time.current.to_i.to_s
    signature = "sha256=#{OpenSSL::HMAC.hexdigest('SHA256', secret, "#{timestamp}.#{body}")}"
    post '/webhooks/payments/sepay', params: body,
                                     headers: { 'CONTENT_TYPE' => 'application/json', 'X-SePay-Signature' => signature,
                                                'X-SePay-Timestamp' => timestamp }
    reference
  end

  it 'offers VietQR only while the store has a receiving account and the branch has it on' do
    expect(method_id('vietqr')).to be_present

    account.update!(active: false)
    expect(method_id('vietqr')).to be_nil

    account.update!(active: true)
    Spree::Pos::FeatureFlag.where(store: store, feature: 'vietqr').update_all(enabled: false)
    expect(method_id('vietqr')).to be_nil
  end

  it 'shows a QR, waits for the bank and confirms the tender from the webhook' do
    attempt = prepare('vietqr', 100_000)
    payment = Spree::Pos::VietqrTender.payment_for(attempt)
    expect(payment).to have_attributes(status: 'pending', amount: 100_000, payment_method: vietqr)

    summary = Spree::Pos::VietqrTender.summary(attempt)
    expect(summary).to include(status: 'allocated', amount: 100_000, account_number: '0123456789',
                               transfer_content: "MMO#{sale.workspace.order.number}")
    expect(summary[:qr_url]).to include('img.vietqr.io/image/970436-0123456789')

    expect { confirm(attempt, evidence_kind: 'vietqr_webhook') }.
      to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('vietqr_not_received') }

    reference = bank_webhook(content: "chuyen tien #{summary[:transfer_content]}", amount: 100_000)
    expect(response).to have_http_status(:ok)
    expect(payment.reload.status).to eq('completed')
    expect(Spree::Pos::VietqrTender.summary(attempt.reload)).to include(status: 'confirmed')

    expect { confirm(attempt, evidence_kind: 'vietqr_webhook') }.not_to change(Spree::Payment, :count)
    funds = Spree::Pos::ReceivedFunds.find_by!(tender_attempt: attempt)
    expect(funds).to have_attributes(kind: 'bank_manual', reference: reference, receiving_account: '0123456789',
                                     applied_amount: 100_000)
    expect(Spree::Pos::ReceiptEvidence.find_by!(tender_attempt: attempt).kind).to eq('vietqr_webhook')
    expect(Spree::Pos::FundsAllocation.find_by!(received_funds: funds).payment).to eq(payment)

    Spree::Pos::Workspaces::Complete.call(**editing_args(sale))
    expect(sale.workspace.reload.operational_status).to eq('completed')
  end

  it 'lets the cashier attest a transfer by hand when no webhook arrives' do
    attempt = prepare('vietqr', 100_000)

    expect { confirm(attempt, evidence_kind: 'vietqr_manual') }.
      to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('vietqr_evidence_required') }

    confirm(attempt, evidence_kind: 'vietqr_manual', reference: 'FT-HAND-1', receiving_account: '0123456789')
    expect(Spree::Pos::VietqrTender.payment_for(attempt).status).to eq('completed')
    expect(Spree::Pos::VietqrTender.allocation_for(attempt)).to be_confirmed
    expect(Spree::Pos::ReceivedFunds.find_by!(tender_attempt: attempt).reference).to eq('FT-HAND-1')
  end

  it 'releases the QR and voids the payment on cancel, but keeps money the bank already reported' do
    attempt = prepare('vietqr', 100_000)
    Spree::Pos::Tenders::Cancel.call(**editing_args(sale), attempt_id: attempt.prefixed_id)
    expect(Spree::Pos::VietqrTender.payment_for(attempt).status).to eq('void')
    expect(SpreeVietqr::PaymentAllocation.find_by!(payment: Spree::Pos::VietqrTender.payment_for(attempt))).to be_released
    expect(account.reload.period_allocated_amount).to eq(0)

    again = prepare('vietqr', 100_000)
    bank_webhook(content: Spree::Pos::VietqrTender.summary(again)[:transfer_content], amount: 100_000)
    expect { Spree::Pos::Tenders::Cancel.call(**editing_args(sale), attempt_id: again.prefixed_id) }.
      to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('vietqr_already_received') }
  end

  it 'splits a sale between cash and VietQR without the cash payment voiding the waiting QR' do
    qr = prepare('vietqr', 60_000)
    cash = prepare('cash', 40_000)
    expect { prepare('vietqr', 1) }.to raise_error(Spree::Pos::Conflict)

    confirm(cash, evidence_kind: 'cash_count', handed_amount: '40000')
    expect(Spree::Pos::VietqrTender.payment_for(qr).status).to eq('pending')

    bank_webhook(content: Spree::Pos::VietqrTender.summary(qr)[:transfer_content], amount: 60_000)
    confirm(qr, evidence_kind: 'vietqr_webhook')
    Spree::Pos::Workspaces::Complete.call(**editing_args(sale))
    expect(sale.workspace.reload.operational_status).to eq('completed')
  end

  it 'refuses VietQR when the branch switched it off' do
    id = method_id('vietqr')
    Spree::Pos::FeatureFlag.create!(store: store, branch: branch, feature: 'vietqr', enabled: false,
                                    changed_by: sale.cashier, reason: 'Tắt VietQR')
    expect { Spree::Pos::Tenders::Prepare.call(**editing_args(sale), payment_method_id: id, amount: '100000') }.
      to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('feature_disabled') }
  end
end
