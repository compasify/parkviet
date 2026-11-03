# frozen_string_literal: true

RSpec.describe 'POS test database safety' do
  it 'refuses database cleaner truncation and deletion' do
    expect { DatabaseCleaner.clean_with(:truncation) }.to raise_error(RuntimeError, /disabled/)
    expect { DatabaseCleaner.clean_with(:deletion) }.to raise_error(RuntimeError, /disabled/)
  end

  it 'runs each example inside a transaction' do
    expect(ActiveRecord::Base.connection.transaction_open?).to be(true)
  end
end
