# frozen_string_literal: true

require 'spree/api/testing_support/v3/base'
require_relative '../../../support/pos_credit_helpers'

# HTTP contract for credit accounts, credit approvals, credit completion,
# receivables and collections, including who may read or write them.
RSpec.describe 'POS credit and receivables API', type: :request do
  include PosCreditHelpers

  let(:store) { create(:store, default_currency: 'VND', supported_currencies: 'VND') }
  let(:branch) { credit_branch(store) }
  # Approval revocation lives under the topology-scoped approvals endpoint.
  let(:manager) do
    credit_staff(store, branch, PosCreditHelpers::MANAGER + [Spree::Pos::Capabilities::CREDIT_SELL], extra_permissions: %w[write_pos_topology])
  end
  let(:profile) { credit_customer(store, manager) }

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

  def configure(user, branch_for = branch, **attrs)
    call(user, :post, 'credit_accounts', { branch_id: branch_for.prefixed_id, customer_id: profile.prefixed_id,
                                           credit_limit: '1000000', due_days: 15 }.merge(attrs))
  end

  def complete_body(sale, approval_id)
    workspace = sale.workspace.reload
    { expected_revision: workspace.revision, lease_generation: workspace.lease_generation, editor_id: sale.editor_id,
      credit_approval_id: approval_id }
  end

  def credit_order(sale, paid: 0)
    take_tender(sale, 'cash', paid) if paid.positive?
    workspace = sale.workspace.reload
    approval = call(manager, :post, "workspaces/#{workspace.prefixed_id}/credit_approvals",
                    { requester_id: sale.cashier.prefixed_id, amount: (workspace.order.total - paid).to_i.to_s, revision: workspace.revision })
    expect(response).to have_http_status(:created)
    call(sale.cashier, :post, "workspaces/#{workspace.prefixed_id}/complete", complete_body(sale, approval.dig('data', 'approval_id')))
    expect(response).to have_http_status(:ok)
    workspace.order.reload
  end

  it 'lets only a credit manager of the requested branch configure an account' do
    cashier = credit_staff(store, branch, PosCreditHelpers::CASHIER)
    configure(cashier)
    expect(response).to have_http_status(:forbidden)

    elsewhere = credit_branch(store)
    configure(manager, elsewhere)
    expect(response).to have_http_status(:not_found).or have_http_status(:forbidden)

    data = configure(manager)['data']
    expect(response).to have_http_status(:created)
    expect(data).to include('credit_limit' => '1000000.0', 'due_days' => 15, 'status' => 'active', 'available' => '1000000.0')
    configure(manager)
    expect(response).to have_http_status(:conflict)

    call(manager, :patch, "credit_accounts/#{data['id']}", { branch_id: branch.prefixed_id, status: 'suspended' })
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.dig('data', 'status')).to eq('suspended')
    expect(Spree::Pos::AuditEntry.where(action: 'credit.configure').count).to eq(2)
  end

  it 'approves, shows and completes a credit sale; a cashier without the credit grant cannot use it' do
    configure(manager)
    sale = credit_sale(store, branch, price: 500_000, cashier: credit_staff(store, branch, [Spree::Pos::Capabilities::OPEN_SHIFT, Spree::Pos::Capabilities::PAYMENT]))
    assign(sale, profile)
    take_tender(sale, 'cash', 200_000)
    take_tender(sale, 'bank_manual', 200_000)
    workspace = sale.workspace.reload
    approve = { requester_id: sale.cashier.prefixed_id, amount: '100000', revision: workspace.revision }

    call(manager, :post, "workspaces/#{workspace.prefixed_id}/credit_approvals", approve)
    expect(response).to have_http_status(:forbidden)

    Spree::Pos::StaffMembership.find_by!(staff: sale.cashier).update!(capabilities: PosCreditHelpers::CASHIER)
    call(sale.cashier, :post, "workspaces/#{workspace.prefixed_id}/credit_approvals", approve)
    expect(response).to have_http_status(:not_found)
    approval = call(manager, :post, "workspaces/#{workspace.prefixed_id}/credit_approvals", approve)['data']
    expect(response).to have_http_status(:created)

    status = call(sale.cashier, :get, "workspaces/#{workspace.prefixed_id}/credit")['data']
    expect(status).to include('can_sell' => true)
    expect(status['account']).to include('available' => '900000.0', 'reserved' => '100000.0')
    expect(status['reservation']).to include('amount' => '100000.0', 'usable' => true, 'approval_id' => approval['approval_id'])

    call(sale.cashier, :post, "approvals", { branch_id: branch.prefixed_id, requester_id: sale.cashier.prefixed_id,
                                             workspace_id: workspace.prefixed_id, revision: workspace.revision,
                                             action_name: 'credit.sale', amount: '100000', expires_at: 10.minutes.from_now.iso8601 })
    expect(response.status).to be_in([403, 409])

    Spree::Pos::StaffMembership.find_by!(staff: sale.cashier).update!(capabilities: [Spree::Pos::Capabilities::OPEN_SHIFT, Spree::Pos::Capabilities::PAYMENT])
    call(sale.cashier, :post, "workspaces/#{workspace.prefixed_id}/complete", complete_body(sale, approval['approval_id']))
    expect(response).to have_http_status(:forbidden)

    Spree::Pos::StaffMembership.find_by!(staff: sale.cashier).update!(capabilities: PosCreditHelpers::CASHIER)
    data = call(sale.cashier, :post, "workspaces/#{workspace.prefixed_id}/complete", complete_body(sale, approval['approval_id']))['data']
    expect(response).to have_http_status(:ok)
    expect(data['financial']['credit']).to include('debt' => '100000.0', 'balance' => '100000.0')
    order = workspace.order.reload
    expect(order.payments.where(status: 'completed').sum(:amount)).to eq(BigDecimal('400000'))
    expect(order.payment_status).to eq('partially_paid')
  end

  it 'revoking a credit approval returns its exposure' do
    account_id = configure(manager, credit_limit: '100000')['data']['id']
    sale = credit_sale(store, branch, price: 100_000)
    assign(sale, profile)
    workspace = sale.workspace.reload
    approval = call(manager, :post, "workspaces/#{workspace.prefixed_id}/credit_approvals",
                    { requester_id: sale.cashier.prefixed_id, amount: '100000', revision: workspace.revision })['data']
    expect(Spree::Pos::CreditAccount.find_by_prefix_id!(account_id).exposure.available).to eq(0)

    call(manager, :post, "approvals/#{approval['approval_id']}/revoke")
    expect(response).to have_http_status(:ok)
    expect(Spree::Pos::CreditAccount.find_by_prefix_id!(account_id).exposure.available).to eq(BigDecimal('100000'))
    expect(Spree::Pos::CreditReservation.sole.released_reason).to eq('approval_revoked')
  end

  it 'lists receivables only to branch members, masks contacts for readers who cannot collect, and filters server-side' do
    configure(manager)
    order = credit_order(credit_sale(store, branch, price: 300_000).tap { |sale| assign(sale, profile) })

    rows = call(manager, :get, 'receivables', { branch_id: branch.prefixed_id })
    expect(response).to have_http_status(:ok)
    expect(rows['data'].sole).to include('order_id' => order.prefixed_id, 'balance' => '300000.0', 'debt' => '300000.0',
                                         'paid_at_sale' => '0.0', 'overdue' => false, 'aging' => 'current')
    expect(rows['data'].sole['customer']['phone']).to eq(profile.phone)

    reader = credit_staff(store, branch, [Spree::Pos::Capabilities::OPEN_SHIFT])
    masked = call(reader, :get, 'receivables', { branch_id: branch.prefixed_id })['data'].sole
    expect(masked['customer']['phone']).to end_with(profile.phone[-3..])
    expect(masked['customer']['phone']).not_to eq(profile.phone)

    call(reader, :get, 'receivables', { branch_id: branch.prefixed_id, status: 'overdue' })
    expect(response.parsed_body['data']).to eq([])
    call(reader, :get, 'receivables', { branch_id: branch.prefixed_id, status: 'bogus' })
    expect(response).to have_http_status(:conflict)

    customers = call(manager, :get, 'receivables/customers', { branch_id: branch.prefixed_id })
    expect(customers['data'].sole).to include('balance' => '300000.0', 'overdue' => '0.0', 'orders' => 1)

    other_branch = credit_branch(store)
    outsider = credit_staff(store, other_branch, PosCreditHelpers::MANAGER)
    call(outsider, :get, 'receivables', { branch_id: branch.prefixed_id })
    expect(response).to have_http_status(:forbidden)
    call(outsider, :get, 'receivables', { branch_id: other_branch.prefixed_id })
    expect(response.parsed_body['data']).to eq([])
  end

  it 'collects, allocates the remainder and reverses only with the resolve grant' do
    account_id = configure(manager)['data']['id']
    first = credit_order(credit_sale(store, branch, price: 300_000).tap { |sale| assign(sale, profile) })
    second = credit_order(credit_sale(store, branch, price: 200_000).tap { |sale| assign(sale, profile) })
    collector = credit_staff(store, branch, PosCreditHelpers::CASHIER)
    body = { branch_id: branch.prefixed_id, credit_account_id: account_id, kind: 'cash', amount: '350000',
             handed_amount: '400000', allocations: [{ order_id: first.prefixed_id, amount: '300000' }] }

    call(collector, :post, 'collections', body)
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('shift_required')

    open_drawer(store, branch, collector)
    collection = call(collector, :post, 'collections', body)['data']
    expect(response).to have_http_status(:created)
    expect(collection['funds']).to include('received_net' => '350000.0', 'change_amount' => '50000.0', 'available' => '50000.0')

    data = call(collector, :post, "collections/#{collection['id']}/allocations",
                { allocations: [{ order_id: second.prefixed_id, amount: '50000' }] })['data']
    expect(response).to have_http_status(:created)
    expect(data['funds']['available']).to eq('0.0')
    expect(data['allocations'].length).to eq(2)

    child = data['allocations'].find { |row| row['order_id'] == second.prefixed_id }
    call(collector, :post, "collections/#{collection['id']}/allocations/#{child['id']}/reverse", { reason: 'Nhầm đơn' })
    expect(response).to have_http_status(:forbidden)
    data = call(manager, :post, "collections/#{collection['id']}/allocations/#{child['id']}/reverse", { reason: 'Nhầm đơn' })['data']
    expect(response).to have_http_status(:ok)
    expect(data['funds']['available']).to eq('50000.0')

    rows = call(collector, :get, 'receivables', { branch_id: branch.prefixed_id, status: 'all' })['data']
    expect(rows.map { |row| [row['order_id'], row['balance']] }).to contain_exactly([first.prefixed_id, '0.0'], [second.prefixed_id, '200000.0'])

    other = credit_staff(store, credit_branch(store), PosCreditHelpers::MANAGER)
    call(other, :get, "collections/#{collection['id']}")
    expect(response).to have_http_status(:forbidden)
  end

  it 'lists accounts only to credit managers of their home branch and lets cashiers look up one customer' do
    account = configure(manager)['data']
    elsewhere = credit_branch(store)
    remote_manager = credit_staff(store, elsewhere, PosCreditHelpers::MANAGER)
    cashier = credit_staff(store, branch, PosCreditHelpers::CASHIER)

    expect(call(manager, :get, 'credit_accounts', { branch_id: branch.prefixed_id })['data'].map { |row| row['id'] }).to eq([account['id']])
    expect(call(remote_manager, :get, 'credit_accounts', { branch_id: elsewhere.prefixed_id })['data']).to eq([])
    call(remote_manager, :patch, "credit_accounts/#{account['id']}", { branch_id: elsewhere.prefixed_id, credit_limit: '5' })
    expect(response).to have_http_status(:forbidden)

    call(cashier, :get, 'credit_accounts', { branch_id: branch.prefixed_id })
    expect(response).to have_http_status(:forbidden)
    found = call(cashier, :get, 'credit_accounts', { branch_id: branch.prefixed_id, customer_id: profile.prefixed_id })['data']
    expect(found.sole).to include('id' => account['id'], 'branch_id' => branch.prefixed_id)
  end

  it 'lets masked readers search receivables by name or full phone, never by phone fragments' do
    configure(manager)
    credit_order(credit_sale(store, branch, price: 100_000).tap { |sale| assign(sale, profile) })
    reader = credit_staff(store, branch, [Spree::Pos::Capabilities::OPEN_SHIFT])
    search = ->(user, q) { call(user, :get, 'receivables', { branch_id: branch.prefixed_id, q: q })['data'] }

    expect(search.call(reader, profile.phone[-4..])).to eq([])
    expect(search.call(reader, profile.name.split.last).size).to eq(1)
    expect(search.call(reader, profile.phone).size).to eq(1)
    expect(search.call(manager, profile.phone[-4..]).size).to eq(1)
  end

  it 'runs the credit request from cashier to approver and back, with revoke' do
    configure(manager)
    sale = credit_sale(store, branch, price: 150_000)
    assign(sale, profile)
    workspace = sale.workspace.reload
    body = { expected_revision: workspace.revision, lease_generation: workspace.lease_generation, editor_id: sale.editor_id }

    requested = call(sale.cashier, :post, "workspaces/#{workspace.prefixed_id}/credit_requests", body)['data']
    expect(response).to have_http_status(:created)
    expect(requested).to include('status' => 'pending', 'amount' => '150000.0', 'order_number' => workspace.order.number)

    call(sale.cashier, :get, 'credit_requests', { branch_id: branch.prefixed_id })
    expect(response).to have_http_status(:forbidden)
    listed = call(manager, :get, 'credit_requests', { branch_id: branch.prefixed_id })['data']
    expect(listed.sole).to include('id' => requested['id'], 'requester' => include('id' => sale.cashier.prefixed_id))

    approved = call(manager, :post, "credit_requests/#{requested['id']}/approve")['data']
    expect(response).to have_http_status(:ok)
    expect(approved).to include('status' => 'approved', 'approval_active' => true)
    status = call(sale.cashier, :get, "workspaces/#{workspace.prefixed_id}/credit")['data']
    expect(status['request']).to include('status' => 'approved')
    expect(status['reservation']).to include('usable' => true)

    call(manager, :post, "credit_requests/#{requested['id']}/revoke")
    expect(response).to have_http_status(:ok)
    expect(call(sale.cashier, :get, "workspaces/#{workspace.prefixed_id}/credit")['data']['reservation']).to be_nil
    expect(call(manager, :get, 'credit_requests', { branch_id: branch.prefixed_id })['data']).to eq([])
  end

  it 'refuses a tender confirm that reuses a recorded bank reference unless a resolver confirms it' do
    sale = credit_sale(store, branch, price: 200_000)
    take_tender(sale, 'bank_manual', 100_000)
    used = Spree::Pos::ReceivedFunds.sole
    method = Spree::Pos::PaymentMethodResolver.new(store: store).available.find { |row| row.kind == 'bank_manual' }
    Spree::Pos::Tenders::Prepare.call(**editing_args(sale), payment_method_id: method.prefixed_id || 'posmethod-bank_manual', amount: '100000')
    attempt = Spree::Pos::TenderAttempt.where(status: 'prepared').sole
    evidence = { evidence_kind: 'bank_manual', reference: used.reference, receiving_account: used.receiving_account }

    expect do
      Spree::Pos::Tenders::Confirm.call(**editing_args(sale), attempt_id: attempt.prefixed_id, **evidence, confirm_duplicate: true)
    end.to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('duplicate_reference') }
    Spree::Pos::StaffMembership.find_by!(staff: sale.cashier).update!(capabilities: PosCreditHelpers::CASHIER + [Spree::Pos::Capabilities::RESOLVE])
    Spree::Pos::Tenders::Confirm.call(**editing_args(sale), attempt_id: attempt.prefixed_id, **evidence, confirm_duplicate: true)
    expect(Spree::Pos::ReceivedFunds.count).to eq(2)
    expect(Spree::Pos::AuditEntry.where(action: 'funds.duplicate_reference_confirmed').count).to eq(1)
  end

  it 'gives a cashier no direct core path to pay, capture or complete a credit order' do
    configure(manager)
    sale = credit_sale(store, branch, price: 100_000)
    assign(sale, profile)
    order = sale.workspace.order
    headers = { 'Authorization' => "Bearer #{token_for(sale.cashier)}" }

    post "/api/v3/admin/orders/#{order.prefixed_id}/payments", headers: headers, params: { amount: '100000' }, as: :json
    expect(response).to have_http_status(:forbidden)
    patch "/api/v3/admin/orders/#{order.prefixed_id}/complete", headers: headers, as: :json
    expect(response).to have_http_status(:forbidden)
    call(sale.cashier, :post, "workspaces/#{sale.workspace.prefixed_id}/complete", complete_body(sale, 'posapproval_missing'))
    expect(response).to have_http_status(:conflict)
    expect(order.reload).not_to be_placed
    expect(order.payments).to be_empty
  end
end
