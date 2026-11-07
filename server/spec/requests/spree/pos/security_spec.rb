# frozen_string_literal: true

require 'csv'
require 'spree/api/testing_support/v3/base'
require_relative '../../../support/pos_shift_helpers'
require_relative '../../../support/pos_trace_helpers'

# Negative security suite over the HTTP surface: POS staff cannot write
# through the core Admin API, cannot read or act on another branch's or
# store's POS records, approvals are bound to one use, the customer display
# token and staff tokens never cross, cookies alone authorize nothing, CSV
# exports are formula-safe and expire, and personal data stays masked.
RSpec.describe 'POS security', type: :request do
  include PosShiftHelpers
  include PosTraceHelpers
  include ActiveSupport::Testing::TimeHelpers

  let(:store) { create(:store, default_currency: 'VND', supported_currencies: 'VND') }
  let(:branch) { returns_branch(store) }
  let(:everything) do
    caps = Spree::Pos::Capabilities
    PosShiftHelpers::MANAGER + [caps::CREDIT_SELL, caps::REPORT_READ, caps::REPORT_EXPORT, caps::INVENTORY_MANAGE,
                                caps::INVENTORY_TRACE, caps::TAKEOVER, caps::CUSTOMER]
  end
  let(:cashier) { credit_staff(store, branch, PosShiftHelpers::LEAD) }
  let(:manager) { credit_staff(store, branch, everything) }

  before { allow(Spree::Store).to receive(:default).and_return(store) }

  def token_for(user)
    @tokens ||= {}
    @tokens[user.id] ||= begin
      post '/api/v3/admin/auth/login', params: { email: user.email, password: 'secret123' }, as: :json
      expect(response).to have_http_status(:ok)
      response.parsed_body.fetch('token')
    end
  end

  def auth(user, extra = {})
    { 'Authorization' => "Bearer #{token_for(user)}" }.merge(extra)
  end

  def call(user, verb, path, body = {}, key: SecureRandom.uuid, headers: {})
    send(verb, "/api/v3/admin/pos/#{path}", headers: auth(user, 'Idempotency-Key' => key).merge(headers),
                                            params: verb == :get ? body : body.merge(idempotency_key: key), as: verb == :get ? nil : :json)
    response.parsed_body
  end

  def core(user, verb, path, body = {})
    send(verb, "/api/v3/admin/#{path}", headers: auth(user), params: body, as: :json)
    response
  end

  describe 'core Admin API writes by POS staff' do
    it 'refuses order, payment, refund, return and stock writes and leaves every ledger untouched' do
      sale = paid_sale(store, branch, cashier: cashier, price: 70_000, quantity: 2)
      order = sale.workspace.order
      payment = order.payments.first
      level = branch.stock_location.stock_level(sale.product.default_variant)
      ledger = -> { [Spree::Order.count, Spree::Payment.count, Spree::Refund.count, Spree::StockMovement.count, Spree::Return.count, order.reload.attributes, payment.reload.attributes, level.reload.count_on_hand] }
      before = ledger.call

      [manager, cashier].each do |user|
        attempts = [
          [:post, 'orders', { order: {} }],
          [:patch, "orders/#{order.prefixed_id}", { order: { email: 'evil@example.test' } }],
          [:patch, "orders/#{order.prefixed_id}/complete", {}],
          [:patch, "orders/#{order.prefixed_id}/cancel", {}],
          [:post, "orders/#{order.prefixed_id}/items", { variant_id: sale.product.default_variant.prefixed_id, quantity: 1 }],
          [:post, "orders/#{order.prefixed_id}/payments", { payment_method_id: payment.payment_method.prefixed_id, amount: '1' }],
          [:patch, "orders/#{order.prefixed_id}/payments/#{payment.prefixed_id}/capture", {}],
          [:patch, "orders/#{order.prefixed_id}/payments/#{payment.prefixed_id}/void", {}],
          [:post, "orders/#{order.prefixed_id}/refunds", { payment_id: payment.prefixed_id, amount: '70000' }],
          [:post, "orders/#{order.prefixed_id}/returns", {}],
          [:patch, "stock_levels/#{level.prefixed_id}", { count_on_hand: 99 }],
          [:post, 'stock_levels/bulk_upsert', { stock_levels: [] }]
        ]
        attempts.each do |verb, path, body|
          status = core(user, verb, path, body).status
          # Refused by permission (403); a record outside the reader's scope is not found (404).
          expect(status).to be_in(path.start_with?('stock_levels/') ? [403, 404] : [403]), "#{verb.upcase} #{path} answered #{status}"
        end
      end
      expect(ledger.call).to eq(before)
    end
  end

  describe 'records of another branch or store' do
    let(:other_branch) { returns_branch(store) }
    # Works at another branch of the same store with every capability.
    let(:outsider) { credit_staff(store, other_branch, everything) }

    it 'never shows or acts on another branch\'s POS records' do
      sale = paid_sale(store, branch, cashier: manager, price: 100_000, quantity: 3)
      received = return_and_receive(store, manager, branch, sale, quantity: 1)
      refund = request_refund(store, manager, received, amount: 100_000)
      profile = credit_customer(store, manager)
      account = configure_credit(store, manager, branch, profile, limit: 1_000_000)
      debt = credit_order(store, branch, manager, profile, price: 50_000)
      collection = Spree::Pos::Collections::Receive.call(
        store: store, staff: manager, key: SecureRandom.uuid, branch_id: branch.prefixed_id, credit_account_id: account.prefixed_id,
        kind: 'cash', amount: '20000', allocations: [{ 'order_id' => debt.workspace.order.prefixed_id, 'amount' => '20000' }]
      )
      funds_id = Spree::Pos::FundsAllocation.where(order_id: sale.workspace.order_id).first.received_funds.prefixed_id
      receipt = call(manager, :get, 'receipts/lookup', { source_id: sale.workspace.prefixed_id })['data']
      shift = sale.workspace.reload.shift
      display = call(manager, :post, 'display_sessions', { shift_id: shift.prefixed_id })['data']
      export = call(manager, :post, 'exports', { branch_id: branch.prefixed_id, report_type: 'sales' })['data']
      milk = stocked_product(store, branch, price: 10_000)
      track_variant!(store, milk.default_variant, 'lot')
      enroll_lots!(branch, milk.default_variant, [['LOT-A', Date.current + 9, 3]], opened_by: manager)
      phone = stocked_product(store, branch, price: 10_000)
      track_variant!(store, phone.default_variant, 'serial')
      enroll_serials!(branch, phone.default_variant, ['IMEI-SECRET'], opened_by: manager)
      draft = open_sale(store, branch, cashier: manager, product: stocked_product(store, branch, price: 5_000))

      reads = {
        "workspaces/#{draft.workspace.prefixed_id}" => {},
        "received_funds/#{funds_id}" => {},
        "collections/#{collection['id']}" => {},
        "returns/#{received['id']}" => {},
        "refund_requests/#{refund['id']}" => {},
        "receipts/#{receipt['id']}" => {},
        'receipts/lookup' => { source_id: sale.workspace.prefixed_id },
        "shifts/#{shift.prefixed_id}" => {},
        "exports/#{export['id']}" => {},
        "display_sessions/#{display['id']}" => {},
        "orders/#{sale.workspace.order.prefixed_id}" => {},
        'lots' => { branch_id: branch.prefixed_id },
        'serial_units' => { branch_id: branch.prefixed_id },
        'reports/sales' => { branch_id: branch.prefixed_id },
        'receivables' => { branch_id: branch.prefixed_id },
        'operations/metrics' => { branch_id: branch.prefixed_id },
        'received_funds' => { branch_id: branch.prefixed_id }
      }
      reads.each do |path, query|
        call(manager, :get, path, query)
        expect(response).to have_http_status(:ok), "insider could not read #{path}: #{response.status}"
        body = call(outsider, :get, path, query)
        expect(response.status).to be_in([403, 404]), "outsider read #{path}: #{response.status}"
        expect(body.to_json).not_to include('IMEI-SECRET', 'LOT-A', profile.phone)
      end

      Spree::Pos::GenerateExportJob.perform_now(Spree::Pos::ExportRequest.find_by_prefix_id!(export['id']).id)
      colleague = credit_staff(store, branch, everything)
      session = Spree::Pos::DisplaySession.find_by_prefix_id!(display['id'])
      # Each write: who may do it at the branch, the body, and the state it
      # must leave untouched when an outsider tries it. The outsider goes
      # first and must change nothing; then the insider's identical request
      # must succeed, so the refusal is about scope and not a bad request.
      writes = [
        { path: 'returns', insider: manager, state: -> { Spree::Pos::ReturnOperation.count },
          body: lambda {
            { branch_id: branch.prefixed_id, order_id: sale.workspace.order.prefixed_id, reason: 'x',
              lines: [{ sale_line_id: sale_line(sale).prefixed_id, quantity: 1, condition: 'resellable' }] }
          } },
        { path: "refund_requests/#{refund['id']}/approve", insider: colleague, body: -> { {} },
          state: -> { Spree::Pos::RefundRequest.find_by_prefix_id!(refund['id']).approval_id } },
        { path: "workspaces/#{draft.workspace.prefixed_id}/lease", insider: colleague,
          body: -> { { editor_id: SecureRandom.uuid, takeover: true } },
          state: -> { draft.workspace.reload.slice(:lease_holder_id, :lease_generation, :lease_editor_digest) } },
        { path: "display_sessions/#{display['id']}/clear", insider: manager,
          body: -> { { expected_generation: session.reload.generation } }, state: -> { session.reload.generation } },
        { path: "receipts/#{receipt['id']}/prints", insider: manager, body: -> { {} }, state: -> { Spree::Pos::ReceiptPrint.count } },
        { path: "shifts/#{shift.prefixed_id}/count", insider: manager, body: -> { { counted: '0' } },
          state: -> { shift.reload.closing_counted } },
        { path: "exports/#{export['id']}/download_link", insider: manager, body: -> { {} },
          state: -> { Spree::Pos::AuditEntry.where(action: 'report.export_download').count } }
      ]
      writes.each do |write|
        before = write[:state].call
        body = call(outsider, :post, write[:path], write[:body].call)
        expect(response.status).to be_in([403, 404]), "outsider wrote #{write[:path]}: #{response.status}"
        expect(body.to_json).not_to include('/export_files/')
        expect(write[:state].call).to eq(before), "outsider changed state through #{write[:path]}"
        call(write[:insider], :post, write[:path], write[:body].call)
        expect(response.status).to be_between(200, 202), "insider could not #{write[:path]}: #{response.status} #{response.body}"
        expect(write[:state].call).not_to eq(before), "insider request to #{write[:path]} changed nothing"
      end
    end

    it 'never shows another store\'s POS records, even to its own managers' do
      sale = paid_sale(store, branch, cashier: manager, price: 30_000)
      foreign = create(:store, default_currency: 'VND', supported_currencies: 'VND')
      foreign_branch = returns_branch(foreign)
      stranger = credit_staff(foreign, foreign_branch, everything, extra_permissions: %w[read_pos_topology write_pos_topology])
      header = { 'X-Spree-Store-Id' => foreign.prefixed_id }
      allow(Spree::Store).to receive(:default).and_return(foreign)
      ["workspaces/#{sale.workspace.prefixed_id}", "orders/#{sale.workspace.order.prefixed_id}",
       "shifts/#{sale.workspace.shift.prefixed_id}", "branches/#{branch.prefixed_id}"].each do |path|
        call(stranger, :get, path, {}, headers: header)
        expect(response.status).to be_in([403, 404]), "foreign staff read #{path}: #{response.status}"
      end
      call(stranger, :get, 'context', { branch_id: branch.prefixed_id }, headers: header)
      expect(response.status).to be_in([403, 404])
      call(stranger, :put, 'feature_flags/credit', { branch_id: branch.prefixed_id, enabled: false, reason: 'x' }, headers: header)
      expect(response.status).to be_in([403, 404])
    end
  end

  describe 'approvals' do
    let(:profile) { credit_customer(store, manager) }

    before do
      configure_credit(store, manager, branch, profile, limit: 5_000_000)
    end

    def on_credit(price)
      sale = credit_sale(store, branch, price: price)
      assign(sale, profile)
      sale
    end

    def refused(&)
      expect(&).to raise_error(Spree::Pos::Conflict)
    end

    it 'binds a credit approval to one workspace revision, amount and use' do
      sale = on_credit(200_000)
      approval = approve_credit(sale, manager, 200_000)
      other = on_credit(200_000)
      refused { complete_on_credit(other, approval['approval_id']) }

      workspace = sale.workspace.reload
      Spree::Pos::Workspaces::ManageLineItem.add(workspace: workspace, staff: sale.cashier, revision: workspace.revision,
                                                 key: SecureRandom.uuid, lease_generation: workspace.lease_generation,
                                                 editor_id: sale.editor_id, variant_id: sale.product.default_variant.prefixed_id,
                                                 quantity: 1)
      refused { complete_on_credit(sale, approval['approval_id']) }

      fresh = approve_credit(sale, manager, sale.workspace.reload.order.total.to_i)
      complete_on_credit(sale, fresh['approval_id'])
      expect(Spree::Pos::Approval.find_by_prefix_id!(fresh['approval_id']).status).to eq('consumed')
      refused { complete_on_credit(sale, fresh['approval_id']) }
      expect(Spree::Pos::ReceivableEntry.where(order_id: sale.workspace.order_id, kind: 'debit').count).to eq(1)
    end

    it 'refuses revoked, expired, self-granted approvals and approvers who lost the right' do
      revoked = on_credit(100_000)
      grant = approve_credit(revoked, manager, 100_000)
      Spree::Pos::Approvals::Revoke.call(approval: Spree::Pos::Approval.find_by_prefix_id!(grant['approval_id']), staff: manager)
      refused { complete_on_credit(revoked, grant['approval_id']) }

      expired = on_credit(100_000)
      grant = approve_credit(expired, manager, 100_000)
      # Expiry is checked against the database clock.
      Spree::Pos::Approval.find_by_prefix_id!(grant['approval_id']).update_columns(expires_at: Spree::Pos::Workspace.database_now - 1)
      refused { complete_on_credit(expired, grant['approval_id']) }

      lost = on_credit(100_000)
      grant = approve_credit(lost, manager, 100_000)
      membership = Spree::Pos::StaffMembership.find_by!(staff: manager, branch: branch)
      membership.update!(capabilities: membership.capabilities - [Spree::Pos::Capabilities::APPROVE])
      refused { complete_on_credit(lost, grant['approval_id']) }
      membership.update!(capabilities: membership.capabilities + [Spree::Pos::Capabilities::APPROVE])

      seller = credit_staff(store, branch, everything)
      own = credit_sale(store, branch, price: 100_000, cashier: seller)
      assign(own, profile)
      expect { approve_credit(own, seller, 100_000) }.to raise_error(Spree::Pos::Conflict, /own credit sale/)
      expect(Spree::Pos::ReceivableEntry.count).to eq(0)
    end
  end

  describe 'drawer cash without an open shift' do
    def drawer_rows
      [Spree::Pos::ReceivedFunds.count, Spree::Pos::CashMovement.count, Spree::Payment.where(status: 'completed').count, Spree::Refund.count]
    end

    it 'refuses a cash tender confirmation once the sale\'s shift is closed' do
      sale = open_sale(store, branch, cashier: cashier, product: stocked_product(store, branch, price: 30_000))
      method = Spree::Pos::PaymentMethodResolver.new(store: store).available.find { |row| row.kind == 'cash' }
      Spree::Pos::Tenders::Prepare.call(**editing_args(sale), payment_method_id: method.prefixed_id || 'posmethod-cash', amount: '30000')
      attempt = Spree::Pos::TenderAttempt.where(workspace: sale.workspace).sole
      shift = sale.workspace.reload.shift
      # Closing normally waits for the attempt; here the shift was closed
      # elsewhere while the cashier still had the confirm dialog open.
      shift.update_columns(status: 'closed', closed_at: Time.current)
      before = drawer_rows
      workspace = sale.workspace.reload
      call(cashier, :post, "workspaces/#{workspace.prefixed_id}/tender_attempts/#{attempt.prefixed_id}/confirm",
           { expected_revision: workspace.revision, lease_generation: workspace.lease_generation, editor_id: sale.editor_id,
             evidence_kind: 'cash_count', handed_amount: '30000' })
      expect(response).to have_http_status(:conflict)
      expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('shift_closed')
      expect(attempt.reload.status).to eq('prepared')
      expect(drawer_rows).to eq(before)
    end

    it 'refuses unsolicited drawer cash on a shift that is not the caller\'s own open shift' do
      colleague = credit_staff(store, branch, PosShiftHelpers::LEAD)
      theirs = open_shift(store, branch, colleague)
      before = drawer_rows
      call(cashier, :post, 'received_funds', { branch_id: branch.prefixed_id, shift_id: theirs.prefixed_id, kind: 'cash',
                                               handed_amount: '50000', custody: 'drawer' })
      expect(response).to have_http_status(:conflict)
      mine = open_shift(store, branch, cashier)
      count_shift(mine, cashier, 0)
      close_shift(mine, cashier)
      call(cashier, :post, 'received_funds', { branch_id: branch.prefixed_id, shift_id: mine.prefixed_id, kind: 'cash',
                                               handed_amount: '50000', custody: 'drawer' })
      expect(response).to have_http_status(:conflict)
      expect(drawer_rows).to eq(before)
    end

    it 'refuses a cash refund payout from staff without their own open shift' do
      sale = paid_sale(store, branch, cashier: cashier, price: 40_000)
      refund = request_refund(store, cashier, return_and_receive(store, cashier, branch, sale, quantity: 1), amount: 40_000)
      payer = credit_staff(store, branch, PosShiftHelpers::MANAGER)
      before = drawer_rows
      call(payer, :post, "refund_requests/#{refund['id']}/confirmation", { evidence_kind: 'cash_count' })
      expect(response).to have_http_status(:conflict)
      expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('shift_required')
      expect(Spree::Pos::RefundRequest.find_by_prefix_id!(refund['id']).status).to eq('reserved')
      expect(drawer_rows).to eq(before)
    end
  end

  describe 'customer display channel' do
    it 'keeps the display token out of the Admin API and staff tokens out of the display' do
      sale = open_sale(store, branch, cashier: cashier, product: stocked_product(store, branch, price: 20_000))
      body = call(cashier, :post, 'display_sessions', { shift_id: sale.workspace.reload.shift.prefixed_id })
      token = body['token']
      expect(token).to be_present

      %w[context workspaces received_funds].each do |path|
        get "/api/v3/admin/pos/#{path}", headers: { 'Authorization' => "Bearer #{token}" }
        expect(response).to have_http_status(:unauthorized)
      end
      get '/api/v3/admin/orders', headers: { 'Authorization' => "Bearer #{token}" }
      expect(response).to have_http_status(:unauthorized)

      jwt = token_for(cashier)
      get '/api/v3/pos_display/state', headers: { 'Authorization' => "Display #{jwt}" }
      expect(response).to have_http_status(:unauthorized)
      get '/api/v3/pos_display/state', headers: { 'Authorization' => "Bearer #{jwt}" }
      expect(response).to have_http_status(:unauthorized)
      get '/api/v3/pos_display/state', headers: { 'Authorization' => "Display #{token}" }
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.to_json).not_to include(cashier.email)
    end
  end

  describe 'cookie-based staff session' do
    let(:origin) { 'https://evil.example' }

    it 'authorizes nothing from the refresh cookie alone and never hands a token to a foreign origin' do
      token_for(cashier)
      cookie = response.headers['set-cookie'].to_s
      expect(cookie).to match(/httponly/i)
      expect(cookie).to match(/samesite=(lax|strict)/i)

      post '/api/v3/admin/pos/workspaces', headers: { 'Origin' => origin }, params: { register_id: 'x' }, as: :json
      expect(response).to have_http_status(:unauthorized)
      get '/api/v3/admin/pos/context', headers: { 'Origin' => origin }
      expect(response).to have_http_status(:unauthorized)

      tokens = Spree::RefreshToken.count
      post '/api/v3/admin/auth/refresh', headers: { 'Origin' => origin }, as: :json
      expect(response).to have_http_status(:forbidden)
      expect(response.parsed_body).not_to have_key('token')
      expect(response.headers['Access-Control-Allow-Origin']).not_to eq(origin)
      expect(response.headers['set-cookie'].to_s).not_to include('spree_admin_refresh_token')
      expect(Spree::RefreshToken.count).to eq(tokens)
      post '/api/v3/admin/auth/logout', headers: { 'Origin' => origin }, as: :json
      expect(response).to have_http_status(:forbidden)

      # The same cookie still refreshes from the app's own origin.
      post '/api/v3/admin/auth/refresh', headers: { 'Origin' => 'http://www.example.com' }, as: :json
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body['token']).to be_present
    end
  end

  describe 'exports' do
    let(:reader) { manager }

    it 'escapes every formula-like cell, including customer-typed names, and stops serving expired files' do
      profile = Spree::Pos::CustomerProfile.create!(store: store, created_by: manager, name: '=HYPERLINK("http://x.test")',
                                                    phone: "09#{rand(10**8).to_s.rjust(8, '0')}")
      configure_credit(store, manager, branch, profile, limit: 1_000_000)
      credit_order(store, branch, manager, profile, price: 40_000)
      shift = open_shift(store, branch, manager, float: 50_000)
      move_cash(shift, manager, 'cash_in', 1_000, reason: '+SUM(1)')

      files = %w[receivables cashbook sales].map do |type|
        created = call(reader, :post, 'exports', { branch_id: branch.prefixed_id, report_type: type })['data']
        export = Spree::Pos::ExportRequest.find_by_prefix_id!(created['id'])
        Spree::Pos::GenerateExportJob.perform_now(export.id)
        expect(export.reload.status).to eq('ready')
        export
      end
      cells = files.flat_map do |export|
        url = call(reader, :post, "exports/#{export.prefixed_id}/download_link")['data']['url']
        get url
        expect(response).to have_http_status(:ok)
        CSV.parse(response.body.dup.force_encoding(Encoding::UTF_8).delete_prefix("﻿")).flatten.compact
      end
      expect(cells).to include("'+SUM(1)")
      formula = Spree::Pos::Reports::ExportFile::FORMULA_START
      number = Spree::Pos::Reports::ExportFile::NUMBER
      expect(cells.grep_v(number).grep(formula)).to eq([])

      travel(Spree::Pos::ExportRequest::TTL + 1.minute) do
        @tokens = nil
        call(reader, :post, "exports/#{files.first.prefixed_id}/download_link")
        expect(response).to have_http_status(:gone)
      end
    end
  end

  describe 'personal data' do
    # Collectors, approvers and credit managers read contacts in the debt
    # list; other staff of the branch see them masked.
    it 'masks customer contact details for staff without contact rights' do
      profile = credit_customer(store, manager, name: 'Trần Thị Bình')
      configure_credit(store, manager, branch, profile, limit: 1_000_000)
      credit_order(store, branch, manager, profile, price: 60_000)
      viewer = credit_staff(store, branch, [Spree::Pos::Capabilities::OPEN_SHIFT])

      body = call(viewer, :get, 'receivables', { branch_id: branch.prefixed_id })
      expect(response).to have_http_status(:ok)
      expect(body.to_json).not_to include(profile.phone)
      call(viewer, :get, 'receivables', { branch_id: branch.prefixed_id, q: profile.phone[0, 6] })
      expect(response.parsed_body.to_json).not_to include(profile.phone)

      context = call(viewer, :get, 'context', { branch_id: branch.prefixed_id })
      expect(context.to_json).not_to include(profile.phone, 'permission_keys', 'password')
      metrics = call(manager, :get, 'operations/metrics', { branch_id: branch.prefixed_id })
      expect(metrics.to_json).not_to include(profile.phone, profile.name, manager.email)
    end
  end
end
