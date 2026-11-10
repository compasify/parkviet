# frozen_string_literal: true

require 'spree/api/testing_support/v3/base'
require_relative '../../../support/pos_shift_helpers'

# Reports and exports: server-side scope (own shifts unless the reader holds
# report access at the branch), allowlisted filters, branch-timezone dates,
# overnight shifts, spreadsheet-safe CSV, export TTL and re-authorization.
RSpec.describe 'POS reports API', type: :request do
  include PosShiftHelpers
  include ActiveSupport::Testing::TimeHelpers

  let(:store) { create(:store, default_currency: 'VND', supported_currencies: 'VND') }
  let(:branch) { returns_branch(store) }
  let(:cashier) { credit_staff(store, branch, PosShiftHelpers::LEAD) }
  let(:colleague) { credit_staff(store, branch, PosShiftHelpers::LEAD) }
  let(:reader) do
    credit_staff(store, branch, PosShiftHelpers::MANAGER + [Spree::Pos::Capabilities::REPORT_READ, Spree::Pos::Capabilities::REPORT_EXPORT])
  end
  let(:zone) { ActiveSupport::TimeZone[branch.timezone] }

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

  def report(user, type, **query)
    call(user, :get, "reports/#{type}", { branch_id: branch.prefixed_id }.merge(query))
  end

  def today
    Time.now.in_time_zone(branch.timezone).to_date.iso8601
  end

  def business_today
    Spree::Pos::BusinessDay.for(branch, Spree::Pos::Workspace.business_now).iso8601
  end

  describe 'scope' do
    before do
      paid_sale(store, branch, cashier: cashier, price: 40_000)
      paid_sale(store, branch, cashier: colleague, price: 60_000)
    end

    it 'shows a cashier only their own shifts and a report reader the whole branch' do
      own = report(cashier, :sales, from: business_today, to: business_today)
      expect(response).to have_http_status(:ok)
      expect(own['data'].map { |row| row['total'] }).to eq(['40000.0'])
      expect(own['meta']).to include('scope' => 'own', 'timezone' => 'Asia/Ho_Chi_Minh')
      expect(own.dig('meta', 'summary')).to include('orders' => 1, 'sales_total' => '40000.0')

      all = report(reader, :sales, from: business_today, to: business_today)
      expect(all['data'].map { |row| row['total'] }).to contain_exactly('40000.0', '60000.0')
      expect(all.dig('meta', 'summary')).to include('sales_total' => '100000.0')
      receipts = report(reader, :receipts, from: today, to: today, kind: 'cash')
      expect(receipts.dig('meta', 'summary')).to include('total' => '100000.0', 'sale' => '100000.0', 'collection' => '0.0')
    end

    it 'refuses other cashiers, other shifts and non-members' do
      report(cashier, :sales, cashier_id: colleague.prefixed_id)
      expect(response).to have_http_status(:forbidden)
      other_shift = Spree::Pos::Shift.find_by!(owner: colleague)
      report(cashier, :receipts, shift_id: other_shift.prefixed_id)
      expect(response).to have_http_status(:not_found)

      elsewhere = credit_branch(store)
      outsider = credit_staff(store, elsewhere, PosShiftHelpers::MANAGER + [Spree::Pos::Capabilities::REPORT_READ])
      report(outsider, :sales)
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe 'filters' do
    it 'accepts only allowlisted filters and bounded dates' do
      report(reader, :sales, foo: '1')
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body.dig('error', 'message')).to include('foo')
      report(reader, :sales, from: '07/11/2026')
      expect(response).to have_http_status(:unprocessable_content)
      report(reader, :sales, from: '2025-01-01', to: '2026-11-07')
      expect(response).to have_http_status(:unprocessable_content)
      report(reader, :sales, from: '2026-11-07', to: '2026-11-01')
      expect(response).to have_http_status(:unprocessable_content)
      report(reader, :sales, section: 'everything')
      expect(response).to have_http_status(:unprocessable_content)
      report(reader, :receivables, from: today)
      expect(response).to have_http_status(:unprocessable_content)
      call(reader, :get, 'reports/payroll', { branch_id: branch.prefixed_id })
      expect(response).to have_http_status(:not_found)
      report(reader, :receivables, status: 'overdue')
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'dates' do
    it 'counts days in the branch timezone and keeps an overnight shift on both days' do
      travel_to zone.local(2026, 11, 5, 22, 0)
      shift = open_shift(store, branch, cashier, float: 100_000)
      travel_to zone.local(2026, 11, 5, 23, 30)
      paid_sale(store, branch, cashier: cashier, price: 30_000)
      travel_to zone.local(2026, 11, 6, 0, 30)
      paid_sale(store, branch, cashier: cashier, price: 20_000)
      travel_to zone.local(2026, 11, 6, 1, 0)
      count_shift(shift, cashier, 150_000)
      close_shift(shift, cashier)
      travel_back

      # 00:30 is before the 04:00 cutoff, so both sales belong to 5 November.
      fifth = report(reader, :sales, from: '2026-11-05', to: '2026-11-05')['data']
      expect(fifth.map { |row| row['total'] }).to contain_exactly('30000.0', '20000.0')
      expect(fifth.map { |row| row['business_date'] }.uniq).to eq(['2026-11-05'])
      expect(report(reader, :sales, from: '2026-11-06', to: '2026-11-06')['data']).to be_empty
      sold_at = fifth.find { |row| row['total'] == '20000.0' }['sold_at']
      expect(sold_at).to start_with('2026-11-06T00:30:00').and end_with('+07:00')

      %w[2026-11-05 2026-11-06].each do |day|
        cashbook = report(reader, :cashbook, from: day, to: day)
        expect(cashbook['data'].map { |row| row['running_expected'] }).to eq(['130000.0', '150000.0'])
        expect(cashbook.dig('meta', 'summary', 'shifts').first).to include('expected' => '150000.0', 'counted' => '150000.0')
      end
      expect(report(reader, :cashbook, from: '2026-11-07', to: '2026-11-07')['data']).to be_empty
      expect(report(reader, :closures, from: '2026-11-06', to: '2026-11-06')['data'].first).to include('variance' => '0.0')
      expect(report(reader, :closures, from: '2026-11-05', to: '2026-11-05')['data']).to be_empty
    ensure
      travel_back
    end

    it 'reports late evidence by its actual received time and shows when it was booked' do
      shift = open_shift(store, branch, reader)
      actual = 1.day.ago
      Spree::Pos::RecordUnsolicitedFunds.call(store: store, staff: reader, key: SecureRandom.uuid, branch_id: branch.prefixed_id,
                                              shift_id: shift.prefixed_id, kind: 'bank_manual', handed_amount: '70000',
                                              reference: 'FT-LATE', receiving_account: 'VCB-1', received_at: actual.iso8601)
      yesterday = actual.in_time_zone(branch.timezone).to_date.iso8601
      rows = report(reader, :receipts, from: yesterday, to: yesterday, source: 'unsolicited')['data']
      expect(rows.length).to eq(1)
      expect(rows.first).to include('kind' => 'bank_manual', 'source' => 'unsolicited', 'received_net' => '70000.0')
      expect(rows.first['booked_at'].to_date).to be > rows.first['received_at'].to_date
      expect(report(reader, :receipts, from: today, to: today)['data']).to be_empty
    end
  end

  describe 'blind count' do
    it 'keeps an open shift out of its own cashier cashbook until it is closed' do
      shift = open_shift(store, branch, cashier, float: 50_000)
      move_cash(shift, cashier, 'cash_in', 10_000)
      expect(report(cashier, :cashbook, from: today, to: today)['data']).to be_empty
      expect(report(reader, :cashbook, from: today, to: today)['data'].length).to eq(1)

      state = call(cashier, :get, "shifts/#{shift.prefixed_id}/closure")['data']
      expect(state['count']).to include('expected' => nil, 'variance' => nil)
      call(cashier, :post, "shifts/#{shift.prefixed_id}/count", { counted: '60000' })
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body['data']).to include('expected' => '60000.0', 'variance' => '0.0')
      call(cashier, :post, "shifts/#{shift.prefixed_id}/close", {})
      expect(response).to have_http_status(:created)
      expect(report(cashier, :cashbook, from: today, to: today)['data'].length).to eq(1)
    end

    it 'returns checklist items with a blocked count' do
      shift = open_shift(store, branch, cashier)
      sale = open_sale(store, branch, cashier: cashier, product: stocked_product(store, branch, price: 10_000))
      cash_tender(sale, 5_000, 5_000)
      call(cashier, :post, "shifts/#{shift.prefixed_id}/count", { counted: '5000' })
      expect(response).to have_http_status(:conflict)
      details = response.parsed_body.dig('error', 'details')
      expect(details['reason']).to eq('close_blocked')
      expect(details.dig('checklist', 'blocking').first).to include('type' => 'workspace_money',
                                                                    'workspace_id' => sale.workspace.prefixed_id)
    end
  end

  describe 'exports' do
    let(:injected) { "=HYPERLINK(\"http://evil.test\",\"x\")" }

    def export!(user, type = 'cashbook', filters = { from: today, to: today }, key: SecureRandom.uuid)
      post '/api/v3/admin/pos/exports', headers: { 'Authorization' => "Bearer #{token_for(user)}", 'Idempotency-Key' => key },
                                        params: { branch_id: branch.prefixed_id, report_type: type, filters: filters,
                                                  idempotency_key: key }, as: :json
      response.parsed_body
    end

    def link!(user, export)
      post "/api/v3/admin/pos/exports/#{export.prefixed_id}/download_link", headers: { 'Authorization' => "Bearer #{token_for(user)}" },
                                                                            as: :json
      response.parsed_body.dig('data', 'url')
    end

    it 'builds a spreadsheet-safe CSV only for the requester while they may still export' do
      shift = open_shift(store, branch, reader, float: 100_000)
      move_cash(shift, reader, 'cash_out', 10_000, reason: injected, evidence: '+cmd', confirmer: cashier)
      move_cash(shift, reader, 'cash_in', 5_000, reason: ' @SUM(A1)', evidence: '-2+3')

      export!(cashier)
      expect(response).to have_http_status(:forbidden)
      key = SecureRandom.uuid
      created = export!(reader, key: key)
      expect(response).to have_http_status(:accepted)
      expect(created.dig('data', 'status')).to eq('queued')
      expect(created.dig('data', 'filters')).to include('from' => today, 'to' => today)
      export!(reader, key: key)
      expect(response).to have_http_status(:accepted)
      expect(Spree::Pos::ExportRequest.where(requester: reader).count).to eq(1)

      export = Spree::Pos::ExportRequest.find_by_prefix_id!(created.dig('data', 'id'))
      expect(export.full_scope).to be(true)
      Spree::Pos::GenerateExportJob.perform_now(export.id)
      Spree::Pos::GenerateExportJob.perform_now(export.id)
      expect(export.reload).to have_attributes(status: 'ready', row_count: 2)
      expect(export.expires_at).to be_within(1.minute).of(24.hours.from_now)

      url = link!(reader, export)
      expect(url).to start_with('/api/v3/admin/pos/export_files/')
      get url
      expect(response).to have_http_status(:ok)
      expect(response.headers['Content-Disposition']).to include('attachment').and include('.csv')
      body = response.body.dup.force_encoding(Encoding::UTF_8)
      expect(body).to start_with("﻿")
      csv = CSV.parse(body.delete_prefix("﻿"))
      expect(csv.first).to include('reason', 'amount', 'running_expected')
      reason = csv.first.index('reason')
      amount = csv.first.index('amount')
      evidence = csv.first.index('evidence_reference')
      expect(csv[1][reason]).to eq("'#{injected}")
      expect(csv[1][evidence]).to eq("'+cmd")
      expect(csv[1][amount]).to eq('-10000.0')
      expect(csv[2][reason]).to eq("'@SUM(A1)")
      expect(csv[2][evidence]).to eq("'-2+3")
      get '/api/v3/admin/pos/export_files/forged-token'
      expect(response).to have_http_status(:not_found)

      other = credit_staff(store, branch, PosShiftHelpers::MANAGER + [Spree::Pos::Capabilities::REPORT_EXPORT])
      link!(other, export)
      expect(response).to have_http_status(:not_found)

      # A branch-wide export needs branch-wide report access again at download.
      membership = Spree::Pos::StaffMembership.find_by!(staff: reader, branch: branch)
      membership.update!(capabilities: membership.capabilities - [Spree::Pos::Capabilities::REPORT_READ])
      link!(reader, export)
      expect(response).to have_http_status(:forbidden)
      membership.update!(capabilities: membership.capabilities + [Spree::Pos::Capabilities::REPORT_READ] -
                                       [Spree::Pos::Capabilities::REPORT_EXPORT])
      link!(reader, export)
      expect(response).to have_http_status(:forbidden)
    end

    it 'refuses expired files and purges them' do
      created = export!(reader, 'closures')
      export = Spree::Pos::ExportRequest.find_by_prefix_id!(created.dig('data', 'id'))
      Spree::Pos::GenerateExportJob.perform_now(export.id)
      expect(export.reload.file).to be_attached
      url = link!(reader, export)

      travel 25.hours do
        @tokens = nil
        link!(reader, export)
        expect(response).to have_http_status(:gone)
        expect(response.parsed_body.dig('error', 'code')).to eq('export_expired')
        get url
        expect(response.status).to be_in([404, 410])
        Spree::Pos::PurgeExpiredExportsJob.perform_now
      end
      expect(export.reload.status).to eq('expired')
      expect(export.file).not_to be_attached
    end

    it 'fails an export whose requester lost access before it ran' do
      created = export!(reader, 'sales')
      export = Spree::Pos::ExportRequest.find_by_prefix_id!(created.dig('data', 'id'))
      Spree::Pos::StaffMembership.find_by!(staff: reader, branch: branch).update!(status: 'disabled')
      Spree::Pos::GenerateExportJob.perform_now(export.id)
      expect(export.reload).to have_attributes(status: 'failed', error_message: 'Access to this report was withdrawn.')
      expect(export.file).not_to be_attached
    end

    it 'exports every row in keyset batches' do
      shift = open_shift(store, branch, reader, float: 0)
      stub_const('Spree::Pos::Reports::Base::BATCH', 2)
      5.times { |index| move_cash(shift, reader, 'cash_in', 1_000 * (index + 1), reason: "Lần #{index + 1}") }
      created = export!(reader)
      export = Spree::Pos::ExportRequest.find_by_prefix_id!(created.dig('data', 'id'))
      Spree::Pos::GenerateExportJob.perform_now(export.id)
      expect(export.reload.row_count).to eq(5)
      body = export.file.download.force_encoding(Encoding::UTF_8).delete_prefix("﻿")
      expect(CSV.parse(body).drop(1).map { |row| row[csv_index(body, 'reason')] }).to eq((1..5).map { |n| "Lần #{n}" })
    end

    def csv_index(body, column)
      CSV.parse(body).first.index(column)
    end
  end

  describe 'blind count in reports' do
    it 'hides cash totals of the reader own uncounted open shift' do
      shift = open_shift(store, branch, cashier, float: 0)
      paid_sale(store, branch, cashier: cashier, price: 40_000)
      expect(report(cashier, :receipts, from: today, to: today).dig('meta', 'summary', 'cash')).to be_nil
      expect(report(cashier, :receipts, from: today, to: today)['data']).to be_empty
      expect(report(reader, :receipts, from: today, to: today).dig('meta', 'summary', 'cash')).to eq('40000.0')
      count_shift(shift, cashier, 40_000)
      expect(report(cashier, :receipts, from: today, to: today).dig('meta', 'summary', 'cash')).to eq('40000.0')
      expect(report(cashier, :cashbook, from: today, to: today)['data'].length).to eq(1)
    end
  end

  describe 'summaries' do
    it 'pages the cashbook shift summary with the true count and sums receivables in SQL' do
      stub_const('Spree::Pos::Reports::Cashbook::SHIFT_PAGE', 1)
      first = open_shift(store, branch, cashier, float: 10_000)
      second = open_shift(store, branch, colleague, float: 20_000)
      move_cash(second, colleague, 'cash_in', 5_000)
      page_two = report(reader, :cashbook, from: today, to: today, shift_page: '2').dig('meta', 'summary')
      expect(page_two).to include('shift_count' => 2, 'shift_page' => 2, 'shift_pages' => 2)
      expect(page_two['shifts'].map { |row| row['shift_id'] }).to eq([second.prefixed_id])
      expect(page_two['shifts'].first).to include('expected' => '25000.0', 'inflow_total' => '5000.0', 'movement_count' => 1)
      report(reader, :cashbook, shift_page: 'x')
      expect(response).to have_http_status(:unprocessable_content)
      expect(first).to be_persisted

      profile = credit_customer(store, reader)
      configure_credit(store, reader, branch, profile, limit: 1_000_000)
      sale = credit_sale(store, branch, price: 300_000, cashier: cashier, product: stocked_product(store, branch, price: 300_000))
      assign(sale, profile)
      complete_on_credit(sale, approve_credit(sale, reader, 300_000)['approval_id'])
      summary = report(reader, :receivables).dig('meta', 'summary')
      expect(summary).to include('balance' => '300000.0', 'overdue' => '0.0', 'current' => '300000.0', 'days_over_90' => '0.0')
    end
  end

  describe 'command receipts' do
    it 'rechecks every shift and report command by its key' do
      shift = open_shift(store, branch, cashier, float: 100_000)
      commands = []
      recorded = lambda do |user, path, body|
        key = SecureRandom.uuid
        post "/api/v3/admin/pos/#{path}", headers: { 'Authorization' => "Bearer #{token_for(user)}", 'Idempotency-Key' => key },
                                          params: body.merge(idempotency_key: key), as: :json
        expect(response.status).to be_between(200, 202), response.body
        commands << [user, key, response.parsed_body['data']]
        response.parsed_body['data']
      end
      recorded.call(cashier, "shifts/#{shift.prefixed_id}/cash_movements", { kind: 'cash_in', amount: '1000', reason: 'Tiền lẻ' })
      request = recorded.call(cashier, "shifts/#{shift.prefixed_id}/cash_movements",
                              { kind: 'safe_drop', amount: '1000', reason: 'Nộp', evidence_reference: 'TUI' })
      recorded.call(reader, "cash_movement_requests/#{request['id']}/confirm", {})
      counted = recorded.call(cashier, "shifts/#{shift.prefixed_id}/count", { counted: '90000', reason: 'Thiếu' })
      recorded.call(reader, "shifts/#{shift.prefixed_id}/close_approval", { revision: counted['revision'] })
      recorded.call(cashier, "shifts/#{shift.prefixed_id}/close", {})
      recorded.call(reader, 'exports', { branch_id: branch.prefixed_id, report_type: 'closures', filters: {} })

      commands.each do |(user, key, data)|
        get '/api/v3/admin/pos/command_receipts', headers: { 'Authorization' => "Bearer #{token_for(user)}" },
                                                  params: { idempotency_key: key }
        expect(response).to have_http_status(:ok), response.body
        expect(response.parsed_body['data']).to eq(data)
      end
    end
  end

  it 'escapes formula cells, also behind leading whitespace, but keeps plain numbers' do
    cell = ->(value) { Spree::Pos::Reports::ExportFile.cell(value) }
    expect(%w[=1+1 +1 -A1 @x].map(&cell)).to eq(%w['=1+1 '+1 '-A1 '@x])
    expect(cell.call("\rX")).to eq("'\rX")
    expect(cell.call("\tX")).to eq("'\tX")
    expect(cell.call('  =1+1')).to eq("'  =1+1")
    expect([cell.call('-10000.0'), cell.call('250000'), cell.call(nil), cell.call('Gạo')]).to eq(['-10000.0', '250000', '', 'Gạo'])
  end
end
