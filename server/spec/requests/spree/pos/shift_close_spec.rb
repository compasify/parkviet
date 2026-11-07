# frozen_string_literal: true

require 'spree/api/testing_support/v3/base'
require_relative '../../../support/pos_shift_helpers'

# HTTP contract for drawer movements, the close wizard (checklist, blind
# count, variance approval, snapshot), late-cash reconciliation and the
# branch variance threshold.
RSpec.describe 'POS shift close API', type: :request do
  include PosShiftHelpers

  let(:store) { create(:store, default_currency: 'VND', supported_currencies: 'VND') }
  let(:branch) { returns_branch(store) }
  let(:cashier) { credit_staff(store, branch, PosShiftHelpers::LEAD) }
  let(:manager) { credit_staff(store, branch, PosShiftHelpers::MANAGER, extra_permissions: %w[write_pos_topology read_pos_topology]) }
  let(:auditor) { credit_staff(store, branch, PosShiftHelpers::MANAGER) }

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

  it 'lets a topology manager set the variance threshold and a cashier record drawer movements' do
    call(manager, :patch, "branches/#{branch.prefixed_id}", { variance_threshold: '20000' })
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.dig('data', 'variance_threshold')).to eq('20000.0')
    call(manager, :patch, "branches/#{branch.prefixed_id}", { variance_threshold: '-1' })
    expect(response).to have_http_status(:unprocessable_content)
    call(cashier, :patch, "branches/#{branch.prefixed_id}", { variance_threshold: '' })
    expect(response).to have_http_status(:forbidden)

    shift = open_shift(store, branch, cashier, float: 100_000)
    call(cashier, :post, "shifts/#{shift.prefixed_id}/cash_movements", { kind: 'safe_drop', amount: '50000', reason: 'Nộp két' })
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('evidence_required')
    request = call(cashier, :post, "shifts/#{shift.prefixed_id}/cash_movements",
                   { kind: 'safe_drop', amount: '50000', reason: 'Nộp két', evidence_reference: 'TUI-5' })['data']
    expect(response).to have_http_status(:created)
    expect(request).to include('status' => 'requested', 'kind' => 'safe_drop', 'amount' => '50000.0')
    expect(call(cashier, :get, "shifts/#{shift.prefixed_id}/cash_movements")['data']).to be_empty

    pending = call(manager, :get, 'cash_movement_requests', { branch_id: branch.prefixed_id, status: 'requested' })['data']
    expect(pending.map { |row| row['id'] }).to eq([request['id']])
    call(cashier, :post, "cash_movement_requests/#{request['id']}/confirm", {})
    expect(response).to have_http_status(:conflict)
    confirmed = call(manager, :post, "cash_movement_requests/#{request['id']}/confirm", {})['data']
    expect(confirmed).to include('status' => 'confirmed', 'cash_movement_id' => be_present)
    list = call(cashier, :get, "shifts/#{shift.prefixed_id}/cash_movements")
    expect(list['data'].map { |row| [row['reason'], row['amount']] }).to eq([['Nộp két', '-50000.0']])
    expect(call(cashier, :get, 'cash_movement_requests', { branch_id: branch.prefixed_id })['data'].length).to eq(1)

    open = call(manager, :get, 'shift_closures/open', { branch_id: branch.prefixed_id })['data']
    expect(open.map { |row| row['id'] }).to eq([shift.prefixed_id])
    call(cashier, :get, 'shift_closures/open', { branch_id: branch.prefixed_id })
    expect(response).to have_http_status(:forbidden)
    call(manager, :post, "shifts/#{shift.prefixed_id}/cash_movements", { kind: 'cash_in', amount: '1000', reason: 'x' })
    expect(response).to have_http_status(:forbidden)
  end

  it 'runs the close wizard with a variance approval from another person' do
    shift = open_shift(store, branch, cashier, float: 100_000)
    state = call(cashier, :get, "shifts/#{shift.prefixed_id}/closure")['data']
    expect(state).to include('can_close' => true, 'can_approve' => false)
    expect(state['checklist']).to eq('blocking' => [], 'warnings' => [])

    counted = call(cashier, :post, "shifts/#{shift.prefixed_id}/count", { counted: '80000', reason: 'Thiếu tiền lẻ' })['data']
    expect(counted).to include('variance' => '-20000.0', 'requires_approval' => true)
    call(cashier, :post, "shifts/#{shift.prefixed_id}/close", {})
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('approval_required')

    pending = call(manager, :get, 'shift_closures/pending', { branch_id: branch.prefixed_id })['data']
    expect(pending.map { |row| row['shift_id'] }).to eq([shift.prefixed_id])
    expect(pending.first).to include('variance' => '-20000.0', 'reason' => 'Thiếu tiền lẻ', 'self_count' => false)
    call(cashier, :get, 'shift_closures/pending', { branch_id: branch.prefixed_id })
    expect(response).to have_http_status(:forbidden)

    approved = call(manager, :post, "shifts/#{shift.prefixed_id}/close_approval", { revision: counted['revision'] })['data']
    expect(approved.dig('approval', 'approver_id')).to eq(manager.prefixed_id)
    closure = call(cashier, :post, "shifts/#{shift.prefixed_id}/close", {})['data']
    expect(response).to have_http_status(:created)
    expect(closure).to include('variance' => '-20000.0', 'approver_id' => manager.prefixed_id, 'reason' => 'Thiếu tiền lẻ')
    state = call(cashier, :get, "shifts/#{shift.prefixed_id}/closure")['data']
    expect(state).to include('can_close' => false)
    expect(state.dig('closure', 'id')).to eq(closure['id'])

    call(cashier, :post, "shifts/#{shift.prefixed_id}/cash_movements", { kind: 'cash_in', amount: '1000', reason: 'Sau ca' })
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('shift_closed')
  end

  it 'lists late-cash candidates and reconciles held cash into the opening float' do
    s1 = open_shift(store, branch, cashier, float: 0)
    count_shift(s1, cashier, 100_000, reason: 'Thừa tiền')
    approve_close(s1, manager)
    close_shift(s1, cashier)
    s2 = open_shift(store, branch, cashier, float: 100_000)
    funds = held_cash(store, branch, s1, manager, 100_000)

    candidates = call(auditor, :get, 'cash_reconciliations/candidates', { branch_id: branch.prefixed_id })['data']
    expect(candidates['closures'].first).to include('shift_id' => s1.prefixed_id, 'unexplained' => '100000.0')
    expect(candidates['held_funds'].first).to include('id' => funds.prefixed_id, 'amount' => '100000.0', 'recorded_by_me' => false)
    expect(candidates['shifts'].map { |row| row['id'] }).to include(s2.prefixed_id)
    call(cashier, :get, 'cash_reconciliations/candidates', { branch_id: branch.prefixed_id })
    expect(response).to have_http_status(:forbidden)

    result = call(auditor, :post, 'cash_reconciliations', {
                    branch_id: branch.prefixed_id, outcome: 'in_opening_float', reason: 'Tiền đã nằm trong quỹ đầu ca sau',
                    closure_id: candidates['closures'].first['id'], funds_id: funds.prefixed_id, target_shift_id: s2.prefixed_id
                  })['data']
    expect(response).to have_http_status(:created)
    expect(result).to include('outcome' => 'in_opening_float', 'cash_movement_id' => nil, 'closed_shift_id' => s1.prefixed_id)
    expect(expected_cash(s2)).to eq(BigDecimal('100000'))
    after = call(auditor, :get, 'cash_reconciliations/candidates', { branch_id: branch.prefixed_id })['data']
    expect(after['closures']).to be_empty
    expect(after['held_funds']).to be_empty
    expect(call(auditor, :get, 'cash_reconciliations', { branch_id: branch.prefixed_id })['data'].length).to eq(1)
  end
end
