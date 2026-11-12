# frozen_string_literal: true

require 'spree/api/testing_support/v3/base'
require_relative '../../../support/pos_meal_helpers'
require_relative '../../../support/pos_schema_helpers'

# A canteen counter over the API: finding the eater by code or name inside
# the store only, the lookup rate limit, importing accounts from a CSV,
# recording a meal (a 409 with the reason the counter plays its sound for),
# paying from the wallet and approvals bound to the meal account.
RSpec.describe 'POS meal accounts', type: :request do
  include PosMealHelpers
  include PosSchemaHelpers

  let(:store) { Spree::Store.default }
  let(:branch) { canteen_branch(store) }
  let(:cashier) { credit_staff(store, branch, PosMealHelpers::MEAL_CASHIER) }
  let(:manager) { credit_staff(store, branch, PosCreditHelpers::MANAGER + [PosMealHelpers::CAPS::MEAL_ACCOUNT_MANAGE]) }
  let(:noon) { Time.zone.parse('2026-11-12 05:30:00 UTC') }

  before { allow(Spree::Pos::Workspace).to receive(:business_now).and_return(noon) }

  def headers(user = cashier)
    @tokens ||= {}
    @tokens[user.id] ||= begin
      post '/api/v3/admin/auth/login', params: { email: user.email, password: 'secret123' }, as: :json
      response.parsed_body.fetch('token')
    end
    { 'Authorization' => "Bearer #{@tokens[user.id]}", 'Idempotency-Key' => SecureRandom.uuid }
  end

  def editing_params(sale)
    workspace = sale.workspace.reload
    { expected_revision: workspace.revision, lease_generation: workspace.lease_generation, editor_id: sale.editor_id }
  end

  it 'finds an eater by exact code or by name, only in the current store' do
    account = meal_account!(store, manager, branch, code: 'NV042', name: 'Trần Thị Mai')
    meal_account!(store, manager, branch, code: 'NV043', name: 'Trần Văn Minh')
    other_store = create(:store)
    other_profile = Spree::Pos::CustomerProfile.create!(store: other_store, name: 'Trần Thị Mai', phone: '0911000111',
                                                        created_by: manager)
    wallet = Spree::Pos::StoredValueAccount.create!(store: other_store, customer_profile: other_profile, kind: 'meal', currency: 'USD',
                                                    status: 'active')
    Spree::Pos::MealAccount.create!(store: other_store, customer_profile: other_profile, stored_value_account: wallet,
                                    employee_code: 'NV042', pay_mode: 'wallet', status: 'active')

    get '/api/v3/admin/pos/meal_accounts/resolve', headers: headers, params: { branch_id: branch.prefixed_id, q: 'nv042' }
    expect(response).to have_http_status(:ok), response.body
    expect(response.parsed_body.dig('data', 'match', 'id')).to eq(account.prefixed_id)
    expect_pos_schema!(response, 'MealResolve')

    get '/api/v3/admin/pos/meal_accounts/resolve', headers: headers, params: { branch_id: branch.prefixed_id, q: 'Trần' }
    suggestions = response.parsed_body.dig('data', 'suggestions')
    expect(response.parsed_body.dig('data', 'match')).to be_nil
    expect(suggestions.map { |row| row['employee_code'] }).to contain_exactly('NV042', 'NV043')
    expect(suggestions.map { |row| Spree::Pos::MealAccount.find_by_prefix_id!(row['id']).store_id }.uniq).to eq([store.id])
  end

  it 'limits lookups per staff member' do
    staff = credit_staff(store, branch, PosMealHelpers::MEAL_CASHIER)
    auth = headers(staff)
    codes = Array.new(Spree::Api::V3::Admin::Pos::MealAccountsController::RESOLVE_ATTEMPTS + 1) do
      get '/api/v3/admin/pos/meal_accounts/resolve', headers: auth, params: { branch_id: branch.prefixed_id, q: 'NV999' }
      response.status
    end

    expect(codes.first).to eq(200)
    expect(codes.last).to eq(429)
    expect(response.parsed_body.dig('error', 'code')).to eq('meal_resolve_rate_limited')
  end

  it 'imports accounts from a CSV all or nothing' do
    sponsor = meal_sponsor!(store, manager, branch, name: 'Công ty ABC')
    csv = "employee_code,name,phone,group_label,sponsor,daily_meal_limit\n" \
          "nv100,Lê Văn Bình,0901000100,Kho,Công ty ABC,2\n" \
          "NV101,Phạm Thị Hoa,0901000101,Văn phòng,,1\n"
    post '/api/v3/admin/pos/meal_accounts/import', headers: headers(manager), params: { branch_id: branch.prefixed_id, csv: csv }
    expect(response).to have_http_status(:ok), response.body
    expect(response.parsed_body['data']).to eq('created' => 2, 'updated' => 0)
    expect(Spree::Pos::MealAccount.find_by!(store: store, employee_code: 'NV100')).
      to have_attributes(meal_sponsor_id: sponsor.id, pay_mode: 'sponsor', daily_meal_limit: 2, group_label: 'Kho')

    bad = "employee_code,name,phone,sponsor\nNV100,Lê Văn Bình,0901000100,\nNV102,Không Có,0901000102,Không có công ty\n"
    post '/api/v3/admin/pos/meal_accounts/import', headers: headers(manager), params: { branch_id: branch.prefixed_id, csv: bad }
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('meal_import_invalid')
    expect(response.parsed_body.dig('error', 'details', 'errors')).to contain_exactly(include('line' => 3, 'field' => 'sponsor'))
    expect(Spree::Pos::MealAccount.for_store(store).where(employee_code: 'NV102')).to be_empty

    plain = credit_staff(store, branch, PosCreditHelpers::CASHIER)
    post '/api/v3/admin/pos/meal_accounts/import', headers: headers(plain), params: { branch_id: branch.prefixed_id, csv: csv }
    expect(response).to have_http_status(:forbidden)
  end

  it 'records a meal, answers a refusal with its reason and pays from the wallet' do
    account = meal_account!(store, manager, branch, code: 'NV200', daily_meal_limit: 1)
    sale = meal_sale(store, branch, cashier, price: 35_000)
    top_up!(store, cashier, branch, account, 50_000)
    path = "/api/v3/admin/pos/workspaces/#{sale.workspace.prefixed_id}"

    post "#{path}/meal_swipes", headers: headers, params: editing_params(sale).merge(code: 'nv200'), as: :json
    expect(response).to have_http_status(:created), response.body
    expect(response.parsed_body.dig('data', 'meal')).to include('employee_code' => 'NV200', 'wallet_covers' => true)
    expect_pos_schema!(response, 'MealSwipe')

    get "#{path}/meal", headers: headers
    expect(response.parsed_body.dig('data', 'plan')).to include('employee_amount' => '35000.0', 'sponsor_amount' => '0.0')
    expect_pos_schema!(response, 'WorkspaceMeal')

    post "#{path}/meal_wallet", headers: headers, params: editing_params(sale), as: :json
    expect(response).to have_http_status(:ok), response.body
    expect(response.parsed_body.dig('data', 'meal', 'balance')).to eq('15000.0')
    expect_pos_schema!(response, 'MealWalletPay')

    allow(Spree::Pos::Workspace).to receive(:business_now).and_return(noon + 5.minutes)
    other = meal_sale(store, branch, cashier, price: 35_000)
    post "/api/v3/admin/pos/workspaces/#{other.workspace.prefixed_id}/meal_swipes", headers: headers,
                                                                                    params: editing_params(other).merge(code: 'NV200'), as: :json
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('meal_daily_limit')
    expect(Spree::Pos::MealSwipe.where(workspace: other.workspace).pluck(:result)).to eq(['limit'])
  end

  it 'adds a sponsor with credit terms, reports the meals and exports its statement' do
    reader = credit_staff(store, branch, PosCreditHelpers::MANAGER + [PosMealHelpers::CAPS::MEAL_ACCOUNT_MANAGE,
                                                                      PosMealHelpers::CAPS::REPORT_READ, PosMealHelpers::CAPS::REPORT_EXPORT])
    post '/api/v3/admin/pos/meal_sponsors', headers: headers(reader), params: {
      branch_id: branch.prefixed_id, name: 'Công ty XYZ', phone: '0281234567', credit_limit: '2000000', due_days: 30,
      subsidy_mode: 'none', statement_day: 25
    }, as: :json
    expect(response).to have_http_status(:created), response.body
    sponsor = Spree::Pos::MealSponsor.find_by_prefix_id!(response.parsed_body.dig('data', 'id'))
    expect(sponsor.credit_account.credit_limit).to eq(2_000_000)

    account = meal_account!(store, manager, branch, meal_sponsor_id: sponsor.prefixed_id, pay_mode: 'sponsor')
    sale = meal_sale(store, branch, cashier, price: 35_000)
    swipe(sale, account)
    post "/api/v3/admin/pos/workspaces/#{sale.workspace.prefixed_id}/complete", headers: headers,
                                                                                params: editing_params(sale).merge(meal_sponsor: true), as: :json
    expect(response).to have_http_status(:ok), response.body

    get '/api/v3/admin/pos/reports/meals', headers: headers(reader), params: { branch_id: branch.prefixed_id, from: '2026-11-12', to: '2026-11-12' }
    expect(response).to have_http_status(:ok), response.body
    expect(response.parsed_body['data']).to contain_exactly(include('result' => 'ok', 'meals' => 1, 'sponsor' => 'Công ty XYZ'))

    post '/api/v3/admin/pos/exports', headers: headers(reader), params: {
      branch_id: branch.prefixed_id, report_type: 'meal_statement',
      filters: { from: '2026-11-12', to: '2026-11-12', meal_sponsor_id: sponsor.prefixed_id }
    }, as: :json
    expect(response).to have_http_status(:accepted), response.body
    export = Spree::Pos::ExportRequest.find_by_prefix_id!(response.parsed_body.dig('data', 'id'))
    Spree::Pos::GenerateExportJob.perform_now(export.id)
    expect(export.reload).to have_attributes(status: 'ready', row_count: 1)
  end

  it 'grants wallet approvals only on the meal account, bound to its version' do
    account = meal_account!(store, manager, branch)
    post '/api/v3/admin/pos/approvals', headers: headers(manager), params: {
      branch_id: branch.prefixed_id, requester_id: cashier.prefixed_id, meal_account_id: account.prefixed_id,
      action_name: Spree::Pos::Approval::MEAL_REFUND_ACTION, amount: '50000', revision: account.revision,
      expires_at: 10.minutes.from_now.iso8601
    }, as: :json
    expect(response).to have_http_status(:created), response.body
    approval = Spree::Pos::Approval.find_by_prefix_id!(response.parsed_body.dig('data', 'id'))
    expect(approval).to have_attributes(subject_type: 'Spree::Pos::MealAccount', subject_id: account.id, amount: 50_000)

    sale = meal_sale(store, branch, cashier, price: 35_000)
    post '/api/v3/admin/pos/approvals', headers: headers(manager), params: {
      branch_id: branch.prefixed_id, requester_id: cashier.prefixed_id, workspace_id: sale.workspace.prefixed_id,
      action_name: Spree::Pos::Approval::MEAL_OVERRIDE_ACTION, revision: sale.workspace.reload.revision,
      expires_at: 10.minutes.from_now.iso8601
    }, as: :json
    expect(response).to have_http_status(:conflict)
  end
end
