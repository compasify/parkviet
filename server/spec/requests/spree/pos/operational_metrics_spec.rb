# frozen_string_literal: true

require 'spree/api/testing_support/v3/base'
require_relative '../../../support/pos_shift_helpers'

# Branch health for supervisors, counted from the source facts, and the
# structured command log: correlation ids only, never keys, tokens or
# personal data.
RSpec.describe 'POS operational metrics', type: :request do
  include PosShiftHelpers

  let(:store) { create(:store, default_currency: 'VND', supported_currencies: 'VND') }
  let(:branch) { returns_branch(store) }
  let(:cashier) { credit_staff(store, branch, PosShiftHelpers::LEAD) }
  let(:manager) { credit_staff(store, branch, PosShiftHelpers::MANAGER) }
  let(:reader) { credit_staff(store, branch, [Spree::Pos::Capabilities::REPORT_READ]) }

  before { allow(Spree::Store).to receive(:default).and_return(store) }

  def metrics(user)
    post '/api/v3/admin/auth/login', params: { email: user.email, password: 'secret123' }, as: :json
    token = response.parsed_body.fetch('token')
    get '/api/v3/admin/pos/operations/metrics', headers: { 'Authorization' => "Bearer #{token}" }, params: { branch_id: branch.prefixed_id }
    response.parsed_body['data']
  end

  it 'counts stuck money, attention items, variances and traced drift for approvers and report readers only' do
    stuck = open_sale(store, branch, cashier: cashier, product: stocked_product(store, branch, price: 10_000))
    method = Spree::Pos::PaymentMethodResolver.new(store: store).available.find { |row| row.kind == 'bank_manual' }
    Spree::Pos::Tenders::Prepare.call(**editing_args(stuck), payment_method_id: method.prefixed_id || 'posmethod-bank_manual', amount: '10000')
    Spree::Pos::TenderAttempt.where(workspace: stuck.workspace).update_all(created_at: 20.minutes.ago)
    sale = paid_sale(store, branch, cashier: cashier, price: 50_000)
    refund = request_refund(store, cashier, return_and_receive(store, cashier, branch, sale, quantity: 1), amount: 50_000)
    Spree::Pos::RefundRequest.find_by_prefix_id!(refund['id']).update_columns(updated_at: 20.minutes.ago)
    approver = credit_staff(store, branch, PosShiftHelpers::MANAGER)
    # An approved overage nobody placed yet is unexplained...
    over = open_shift(store, branch, manager)
    count_shift(over, manager, 20_000, reason: 'Thừa')
    approve_close(over, approver)
    close_shift(over, manager)
    # ...an approved shortage is explained...
    short = open_shift(store, branch, manager, float: 10_000)
    count_shift(short, manager, 0, reason: 'Thiếu, đã báo')
    approve_close(short, approver)
    close_shift(short, manager)
    # ...and an old overage is outside the window.
    old = open_shift(store, branch, manager)
    count_shift(old, manager, 5_000, reason: 'Thừa cũ')
    approve_close(old, approver)
    closure = close_shift(old, manager)
    Spree::Pos::ShiftClosure.where(id: Spree::Pos::ShiftClosure.find_by_prefix_id!(closure['id']).id).update_all(closed_at: 40.days.ago)

    data = metrics(manager)
    expect(response).to have_http_status(:ok)
    expect(response.headers['Cache-Control']).to include('no-store')
    expect(data['tenders']).to include('prepared' => 1, 'unknown' => 0)
    expect(data['tenders']['oldest_unresolved_age_seconds']).to be >= 20 * 60
    expect(data['attention']).to include('stale_tenders' => 1, 'stale_refunds' => 1, 'open_stock_discrepancies' => 0)
    expect(data['payouts']['refunds']).to eq('reserved' => 1)
    expect(data['variances']).to include('closures_with_unexplained_variance' => 1, 'counts_awaiting_close' => 0)
    # The outbox has no branch: its store-wide figures are for store-level readers only.
    expect(data['outbox']).to be_nil
    expect(data['traceability']).to include('enrolled' => 0, 'drifted' => 0)
    expect(data['lock_waits'].keys).to contain_exactly('available', 'waiting', 'oldest_waiting_statement_seconds')
    expect(data['lock_waits']['waiting']).to eq(0) if data['lock_waits']['available']
    expect(data.to_json).not_to include(cashier.email, 'IMEI', 'query')

    store_reader = credit_staff(store, branch, [Spree::Pos::Capabilities::APPROVE], extra_permissions: %w[write_pos_topology])
    expect(metrics(store_reader)['outbox']['pending']).to be_positive

    expect(metrics(reader)['tenders']['prepared']).to eq(1)
    metrics(cashier)
    expect(response).to have_http_status(:not_found)
  end

  it 'logs each command once with correlation ids and a keyed digest, tags nested commands, never the key or payload values' do
    lines = []
    logger = ActiveSupport::TaggedLogging.new(Logger.new(StringIO.new))
    allow(logger).to receive(:info) { |message = nil, &block| lines << (message || block&.call) }
    allow(Rails).to receive(:logger).and_return(logger)

    sale = open_sale(store, branch, cashier: cashier, product: stocked_product(store, branch, price: 10_000))
    key = 'customer-0912345678-secret-key'
    args = editing_args(sale).merge(key: key)
    Spree::Pos::Workspaces::UpdateNote.call(**args, note: 'Gọi 0912345678')
    Spree::Pos::Workspaces::UpdateNote.call(**args, note: 'Gọi 0912345678')

    sold = paid_sale(store, branch, cashier: cashier, price: 10_000)
    returned = return_and_receive(store, cashier, branch, sold, quantity: 1)
    register = Spree::Pos::Shift.open_now.find_by!(owner: cashier).register
    Spree::Pos::Exchanges::Execute.call(store: store, staff: cashier, key: SecureRandom.uuid, return_id: returned['id'],
                                        editor_id: SecureRandom.uuid, register_id: register.prefixed_id)
    foreign = returns_branch(create(:store, default_currency: 'VND', supported_currencies: 'VND'))
    expect do
      Spree::Pos::Returns::Prepare.call(store: store, staff: cashier, key: SecureRandom.uuid, branch_id: foreign.prefixed_id,
                                        order_id: sold.workspace.order.prefixed_id, reason: 'x',
                                        lines: [{ 'sale_line_id' => sale_line(sold).prefixed_id, 'quantity' => 1 }])
    end.to raise_error(ActiveRecord::RecordNotFound)

    events = lines.filter_map { |line| JSON.parse(line) if line.to_s.start_with?('{') }.select { |row| row['event'] == 'pos.command' }
    mine = events.select { |row| row['workspace'] == sale.workspace.prefixed_id && row['command'] == 'update_note' }
    expect(mine.map { |row| row['outcome'] }).to eq(%w[executed replayed])
    secret = Rails.application.key_generator.generate_key('spree.pos.command_log.key_digest', 32)
    expect(mine.first).to include('store' => store.prefixed_id, 'branch' => branch.prefixed_id, 'actor' => cashier.prefixed_id,
                                  'key_digest' => OpenSSL::HMAC.hexdigest('SHA256', secret, key)[0, 16])
    expect(mine.first['key_digest']).not_to eq(Digest::SHA256.hexdigest(key)[0, 16])
    expect(mine.first).not_to have_key('parent')
    nested = events.find { |row| row['command'] == 'create' && row['parent'] }
    expect(nested).to include('parent' => 'exchange.execute', 'outcome' => 'executed')
    exchange = events.index { |row| row['command'] == 'exchange.execute' }
    expect(events.index(nested)).to be < exchange
    refused = events.find { |row| row['command'] == 'return.prepare' && row['outcome'] == 'refused' }
    expect(refused).not_to have_key('branch')
    expect(lines.join).not_to include(key, '0912345678', foreign.prefixed_id)
  end
end
