# frozen_string_literal: true

RSpec.describe Spree::Product, type: :model do
  let(:store) { @default_store }

  it 'creates a product' do
    product = create(:product, store: store)
    expect(product).to be_persisted
  end
end
