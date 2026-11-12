# frozen_string_literal: true

require 'rails_helper'
require 'json'
require 'yaml'

# The golden files hold each input with the document the server builds from
# it. packages/pos-shared/src/receipt-template/server-contract.test.ts renders
# the same inputs through the TypeScript renderer and expects the same
# document, so neither side can change alone. A missing file is written and
# the example fails, so a new golden is always looked at before it counts.
RSpec.describe Spree::Pos::PrintDocuments do
  fixtures_dir = Rails.root.join('spec/fixtures/print_documents')
  now = Time.utc(2026, 11, 11, 3, 4, 5)
  zone = 'Asia/Ho_Chi_Minh'

  custom_config = {
    'schema' => 1,
    'page' => { 'margin_mm' => 99, 'font' => 'mono', 'font_size' => 'l', 'line_spacing' => 1.2, 'copies' => 2 },
    'header' => [
      { 'type' => 'logo', 'width_pct' => 50, 'align' => 'left', 'monochrome' => true },
      { 'type' => 'business', 'fields' => %w[name branch address phone unknown], 'align' => 'center' },
      { 'type' => 'text', 'value' => "ĐT: {store.phone}\n{unknown.variable}\nCa: {cashier}\nSố: {document.number}", 'bold' => true, 'size' => 'l' },
      { 'type' => 'title', 'label' => 'HÓA ĐƠN <b>' },
      { 'type' => 'title', 'label' => 'bỏ qua' },
      { 'type' => 'divider', 'style' => 'solid' },
      { 'type' => 'spacer', 'mm' => 50 },
      'not a block'
    ],
    'meta' => { 'fields' => %w[time customer], 'labels' => { 'time' => 'Lúc' } },
    'lines' => { 'layout' => 'table', 'columns' => %w[index name sku unit qty price discount amount], 'show_trace' => true, 'show_conversion' => true },
    'totals' => { 'fields' => %w[item_total], 'labels' => { 'total' => 'Phải trả' } },
    'payments' => { 'fields' => %w[methods paid_total debt pay_qr], 'labels' => { 'methods' => 'bỏ qua', 'pay_qr' => 'Trả sau' } },
    'footer' => [
      { 'type' => 'qr', 'source' => 'url', 'value' => 'https://example.test/a?b=1', 'caption' => 'Xem', 'align' => 'right' },
      { 'type' => 'qr', 'source' => 'url', 'value' => 'javascript:alert(1)' },
      { 'type' => 'qr', 'source' => 'store_social', 'field' => 'facebook' },
      { 'type' => 'barcode', 'align' => 'center' },
      { 'type' => 'signatures', 'parties' => %w[seller buyer], 'labels' => { 'buyer' => 'Khách' } },
      { 'type' => 'title', 'label' => 'không in ở chân' }
    ]
  }

  store = { 'name' => 'Cửa hàng <A&B>', 'address' => '1 Lê Lợi', 'contact_phone' => '0281234567', 'customer_support_email' => 'a@b.vn',
            'url' => 'shop.example.test', 'facebook' => '@shopvn', 'instagram' => 'https://instagram.com/shopvn' }
  sale_document = {
    'title' => 'PHIẾU BÁN HÀNG', 'currency' => 'VND', 'timezone' => zone, 'at' => '2026-11-10T02:00:00Z', 'business_date' => '2026-11-10',
    'cashier' => 'Thu Ngân', 'register' => 'Quầy 1', 'order_number' => 'R100', 'store' => store,
    'branch' => { 'name' => 'Chi nhánh 1', 'code' => 'CN1', 'return_window_days' => 7 },
    'customer' => { 'name' => 'Chị <Lan>', 'phone' => '090***567', 'address' => '2 Hai Bà Trưng' },
    'delivery' => { 'deliverer' => 'Anh Giao', 'fee' => '15000.0' },
    'lines' => [
      { 'name' => 'Trà & Sữa', 'sku' => 'TS-1', 'quantity' => 2, 'sale_quantity' => '1.5', 'sale_unit' => 'lon', 'unit_price' => '45000.0', 'discount' => '5000.0',
        'net_amount' => '85000.0', 'conversion' => '1 lon = 6 chai', 'trace' => [{ 'serial' => 'S1', 'lot_code' => 'L1', 'expiry_on' => '2027-01-02' }, {}] },
      { 'name' => 'Bánh', 'quantity' => 1, 'unit_price' => '1234.50', 'discount' => '0.0', 'amount' => '1234.50' }
    ],
    'totals' => { 'item_total' => '90000.0', 'discount_total' => '5000.0', 'additional_tax_total' => '0.0', 'included_tax_total' => '100.0', 'total' => '100000.0' },
    'taxes' => [{ 'label' => 'VAT', 'rate' => '0.08', 'amount' => '8000.0' }, { 'amount' => '0.0' }],
    'receipts' => [{ 'method' => 'cash', 'amount' => '50000.0', 'handed' => '60000.0', 'change' => '10000.0' },
                   { 'method' => 'vietqr', 'amount' => '20000.0', 'reference' => 'FT1' }, { 'method' => 'bank', 'amount' => '1.0' }],
    'paid_total' => '70001.0',
    'credit' => { 'debt' => '29999.0', 'due_on' => '2026-12-01',
                  'pay_qr' => { 'amount' => '29999.0', 'currency' => 'VND', 'transfer_content' => 'TNR100', 'bank_name' => 'VCB', 'account_number' => '123',
                                'account_name' => 'SHOP', 'payload' => '000201' } },
    'note' => 'Ít đá <nhé>'
  }
  receipt = lambda do |type, document, number: 'R100', late: false|
    { 'source_type' => type, 'number' => number, 'issued_at' => '2026-11-10T02:00:00Z', 'issued_late' => late, 'disclaimer' => 'Không phải hóa đơn', 'document' => document }
  end
  return_document = { 'title' => 'PHIẾU TRẢ', 'timezone' => zone, 'at' => '2026-11-10T02:00:00Z', 'return_number' => 'RT1', 'order_number' => 'R100',
                      'lines' => [{ 'name' => 'Trà', 'sku' => 'T', 'quantity' => '2.50', 'condition' => 'damaged', 'amount' => '10000.0' },
                                  { 'name' => 'Cà phê', 'quantity' => 1, 'condition' => 'resellable', 'amount' => '5000.0' }],
                      'entitlement_total' => '15000.0', 'entitlement_posted' => true, 'credit_note_amount' => '1000.0', 'refund_entitlement' => '14000.0', 'reason' => 'Lỗi' }
  workspace = {
    'business_date' => '2026-11-11', 'note' => "  Không hành\n ",
    'customer' => Spree::Pos::ReceiptSnapshot.masked_customer({ 'name' => 'Anh Ba', 'phone' => '0900000000', 'address' => '' }, mask: true),
    'delivery' => { 'deliverer' => '', 'fee' => '0.0' },
    'totals' => { 'currency' => 'VND', 'item_total' => '60000.0', 'discount_total' => '1000.0', 'total' => '59000.0',
                  'taxes' => [{ 'label' => 'VAT', 'rate' => '10', 'amount' => '500.0' }] },
    'financial' => { 'allocated' => '9000.0', 'remaining' => '50000.0' },
    'line_items' => [{ 'name' => 'Bia <1>', 'sku' => 'B1', 'quantity' => 2, 'price' => '30000.0', 'amount' => '60000.0', 'serial_codes' => ['X1'], 'lot_code' => 'L9' }]
  }
  place = { 'storeName' => 'Quán', 'storeProfile' => { 'address' => '3 Pasteur', 'logo_url' => 'https://cdn.example.test/l.png' },
            'branchName' => 'CN2', 'branchCode' => 'C2', 'returnWindowDays' => nil, 'registerName' => 'Bar' }
  default_config = ->(type) { Spree::Pos::ReceiptTemplate.default_config(type) }

  receipt_cases = {
    'sale-default' => -> { [receipt['sale', sale_document], { 'copy' => false, 'copy_number' => 0 }, default_config['sale']] },
    'sale-copy-custom' => -> { [receipt['sale', sale_document, late: true], { 'copy' => true, 'copy_number' => 2 }, custom_config] },
    'sale-einvoice' => lambda {
      einvoice = { 'status' => 'pending', 'invoice_type' => 'cash_register', 'number' => nil, 'symbol' => nil, 'template_code' => nil,
                   'lookup_code' => 'AB12CD34EF', 'lookup_url' => 'https://tracuu.example.test',
                   'buyer_url' => 'https://pos.example.test/pos_einvoice/token-1' }
      footer = [{ 'type' => 'text', 'value' => "Mã tra cứu: {einvoice.lookup_code}\nTra cứu tại {einvoice.lookup_url}\n{einvoice.buyer_qr}" }]
      [receipt['sale', sale_document].merge('einvoice' => einvoice), nil, default_config['sale'].merge('footer' => footer)]
    },
    'sale-call-number' => lambda {
      footer = [{ 'type' => 'text', 'value' => 'Mời {order.guest_name} nhận món' }]
      [receipt['sale', sale_document.merge('call_number' => '12', 'guest_name' => 'Chị Lan')], nil, default_config['sale'].merge('footer' => footer)]
    },
    'return-default' => -> { [receipt['return', return_document, number: 'RT1'], nil, default_config['return']] },
    'return-pending' => lambda {
      [receipt['return_supplement', return_document.merge('entitlement_posted' => false), number: 'RT2'], nil, default_config['return']]
    },
    'refund-default' => lambda {
      [receipt['refund', { 'title' => 'HOÀN TIỀN', 'at' => '2026-11-10T02:00:00Z', 'method' => 'bank', 'amount' => '5000.0', 'reference' => 'FT9' }, number: 'RF1'], nil,
       default_config['refund']]
    },
    'shift-closure-default' => lambda {
      [receipt['shift_closure', { 'title' => 'CHỐT CA', 'at' => '2026-11-10T02:00:00Z', 'opened_at' => '2026-11-10T01:00:00Z', 'closer' => 'A', 'approver' => 'B', 'opening_float' => '1.0',
                                  'inflow_total' => '2.0', 'outflow_total' => '3.0', 'expected' => '0.0', 'counted' => '1.0', 'variance' => '1.0', 'reason' => 'Thiếu' }, number: 'SC1'], nil,
       default_config['shift_closure']]
    }
  }
  # A room whose clock still runs: the time line carries the server's quote
  # and when it was read.
  timed_workspace = workspace.merge(
    'line_items' => workspace['line_items'] + [
      { 'name' => 'Giờ hát', 'kind' => 'timed', 'quantity' => 1, 'price' => '0.0', 'amount' => '0.0',
        'timed_session' => { 'id' => 'postimed_1', 'status' => 'running', 'resource_name' => 'VIP 1', 'started_at' => '2026-11-11T01:30:00Z',
                             'stopped_at' => nil, 'quote' => { 'as_of' => '2026-11-11T03:04:05Z', 'final' => false, 'played_minutes' => 94,
                                                                'billed_minutes' => 90, 'amount' => '300000.0', 'lines' => [] } } }
    ]
  )
  prebill_cases = {
    'prebill-default' => -> { [default_config['prebill'], nil, workspace] },
    'prebill-reprint-custom' => -> { [custom_config, described_class::REPRINT_BANNER, workspace] },
    'prebill-timed-running' => -> { [default_config['prebill'], nil, timed_workspace] }
  }

  def check_golden(path, content)
    unless path.exist?
      path.write("#{JSON.pretty_generate(content)}\n")
      raise "Wrote #{path.basename}; review it and run again"
    end
    expect(content).to eq(JSON.parse(path.read))
  end

  receipt_cases.each do |name, build|
    it "builds the #{name} document" do
      input, print, config = instance_exec(&build)
      document = described_class.receipt(receipt: input, print: print, config: config).as_json
      check_golden(fixtures_dir.join("#{name}.json"), { 'input' => { 'receipt' => input, 'print' => print, 'config' => config }, 'document' => document })
    end
  end

  prebill_cases.each do |name, build|
    it "builds the #{name} document" do
      config, banner, input = instance_exec(&build)
      document = described_class.prebill(workspace: input, place: place, config: config, now: now, time_zone: zone, banner: banner).as_json
      check_golden(fixtures_dir.join("#{name}.json"),
                   { 'input' => { 'workspace' => input, 'place' => place, 'now' => now.iso8601(3), 'timeZone' => zone, 'config' => config, 'banner' => banner },
                     'document' => document })
    end
  end

  # The schema the TypeScript type is checked against, resolved from the
  # published contract so the two cannot disagree.
  it 'publishes the document schema for the client contract test' do
    openapi = YAML.safe_load_file(Rails.root.join('openapi/pos-staff.yaml'), aliases: true)
    names = %w[PrintDocument PrintPage PrintRow PrintPayQr PrintBlock PrintLines]
    check_golden(fixtures_dir.join('schema.json'), openapi.dig('components', 'schemas').slice(*names))
  end

  it 'validates every golden document against the published schema' do
    document = YAML.safe_load_file(Rails.root.join('openapi/pos-staff.yaml'), aliases: true)
    schema = document.dig('components', 'schemas', 'PrintDocument').merge('components' => document['components'])
    (receipt_cases.keys + prebill_cases.keys).each do |name|
      golden = JSON.parse(fixtures_dir.join("#{name}.json").read)
      errors = JSONSchemer.schema(schema).validate(golden['document']).to_a
      expect(errors.map { |error| error['error'] }).to eq([]), name
    end
  end

  it 'carries only what a printer needs' do
    document = described_class.receipt(receipt: receipt['sale', sale_document], print: nil, config: default_config['sale'])
    expect(document.keys).to match_array(%w[version kind documentType page banners header meta lines totals payments payQr notes footer disclaimer])
  end

  it 'stamps a reprint once' do
    twice = described_class.reprint(described_class.reprint({ 'banners' => ['A'] }))
    expect(twice['banners']).to eq(['A', described_class::REPRINT_BANNER])
  end

  it 'builds cup labels that pass the schema' do
    document = YAML.safe_load_file(Rails.root.join('openapi/pos-staff.yaml'), aliases: true)
    schema = document.dig('components', 'schemas', 'PrintDocument').merge('components' => document['components'])
    branch = instance_double(Spree::Pos::Branch, timezone: zone, store: instance_double(Spree::Store, name: 'Quán'))
    settings = Spree::Pos::CupLabels::Settings::FIELDS.then { |fields| { 'size' => '58x40', 'fields' => fields, 'pickup_minutes' => 15 } }

    label = Spree::Pos::CupLabels::Document.sample(branch: branch, settings: settings, at: now).as_json
    expect(JSONSchemer.schema(schema).validate(label).to_a.map { |error| error['error'] }).to eq([])
    expect(label['page']['label']).to eq('width_mm' => 58, 'height_mm' => 40)
    expect(label['header'].flat_map { |block| block['lines'] }).
      to eq(['Số 1 · 1/1', 'Trà sữa (L)', '+ Ít đá', '+ Trân châu', 'Ghi chú: Ít ngọt', 'Lan', '11/11/2026 10:04 · Quán'])
  end

  it 'builds a test page that passes the schema' do
    branch = instance_double(Spree::Pos::Branch, timezone: zone)
    printer = instance_double(Spree::Pos::Printer, name: 'Quầy', connection: 'browser', paper: '80mm', branch: branch)
    document = YAML.safe_load_file(Rails.root.join('openapi/pos-staff.yaml'), aliases: true)
    schema = document.dig('components', 'schemas', 'PrintDocument').merge('components' => document['components'])

    page = described_class.test_page(printer: printer, now: now).as_json
    expect(JSONSchemer.schema(schema).validate(page).to_a.map { |error| error['error'] }).to eq([])
  end
end
