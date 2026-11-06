# frozen_string_literal: true

RSpec.describe 'POS customer email qualification' do
  it 'characterizes the configured customer model without an email' do
    customer = Spree.customer_class.new(first_name: 'Lan', phone: '0901234567')
    expect(customer).not_to be_valid
    expect(customer.errors[:email]).not_to be_empty
    expect(Spree.customer_class.columns_hash.fetch('email').null).to be(false)
  end
end
