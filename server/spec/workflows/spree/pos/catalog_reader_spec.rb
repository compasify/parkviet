# frozen_string_literal: true

RSpec.describe Spree::Pos::CatalogReader do
  let(:store) { Spree::Store.default }
  let(:product) { create(:product, store: store, name: 'Green shirt') }
  let(:variant) { product.default_variant }
  let(:reader) { described_class.new(store: store, products: Spree::Product.where(id: product.id)) }

  it 'searches an explicitly scoped product by name, SKU or barcode without exposing internal fields' do
    variant.update!(sku: 'SHIRT-01', barcode: '012345', cost_price: 123)
    variant.set_price(store.default_currency, 100)
    %w[Green SHIRT-01 012345].each do |query|
      result = reader.search(query: query)
      expect(result[:data].map { |row| row[:id] }).to include(variant.prefixed_id)
      expect(result[:data].first.keys).to match_array(%i[id product_id name sku barcode price compare_at_price currency stock_on_hand])
      expect(result[:data].first[:price]).to eq('100.0')
      expect(result[:data].first[:currency]).to eq(store.default_currency)
    end
  end

  it 'only searches products included in the authorized relation' do
    variant.update!(sku: 'COMMON-ONE')
    other = create(:product, store: store, name: 'Other')
    other.default_variant.update!(sku: 'COMMON-TWO')
    expect(reader.search(query: 'COMMON')[:data].map { |row| row[:id] }).to eq([variant.prefixed_id])
  end

  it 'does not return a foreign store product even when supplied in the scope' do
    foreign_store = create(:store)
    foreign = create(:product, store: foreign_store, name: 'Foreign shirt')
    foreign.default_variant.update!(sku: 'FOREIGN-ONLY')
    all_products = described_class.new(store: store, products: Spree::Product.all)
    expect(all_products.search(query: 'FOREIGN-ONLY')[:data]).to be_empty
  end

  it 'returns all barcode matches with an ambiguity flag and stable pagination' do
    second = create(:variant, product: product, barcode: 'duplicate')
    variant.update!(barcode: 'duplicate')
    first_page = reader.search(query: 'duplicate', exact_barcode: true, limit: 1)
    next_page = reader.search(query: 'duplicate', exact_barcode: true, page: 2, limit: 1)
    expect(first_page[:meta]).to include(count: 2, ambiguous: true, pages: 2)
    expect((first_page[:data] + next_page[:data]).map { |row| row[:id] }).to match_array([variant.prefixed_id, second.prefixed_id])
  end

  it 'escapes wildcard searches and bounds browse and barcode queries' do
    variant.update!(sku: 'A_B')
    expect(reader.search(query: 'A_B')[:data].map { |row| row[:id] }).to include(variant.prefixed_id)
    expect(reader.search(query: '%')[:data]).to be_empty
    expect(reader.search(query: '')[:data].map { |row| row[:id] }).to eq([variant.prefixed_id])
    expect { reader.search(query: '', exact_barcode: true) }.to raise_error(ArgumentError)
    expect { reader.search(query: 'x' * 201) }.to raise_error(ArgumentError)
    expect(reader.search(query: 'A_B', limit: 1000)[:meta][:limit]).to eq(100)
  end

  it 'rejects a missing or incorrectly typed scope' do
    expect { described_class.new(store: store, products: nil) }.to raise_error(ArgumentError)
    expect { described_class.new(store: store, products: Spree::Variant.all) }.to raise_error(ArgumentError)
  end
end
