# frozen_string_literal: true

require 'spree/api/testing_support/v3/base'
require_relative '../../../support/pos_credit_helpers'

# Order source: each POS sale is tagged counter (default), facebook, zalo or
# other; the sales report groups completed sales by it in the branch day.
RSpec.describe 'POS order sources API', type: :request do
  include PosCreditHelpers
  include ActiveSupport::Testing::TimeHelpers

  let(:store) { create(:store, default_currency: 'VND', supported_currencies: 'VND') }
  let(:branch) { credit_branch(store) }
  let(:manager) { credit_staff(store, branch, PosCreditHelpers::MANAGER) }
  let(:reader) { credit_staff(store, branch, PosCreditHelpers::MANAGER + [Spree::Pos::Capabilities::REPORT_READ]) }
  let(:zone) { ActiveSupport::TimeZone[branch.timezone] }

  before { allow(Spree::Store).to receive(:default).and_return(store) }

  def token_for(user)
    @tokens ||= {}
    @tokens[user.id] ||= begin
      post '/api/v3/admin/auth/login', params: { email: user.email, password: 'secret123' }, as: :json
      response.parsed_body.fetch('token')
    end
  end

  def headers(user, key = nil)
    { 'Authorization' => "Bearer #{token_for(user)}" }.merge(key ? { 'Idempotency-Key' => key } : {})
  end

  def set_source(sale, value, user: sale.cashier, key: SecureRandom.uuid, revision: nil)
    workspace = sale.workspace.reload
    body = { expected_revision: revision || workspace.revision, lease_generation: workspace.lease_generation,
             editor_id: sale.editor_id, order_source: value, idempotency_key: key }
    post "/api/v3/admin/pos/workspaces/#{workspace.prefixed_id}/order_source", headers: headers(user, key), params: body, as: :json
    response.parsed_body
  end

  def report(user, **query)
    get '/api/v3/admin/pos/reports/sales', headers: headers(user), params: { branch_id: branch.prefixed_id }.merge(query)
    response.parsed_body
  end

  def sell(price, source: nil, credit: 0)
    sale = credit_sale(store, branch, price: price)
    Spree::Pos::Workspaces::SetOrderSource.call(**editing_args(sale), order_source: source) if source
    if credit.positive?
      profile = credit_customer(store, manager)
      configure_credit(store, manager, branch, profile, limit: 10_000_000)
      assign(sale, profile)
      take_tender(sale, 'cash', price - credit) if price > credit
      complete_on_credit(sale, approve_credit(sale, manager, credit)['approval_id'])
    else
      take_tender(sale, 'cash', price)
      Spree::Pos::Workspaces::Complete.call(**editing_args(sale))
    end
    sale
  end

  def source_rows(body)
    body.dig('meta', 'summary', 'by_source').index_by { |row| row['order_source'] }
  end

  describe 'setting the source' do
    it 'defaults to counter, changes once per key with an audit entry, and refuses unknown values' do
      sale = credit_sale(store, branch, price: 50_000)
      expect(sale.workspace.order_source).to eq('counter')

      key = SecureRandom.uuid
      original = sale.workspace.reload.revision
      first = set_source(sale, 'facebook', key: key)['data']
      expect(response).to have_http_status(:ok), response.body
      expect(first).to include('order_source' => 'facebook', 'revision' => original + 1)
      revision = sale.workspace.reload.revision
      replay = set_source(sale, 'facebook', key: key, revision: original)['data']
      expect(replay).to eq(first)
      expect(sale.workspace.reload.revision).to eq(revision)
      expect(Spree::Pos::AuditEntry.where(action: 'workspace.order_source.set').sole.metadata).
        to include('before' => 'counter', 'order_source' => 'facebook')

      # Picking the current source again changes nothing.
      set_source(sale, 'facebook')
      expect(response).to have_http_status(:ok)
      expect(sale.workspace.reload.revision).to eq(revision)
      expect(Spree::Pos::AuditEntry.where(action: 'workspace.order_source.set').count).to eq(1)

      set_source(sale, 'tiktok')
      expect(response).to have_http_status(:conflict)
      expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('order_source_invalid')
      expect(sale.workspace.reload.order_source).to eq('facebook')
    end

    it 'can still change while a payment is taken, but not once the sale is completed' do
      sale = credit_sale(store, branch, price: 50_000)
      take_tender(sale, 'cash', 50_000)
      set_source(sale, 'zalo')
      expect(response).to have_http_status(:ok), response.body

      Spree::Pos::Workspaces::Complete.call(**editing_args(sale))
      set_source(sale, 'other')
      expect(response).to have_http_status(:conflict)
      expect(sale.workspace.reload).to have_attributes(order_source: 'zalo', operational_status: 'completed')

      get '/api/v3/admin/pos/orders', headers: headers(sale.cashier), params: { branch_id: branch.prefixed_id }
      expect(response).to have_http_status(:ok), response.body
      expect(response.parsed_body['data'].sole).to include('order_source' => 'zalo')
    end

    it 'hides the sale from staff who do not hold it' do
      sale = credit_sale(store, branch, price: 50_000)
      set_source(sale, 'zalo', user: reader)
      expect(response).to have_http_status(:not_found)
      expect(sale.workspace.reload.order_source).to eq('counter')
    end

    it 'refuses unknown values in the database too' do
      sale = credit_sale(store, branch, price: 50_000)
      expect do
        Spree::Pos::Workspace.transaction(requires_new: true) { sale.workspace.update_column(:order_source, 'tiktok') }
      end.to raise_error(ActiveRecord::StatementInvalid)
    end
  end

  describe 'sales by source' do
    it 'groups completed sales of the branch day by source, with what is still owed' do
      sell(100_000)
      sell(80_000, source: 'facebook', credit: 30_000)
      sell(20_000, source: 'facebook')
      sell(60_000, source: 'zalo', credit: 60_000)
      draft = credit_sale(store, branch, price: 999_000)
      Spree::Pos::Workspaces::SetOrderSource.call(**editing_args(draft), order_source: 'other')

      body = report(reader)
      expect(response).to have_http_status(:ok), response.body
      expect(body.dig('meta', 'summary', 'by_source').map { |row| row['order_source'] }).to eq(%w[counter facebook zalo other grabfood shopeefood kiosk])
      rows = source_rows(body)
      expect(rows['counter']).to include('orders' => 1, 'sales_total' => '100000.0', 'owed' => '0.0')
      expect(rows['facebook']).to include('orders' => 2, 'sales_total' => '100000.0', 'owed' => '30000.0')
      expect(rows['zalo']).to include('orders' => 1, 'sales_total' => '60000.0', 'owed' => '60000.0')
      expect(rows['other']).to include('orders' => 0, 'sales_total' => '0.0', 'owed' => '0.0')
      expect(body['data'].map { |row| row['order_source'] }).to contain_exactly('counter', 'facebook', 'facebook', 'zalo')

      filtered = report(reader, order_source: 'facebook')
      expect(filtered['data'].map { |row| row['total'] }).to contain_exactly('80000.0', '20000.0')
      expect(filtered.dig('meta', 'summary')).to include('orders' => 2, 'sales_total' => '100000.0')
      report(reader, order_source: 'tiktok')
      expect(response).to have_http_status(:unprocessable_content)
    end

    it 'counts days in the branch timezone and keeps other branches out' do
      travel_to zone.local(2026, 11, 5, 23, 30)
      sell(30_000, source: 'zalo')
      travel_to zone.local(2026, 11, 6, 0, 30)
      sell(20_000, source: 'zalo')
      travel_back

      elsewhere = credit_branch(store)
      other = credit_sale(store, elsewhere, price: 70_000)
      Spree::Pos::Workspaces::SetOrderSource.call(**editing_args(other), order_source: 'zalo')
      take_tender(other, 'cash', 70_000)
      Spree::Pos::Workspaces::Complete.call(**editing_args(other))

      first = source_rows(report(reader, from: '2026-11-05', to: '2026-11-05'))
      expect(first['zalo']).to include('orders' => 2, 'sales_total' => '50000.0')
      sixth = source_rows(report(reader, from: '2026-11-06', to: '2026-11-06'))
      expect(sixth['zalo']).to include('orders' => 0, 'sales_total' => '0.0')
      both = source_rows(report(reader, from: '2026-11-05', to: '2026-11-06'))
      expect(both['zalo']).to include('orders' => 2, 'sales_total' => '50000.0')
      today = Time.now.in_time_zone(branch.timezone).to_date.iso8601
      expect(source_rows(report(reader, from: today, to: today))['zalo']).to include('orders' => 0)
    ensure
      travel_back
    end

    it 'shows a cashier only their own sales and refuses non-members' do
      mine = sell(40_000, source: 'facebook')
      sell(60_000, source: 'facebook')
      expect(source_rows(report(mine.cashier))['facebook']).to include('orders' => 1, 'sales_total' => '40000.0')

      outsider = credit_staff(store, credit_branch(store), PosCreditHelpers::MANAGER + [Spree::Pos::Capabilities::REPORT_READ])
      report(outsider)
      expect(response).to have_http_status(:forbidden)
    end
  end
end
