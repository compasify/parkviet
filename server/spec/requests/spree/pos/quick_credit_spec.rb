# frozen_string_literal: true

require 'spree/api/testing_support/v3/base'
require_relative '../../../support/pos_credit_helpers'

# Quick credit: with `quick_credit` on, the selling cashier approves the
# unpaid remainder themselves (no second person) and completes on credit.
RSpec.describe 'POS quick credit API', type: :request do
  include PosCreditHelpers

  let(:store) { create(:store, default_currency: 'VND', supported_currencies: 'VND') }
  let(:branch) { credit_branch(store) }
  let(:cashier) { credit_staff(store, branch, PosCreditHelpers::CASHIER) }
  let(:profile) { credit_customer(store, cashier) }

  before { allow(Spree::Store).to receive(:default).and_return(store) }

  def token_for(user)
    @tokens ||= {}
    @tokens[user.id] ||= begin
      post '/api/v3/admin/auth/login', params: { email: user.email, password: 'secret123' }, as: :json
      response.parsed_body.fetch('token')
    end
  end

  def call(user, path, body = {}, key: SecureRandom.uuid)
    post "/api/v3/admin/pos/#{path}", headers: { 'Authorization' => "Bearer #{token_for(user)}", 'Idempotency-Key' => key },
                                      params: body.merge(idempotency_key: key), as: :json
    response.parsed_body
  end

  def editing_body(sale)
    workspace = sale.workspace.reload
    { expected_revision: workspace.revision, lease_generation: workspace.lease_generation, editor_id: sale.editor_id }
  end

  def quick_credit(sale, key: SecureRandom.uuid)
    call(sale.cashier, "workspaces/#{sale.workspace.prefixed_id}/quick_credit", editing_body(sale), key: key)
  end

  def complete(sale, approval_id)
    call(sale.cashier, "workspaces/#{sale.workspace.prefixed_id}/complete", editing_body(sale).merge(credit_approval_id: approval_id))
  end

  def quick_sale(price)
    sale = credit_sale(store, branch, price: price, cashier: cashier)
    assign(sale, profile)
    sale
  end

  it 'opens an account with the default terms, self-approves and completes the sale on credit' do
    sale = quick_sale(150_000)
    take_tender(sale, 'cash', 50_000)

    reservation = quick_credit(sale)['data']
    expect(response).to have_http_status(:created)
    expect(reservation).to include('amount' => '100000.0', 'usable' => true)
    expect(reservation.dig('approver', 'id')).to eq(cashier.prefixed_id)

    account = Spree::Pos::CreditAccount.find_by!(customer_profile: profile)
    expect(account.credit_limit).to eq(Spree::Pos::Credit::QuickApprove::DEFAULT_LIMIT)
    expect(account.due_days).to eq(Spree::Pos::Credit::QuickApprove::DEFAULT_DUE_DAYS)
    expect(account.branch).to eq(branch)

    data = complete(sale, reservation['approval_id'])['data']
    expect(response).to have_http_status(:ok), response.body
    expect(data['financial']['credit']).to include('debt' => '100000.0')
    order = sale.workspace.reload.order
    expect(order).to be_placed
    expect(receivable_balance(order)).to eq(BigDecimal('100000'))
    expect(account.reload.exposure.open_debt).to eq(BigDecimal('100000'))
    expect(Spree::Pos::AuditEntry.where(action: %w[credit.configure credit.quick_approve workspace.complete_on_credit]).
      pluck(:action)).to contain_exactly('credit.configure', 'credit.quick_approve', 'workspace.complete_on_credit')
  end

  it 'replays the same key without a second reservation and reuses an existing account' do
    account = configure_credit(store, credit_staff(store, branch, PosCreditHelpers::MANAGER), branch, profile, limit: 500_000)
    sale = quick_sale(200_000)
    key = SecureRandom.uuid

    first = quick_credit(sale, key: key)['data']
    expect(response).to have_http_status(:created)
    second = quick_credit(sale, key: key)['data']
    expect(response.status).to be_in([200, 201])
    expect(second['id']).to eq(first['id'])
    expect(Spree::Pos::CreditReservation.count).to eq(1)
    expect(Spree::Pos::CreditAccount.sole).to eq(account)
    expect(account.reload.exposure.available).to eq(BigDecimal('300000'))
  end

  it 'refuses an amount over the credit limit with credit_limit_exceeded' do
    account = configure_credit(store, credit_staff(store, branch, PosCreditHelpers::MANAGER), branch, profile, limit: 100_000)
    sale = quick_sale(150_000)

    quick_credit(sale)
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('credit_limit_exceeded')
    expect(Spree::Pos::CreditReservation.count).to eq(0)
    expect(account.reload.exposure.open_debt).to eq(0)
  end

  it 'is refused while quick_credit is off; a second person must still approve' do
    sale = quick_sale(100_000)
    Spree::Pos::FeatureFlag.where(store: store, branch_id: nil, feature: 'quick_credit').update_all(enabled: false)

    quick_credit(sale)
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('feature_disabled')
    expect(Spree::Pos::CreditAccount.count).to eq(0)

    # The cashier still cannot approve their own sale through the regular path.
    expect do
      Spree::Pos::Credit::Approve.call(workspace: sale.workspace.reload, staff: cashier, key: SecureRandom.uuid,
                                       requester_id: cashier.prefixed_id, amount: '100000', revision: sale.workspace.revision)
    end.to raise_error(CanCan::AccessDenied)
  end

  it 'turning quick_credit off invalidates a self-approval before completion' do
    sale = quick_sale(100_000)
    reservation = quick_credit(sale)['data']
    Spree::Pos::FeatureFlag.where(store: store, branch_id: nil, feature: 'quick_credit').update_all(enabled: false)

    complete(sale, reservation['approval_id'])
    expect(response).to have_http_status(:conflict)
    expect(sale.workspace.reload.order).not_to be_placed
  end

  it 'forbids a cashier without the credit-sell grant' do
    seller = credit_staff(store, branch, [Spree::Pos::Capabilities::OPEN_SHIFT, Spree::Pos::Capabilities::PAYMENT])
    sale = credit_sale(store, branch, price: 100_000, cashier: seller)
    assign(sale, profile)

    quick_credit(sale)
    expect(response).to have_http_status(:forbidden)
    expect(Spree::Pos::CreditAccount.count).to eq(0)
  end

  it 'still keeps a self-approval out of the general approval rules' do
    approval = Spree::Pos::Approval.new(store: store, branch: branch, approver: cashier, requester: cashier,
                                        subject_type: 'Spree::Pos::Workspace', subject_id: 1, action: Spree::Pos::Credit::ACTION,
                                        revision: '0', expires_at: 5.minutes.from_now)
    expect(approval).not_to be_valid
    approval.self_credit = true
    expect(approval).to be_valid
  end
end
