# frozen_string_literal: true

require 'spree/api/testing_support/v3/base'
require_relative '../../../support/pos_shift_helpers'

RSpec.describe 'POS print jobs API', type: :request do
  include PosShiftHelpers

  let(:store) { create(:store, default_currency: 'VND', supported_currencies: 'VND') }
  let(:branch) { returns_branch(store) }
  let(:cashier) { credit_staff(store, branch, PosShiftHelpers::LEAD) }
  let(:manager) { credit_staff(store, branch, PosShiftHelpers::MANAGER, extra_permissions: %w[write_pos_topology]) }
  let(:device_token) { Spree::Pos::Device.new_token }
  let(:device) { station(branch, device_token) }
  let(:printer) do
    Spree::Pos::Printer.create!(store: store, branch: branch, name: 'Quầy', connection: 'sunmi_builtin', paper: '58mm', command_language: 'escpos',
                                roles: %w[receipt prebill], print_station_device: device)
  end
  let(:lan_printer) do
    Spree::Pos::Printer.create!(store: store, branch: branch, name: 'Epson', connection: 'epson_epos', address: '10.0.0.5:8008', paper: '80mm',
                                command_language: 'escpos', roles: ['receipt'])
  end

  before { allow(Spree::Store).to receive(:default).and_return(store) }

  def station(at, token, mode: 'print_station')
    Spree::Pos::Device.create!(store: at.store, branch: at, name: 'Trạm', mode: mode, platform: 'android', token_digest: Spree::Pos::Device.digest(token))
  end

  def token_for(user)
    @tokens ||= {}
    @tokens[user.id] ||= begin
      post '/api/v3/admin/auth/login', params: { email: user.email, password: 'secret123' }, as: :json
      response.parsed_body.fetch('token')
    end
  end

  def call(user, verb, path, body = {}, key: SecureRandom.uuid)
    send(verb, "/api/v3/admin/pos/#{path}", headers: { 'Authorization' => "Bearer #{token_for(user)}", 'Idempotency-Key' => key },
                                            params: body, as: verb == :get ? nil : :json)
    response.parsed_body
  end

  def device_call(path, body = {}, token: device_token)
    post "/api/v3/pos_device/#{path}", headers: { 'Authorization' => "Device #{token}" }, params: body, as: :json
    response.parsed_body
  end

  def reason
    response.parsed_body.dig('error', 'details', 'reason')
  end

  def receipt_of(sale)
    call(cashier, :get, 'receipts/lookup', { source_id: sale.workspace.reload.prefixed_id })['data']
  end

  def queue_receipt(receipt, key: SecureRandom.uuid)
    call(cashier, :post, 'print_jobs', { kind: 'receipt', printer_id: printer.prefixed_id, receipt_id: receipt['id'] }, key: key)['data']
  end

  def queue_prebill(sale, key: SecureRandom.uuid)
    call(cashier, :post, 'print_jobs', { kind: 'prebill', printer_id: printer.prefixed_id, workspace_id: sale.workspace.prefixed_id }, key: key)['data']
  end

  # The retry delay has passed.
  def due(job_id)
    Spree::Pos::PrintJob.find_by_prefix_id!(job_id).update!(next_attempt_at: 1.second.ago)
  end

  def fail_out(job_id)
    5.times do |index|
      device_call('print_jobs/claim')
      device_call("print_jobs/#{job_id}/report", { attempt: index + 1, status: 'failed', error: 'paper_out' })
      due(job_id) if index < 4
    end
  end

  def direct_print(receipt, body = {})
    call(cashier, :post, "receipts/#{receipt['id']}/prints", { printer_id: lan_printer.prefixed_id }.merge(body))['data']
  end

  def void(user, receipt, print, body = { reason: 'printer_error' })
    call(user, :post, "receipts/#{receipt['id']}/prints/#{print['id']}/void", body)
  end

  def prebill_approval(workspace, action: Spree::Pos::PrintJob::REPRINT_PREBILL_ACTION, revision: workspace.revision)
    Spree::Pos::Approval.create!(store: store, branch: branch, approver: manager, requester: cashier, action: action, revision: revision,
                                 subject_type: workspace.class.name, subject_id: workspace.id, status: 'active', expires_at: 10.minutes.from_now)
  end

  describe 'receipts' do
    let(:sale) { paid_sale(store, branch, cashier: cashier, price: 45_000, quantity: 1) }

    it 'queues the receipt, records its print, and sends the document only to the station' do
      data = queue_receipt(receipt_of(sale))
      expect(response).to have_http_status(:created)
      expect_pos_schema!(response, 'PrintJobResult')
      expect(data['print_job']).to include('kind' => 'receipt', 'status' => 'queued')
      expect(data['print_job']).not_to have_key('document')
      expect(data['print']).to include('copy_number' => 0)

      claim = device_call('print_jobs/claim')['data']
      expect(response).to have_http_status(:ok)
      expect(claim['attempt']).to eq(1)
      errors = JSONSchemer.schema(pos_component_schema('PrintJobClaim')).validate(claim).to_a
      expect(errors.map { |error| error['error'] }).to eq([])
    end

    it 'replays a repeated key without a second job, print or event' do
      receipt = receipt_of(sale)
      key = SecureRandom.uuid
      first = queue_receipt(receipt, key: key)

      expect(Spree::Pos::Realtime).not_to receive(:publish)
      second = queue_receipt(receipt, key: key)
      expect(second['print_job']['id']).to eq(first['print_job']['id'])
      expect(Spree::Pos::PrintJob.where(printer: printer).count).to eq(1)
      expect(Spree::Pos::ReceiptPrint.count).to eq(1)
    end

    it 'gives two people using one key their own jobs' do
      receipt = receipt_of(sale)
      key = SecureRandom.uuid
      queue_receipt(receipt, key: key)
      call(manager, :post, 'print_jobs', { kind: 'receipt', printer_id: printer.prefixed_id, receipt_id: receipt['id'] }, key: key)

      expect(response).to have_http_status(:created)
      expect(Spree::Pos::PrintJob.where(printer: printer).count).to eq(2)
    end

    it 'reprints as the next numbered copy' do
      job = queue_receipt(receipt_of(sale))['print_job']
      data = call(cashier, :post, "print_jobs/#{job['id']}/reprint")['data']

      expect(response).to have_http_status(:created)
      expect(data['print']).to include('copy' => true, 'copy_number' => 1)
      expect(data['print_job']['copy_of_id']).to eq(job['id'])
      copy = Spree::Pos::PrintJob.find_by_prefix_id!(data['print_job']['id'])
      expect(copy.document['banners']).to eq(['BẢN SAO – lần 1'])
    end

    it 'refuses a printer of another branch' do
      other_branch = returns_branch(store)
      other = Spree::Pos::Printer.create!(store: store, branch: other_branch, name: 'Khác', connection: 'sunmi_builtin', paper: '58mm',
                                          command_language: 'escpos', roles: [], print_station_device: station(other_branch, 'other-token'))
      call(cashier, :post, 'print_jobs', { kind: 'receipt', printer_id: other.prefixed_id, receipt_id: receipt_of(sale)['id'] })
      expect(response).to have_http_status(:not_found)
    end

    it 'gives the number back when a job that never printed is canceled' do
      receipt = receipt_of(sale)
      job = queue_receipt(receipt)['print_job']
      call(cashier, :post, "print_jobs/#{job['id']}/cancel")

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.dig('data', 'status')).to eq('canceled')
      expect(call(cashier, :get, "receipts/#{receipt['id']}")['data']).to include('printed' => false, 'copy_count' => 0)
    end

    it 'keeps the number when a claim lapsed, because the paper may exist' do
      receipt = receipt_of(sale)
      job = queue_receipt(receipt)['print_job']
      device_call('print_jobs/claim')
      row = Spree::Pos::PrintJob.find_by_prefix_id!(job['id'])
      row.update!(claim_expires_at: 1.minute.ago)
      Spree::Pos::ReleasePrintClaimsJob.perform_now
      call(cashier, :post, "print_jobs/#{job['id']}/cancel")

      expect(response).to have_http_status(:ok)
      expect(call(cashier, :get, "receipts/#{receipt['id']}")['data']).to include('printed' => true)
    end

    it 'gives the number back after five reported failures' do
      receipt = receipt_of(sale)
      job = queue_receipt(receipt)['print_job']
      fail_out(job['id'])

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.dig('data', 'status')).to eq('failed')
      expect(call(cashier, :get, "receipts/#{receipt['id']}")['data']).to include('printed' => false)
    end

    it 'keeps the original when canceling it would leave a later copy standing' do
      receipt = receipt_of(sale)
      original = queue_receipt(receipt)
      copy = queue_receipt(receipt)
      expect(copy['print']['copy_number']).to eq(1)
      call(cashier, :post, "print_jobs/#{original['print_job']['id']}/cancel")

      expect(response).to have_http_status(:ok)
      expect(Spree::Pos::ReceiptPrint.find_by_prefix_id!(original['print']['id']).voided?).to be(false)
      expect(call(cashier, :get, "receipts/#{receipt['id']}")['data']).to include('printed' => true, 'copy_count' => 1)
    end

    it 'keeps the original when its failure comes after a later copy was queued' do
      receipt = receipt_of(sale)
      original = queue_receipt(receipt)
      queue_receipt(receipt)
      fail_out(original['print_job']['id'])

      expect(response.parsed_body.dig('data', 'status')).to eq('failed')
      expect(Spree::Pos::ReceiptPrint.find_by_prefix_id!(original['print']['id']).voided?).to be(false)
    end

    it 'gives back the latest copy when it never printed' do
      receipt = receipt_of(sale)
      queue_receipt(receipt)
      copy = queue_receipt(receipt)
      call(cashier, :post, "print_jobs/#{copy['print_job']['id']}/cancel")

      expect(Spree::Pos::ReceiptPrint.find_by_prefix_id!(copy['print']['id']).voided?).to be(true)
    end

    it 'refuses a printer without the receipt role' do
      printer.update!(roles: ['prebill'])
      queue_receipt(receipt_of(sale))

      expect(response).to have_http_status(:conflict)
      expect(reason).to eq('printer_wrong_kind')
    end

    it 'refuses a label printer' do
      printer.update!(command_language: 'tspl')
      queue_receipt(receipt_of(sale))

      expect(response).to have_http_status(:conflict)
      expect(reason).to eq('printer_wrong_kind')
    end

    it 'refuses a printer whose station was revoked, on create and on reprint' do
      receipt = receipt_of(sale)
      job = queue_receipt(receipt)['print_job']
      device.update_columns(status: 'revoked')

      queue_receipt(receipt)
      expect(reason).to eq('printer_station_unavailable')
      call(cashier, :post, "print_jobs/#{job['id']}/reprint")
      expect(reason).to eq('printer_station_unavailable')
    end

    it 'refuses a reprint once the printer lost its role' do
      job = queue_receipt(receipt_of(sale))['print_job']
      printer.update!(roles: ['prebill'])
      call(cashier, :post, "print_jobs/#{job['id']}/reprint")

      expect(response).to have_http_status(:conflict)
      expect(reason).to eq('printer_wrong_kind')
    end

    it 'does not let a failed job be reprinted twice' do
      job = queue_receipt(receipt_of(sale))['print_job']
      fail_out(job['id'])
      call(cashier, :post, "print_jobs/#{job['id']}/reprint")
      expect(response).to have_http_status(:created)

      call(cashier, :post, "print_jobs/#{job['id']}/reprint")
      expect(response).to have_http_status(:conflict)
      expect(reason).to eq('print_job_already_reprinted')
    end

    it 'lets a failed job be reprinted again once its copy was canceled' do
      job = queue_receipt(receipt_of(sale))['print_job']
      fail_out(job['id'])
      copy = call(cashier, :post, "print_jobs/#{job['id']}/reprint")['data']['print_job']
      call(cashier, :post, "print_jobs/#{copy['id']}/cancel")

      call(cashier, :post, "print_jobs/#{job['id']}/reprint")
      expect(response).to have_http_status(:created)
    end

    it 'falls back when the template of the job was disabled since and is not the original\'s' do
      templates = Spree::Pos::ReceiptTemplate
      receipt = receipt_of(sale)
      call(cashier, :post, "receipts/#{receipt['id']}/prints")
      other = templates.create_with_version!(store: store, document_type: 'sale', name: 'Khác', paper: '58mm',
                                             config: templates.default_config('sale'), actor: nil)
      job = call(cashier, :post, 'print_jobs', { kind: 'receipt', printer_id: printer.prefixed_id, receipt_id: receipt['id'],
                                                 receipt_template_id: other.prefixed_id })['data']['print_job']
      other.update!(status: 'disabled')
      data = call(cashier, :post, "print_jobs/#{job['id']}/reprint")['data']

      expect(response).to have_http_status(:created)
      expect(data['print']['template_id']).not_to eq(other.prefixed_id)
    end

    it 'will not cancel a job a station holds' do
      job = queue_receipt(receipt_of(sale))['print_job']
      device_call('print_jobs/claim')
      call(cashier, :post, "print_jobs/#{job['id']}/cancel")

      expect(response).to have_http_status(:conflict)
      expect(reason).to eq('print_job_not_cancelable')
    end

    describe 'voiding a direct print' do
      it 'takes back the caller\'s latest print' do
        receipt = receipt_of(sale)
        print = direct_print(receipt)['print']
        data = void(cashier, receipt, print)['data']

        expect(response).to have_http_status(:ok)
        expect(Spree::Pos::AuditEntry.find_by!(action: 'receipt.print_voided').metadata).to include('reason' => 'printer_error')
        expect(data['receipt']).to include('printed' => false, 'copy_count' => 0)
        again = call(cashier, :post, "receipts/#{receipt['id']}/prints")['data']['print']
        expect(again['copy_number']).to eq(0)
      end

      it 'refuses someone else\'s print' do
        receipt = receipt_of(sale)
        print = direct_print(receipt)['print']
        void(manager, receipt, print)

        expect(response).to have_http_status(:conflict)
        expect(reason).to eq('print_not_voidable')
      end

      it 'refuses an earlier print' do
        receipt = receipt_of(sale)
        first = direct_print(receipt)['print']
        direct_print(receipt)
        void(cashier, receipt, first)

        expect(response).to have_http_status(:conflict)
      end

      it 'refuses a print made through the browser' do
        receipt = receipt_of(sale)
        print = call(cashier, :post, "receipts/#{receipt['id']}/prints")['data']['print']
        void(cashier, receipt, print)

        expect(response).to have_http_status(:conflict)
        expect(reason).to eq('print_not_voidable')
        expect(call(cashier, :get, "receipts/#{receipt['id']}")['data']).to include('printed' => true)
      end

      it 'needs a reason known to leave no paper' do
        receipt = receipt_of(sale)
        print = direct_print(receipt)['print']
        [{}, { reason: 'cors' }, { reason: 'unreachable' }, { reason: 'timeout' }].each do |body|
          void(cashier, receipt, print, body)
          expect(response).to have_http_status(:unprocessable_content)
        end
        expect(call(cashier, :get, "receipts/#{receipt['id']}")['data']).to include('printed' => true)
      end

      it 'refuses a channel parameter' do
        receipt = receipt_of(sale)
        void(cashier, receipt, direct_print(receipt)['print'], { reason: 'printer_error', channel_id: 'x' })

        expect(response).to have_http_status(:unprocessable_content)
      end

      it 'records the print only for an active LAN printer of the branch' do
        receipt = receipt_of(sale)
        direct_print(receipt, { printer_id: printer.prefixed_id })
        expect(response).to have_http_status(:conflict)
        expect(reason).to eq('printer_not_direct')

        lan_printer.update!(status: 'disabled')
        direct_print(receipt)
        expect(response).to have_http_status(:conflict)
        expect(reason).to eq('printer_disabled')

        other = returns_branch(store)
        elsewhere = Spree::Pos::Printer.create!(store: store, branch: other, name: 'Xa', connection: 'epson_epos', address: '10.0.0.6', paper: '80mm',
                                                command_language: 'escpos', roles: ['receipt'])
        direct_print(receipt, { printer_id: elsewhere.prefixed_id })
        expect(response).to have_http_status(:not_found)
        expect(call(cashier, :get, "receipts/#{receipt['id']}")['data']).to include('printed' => false)
      end

      it 'refuses a LAN printer without the receipt role' do
        lan_printer.update!(roles: ['prebill'])
        direct_print(receipt_of(sale))

        expect(response).to have_http_status(:conflict)
        expect(reason).to eq('printer_wrong_kind')
      end

      it 'refuses a print the queue is carrying' do
        receipt = receipt_of(sale)
        data = queue_receipt(receipt)
        void(cashier, receipt, data['print'])

        expect(response).to have_http_status(:conflict)
      end
    end
  end

  describe 'pre-bills' do
    let(:sale) { credit_sale(store, branch, price: 30_000, cashier: cashier) }

    it 'prints once per content' do
      queue_prebill(sale)
      expect(response).to have_http_status(:created)

      queue_prebill(sale)
      expect(response).to have_http_status(:conflict)
      expect(reason).to eq('prebill_already_printed')
    end

    it 'carries the not-paid banner' do
      job = Spree::Pos::PrintJob.find_by_prefix_id!(queue_prebill(sale)['print_job']['id'])
      expect(job.document['banners']).to eq(['TẠM TÍNH – CHƯA THANH TOÁN'])
      expect(job.document['documentType']).to eq('prebill')
    end

    it 'still counts as printed after the revision moved without the bill changing' do
      queue_prebill(sale)
      Spree::Pos::Workspace.where(id: sale.workspace.id).update_all("revision = revision + 1, service_mode = 'takeaway', operational_status = 'parked'")

      queue_prebill(sale)
      expect(response).to have_http_status(:conflict)
      expect(reason).to eq('prebill_already_printed')
    end

    it 'allows a free new one once the note changes' do
      queue_prebill(sale)
      sale.workspace.reload.update!(note: 'Ít đá', revision: sale.workspace.revision + 1)

      queue_prebill(sale)
      expect(response).to have_http_status(:created)
    end

    it 'allows a free new one once the lines change' do
      queue_prebill(sale)
      sale.workspace.order.line_items.first.update_columns(quantity: 3)

      queue_prebill(sale)
      expect(response).to have_http_status(:created)
    end

    it 'allows a free new one once the customer changes' do
      queue_prebill(sale)
      profile = Spree::Pos::CustomerProfile.create!(store: store, name: 'Chị Lan', phone: '0901234567', created_by: cashier)
      sale.workspace.reload.update!(pos_customer: profile)

      queue_prebill(sale)
      expect(response).to have_http_status(:created)
    end

    it 'does not count a job that certainly never printed' do
      job = queue_prebill(sale)['print_job']
      fail_out(job['id'])

      queue_prebill(sale)
      expect(response).to have_http_status(:created)
    end

    it 'counts a job still retrying after a failure' do
      job = queue_prebill(sale)['print_job']
      device_call('print_jobs/claim')
      device_call("print_jobs/#{job['id']}/report", { attempt: 1, status: 'failed', error: 'paper_out' })

      queue_prebill(sale)
      expect(response).to have_http_status(:conflict)
      expect(reason).to eq('prebill_already_printed')
    end

    it 'counts a job whose claim lapsed, because the paper may exist' do
      job = queue_prebill(sale)['print_job']
      device_call('print_jobs/claim')
      row = Spree::Pos::PrintJob.find_by_prefix_id!(job['id'])
      row.update!(status: 'failed', attempts: 5, claim_expires_at: nil, last_error: 'lease_expired')

      queue_prebill(sale)
      expect(response).to have_http_status(:conflict)
    end

    it 'does not count a job canceled before any attempt' do
      job = queue_prebill(sale)['print_job']
      call(cashier, :post, "print_jobs/#{job['id']}/cancel")

      queue_prebill(sale)
      expect(response).to have_http_status(:created)
    end

    it 'refuses a printer without the pre-bill role' do
      printer.update!(roles: ['receipt'])
      queue_prebill(sale)

      expect(response).to have_http_status(:conflict)
      expect(reason).to eq('printer_wrong_kind')
    end

    describe 'the customer on the document' do
      let(:profile) { Spree::Pos::CustomerProfile.create!(store: store, name: 'Nguyễn Văn An', phone: '0901234567', address: '2 Lê Lợi', created_by: cashier) }

      def queued_customer_text(user, target)
        data = call(user, :post, 'print_jobs', { kind: 'prebill', printer_id: printer.prefixed_id, workspace_id: target.workspace.prefixed_id })['data']
        Spree::Pos::PrintJob.find_by_prefix_id!(data['print_job']['id']).document.to_json
      end

      it 'masks name and phone for a reader who may not see them, and keeps the address' do
        waiter = credit_staff(store, branch, [Spree::Pos::Capabilities::OPEN_SHIFT])
        waiter_sale = credit_sale(store, branch, price: 30_000, cashier: waiter)
        waiter_sale.workspace.update!(pos_customer: profile)
        text = queued_customer_text(waiter, waiter_sale)

        expect(text).not_to include('Nguyễn Văn An')
        expect(text).not_to include('0901234567')
        expect(text).to include('N••••• V•• A•')
        expect(text).to include('2 Lê Lợi')
      end

      it 'always masks the phone, and shows the name to a reader who may see it' do
        sale.workspace.update!(pos_customer: profile)
        text = queued_customer_text(cashier, sale)

        expect(text).to include('Nguyễn Văn An')
        expect(text).not_to include('0901234567')
      end

      it 'masks a reprint too' do
        waiter = credit_staff(store, branch, [Spree::Pos::Capabilities::OPEN_SHIFT])
        waiter_sale = credit_sale(store, branch, price: 30_000, cashier: waiter)
        waiter_sale.workspace.update!(pos_customer: profile)
        job = call(waiter, :post, 'print_jobs', { kind: 'prebill', printer_id: printer.prefixed_id, workspace_id: waiter_sale.workspace.prefixed_id })['data']['print_job']
        approval = Spree::Pos::Approval.create!(store: store, branch: branch, approver: manager, requester: waiter, action: Spree::Pos::PrintJob::REPRINT_PREBILL_ACTION,
                                                revision: waiter_sale.workspace.reload.revision, subject_type: 'Spree::Pos::Workspace', subject_id: waiter_sale.workspace.id,
                                                status: 'active', expires_at: 10.minutes.from_now)
        data = call(waiter, :post, "print_jobs/#{job['id']}/reprint", { approval_id: approval.prefixed_id })['data']

        text = Spree::Pos::PrintJob.find_by_prefix_id!(data['print_job']['id']).document.to_json
        expect(text).not_to include('Nguyễn Văn An')
        expect(text).not_to include('0901234567')
      end
    end

    describe 'the template of a reprint' do
      let(:templates) { Spree::Pos::ReceiptTemplate }
      let(:chosen) do
        config = templates.default_config('prebill').merge('footer' => [{ 'type' => 'text', 'value' => 'MẪU RIÊNG' }])
        templates.create_with_version!(store: store, document_type: 'prebill', name: 'Riêng', paper: '58mm', config: config, actor: nil)
      end

      def reprint_with_approval(job)
        approval = prebill_approval(sale.workspace.reload)
        call(cashier, :post, "print_jobs/#{job['id']}/reprint", { approval_id: approval.prefixed_id })['data']
      end

      def queue_on_chosen
        call(cashier, :post, 'print_jobs', { kind: 'prebill', printer_id: printer.prefixed_id, workspace_id: sale.workspace.prefixed_id,
                                             receipt_template_id: chosen.prefixed_id })['data']['print_job']
      end

      it 'uses the template first chosen, not the default' do
        data = reprint_with_approval(queue_on_chosen)
        expect(Spree::Pos::PrintJob.find_by_prefix_id!(data['print_job']['id']).document.to_json).to include('MẪU RIÊNG')
      end

      it 'uses the version first printed after the template was edited' do
        job = queue_on_chosen
        chosen.with_lock { chosen.revise!(config: templates.default_config('prebill'), actor: nil) }
        data = reprint_with_approval(job)

        copy = Spree::Pos::PrintJob.find_by_prefix_id!(data['print_job']['id'])
        expect(copy.template_version).to eq(1)
        expect(copy.document.to_json).to include('MẪU RIÊNG')
      end

      it 'still reprints after the template was disabled' do
        job = queue_on_chosen
        chosen.update!(status: 'disabled')
        data = reprint_with_approval(job)

        expect(response).to have_http_status(:created)
        expect(Spree::Pos::PrintJob.find_by_prefix_id!(data['print_job']['id']).document.to_json).to include('MẪU RIÊNG')
      end
    end

    describe 'asking for and granting a reprint' do
      def print_it
        job = queue_prebill(sale)['print_job']
        device_call('print_jobs/claim')
        device_call("print_jobs/#{job['id']}/report", { attempt: 1, status: 'printed' })
        job
      end

      def listed(user)
        call(user, :get, 'print_jobs/prebills', { branch_id: branch.prefixed_id })
        response.parsed_body['data']
      end

      def grant(row, by: manager)
        call(by, :post, 'approvals', { branch_id: branch.prefixed_id, workspace_id: row['workspace_id'], requester_id: row['reprint']['requester_id'],
                                       revision: row['reprint']['workspace_revision'], action_name: Spree::Pos::PrintJob::REPRINT_PREBILL_ACTION,
                                       expires_at: 30.minutes.from_now.iso8601 })
      end

      it 'lists a printed pre-bill as needing approval, in the documented shape' do
        job = print_it
        rows = listed(cashier)

        expect_pos_schema!(response, 'PrintJob')
        expect(rows.map { |row| row['id'] }).to eq([job['id']])
        expect(rows.first).to include('workspace_id' => sale.workspace.prefixed_id, 'source_revision' => sale.workspace.reload.revision)
        expect(rows.first['reprint']).to include('approval_id' => nil, 'can_approve' => false)
      end

      it 'lets a manager grant it to the person working the order, who can then spend it' do
        job = print_it
        row = listed(manager).first
        expect(row['reprint']).to include('can_approve' => true, 'requester_id' => cashier.prefixed_id)

        grant(row)
        expect(response).to have_http_status(:created)

        approval_id = listed(cashier).first['reprint']['approval_id']
        expect(approval_id).to be_present
        expect(listed(manager).first['reprint']['approval_id']).to be_nil

        call(cashier, :post, "print_jobs/#{job['id']}/reprint", { approval_id: approval_id })
        expect(response).to have_http_status(:created)
        expect(listed(cashier).first['reprint']['approval_id']).to be_nil
      end

      it 'refuses a grant from someone without the capability' do
        print_it
        other = credit_staff(store, branch, PosShiftHelpers::LEAD, extra_permissions: %w[write_pos_topology])
        row = listed(manager).first
        call(other, :post, 'approvals', { branch_id: branch.prefixed_id, workspace_id: row['workspace_id'], requester_id: row['reprint']['requester_id'],
                                          revision: row['reprint']['workspace_revision'], action_name: Spree::Pos::PrintJob::REPRINT_PREBILL_ACTION,
                                          expires_at: 30.minutes.from_now.iso8601 })
        expect(response).to have_http_status(:forbidden)
      end

      it 'lets a branch manager without store setup permission grant it' do
        print_it
        branch_manager = credit_staff(store, branch, PosShiftHelpers::MANAGER)
        row = listed(branch_manager).first
        expect(row['reprint']).to include('can_approve' => true)

        grant(row, by: branch_manager)
        expect(response).to have_http_status(:created)
      end

      it 'offers no approval to someone the approvals endpoint would refuse' do
        print_it
        lead = credit_staff(store, branch, PosShiftHelpers::LEAD)

        expect(listed(lead).map { |row| row['reprint']['can_approve'] }).to all(be(false))
      end

      it 'stops showing an approval once the order moved on' do
        print_it
        grant(listed(manager).first)
        Spree::Pos::Workspace.where(id: sale.workspace.id).update_all('revision = revision + 1')

        expect(listed(cashier).first['reprint']['approval_id']).to be_nil
      end

      it 'offers no approval to the only person working the order' do
        solo = credit_sale(store, branch, price: 30_000, cashier: manager)
        job = call(manager, :post, 'print_jobs', { kind: 'prebill', printer_id: printer.prefixed_id, workspace_id: solo.workspace.prefixed_id })['data']['print_job']
        device_call('print_jobs/claim')
        device_call("print_jobs/#{job['id']}/report", { attempt: 1, status: 'printed' })

        expect(listed(manager).first['reprint']).to include('requester_id' => nil, 'can_approve' => false)
      end

      it 'shows only the latest print of an order, and only open orders' do
        job = print_it
        approval = prebill_approval(sale.workspace.reload)
        copy = call(cashier, :post, "print_jobs/#{job['id']}/reprint", { approval_id: approval.prefixed_id })['data']['print_job']
        device_call('print_jobs/claim')
        device_call("print_jobs/#{copy['id']}/report", { attempt: 1, status: 'printed' })
        expect(listed(cashier).map { |row| row['id'] }).to eq([copy['id']])

        Spree::Pos::Workspace.where(id: sale.workspace.id).update_all(operational_status: 'canceled')
        expect(listed(cashier)).to be_empty
      end

      it 'hides another cashier\'s orders from someone who cannot approve' do
        print_it
        other = credit_staff(store, branch, PosShiftHelpers::LEAD)
        expect(listed(other)).to be_empty
      end

      it 'hides another branch' do
        call(cashier, :get, 'print_jobs/prebills', { branch_id: returns_branch(store).prefixed_id })
        expect(response).to have_http_status(:not_found)
      end
    end

    it 'refuses a reprint without an approval' do
      job = queue_prebill(sale)['print_job']
      call(cashier, :post, "print_jobs/#{job['id']}/reprint")

      expect(response).to have_http_status(:conflict)
      expect(reason).to eq('approval_required')
      expect(Spree::Pos::PrintJob.where(printer: printer).count).to eq(1)
    end

    it 'reprints with an approval and spends it' do
      job = queue_prebill(sale)['print_job']
      approval = prebill_approval(sale.workspace.reload)
      data = call(cashier, :post, "print_jobs/#{job['id']}/reprint", { approval_id: approval.prefixed_id })['data']

      expect(response).to have_http_status(:created)
      copy = Spree::Pos::PrintJob.find_by_prefix_id!(data['print_job']['id'])
      expect(copy.document['banners']).to eq(['TẠM TÍNH – CHƯA THANH TOÁN', 'IN LẠI'])
      expect(approval.reload.status).to eq('consumed')
    end

    it 'cannot spend one approval twice' do
      job = queue_prebill(sale)['print_job']
      approval = prebill_approval(sale.workspace.reload)
      call(cashier, :post, "print_jobs/#{job['id']}/reprint", { approval_id: approval.prefixed_id })
      call(cashier, :post, "print_jobs/#{job['id']}/reprint", { approval_id: approval.prefixed_id })

      expect(response).to have_http_status(:conflict)
      expect(Spree::Pos::PrintJob.where(printer: printer).count).to eq(2)
    end

    it 'replays a reprint under its key without spending again' do
      job = queue_prebill(sale)['print_job']
      approval = prebill_approval(sale.workspace.reload)
      key = SecureRandom.uuid
      first = call(cashier, :post, "print_jobs/#{job['id']}/reprint", { approval_id: approval.prefixed_id }, key: key)['data']
      second = call(cashier, :post, "print_jobs/#{job['id']}/reprint", { approval_id: approval.prefixed_id }, key: key)['data']

      expect(second['print_job']['id']).to eq(first['print_job']['id'])
    end

    it 'refuses an approval for another action' do
      job = queue_prebill(sale)['print_job']
      approval = prebill_approval(sale.workspace.reload, action: 'workspace.discount')
      call(cashier, :post, "print_jobs/#{job['id']}/reprint", { approval_id: approval.prefixed_id })

      expect(response).to have_http_status(:conflict)
      expect(approval.reload.status).to eq('active')
    end

    it 'refuses an approval once the order has changed' do
      job = queue_prebill(sale)['print_job']
      approval = prebill_approval(sale.workspace.reload)
      Spree::Pos::Workspace.where(id: sale.workspace.id).update_all('revision = revision + 1')
      call(cashier, :post, "print_jobs/#{job['id']}/reprint", { approval_id: approval.prefixed_id })

      expect(response).to have_http_status(:conflict)
      expect(approval.reload.status).to eq('active')
    end

    it 'refuses a completed order' do
      job = queue_prebill(sale)['print_job']
      approval = prebill_approval(sale.workspace.reload)
      Spree::Pos::Workspace.where(id: sale.workspace.id).update_all(operational_status: 'canceled')
      call(cashier, :post, "print_jobs/#{job['id']}/reprint", { approval_id: approval.prefixed_id })

      expect(response).to have_http_status(:conflict)
      expect(reason).to eq('workspace_not_open')
    end
  end

  describe 'the queue' do
    let(:sale) { paid_sale(store, branch, cashier: cashier, price: 45_000, quantity: 1) }

    it 'lists jobs by status, without documents' do
      job = queue_receipt(receipt_of(sale))['print_job']
      call(cashier, :get, 'print_jobs', { branch_id: branch.prefixed_id, status: 'queued,failed' })

      expect(response).to have_http_status(:ok)
      expect_pos_schema!(response, 'PrintJob')
      expect(response.parsed_body['data'].map { |row| row['id'] }).to eq([job['id']])
    end

    it 'says when a waiting job is stuck on an unavailable printer' do
      queue_receipt(receipt_of(sale))
      device.update_columns(status: 'revoked')
      call(cashier, :get, 'print_jobs', { branch_id: branch.prefixed_id, status: 'queued' })
      expect(response.parsed_body['data'].first).to include('printer_available' => false)

      device.update_columns(status: 'active')
      printer.update!(status: 'disabled')
      call(cashier, :get, 'print_jobs', { branch_id: branch.prefixed_id, status: 'queued' })
      expect(response.parsed_body['data'].first).to include('printer_available' => false)
    end

    it 'marks a job with a standing reprint' do
      job = queue_receipt(receipt_of(sale))['print_job']
      call(cashier, :post, "print_jobs/#{job['id']}/reprint")
      call(cashier, :get, 'print_jobs', { branch_id: branch.prefixed_id })

      original = response.parsed_body['data'].find { |row| row['id'] == job['id'] }
      expect(original).to include('reprinted' => true, 'printer_available' => true)
    end

    it 'refuses an unknown status' do
      call(cashier, :get, 'print_jobs', { branch_id: branch.prefixed_id, status: 'nope' })
      expect(response).to have_http_status(:unprocessable_content)
    end

    it 'hides another branch\'s queue' do
      call(cashier, :get, 'print_jobs', { branch_id: returns_branch(store).prefixed_id })
      expect(response).to have_http_status(:not_found)
    end

    it 'hides another store\'s job' do
      foreign_store = create(:store, default_currency: 'VND', supported_currencies: 'VND')
      foreign_branch = returns_branch(foreign_store)
      foreign_printer = Spree::Pos::Printer.create!(store: foreign_store, branch: foreign_branch, name: 'X', connection: 'sunmi_builtin', paper: '58mm',
                                                    command_language: 'escpos', roles: [], print_station_device: station(foreign_branch, 'foreign'))
      foreign = Spree::Pos::PrintJobs::Enqueue.call(store: foreign_store, printer: foreign_printer, kind: 'test', document: { 'version' => 1 }, key: 'k')
      call(cashier, :post, "print_jobs/#{foreign.prefixed_id}/cancel")

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'the device channel' do
    it 'needs a device token' do
      post '/api/v3/pos_device/print_jobs/claim', as: :json
      expect(response).to have_http_status(:unauthorized)
    end

    it 'is for print stations only' do
      station(branch, 'waiter-token', mode: 'kds')
      device_call('print_jobs/claim', {}, token: 'waiter-token')
      expect(response).to have_http_status(:forbidden)
    end

    it 'answers null when nothing waits' do
      printer
      expect(device_call('print_jobs/claim')).to eq('data' => nil)
    end

    it 'validates the report' do
      job = Spree::Pos::PrintJobs::Enqueue.call(store: store, printer: printer, kind: 'test', document: { 'version' => 1 }, key: 'k')
      device_call('print_jobs/claim')

      device_call("print_jobs/#{job.prefixed_id}/report", { attempt: 0, status: 'printed' })
      expect(response).to have_http_status(:unprocessable_content)
      device_call("print_jobs/#{job.prefixed_id}/report", { attempt: 1, status: 'lost' })
      expect(response).to have_http_status(:unprocessable_content)
    end

    it 'answers a stale report with a conflict' do
      job = Spree::Pos::PrintJobs::Enqueue.call(store: store, printer: printer, kind: 'test', document: { 'version' => 1 }, key: 'k')
      device_call('print_jobs/claim')
      job.update!(claim_expires_at: 1.minute.ago)
      device_call('print_jobs/claim')

      device_call("print_jobs/#{job.prefixed_id}/report", { attempt: 1, status: 'printed' })
      expect(response).to have_http_status(:conflict)
      expect(reason).to eq('print_claim_stale')
    end
  end
end
