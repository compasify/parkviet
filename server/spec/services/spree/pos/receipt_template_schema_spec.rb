# frozen_string_literal: true

RSpec.describe Spree::Pos::ReceiptTemplateSchema do
  def config_for(type)
    Spree::Pos::ReceiptTemplate.default_config(type)
  end

  def errors_of(config, type = 'sale')
    described_class.validate(config, type)
  end

  def pointers(config, type = 'sale')
    errors_of(config, type).map { |error| error[:pointer] }
  end

  it 'accepts every built-in default template' do
    Spree::Pos::ReceiptTemplate::DOCUMENT_TYPES.each do |type|
      expect(errors_of(config_for(type), type)).to eq([]), type
    end
  end

  it 'accepts every block, field and variable the schema lists' do
    config = config_for('sale')
    config['header'] = [
      { 'type' => 'logo', 'width_pct' => 40, 'align' => 'left' },
      { 'type' => 'business', 'fields' => described_class::BUSINESS_FIELDS, 'align' => 'right' },
      { 'type' => 'title', 'label' => 'HÓA ĐƠN' },
      { 'type' => 'divider', 'style' => 'solid' },
      { 'type' => 'spacer', 'mm' => 4 }
    ]
    config['footer'] = [{ 'type' => 'text', 'value' => described_class::VARIABLES.map { |name| "{#{name}}" }.join(' '),
                          'bold' => true, 'size' => 'l', 'align' => 'center' }]
    config['meta']['labels'] = { 'time' => 'Ngày' }
    config['payments']['labels'] = { 'debt' => 'Còn nợ' }
    expect(errors_of(config)).to eq([])
  end

  it 'points at unknown blocks, keys and variables' do
    config = config_for('sale')
    config['header'] << { 'type' => 'html', 'value' => '<b>x</b>' }
    html = config['header'].size - 1
    config['footer'] = [
      { 'type' => 'text', 'value' => 'Hotline {store.phone} {store.secret}' },
      { 'type' => 'divider', 'style' => 'dotted', 'color' => 'red' }
    ]
    config['extra'] = true
    errors = errors_of(config)
    expect(errors).to include(
      { pointer: "/config/header/#{html}/type", code: 'unknown_block', message: 'Block type "html" is not supported.' },
      { pointer: '/config/footer/0/value', code: 'unknown_variable', message: '{store.secret} is not a known variable.' },
      hash_including(pointer: '/config/footer/1/style', code: 'invalid_value'),
      hash_including(pointer: '/config/footer/1/color', code: 'unknown_key'),
      hash_including(pointer: '/config/extra', code: 'unknown_key')
    )
  end

  it 'enforces lengths, block counts, ranges and the config size' do
    config = config_for('sale')
    config['footer'] = [{ 'type' => 'text', 'value' => 'x' * 501 }]
    config['header'] = [{ 'type' => 'title', 'label' => 't' * 61 }]
    config['totals']['labels'] = { 'discount' => 'l' * 41 }
    config['page']['line_spacing'] = 2
    expect(pointers(config)).to contain_exactly('/config/footer/0/value', '/config/header/0/label',
                                                '/config/totals/labels/discount', '/config/page/line_spacing')

    crowded = config_for('sale')
    crowded['footer'] = Array.new(9) { { 'type' => 'spacer' } }
    expect(errors_of(crowded)).to eq([{ pointer: '/config/footer', code: 'too_many', message: 'footer may have at most 8 blocks.' }])

    huge = config_for('sale')
    huge['footer'] = Array.new(8) { { 'type' => 'text', 'value' => 'é' * 500 } }
    huge['header'] = Array.new(8) { { 'type' => 'text', 'value' => 'é' * 500 } }
    expect(errors_of(huge).map { |error| error[:code] }).to eq(['too_large'])
  end

  it 'accepts a field only for document types that carry its data' do
    closure = config_for('shift_closure')
    closure['lines'] = config_for('sale')['lines']
    closure['meta']['fields'] = %w[time customer]
    expect(errors_of(closure, 'shift_closure')).to contain_exactly(
      hash_including(pointer: '/config/lines', code: 'section_unavailable'),
      hash_including(pointer: '/config/meta/fields/1', code: 'field_unavailable')
    )

    prebill = config_for('prebill')
    prebill['totals']['fields'] << 'tax'
    prebill['payments']['labels'] = { 'debt' => 'Nợ' }
    expect(pointers(prebill, 'prebill')).to contain_exactly('/config/totals/fields/3', '/config/payments/labels/debt')
  end

  it 'keeps the title in the header once and payment method labels fixed' do
    config = config_for('sale')
    config['header'] << { 'type' => 'title' }
    title = config['header'].size - 1
    config['footer'] = [{ 'type' => 'title' }]
    config['payments']['labels'] = { 'methods' => 'Thanh toán' }
    expect(errors_of(config).map { |error| [error[:pointer], error[:code]] }).to contain_exactly(
      ["/config/header/#{title}", 'duplicate'], ['/config/footer/0', 'misplaced'], ['/config/payments/labels/methods', 'field_unavailable']
    )
  end

  it 'rejects malformed shapes without raising' do
    expect(errors_of('nope')).to eq([{ pointer: '/config', code: 'invalid_type', message: 'Config must be an object.' }])
    expect(pointers({ 'schema' => 2, 'page' => [], 'header' => {}, 'footer' => [nil] })).to contain_exactly(
      '/config/schema', '/config/page', '/config/header', '/config/footer/0'
    )
    expect(pointers({ 'schema' => 1 })).to contain_exactly('/config/page', '/config/header', '/config/footer')
    duplicated = config_for('sale')
    duplicated['meta']['fields'] = %w[time time]
    expect(errors_of(duplicated)).to eq([{ pointer: '/config/meta/fields/1', code: 'duplicate', message: 'time is listed twice.' }])
  end

  it 'accepts QR codes, barcodes, signatures, a monochrome logo and sale copies' do
    config = config_for('sale')
    config['page']['copies'] = 3
    config['header'].unshift({ 'type' => 'logo', 'width_pct' => 50, 'monochrome' => true })
    config['footer'] = [
      { 'type' => 'qr', 'source' => 'url', 'value' => 'http://example.vn/review?id=1', 'caption' => 'Đánh giá', 'align' => 'right' },
      *described_class::SOCIAL_FIELDS.map { |field| { 'type' => 'qr', 'source' => 'store_social', 'field' => field } },
      { 'type' => 'barcode', 'align' => 'left' },
      { 'type' => 'signatures', 'parties' => described_class::SIGNATURE_PARTIES, 'labels' => { 'buyer' => 'Khách hàng' } }
    ]
    expect(errors_of(config)).to eq([])
  end

  it 'refuses QR links that are not http(s) and malformed QR or signature blocks' do
    config = config_for('sale')
    config['footer'] = [
      { 'type' => 'qr', 'source' => 'url', 'value' => 'javascript:alert(1)' },
      { 'type' => 'qr', 'source' => 'url', 'value' => "https://#{'a' * 300}.vn" },
      { 'type' => 'qr', 'source' => 'url', 'field' => 'url', 'value' => 'ftp://example.vn' },
      { 'type' => 'qr', 'source' => 'store_social', 'field' => 'zalo', 'value' => 'https://x.vn' },
      { 'type' => 'qr', 'source' => 'vietqr_payment' },
      { 'type' => 'signatures', 'parties' => [], 'labels' => { 'boss' => 'x' } },
      { 'type' => 'logo', 'monochrome' => 'yes' },
      { 'type' => 'barcode', 'value' => 'R1' }
    ]
    expect(errors_of(config).map { |error| [error[:pointer], error[:code]] }).to contain_exactly(
      ['/config/footer/0/value', 'invalid_url'], ['/config/footer/1/value', 'too_long'],
      ['/config/footer/2/field', 'unknown_key'], ['/config/footer/2/value', 'invalid_url'],
      ['/config/footer/3/value', 'unknown_key'], ['/config/footer/3/field', 'invalid_value'],
      ['/config/footer/4/source', 'invalid_value'],
      ['/config/footer/5/parties', 'blank'], ['/config/footer/5/labels/boss', 'unknown_key'],
      ['/config/footer/6/monochrome', 'invalid_type'], ['/config/footer/7/value', 'unknown_key']
    )
    malformed = config_for('sale')
    malformed['footer'] = ['http:example.com', 'https:/example.com', 'https://cửahàng.vn', 'https://shop.vn/đổi-trả',
                           'https://shop.vn/%zz', 'https://shop.vn/{id}'].map { |link| { 'type' => 'qr', 'source' => 'url', 'value' => link } }
    expect(errors_of(malformed).map { |error| error[:code] }).to eq(['invalid_url'] * 6)
    good = config_for('sale')
    good['footer'] = [{ 'type' => 'qr', 'source' => 'url', 'value' => 'https://shop.vn:8443/a/b?x=1&y=%C3%A1#top' }]
    expect(errors_of(good)).to eq([])

    missing = config_for('sale')
    missing['footer'] = [{ 'type' => 'qr', 'source' => 'url' }, { 'type' => 'qr' }, { 'type' => 'qr', 'source' => 'store_social' }]
    expect(pointers(missing)).to contain_exactly('/config/footer/0/value', '/config/footer/1/source', '/config/footer/2/field')
  end

  it 'prints several copies at once only for sale receipts, from one to three' do
    sale = config_for('sale')
    sale['page']['copies'] = 4
    expect(errors_of(sale)).to eq([{ pointer: '/config/page/copies', code: 'invalid_value', message: 'copies must be a whole number from 1 to 3.' }])
    sale['page']['copies'] = 1.5
    expect(pointers(sale)).to eq(['/config/page/copies'])
    refund = config_for('refund')
    refund['page']['copies'] = 2
    expect(errors_of(refund, 'refund').map { |error| error[:code] }).to eq(['field_unavailable'])
  end

  it 'raises the errors from validate!' do
    expect { described_class.validate!({ 'schema' => 1 }, 'sale') }.to raise_error(described_class::Invalid) { |error|
      expect(error.errors.length).to eq(3)
      expect(error.message).to eq('page is required.')
    }
  end
end
