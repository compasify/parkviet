# frozen_string_literal: true

RSpec.describe Spree::Pos::ReceiptTemplate, type: :model do
  let(:store) { create(:store, default_currency: 'VND', supported_currencies: 'VND') }

  it 'creates one built-in default per document type once' do
    described_class.ensure_defaults!(store)
    described_class.ensure_defaults!(store)
    templates = described_class.for_store(store)
    expect(templates.count).to eq(6)
    expect(templates.pluck(:document_type)).to match_array(described_class::DOCUMENT_TYPES)
    expect(templates.map { |row| [row.is_default, row.status, row.paper, row.current_version] }.uniq).to eq([[true, 'active', '80mm', 1]])
    sale = templates.find_by(document_type: 'sale')
    expect(sale.name).to eq('Phiếu bán hàng')
    expect(sale.current_config).to eq(described_class.default_config('sale'))
    expect(described_class.for_store(create(:store))).to be_empty
  end

  it 'hands a missing default to the oldest active template instead of adding another' do
    described_class.ensure_defaults!(store)
    sale = described_class.for_store(store).find_by(document_type: 'sale')
    extra = described_class.create_with_version!(store: store, document_type: 'sale', name: 'K58', paper: '58mm',
                                                 config: sale.current_config, actor: nil)
    sale.update!(status: 'disabled', is_default: false)
    described_class.ensure_defaults!(store)
    expect(extra.reload.is_default).to be(true)
    expect(described_class.for_store(store).where(document_type: 'sale').count).to eq(2)
  end

  it 'keeps one active default per document type in the database' do
    described_class.ensure_defaults!(store)
    sale = described_class.for_store(store).find_by(document_type: 'sale')
    expect do
      described_class.create_with_version!(store: store, document_type: 'sale', name: 'Hai', paper: '80mm',
                                           config: sale.current_config, actor: nil, default: true)
    end.to raise_error(ActiveRecord::RecordNotUnique)
  end

  it 'adds an immutable version on every revision' do
    described_class.ensure_defaults!(store)
    template = described_class.for_store(store).find_by(document_type: 'refund')
    changed = template.current_config.merge('footer' => [{ 'type' => 'divider' }])
    template.revise!(config: changed, actor: nil, name: 'Hoàn tiền')
    expect(template.reload).to have_attributes(current_version: 2, name: 'Hoàn tiền')
    expect(template.version_record(1).config).to eq(described_class.default_config('refund'))
    expect(template.current_config).to eq(changed)
    expect { template.version_record(1).update!(config: {}) }.to raise_error(ActiveRecord::ReadOnlyRecord)
  end

  it 'limits active templates per document type' do
    described_class.ensure_defaults!(store)
    config = described_class.default_config('sale')
    4.times do |index|
      described_class.create_with_version!(store: store, document_type: 'sale', name: "M#{index}", paper: '80mm', config: config, actor: nil)
    end
    expect { described_class.ensure_room!(store, 'sale') }.to raise_error(Spree::Pos::Conflict) { |error|
      expect(error.reason).to eq('template_limit_reached')
    }
    expect { described_class.ensure_room!(store, 'prebill') }.not_to raise_error
  end

  it 'validates its attributes and maps return supplements to the return template' do
    template = described_class.new(store: store, document_type: 'invoice', paper: '100mm', name: 'x' * 61, status: 'gone')
    expect(template).not_to be_valid
    expect(template.errors.attribute_names).to include(:document_type, :paper, :name, :status)
    expect(described_class.document_type_for('return_supplement')).to eq('return')
    expect(described_class.document_type_for('sale')).to eq('sale')
  end
end
