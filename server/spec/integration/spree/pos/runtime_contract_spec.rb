# frozen_string_literal: true

RSpec.describe 'POS runtime contract', type: :model do
  it 'uses a test database distinct from the development database' do
    config = ActiveRecord::Base.connection_db_config.configuration_hash
    development = ActiveRecord::Base.configurations.configs_for(env_name: 'development').first.configuration_hash

    expect(Rails.env).to eq('test')
    expect([config[:host], config[:port], config[:database]])
      .not_to eq([development[:host], development[:port], development[:database]])
  end

  it 'exposes integer quantities and four-decimal line-item prices' do
    quantity = Spree::LineItem.columns_hash.fetch('quantity')
    price = Spree::LineItem.columns_hash.fetch('price')

    expect(quantity.type).to eq(:integer)
    expect([price.type, price.precision, price.scale]).to eq([:decimal, 19, 4])
  end

  it 'exposes four-decimal variant price storage' do
    amount = Spree::Price.columns_hash.fetch('amount')

    expect([amount.type, amount.precision, amount.scale]).to eq([:decimal, 19, 4])
  end
end
