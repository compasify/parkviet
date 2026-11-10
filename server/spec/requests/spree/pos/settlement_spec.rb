# frozen_string_literal: true

require 'spree/api/testing_support/v3/base'
require_relative '../../../support/pos_trace_helpers'

module PosSettlementSpec
  CAPS = [Spree::Pos::Capabilities::OPEN_SHIFT, Spree::Pos::Capabilities::PAYMENT,
          Spree::Pos::Capabilities::RESOLVE, Spree::Pos::Capabilities::APPROVE, Spree::Pos::Capabilities::MANAGE].freeze

  Setup = Struct.new(:user, :branch, :workspace, :product, :token, keyword_init: true)
end

# Sandbox settlement gates: split tender with cash change, receipts that never
# double, conservation of received funds across allocation and payouts,
# drawer custody, tracked-SKU guard and guarded completion.
RSpec.describe 'POS split tender and settlement', type: :request, modules_off_rerun: true do
  include ActiveSupport::Testing::TimeHelpers
  include PosTraceHelpers

  let(:store) { create(:store, default_currency: 'VND', supported_currencies: 'VND') }
  let(:password) { 'secret123' }
  let(:editor_id) { SecureRandom.uuid }

  before { allow(Spree::Store).to receive(:default).and_return(store) }

  def workspace_command(ctx, path, revision, **attrs)
    key = SecureRandom.uuid
    post "/api/v3/admin/pos/workspaces/#{ctx.workspace.prefixed_id}/#{path}", headers: headers(ctx.token, key),
                                                                              params: editing(ctx.workspace, revision, key).merge(attrs), as: :json
  end

  def login(user)
    post '/api/v3/admin/auth/login', params: { email: user.email, password: password }, as: :json
    response.parsed_body.fetch('token')
  end

  def staff_user(branch, capabilities)
    user = create(:admin_user, :without_admin_role, password: password)
    role = create(:role, resource: store, permissions: %w[write_pos_orders write_pos_workspaces write_pos_shifts write_pos_topology])
    create(:role_user, user: user, role: role)
    Spree::Pos::StaffMembership.create!(store: store, branch: branch, staff: user, capabilities: capabilities, status: 'active')
    user
  end

  def open_shift(token, branch)
    register = Spree::Pos::Register.create!(store: store, branch: branch, name: 'R', code: "r#{SecureRandom.hex(4)}", status: 'active')
    post '/api/v3/admin/pos/shifts', headers: { 'Authorization' => "Bearer #{token}" },
                                     params: { register_id: register.prefixed_id, opening_float: '0' }, as: :json
    expect(response).to have_http_status(:created)
    register
  end

  def setup_workspace(price: 250, capabilities: PosSettlementSpec::CAPS, register: true, manual_method: true)
    location = create(:stock_location, store: store, backorderable_default: false)
    suffix = SecureRandom.hex(4)
    branch = Spree::Pos::Branch.create!(store: store, stock_location: location, name: "B#{suffix}", code: "b#{suffix}",
                                        timezone: 'Asia/Ho_Chi_Minh', status: 'active')
    user = staff_user(branch, capabilities)
    if manual_method
      create(:check_payment_method, store: store, name: "Bank transfer #{suffix}", active: true)
    else
      create(:credit_card_payment_method, store: store, active: true)
    end
    token = login(user)
    if register
      register_row = open_shift(token, branch)
      created = Spree::Pos::Workspaces::Create.call(store: store, staff: user, register_id: register_row.prefixed_id,
                                                    key: SecureRandom.uuid, editor_id: editor_id)
    else
      post '/api/v3/admin/pos/shifts', headers: { 'Authorization' => "Bearer #{token}" },
                                       params: { branch_id: branch.prefixed_id, opening_float: '0' }, as: :json
      expect(response).to have_http_status(:created)
      created = Spree::Pos::Workspaces::Create.call(store: store, staff: user, branch_id: branch.prefixed_id,
                                                    key: SecureRandom.uuid, editor_id: editor_id)
    end
    workspace = Spree::Pos::Workspace.find_by_prefix_id!(created['id'])
    product = create(:product, store: store, status: 'active', name: 'Ao')
    product.default_variant.set_price('VND', price)
    Spree::Pos::BranchProduct.create!(branch: branch, product: product)
    location.restock(product.default_variant, 10)
    PosSettlementSpec::Setup.new(user: user, branch: branch, workspace: workspace, product: product, token: token)
  end

  def headers(token, key = SecureRandom.uuid)
    { 'Authorization' => "Bearer #{token}", 'Idempotency-Key' => key }
  end

  def editing(workspace, revision, key)
    { expected_revision: revision, lease_generation: workspace.lease_generation, editor_id: editor_id, idempotency_key: key }
  end

  def add_item(ctx, revision)
    key = SecureRandom.uuid
    body = editing(ctx.workspace, revision, key).merge(variant_id: ctx.product.default_variant.prefixed_id, quantity: 1, merge: true)
    post "/api/v3/admin/pos/workspaces/#{ctx.workspace.prefixed_id}/items", headers: headers(ctx.token, key), params: body, as: :json
    response.parsed_body['data']
  end

  def method_id(ctx, kind)
    get "/api/v3/admin/pos/workspaces/#{ctx.workspace.prefixed_id}/payment_methods", headers: headers(ctx.token), as: :json
    expect(response).to have_http_status(:ok)
    response.parsed_body.fetch('data').find { |row| row['kind'] == kind }&.fetch('id')
  end

  def prepare(ctx, revision, kind, amount)
    key = SecureRandom.uuid
    body = editing(ctx.workspace, revision, key).merge(payment_method_id: method_id(ctx, kind), amount: amount.to_s)
    post "/api/v3/admin/pos/workspaces/#{ctx.workspace.prefixed_id}/tender_attempts", headers: headers(ctx.token, key), params: body, as: :json
    response.parsed_body['data']
  end

  def last_attempt(ctx)
    get "/api/v3/admin/pos/workspaces/#{ctx.workspace.prefixed_id}", headers: headers(ctx.token), as: :json
    response.parsed_body.dig('data', 'financial', 'attempts').last
  end

  def confirm(ctx, revision, attempt_id, key: SecureRandom.uuid, **attrs)
    body = editing(ctx.workspace, revision, key).merge(attrs)
    post "/api/v3/admin/pos/workspaces/#{ctx.workspace.prefixed_id}/tender_attempts/#{attempt_id}/confirm",
         headers: headers(ctx.token, key), params: body, as: :json
    response.parsed_body['data']
  end

  def complete(ctx, revision, key: SecureRandom.uuid)
    post "/api/v3/admin/pos/workspaces/#{ctx.workspace.prefixed_id}/complete", headers: headers(ctx.token, key),
                                                                               params: editing(ctx.workspace, revision, key), as: :json
  end

  def record_funds(token, key: SecureRandom.uuid, **attrs)
    post '/api/v3/admin/pos/received_funds', headers: headers(token, key), params: attrs.merge(idempotency_key: key), as: :json
    response.parsed_body['data']
  end

  def payout(token, funds_id, action = nil, payout_id = nil, **attrs)
    key = SecureRandom.uuid
    path = "/api/v3/admin/pos/received_funds/#{funds_id}/payouts"
    path += "/#{payout_id}/#{action}" if action
    post path, headers: headers(token, key), params: attrs.merge(idempotency_key: key), as: :json
    response.parsed_body['data']
  end

  def funds_state(token, funds_id)
    get "/api/v3/admin/pos/received_funds/#{funds_id}", headers: headers(token), as: :json
    response.parsed_body['data']
  end

  def conflict_message
    response.parsed_body.dig('error', 'message') || response.parsed_body['error'] || response.parsed_body.to_s
  end

  def bank_evidence(reference = 'FT001')
    { evidence_kind: 'bank_manual', reference: reference, receiving_account: 'VCB-123' }
  end

  it 'applies only the cash remainder after a bank part, nets the change in the drawer and never doubles a confirm' do
    ctx = setup_workspace(price: 250)
    add_item(ctx, 0)

    prepare(ctx, 1, 'bank_manual', 100)
    expect(response).to have_http_status(:ok)
    confirm(ctx, 2, last_attempt(ctx)['id'], **bank_evidence)
    expect(response).to have_http_status(:ok)

    prepare(ctx, 3, 'cash', 150)
    attempt_id = last_attempt(ctx)['id']
    key = SecureRandom.uuid
    data = confirm(ctx, 4, attempt_id, key: key, evidence_kind: 'cash_count', handed_amount: '200')
    expect(response).to have_http_status(:ok)
    expect(data['financial']).to include('received' => '250.0', 'allocated' => '250.0', 'change_due' => '50.0', 'remaining' => '0.0')

    order = ctx.workspace.reload.order
    expect(order.payments.completed.sum(:amount)).to eq(BigDecimal('250'))
    expect(order.payments.completed.count).to eq(2)
    expect(Spree::Pos::CashMovement.where(shift: ctx.workspace.shift, kind: 'receipt').sum(:amount)).to eq(BigDecimal('150'))

    # A lost response is retried with the same key and payload: the stored
    # result comes back and nothing is recorded twice.
    replay = confirm(ctx, 4, attempt_id, key: key, evidence_kind: 'cash_count', handed_amount: '200')
    expect(response).to have_http_status(:ok)
    expect(replay['revision']).to eq(data['revision'])

    # A second confirm under a new key finds the attempt already confirmed.
    confirm(ctx, 5, attempt_id, evidence_kind: 'cash_count', handed_amount: '200')
    expect(response).to have_http_status(:conflict)
    expect(order.reload.payments.completed.count).to eq(2)
    expect(Spree::Pos::ReceivedFunds.where(workspace: ctx.workspace).count).to eq(2)
  end

  it 'recovers prepared split payments after channel shutdown without repricing or relabeling the quote' do
    ctx = setup_workspace(price: 250)
    add_item(ctx, 0)
    prepare(ctx, 1, 'bank_manual', 100)
    expect(response).to have_http_status(:ok)
    attempt_id = last_attempt(ctx)['id']
    channel = ctx.workspace.order.channel
    channel.update!(active: false)
    Spree::ProductPublication.where(channel: channel, product: ctx.product).destroy_all
    ctx.product.default_variant.set_price('VND', 999)
    confirm(ctx, 2, attempt_id, **bank_evidence('CHANNEL-OFF'))
    expect(response).to have_http_status(:ok)
    prepare(ctx, 3, 'cash', 150)
    expect(response).to have_http_status(:ok)
    confirm(ctx, 4, last_attempt(ctx)['id'], evidence_kind: 'cash_count', handed_amount: '150')
    expect(response).to have_http_status(:ok)
    complete(ctx, 5)
    expect(response).to have_http_status(:ok)
    expect(ctx.workspace.reload).to have_attributes(operational_status: 'completed')
    expect(ctx.workspace.order.reload).to have_attributes(channel_id: channel.id, total: BigDecimal('250'))
    expect(ctx.workspace.to_pos[:line_items].sole[:list_price]).to eq('250.0')
  end

  it 'rechecks channel readiness after the only prepared tender is canceled' do
    ctx = setup_workspace(price: 100)
    add_item(ctx, 0)
    prepare(ctx, 1, 'cash', 100)
    expect(response).to have_http_status(:ok)
    attempt_id = last_attempt(ctx)['id']
    ctx.workspace.order.channel.update!(active: false)
    workspace_command(ctx, "tender_attempts/#{attempt_id}/cancel", 2)
    expect(response).to have_http_status(:ok)
    expect(ctx.workspace.reload.snapshot_locked?).to be(false)
    prepare(ctx, 3, 'cash', 100)
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('pos_channel_inactive')
    expect(Spree::Pos::ReceivedFunds.where(workspace: ctx.workspace)).to be_empty
  end

  it 'rejects unrelated money on a new sale while allowing late money for its original sale after shutdown' do
    ctx = setup_workspace(price: 100)
    add_item(ctx, 0)
    base = { branch_id: ctx.branch.prefixed_id, shift_id: ctx.workspace.shift.prefixed_id,
             kind: 'bank_manual', handed_amount: '100', receiving_account: 'VCB-123' }
    unrelated = record_funds(ctx.token, **base, reference: 'CHANNEL-UNRELATED')
    expect(response).to have_http_status(:created)
    late = record_funds(ctx.token, **base, workspace_id: ctx.workspace.prefixed_id, reference: 'CHANNEL-LATE')
    expect(response).to have_http_status(:created)
    ctx.workspace.order.channel.update!(active: false)
    workspace_command(ctx, 'funds/allocate', 1, funds_id: unrelated['id'], amount: '100')
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('pos_channel_inactive')
    expect(ctx.workspace.order.reload.payments).to be_empty
    workspace_command(ctx, 'funds/allocate', 1, funds_id: late['id'], amount: '100')
    expect(response).to have_http_status(:ok)
    complete(ctx, 2)
    expect(response).to have_http_status(:ok)
    expect(ctx.workspace.reload.operational_status).to eq('completed')
    expect(funds_state(ctx.token, unrelated['id'])['available']).to eq('100.0')
  end

  it 'refuses short, fractional and malformed cash without recording money' do
    ctx = setup_workspace(price: 250)
    add_item(ctx, 0)

    prepare(ctx, 1, 'cash', '99.5')
    expect(response).to have_http_status(:conflict)
    prepare(ctx, 1, 'cash', 250)
    expect(response).to have_http_status(:ok)
    attempt_id = last_attempt(ctx)['id']

    confirm(ctx, 2, attempt_id, evidence_kind: 'cash_count', handed_amount: '200')
    expect(response).to have_http_status(:conflict)
    expect(conflict_message).to include('less than the tender amount')
    confirm(ctx, 2, attempt_id, evidence_kind: 'cash_count', handed_amount: '250.5')
    expect(response).to have_http_status(:conflict)
    confirm(ctx, 2, attempt_id, evidence_kind: 'cash_count', handed_amount: '200.000,5')
    expect(response).to have_http_status(:conflict)
    expect(Spree::Pos::ReceivedFunds.where(workspace: ctx.workspace)).to be_empty
    expect(ctx.workspace.order.reload.payments).to be_empty

    data = confirm(ctx, 2, attempt_id, evidence_kind: 'cash_count', handed_amount: '300')
    expect(response).to have_http_status(:ok)
    expect(data['financial']['change_due']).to eq('50.0')
  end

  it 'records a larger bank transfer as one receipt and keeps the excess unapplied' do
    ctx = setup_workspace(price: 100)
    add_item(ctx, 0)
    prepare(ctx, 1, 'bank_manual', 100)
    attempt_id = last_attempt(ctx)['id']

    confirm(ctx, 2, attempt_id, evidence_kind: 'bank_manual', reference: 'FT1')
    expect(response).to have_http_status(:conflict)
    confirm(ctx, 2, attempt_id, received_amount: '90', **bank_evidence)
    expect(response).to have_http_status(:conflict)

    data = confirm(ctx, 2, attempt_id, received_amount: '130', **bank_evidence)
    expect(response).to have_http_status(:ok)
    expect(data['financial']['remaining']).to eq('0.0')

    funds = Spree::Pos::ReceivedFunds.where(workspace: ctx.workspace).sole
    expect(funds.received_net).to eq(BigDecimal('130'))
    expect(funds.receiving_account).to eq('VCB-123')
    expect(funds.balance.available).to eq(BigDecimal('30'))
    expect(ctx.workspace.order.reload.payments.completed.sum(:amount)).to eq(BigDecimal('100'))
  end

  it 'keeps an unknown attempt reserved against the remaining balance' do
    ctx = setup_workspace(price: 100)
    add_item(ctx, 0)
    prepare(ctx, 1, 'bank_manual', 60)
    Spree::Pos::TenderAttempt.where(workspace: ctx.workspace).update_all(status: 'unknown')

    prepare(ctx, 2, 'cash', 50)
    expect(response).to have_http_status(:conflict)
    prepare(ctx, 2, 'cash', 40)
    expect(response).to have_http_status(:ok)
  end

  it 'takes cash on a branch-only shift that has no register' do
    ctx = setup_workspace(price: 100, register: false)
    expect(ctx.workspace.register).to be_nil
    add_item(ctx, 0)
    prepare(ctx, 1, 'cash', 100)
    expect(response).to have_http_status(:ok)
    confirm(ctx, 2, last_attempt(ctx)['id'], evidence_kind: 'cash_count', handed_amount: '100')
    expect(response).to have_http_status(:ok)
    movement = Spree::Pos::CashMovement.find_by!(shift: ctx.workspace.shift)
    expect(movement.amount).to eq(BigDecimal('100'))
    expect(movement.register).to be_nil
  end

  it 'never books a POS tender on a gateway payment method' do
    ctx = setup_workspace(price: 100, manual_method: false)
    add_item(ctx, 0)
    prepare(ctx, 1, 'cash', 100)
    expect(response).to have_http_status(:conflict)
    expect(Spree::Pos::TenderAttempt.where(workspace: ctx.workspace)).to be_empty
    expect(ctx.workspace.order.reload.payments).to be_empty
  end

  it 'locks items after prepare, refuses tracked tender, and completes + hands over only with completed receipts' do
    ctx = setup_workspace(price: 100)
    add_item(ctx, 0)

    complete(ctx, 1)
    expect(response).to have_http_status(:conflict)
    expect(ctx.workspace.reload.order).not_to be_placed

    prepare(ctx, 1, 'cash', 100)
    add_item(ctx, 2)
    expect(response).to have_http_status(:conflict)

    confirm(ctx, 2, last_attempt(ctx)['id'], evidence_kind: 'cash_count', handed_amount: '100')
    complete(ctx, 3)
    expect(response).to have_http_status(:ok)
    expect(ctx.workspace.reload.operational_status).to eq('completed')
    expect(ctx.workspace.order.placed?).to be(true)
    level = ctx.branch.stock_location.stock_level(ctx.product.default_variant).reload
    expect(level.allocated_count).to eq(1)

    key = SecureRandom.uuid
    post "/api/v3/admin/pos/workspaces/#{ctx.workspace.prefixed_id}/handover", headers: headers(ctx.token, key),
                                                                               params: { idempotency_key: key }, as: :json
    expect(response).to have_http_status(:ok)
    level.reload
    expect(level.count_on_hand).to eq(9)
    expect(level.allocated_count).to eq(0)
  end

  it 'keeps received money and completes once when placement fails after the receipt' do
    ctx = setup_workspace(price: 100)
    add_item(ctx, 0)
    prepare(ctx, 1, 'cash', 100)
    confirm(ctx, 2, last_attempt(ctx)['id'], evidence_kind: 'cash_count', handed_amount: '100')

    failing = double('order complete workflow', call: double('result', success?: false))
    allow(Spree).to receive(:order_complete_workflow).and_return(failing)
    complete(ctx, 3)
    expect(response).to have_http_status(:conflict)
    expect(ctx.workspace.reload.order).not_to be_placed
    expect(Spree::Pos::FundsAllocation.where(workspace: ctx.workspace, status: 'active').count).to eq(1)
    expect(ctx.workspace.order.payments.completed.sum(:amount)).to eq(BigDecimal('100'))

    travel 16.minutes do
      2.times { Spree::Pos::RecoverSettlementJob.perform_now }
    end
    pending_entries = Spree::Pos::OutboxEntry.where(event_type: 'workspace.completion_pending', aggregate_id: ctx.workspace.id)
    expect(pending_entries.count).to eq(1)

    allow(Spree).to receive(:order_complete_workflow).and_call_original
    complete(ctx, 3)
    expect(response).to have_http_status(:ok)
    expect(ctx.workspace.reload.order).to be_placed
    expect(ctx.workspace.order.payments.count).to eq(1)
    expect(Spree::Pos::ReceivedFunds.where(workspace: ctx.workspace).count).to eq(1)
  end

  it 'rolls back a confirm that fails mid-way and records the retry exactly once' do
    ctx = setup_workspace(price: 100)
    add_item(ctx, 0)
    prepare(ctx, 1, 'cash', 100)
    attempt_id = last_attempt(ctx)['id']
    key = SecureRandom.uuid

    allow_any_instance_of(Spree::Payment).to receive(:complete!).and_raise(ActiveRecord::StatementInvalid, 'connection lost')
    expect do
      Spree::Pos::Tenders::Confirm.call(workspace: ctx.workspace.reload, staff: ctx.user, revision: 2,
                                        lease_generation: ctx.workspace.lease_generation, editor_id: editor_id,
                                        key: key, attempt_id: attempt_id, evidence_kind: 'cash_count', handed_amount: '100')
    end.to raise_error(ActiveRecord::StatementInvalid)
    expect(Spree::Pos::ReceivedFunds.where(workspace: ctx.workspace)).to be_empty
    expect(Spree::Pos::CashMovement.where(shift: ctx.workspace.shift)).to be_empty
    expect(Spree::Pos::TenderAttempt.find_by_prefix_id!(attempt_id).status).to eq('prepared')

    allow_any_instance_of(Spree::Payment).to receive(:complete!).and_call_original
    2.times do
      confirm(ctx, 2, attempt_id, key: key, evidence_kind: 'cash_count', handed_amount: '100')
      expect(response).to have_http_status(:ok)
    end
    expect(Spree::Pos::ReceivedFunds.where(workspace: ctx.workspace).count).to eq(1)
    expect(ctx.workspace.order.reload.payments.completed.count).to eq(1)
  end

  it 'completes a free order only with approval authority and without a payment' do
    cashier_caps = [Spree::Pos::Capabilities::OPEN_SHIFT, Spree::Pos::Capabilities::PAYMENT]
    ctx = setup_workspace(price: 0, capabilities: cashier_caps)
    add_item(ctx, 0)
    expect(response).to have_http_status(:ok)

    complete(ctx, 1)
    expect(response).to have_http_status(:forbidden)

    Spree::Pos::StaffMembership.find_by!(staff: ctx.user, branch: ctx.branch).
      update!(capabilities: cashier_caps + [Spree::Pos::Capabilities::APPROVE])
    complete(ctx, 1)
    expect(response).to have_http_status(:ok)
    expect(ctx.workspace.reload.order).to be_placed
    expect(ctx.workspace.order.payments).to be_empty
    expect(Spree::Pos::AuditEntry.where(subject_type: ctx.workspace.class.name, subject_id: ctx.workspace.id,
                                        action: 'workspace.complete_zero_total').count).to eq(1)
  end

  it 'refuses tender for lot-tracked goods without sellable lots before any money is taken' do
    ctx = setup_workspace(price: 100)
    variant = ctx.product.default_variant
    put '/api/v3/admin/pos/units/variant', headers: { 'Authorization' => "Bearer #{ctx.token}" },
                                           params: { branch_id: ctx.branch.prefixed_id, variant_id: variant.prefixed_id,
                                                     sale_unit: 'item', base_unit: 'item', price_unit: 'item', tracked_mode: 'lot' }, as: :json
    expect(response).to have_http_status(:ok)
    key = SecureRandom.uuid
    body = editing(ctx.workspace, 0, key).merge(variant_id: variant.prefixed_id, quantity: 1)
    post "/api/v3/admin/pos/workspaces/#{ctx.workspace.prefixed_id}/items", headers: headers(ctx.token, key), params: body, as: :json
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('trace_not_enrolled')

    lot = enroll_lots!(ctx.branch, variant, [['L1', Date.current + 30, 1]], opened_by: ctx.user).first
    key = SecureRandom.uuid
    post "/api/v3/admin/pos/workspaces/#{ctx.workspace.prefixed_id}/items", headers: headers(ctx.token, key),
                                                                             params: editing(ctx.workspace, 0, key).merge(variant_id: variant.prefixed_id, quantity: 1), as: :json
    expect(response).to have_http_status(:ok)
    lot.update!(status: 'quarantined')

    prepare(ctx, 1, 'cash', 100)
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('trace_insufficient')
    expect(Spree::Pos::ReceivedFunds.where(workspace: ctx.workspace)).to be_empty
  end

  it 'keeps excess as liability, holds payout reservations until a second person confirms with evidence' do
    ctx = setup_workspace(price: 100)
    add_item(ctx, 0)
    prepare(ctx, 1, 'cash', 100)
    confirm(ctx, 2, last_attempt(ctx)['id'], evidence_kind: 'cash_count', handed_amount: '100')
    shift_id = ctx.workspace.shift.prefixed_id
    base = { branch_id: ctx.branch.prefixed_id, shift_id: shift_id, kind: 'bank_manual', handed_amount: '40',
             workspace_id: ctx.workspace.prefixed_id }

    record_funds(ctx.token, **base, reference: 'FT-LATE')
    expect(response).to have_http_status(:conflict)
    funds_id = record_funds(ctx.token, **base, reference: 'FT-LATE', receiving_account: 'VCB-123')['id']
    expect(response).to have_http_status(:created)
    expect(funds_state(ctx.token, funds_id)['available']).to eq('40.0')
    expect(ctx.workspace.order.reload.payments.count).to eq(1)

    payout_id = payout(ctx.token, funds_id, amount: '40', beneficiary_name: 'Khach A', reason: 'Thua chuyen khoan')['id']
    expect(response).to have_http_status(:created)
    payout(ctx.token, funds_id, amount: '40', beneficiary_name: 'Khach A', reason: 'Trung')
    expect(response).to have_http_status(:conflict)

    payout(ctx.token, funds_id, 'confirm', payout_id, evidence_kind: 'bank_manual', reference: 'FT-OUT')
    expect(response).to have_http_status(:conflict)
    expect(conflict_message).to include('other than its requester')

    payout(ctx.token, funds_id, 'resolve', payout_id, outcome: 'unknown')
    expect(response).to have_http_status(:ok)
    payout(ctx.token, funds_id, 'resolve', payout_id, outcome: 'cancel')
    expect(response).to have_http_status(:conflict)
    payout(ctx.token, funds_id, 'resolve', payout_id, outcome: 'failed_no_effect')
    expect(response).to have_http_status(:conflict)
    expect(funds_state(ctx.token, funds_id)).to include('available' => '0.0', 'payout_reserved' => '40.0')

    manager = staff_user(ctx.branch, PosSettlementSpec::CAPS)
    manager_token = login(manager)
    payout(manager_token, funds_id, 'confirm', payout_id, evidence_kind: 'bank_manual')
    expect(response).to have_http_status(:conflict)
    payout(manager_token, funds_id, 'confirm', payout_id, evidence_kind: 'bank_manual', reference: 'FT-OUT')
    expect(response).to have_http_status(:ok)

    payout(ctx.token, funds_id, 'resolve', payout_id, outcome: 'cancel')
    expect(response).to have_http_status(:conflict)
    expect(funds_state(ctx.token, funds_id)).to include('paid_out' => '40.0', 'available' => '0.0', 'payout_reserved' => '0.0')
  end

  it 'adds unsolicited cash only to the caller\'s open drawer and keeps other cash held without a drawer movement' do
    ctx = setup_workspace(price: 100)
    shift = ctx.workspace.shift
    base = { branch_id: ctx.branch.prefixed_id, shift_id: shift.prefixed_id, kind: 'cash', handed_amount: '50' }

    record_funds(ctx.token, **base)
    expect(response).to have_http_status(:created)
    expect(Spree::Pos::CashMovement.where(shift: shift, kind: 'receipt').sum(:amount)).to eq(BigDecimal('50'))

    other = staff_user(ctx.branch, PosSettlementSpec::CAPS)
    other_token = login(other)
    open_shift(other_token, ctx.branch)
    record_funds(other_token, **base)
    expect(response).to have_http_status(:conflict)

    cashier = staff_user(ctx.branch, [Spree::Pos::Capabilities::OPEN_SHIFT, Spree::Pos::Capabilities::PAYMENT])
    record_funds(login(cashier), **base, custody: 'held', custody_note: 'Ket sat')
    expect(response).to have_http_status(:forbidden)

    record_funds(ctx.token, **base, custody: 'held')
    expect(response).to have_http_status(:conflict)
    held = record_funds(ctx.token, **base, custody: 'held', custody_note: 'Nhan ca truoc, de ket sat')
    expect(response).to have_http_status(:created)
    expect(held).to include('custody' => 'held', 'status' => 'attention', 'available' => '50.0')
    expect(Spree::Pos::CashMovement.where(received_funds_id: Spree::Pos::ReceivedFunds.find_by_prefix_id!(held['id']).id)).to be_empty

    shift.update_columns(status: 'closed')
    record_funds(ctx.token, **base)
    expect(response).to have_http_status(:conflict)
    expect(Spree::Pos::CashMovement.where(shift: shift).sum(:amount)).to eq(BigDecimal('50'))
  end

  it 'pays cash out of the confirmer\'s own open drawer, not the closed shift that received it' do
    ctx = setup_workspace(price: 100)
    origin = ctx.workspace.shift
    funds_id = record_funds(ctx.token, branch_id: ctx.branch.prefixed_id, shift_id: origin.prefixed_id, kind: 'cash', handed_amount: '50')['id']
    payout_id = payout(ctx.token, funds_id, amount: '50', beneficiary_name: 'Khach B', reason: 'Tien thua')['id']
    expect(response).to have_http_status(:created)
    origin.update_columns(status: 'closed')

    manager = staff_user(ctx.branch, PosSettlementSpec::CAPS)
    manager_token = login(manager)
    payout(manager_token, funds_id, 'confirm', payout_id, evidence_kind: 'cash_count')
    expect(response).to have_http_status(:conflict)

    open_shift(manager_token, ctx.branch)
    payout(manager_token, funds_id, 'confirm', payout_id, evidence_kind: 'cash_count')
    expect(response).to have_http_status(:ok)
    drawer = Spree::Pos::Shift.find_by!(owner: manager, status: 'open')
    expect(Spree::Pos::CashMovement.where(shift: drawer).sum(:amount)).to eq(BigDecimal('-50'))
    expect(Spree::Pos::CashMovement.where(shift: origin).sum(:amount)).to eq(BigDecimal('50'))
  end

  it 'allocates unapplied funds, reverses before placement, and leaves the order editable and cancelable' do
    ctx = setup_workspace(price: 100)
    add_item(ctx, 0)
    funds_id = record_funds(ctx.token, branch_id: ctx.branch.prefixed_id, shift_id: ctx.workspace.shift.prefixed_id,
                                       kind: 'bank_manual', handed_amount: '100', reference: 'FT-EARLY', receiving_account: 'VCB-123',
                                       workspace_id: ctx.workspace.prefixed_id)['id']

    workspace_command(ctx, 'funds/allocate', 1, funds_id: funds_id, amount: '100.5')
    expect(response).to have_http_status(:conflict)
    workspace_command(ctx, 'funds/allocate', 1, funds_id: funds_id, amount: '100')
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.dig('data', 'financial', 'allocated')).to eq('100.0')
    allocation_id = Spree::Pos::FundsAllocation.find_by!(workspace: ctx.workspace, status: 'active').prefixed_id

    workspace_command(ctx, 'funds/reverse', 2, allocation_id: allocation_id)
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.dig('data', 'financial', 'allocated')).to eq('0.0')
    expect(ctx.workspace.order.reload.payments.where(status: 'completed')).to be_empty
    expect(funds_state(ctx.token, funds_id)['available']).to eq('100.0')

    add_item(ctx, 3)
    expect(response).to have_http_status(:ok)
    workspace_command(ctx, 'cancel', 4)
    expect(response).to have_http_status(:ok)
    expect(funds_state(ctx.token, funds_id)['available']).to eq('100.0')
  end
end
