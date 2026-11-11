# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../support/pos_einvoice_helpers'

# The buyer's own page behind the QR on the bill: a signed link that expires,
# details taken only before the invoice is issued, and nothing an attacker
# can reuse (wrong or tampered tokens, an issued invoice, too many tries).
RSpec.describe 'POS e-invoice buyer page', type: :request do
  include PosEinvoiceHelpers
  include ActiveSupport::Testing::TimeHelpers

  let(:store) { einvoice_store }
  let(:branch) { credit_branch(store) }
  let(:einvoice) { einvoice_of(completed_sale(store, branch)) }
  let(:token) { Spree::Pos::Einvoices::BuyerLink.token(einvoice) }

  before { Spree::Pos::EinvoiceBuyerController::LIMIT_STORE.clear }

  it 'shows the form and takes the details the invoice then carries' do
    get "/pos_einvoice/#{token}"
    expect(response).to have_http_status(:ok)
    expect(response.media_type).to eq('text/html')
    expect(response.headers['Cache-Control']).to include('no-store')
    expect(response.headers['Content-Security-Policy']).to include("default-src 'none'")
    expect(response.body).to include('Mã số thuế', einvoice.order.number)

    post "/pos_einvoice/#{token}", params: { lookup: '1', buyer: { tax_code: '0312345678' } }
    expect(response.body).to include('Công ty thử nghiệm 0312345678')

    post "/pos_einvoice/#{token}", params: { buyer: { tax_code: '0312345678', name: 'Công ty TNHH ABC', address: '2 Hai Bà Trưng',
                                                      email: 'ketoan@abc.vn' } }
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Đã nhận thông tin')
    expect(einvoice.reload.buyer).to include('tax_code' => '0312345678', 'name' => 'Công ty TNHH ABC')
    expect(einvoice.buyer_submitted_at).to be_present
    expect(Spree::Pos::AuditEntry.where(action: 'einvoice.buyer_updated', subject_id: einvoice.id).sole.metadata).
      to include('source' => 'buyer')

    drain_outbox
    expect(einvoice.reload).to have_attributes(status: 'issued', buyer: include('name' => 'Công ty TNHH ABC'))
  end

  it 'asks again for a malformed field' do
    post "/pos_einvoice/#{token}", params: { buyer: { tax_code: '12345' } }
    expect(response).to have_http_status(:unprocessable_content)
    expect(response.body).to include('Mã số thuế gồm 10 chữ số')
    expect(einvoice.reload.buyer).to eq({})
  end

  it 'refuses a wrong, tampered or expired token' do
    get '/pos_einvoice/not-a-token'
    expect(response).to have_http_status(:not_found)
    expect(response.body).to include('không còn hiệu lực')

    get "/pos_einvoice/#{token.reverse}"
    expect(response).to have_http_status(:not_found)

    expires_at = einvoice.buyer_token_expires_at
    travel_to(expires_at + 1.minute) do
      get "/pos_einvoice/#{token}"
      expect(response).to have_http_status(:not_found)
      post "/pos_einvoice/#{token}", params: { buyer: { name: 'Anh Ba' } }
      expect(response).to have_http_status(:not_found)
    end
    expect(einvoice.reload.buyer).to eq({})
  end

  it 'points to the store once the invoice is issued' do
    current = token
    drain_outbox
    get "/pos_einvoice/#{current}"
    expect(response.body).to include('đã được phát hành', einvoice.reload.number)

    post "/pos_einvoice/#{current}", params: { buyer: { name: 'Anh Ba' } }
    expect(response).to have_http_status(:conflict)
    expect(einvoice.reload.buyer).to eq('label' => 'Bán cho người tiêu dùng')
  end

  it 'limits tries per client address' do
    current = token
    Spree::Pos::EinvoiceBuyerController::LIMIT_STORE.clear
    statuses = Array.new(Spree::Pos::EinvoiceBuyerController::ATTEMPTS + 1) do
      get "/pos_einvoice/#{current}"
      response.status
    end
    expect(statuses.last).to eq(429)
    expect(statuses.first(Spree::Pos::EinvoiceBuyerController::ATTEMPTS).uniq).to eq([200])
    Spree::Pos::EinvoiceBuyerController::LIMIT_STORE.clear
  end

  it 'prints the link as a QR on the receipt while it is open' do
    allow(Spree::Pos::Einvoices::BuyerLink).to receive(:base_url).and_return('https://pos.example.test')
    sale = completed_sale(store, branch)
    receipt = Spree::Pos::ReceiptSnapshot.find_by!(source_type: 'sale', source_id: sale.workspace.id).to_pos
    url = receipt.dig(:einvoice, :buyer_url)
    expect(url).to start_with('https://pos.example.test/pos_einvoice/')

    document = Spree::Pos::PrintDocuments.receipt(receipt: receipt.deep_stringify_keys, print: nil,
                                                  config: Spree::Pos::ReceiptTemplate.default_config('sale'))
    expect(document['footer'].last).to include('kind' => 'qr', 'value' => url)

    drain_outbox(at: 11.minutes.from_now)
    issued = Spree::Pos::ReceiptSnapshot.find_by!(source_type: 'sale', source_id: sale.workspace.id).to_pos
    expect(issued[:einvoice]).to include(status: 'issued', buyer_url: nil)
    expect(issued.dig(:einvoice, :lookup_code)).to be_present
  end
end
