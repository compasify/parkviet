# frozen_string_literal: true

require 'spree/api/testing_support/v3/base'
require_relative '../../../support/pos_shift_helpers'
require_relative '../../../support/pos_trace_helpers'

# The store's business details reach printed receipts two ways: copied into
# each receipt snapshot at issue time, and served in the POS context for
# documents printed before they are posted (pre-bill, payment ticket).
RSpec.describe 'POS store profile on receipts and context', type: :request do
  include PosShiftHelpers
  include PosTraceHelpers

  # 1x1 transparent PNG.
  let(:png) { Base64.decode64('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==') }
  let(:store) { create(:store, default_currency: 'VND', supported_currencies: 'VND') }
  let(:branch) { returns_branch(store) }
  let(:cashier) { credit_staff(store, branch, PosShiftHelpers::LEAD) }

  before { allow(Spree::Store).to receive(:default).and_return(store) }

  def token_for(user)
    @tokens ||= {}
    @tokens[user.id] ||= begin
      post '/api/v3/admin/auth/login', params: { email: user.email, password: 'secret123' }, as: :json
      response.parsed_body.fetch('token')
    end
  end

  def get_pos(user, path, params = {})
    get "/api/v3/admin/pos/#{path}", headers: { 'Authorization' => "Bearer #{token_for(user)}" }, params: params
    response.parsed_body
  end

  it 'copies the present store details and the branch return window into a new snapshot, and keeps them after edits' do
    store.update_columns(address: '12 Lê Lợi, Quận 1', contact_phone: '0901 234 567', customer_support_email: '',
                         url: 'https://parkviet.vn', facebook: nil, instagram: '  ')
    branch.update!(return_window_days: 7)
    sale = paid_sale(store, branch, cashier: cashier, price: 20_000)

    receipt = get_pos(cashier, 'receipts/lookup', { source_id: sale.workspace.prefixed_id })['data']
    expect(response).to have_http_status(:ok)
    expect(receipt['document']['store']).to eq(
      'name' => store.name, 'address' => '12 Lê Lợi, Quận 1', 'contact_phone' => '0901 234 567', 'url' => 'https://parkviet.vn'
    )
    expect(receipt['document']['branch']).to include('name' => branch.name, 'return_window_days' => 7)

    store.update_columns(address: 'Địa chỉ mới', contact_phone: '0999 999 999')
    again = get_pos(cashier, "receipts/#{receipt['id']}")['data']
    expect(again['document']['store']).to eq(receipt['document']['store'])
  end

  it 'leaves a store without details with only its name in the snapshot' do
    store.update_columns(address: nil, contact_phone: nil, customer_support_email: nil, url: nil, facebook: nil, instagram: nil)
    sale = paid_sale(store, branch, cashier: cashier, price: 20_000)

    receipt = get_pos(cashier, 'receipts/lookup', { source_id: sale.workspace.prefixed_id })['data']
    expect(receipt['document']['store']).to eq('name' => store.name)
  end

  it 'serves the store profile in the POS context with every field, null when blank' do
    store.update_columns(address: '12 Lê Lợi', contact_phone: '0901 234 567', customer_support_email: 'cskh@parkviet.vn',
                         url: nil, facebook: 'https://facebook.com/parkviet', instagram: '')

    context = get_pos(cashier, 'context')
    expect(response).to have_http_status(:ok)
    expect(context['store']['profile']).to eq(
      'address' => '12 Lê Lợi', 'contact_phone' => '0901 234 567', 'customer_support_email' => 'cskh@parkviet.vn',
      'url' => nil, 'facebook' => 'https://facebook.com/parkviet', 'instagram' => nil, 'logo_url' => nil
    )
  end

  it 'serves the public URL of an attached store logo in the context' do
    store.logo.attach(io: StringIO.new(png), filename: 'logo.png', content_type: 'image/png')

    context = get_pos(cashier, 'context')
    expect(response).to have_http_status(:ok)
    expect(context['store']['profile']['logo_url']).to be_present
    expect(context['store']['profile']['logo_url']).to eq(Rails.application.routes.url_helpers.cdn_image_url(store.logo))
  end
end
